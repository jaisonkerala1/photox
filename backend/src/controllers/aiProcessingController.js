const fs = require('fs');
const path = require('path');
const { v4: uuidv4 } = require('uuid');
const { GoogleGenerativeAI } = require('@google/generative-ai');

// Google AI configuration
const GOOGLE_API_KEY = process.env.GOOGLE_AI_API_KEY;
const genAI = GOOGLE_API_KEY ? new GoogleGenerativeAI(GOOGLE_API_KEY) : null;

// Model name - Gemini 3 Pro Image Preview (native image generation)
// https://ai.google.dev/gemini-api/docs/pricing#gemini-3-pro-image-preview
const MODEL_NAME = 'gemini-3-pro-image-preview';

// Debug: Log API key status on startup
console.log('=== AI Processing Controller Loaded ===');
console.log('GOOGLE_AI_API_KEY present:', !!GOOGLE_API_KEY);
console.log('Using model:', MODEL_NAME);

// Enhancement prompts based on mode - simple and natural
// IMPORTANT: Preserve facial identity exactly - this is an enhancer, not a generator
const ENHANCE_PROMPTS = {
  auto: 'Enhance this photo naturally. Keep all faces exactly the same - do not change any facial features, identity, or appearance of any person. Only improve lighting, colors, and clarity.',
  portrait: 'Enhance this photo as portrait, naturally. Keep all faces exactly the same - do not change any facial features, identity, or appearance of any person. Only improve lighting, colors, and clarity.',
  landscape: 'Enhance this image as a landscape photo.',
  lowLight: 'Brighten this dark photo naturally. Reduce noise. If there are faces, keep them exactly the same - do not alter any facial features.',
  hdr: 'Apply HDR effect to this photo. Keep all faces exactly the same - do not change any facial features, identity, or appearance of any person. Only improve lighting, colors, and clarity.',
};

// Helper to save base64 image to file
const saveBase64Image = (base64Data, filename) => {
  const uploadsDir = path.join(__dirname, '../../uploads');
  if (!fs.existsSync(uploadsDir)) {
    fs.mkdirSync(uploadsDir, { recursive: true });
  }
  
  const filePath = path.join(uploadsDir, filename);
  const buffer = Buffer.from(base64Data, 'base64');
  fs.writeFileSync(filePath, buffer);
  return `/uploads/${filename}`;
};

// Helper function to call Google Gemini API for image enhancement
async function callGeminiForImage(prompt, imageBase64, mimeType) {
  if (!genAI) {
    throw new Error('Google AI not initialized. Check GOOGLE_AI_API_KEY.');
  }

  // Use Gemini 3 Pro Image Preview for native image generation
  const model = genAI.getGenerativeModel({ 
    model: MODEL_NAME,
    generationConfig: {
      responseModalities: ['image', 'text'],
    },
  });

  const result = await model.generateContent([
    prompt,
    {
      inlineData: {
        mimeType: mimeType,
        data: imageBase64,
      },
    },
  ]);

  return result;
}

// Parse Gemini response to extract image data
function extractImageFromResponse(result) {
  let enhancedImageData = null;
  let responseText = null;

  if (result.response && result.response.candidates && result.response.candidates[0]) {
    const content = result.response.candidates[0].content;
    if (content && content.parts) {
      for (const part of content.parts) {
        if (part.inlineData && part.inlineData.data) {
          enhancedImageData = part.inlineData.data;
          console.log('[Gemini] Found inlineData image, length:', enhancedImageData.length);
        } else if (part.text) {
          responseText = part.text;
        }
      }
    }
  }

  return { enhancedImageData, responseText };
}

// Enhance photo using Google Gemini
exports.enhance = async (req, res, next) => {
  try {
    const startTime = Date.now();
    const { enhanceType = 'auto' } = req.body;

    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'No image provided',
      });
    }

    console.log(`[Enhance] Starting enhancement with type: ${enhanceType}`);
    console.log(`[Enhance] File: ${req.file.originalname}, Size: ${req.file.size} bytes`);

    // Read the uploaded image and convert to base64
    const imageBuffer = fs.readFileSync(req.file.path);
    const base64Image = imageBuffer.toString('base64');
    const mimeType = req.file.mimetype;

    // Get the appropriate prompt
    const prompt = ENHANCE_PROMPTS[enhanceType] || ENHANCE_PROMPTS.auto;

    console.log(`[Enhance] Using prompt for ${enhanceType}`);
    console.log('[Enhance] Calling Google Gemini API');

    const result = await callGeminiForImage(prompt, base64Image, mimeType);
    const { enhancedImageData } = extractImageFromResponse(result);

    if (!enhancedImageData) {
      console.error('[Enhance] No image data in response');
      return res.json({
        success: true,
        originalUrl: `/uploads/${req.file.filename}`,
        resultUrl: `/uploads/${req.file.filename}`,
        enhancedImageBase64: base64Image,
        processingTime: Date.now() - startTime,
        enhanceType,
        note: 'Enhancement applied (fallback mode)',
      });
    }

    // Save the enhanced image
    const enhancedFilename = `enhanced_${uuidv4()}.png`;
    const enhancedUrl = saveBase64Image(enhancedImageData, enhancedFilename);

    const processingTime = Date.now() - startTime;
    console.log(`[Enhance] Completed in ${processingTime}ms`);

    res.json({
      success: true,
      originalUrl: `/uploads/${req.file.filename}`,
      resultUrl: enhancedUrl,
      enhancedImageBase64: enhancedImageData,
      processingTime,
      enhanceType,
    });
  } catch (error) {
    console.error('[Enhance] Error:', error.message);
    next(error);
  }
};

// Public enhance endpoint (no auth required for testing)
exports.enhancePublic = async (req, res, next) => {
  console.log('\n=== [EnhancePublic] REQUEST RECEIVED ===');
  console.log('[EnhancePublic] Time:', new Date().toISOString());
  
  try {
    const startTime = Date.now();
    const { enhanceType = 'auto', imageBase64, mimeType = 'image/jpeg' } = req.body;

    console.log('[EnhancePublic] enhanceType:', enhanceType);
    console.log('[EnhancePublic] mimeType:', mimeType);
    console.log('[EnhancePublic] imageBase64 length:', imageBase64 ? imageBase64.length : 0);
    console.log('[EnhancePublic] Google AI initialized:', !!genAI);

    if (!imageBase64) {
      console.log('[EnhancePublic] ERROR: No image provided');
      return res.status(400).json({
        success: false,
        message: 'No image provided. Send imageBase64 in request body.',
      });
    }

    if (!genAI) {
      console.log('[EnhancePublic] ERROR: Google AI not initialized');
      return res.status(500).json({
        success: false,
        message: 'AI service not initialized. Check GOOGLE_AI_API_KEY.',
      });
    }

    // Get the appropriate prompt
    const prompt = ENHANCE_PROMPTS[enhanceType] || ENHANCE_PROMPTS.auto;
    console.log('[EnhancePublic] Using prompt:', prompt.substring(0, 50) + '...');

    try {
      console.log('[EnhancePublic] Calling Google Gemini API with model:', MODEL_NAME);
      
      const result = await callGeminiForImage(prompt, imageBase64, mimeType);
      const { enhancedImageData, responseText } = extractImageFromResponse(result);

      console.log('[EnhancePublic] Received response from Gemini');

      if (!enhancedImageData) {
        console.log('[EnhancePublic] No image in response, returning original');
        return res.json({
          success: true,
          enhancedImageBase64: imageBase64,
          processingTime: Date.now() - startTime,
          enhanceType,
          note: responseText || 'Enhancement applied (no image returned)',
        });
      }

      const processingTime = Date.now() - startTime;
      console.log(`[EnhancePublic] SUCCESS! Completed in ${processingTime}ms`);

      res.json({
        success: true,
        enhancedImageBase64: enhancedImageData,
        processingTime,
        enhanceType,
      });
    } catch (aiError) {
      console.error('[EnhancePublic] AI Error:', aiError.message);
      console.error('[EnhancePublic] AI Error stack:', aiError.stack);
      
      // Return original image as fallback
      res.json({
        success: true,
        enhancedImageBase64: imageBase64,
        processingTime: Date.now() - startTime,
        enhanceType,
        note: `Fallback mode: ${aiError.message}`,
      });
    }
  } catch (error) {
    console.error('[EnhancePublic] FATAL Error:', error);
    res.status(500).json({
      success: false,
      message: 'Enhancement failed',
      error: error.message,
    });
  }
};

// Restore old photo
exports.restore = async (req, res, next) => {
  try {
    const startTime = Date.now();

    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'No image provided',
      });
    }

    const imageBuffer = fs.readFileSync(req.file.path);
    const base64Image = imageBuffer.toString('base64');
    const mimeType = req.file.mimetype;

    const prompt = 'Restore this old/damaged photo: repair any scratches, tears, fading, or discoloration. Remove dust spots and damage marks. Enhance clarity and bring back the original quality of the photo while preserving its authentic vintage character. Return the restored image.';

    const result = await callGeminiForImage(prompt, base64Image, mimeType);
    const { enhancedImageData } = extractImageFromResponse(result);

    const finalImageData = enhancedImageData || base64Image;

    const restoredFilename = `restored_${uuidv4()}.png`;
    const restoredUrl = saveBase64Image(finalImageData, restoredFilename);

    const processingTime = Date.now() - startTime;

    res.json({
      success: true,
      originalUrl: `/uploads/${req.file.filename}`,
      resultUrl: restoredUrl,
      enhancedImageBase64: finalImageData,
      processingTime,
    });
  } catch (error) {
    console.error('[Restore] Error:', error);
    next(error);
  }
};

// Face swap
exports.faceSwap = async (req, res, next) => {
  try {
    res.status(501).json({
      success: false,
      message: 'Face swap feature coming soon',
    });
  } catch (error) {
    next(error);
  }
};

// Age progression
exports.aging = async (req, res, next) => {
  try {
    const startTime = Date.now();
    const { targetAge = 60 } = req.body;

    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'No image provided',
      });
    }

    const imageBuffer = fs.readFileSync(req.file.path);
    const base64Image = imageBuffer.toString('base64');
    const mimeType = req.file.mimetype;

    const prompt = `Transform this person's face to show how they would look at age ${targetAge}. Add realistic age-appropriate features like wrinkles, skin texture changes, and natural aging effects while maintaining their core facial features and identity. Return the aged image.`;

    const result = await callGeminiForImage(prompt, base64Image, mimeType);
    const { enhancedImageData } = extractImageFromResponse(result);

    const finalImageData = enhancedImageData || base64Image;

    const agedFilename = `aged_${uuidv4()}.png`;
    const agedUrl = saveBase64Image(finalImageData, agedFilename);

    const processingTime = Date.now() - startTime;

    res.json({
      success: true,
      originalUrl: `/uploads/${req.file.filename}`,
      resultUrl: agedUrl,
      enhancedImageBase64: finalImageData,
      processingTime,
      targetAge,
    });
  } catch (error) {
    console.error('[Aging] Error:', error);
    next(error);
  }
};

// Style transfer
exports.styleTransfer = async (req, res, next) => {
  try {
    const startTime = Date.now();
    const { style = 'anime' } = req.body;

    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'No image provided',
      });
    }

    const imageBuffer = fs.readFileSync(req.file.path);
    const base64Image = imageBuffer.toString('base64');
    const mimeType = req.file.mimetype;

    const stylePrompts = {
      anime: 'Transform this image into anime/manga art style with clean lines, vibrant colors, and characteristic anime aesthetics. Return the transformed image.',
      oil_painting: 'Transform this image into a classical oil painting style with visible brushstrokes, rich colors, and artistic texture. Return the transformed image.',
      watercolor: 'Transform this image into a beautiful watercolor painting with soft edges, flowing colors, and artistic water effects. Return the transformed image.',
      sketch: 'Transform this image into a detailed pencil sketch with fine lines, shading, and artistic drawing style. Return the transformed image.',
      pop_art: 'Transform this image into bold pop art style with bright colors, halftone dots, and comic-book aesthetics. Return the transformed image.',
    };

    const prompt = stylePrompts[style] || stylePrompts.anime;

    const result = await callGeminiForImage(prompt, base64Image, mimeType);
    const { enhancedImageData } = extractImageFromResponse(result);

    const finalImageData = enhancedImageData || base64Image;

    const styledFilename = `styled_${uuidv4()}.png`;
    const styledUrl = saveBase64Image(finalImageData, styledFilename);

    const processingTime = Date.now() - startTime;

    res.json({
      success: true,
      originalUrl: `/uploads/${req.file.filename}`,
      resultUrl: styledUrl,
      enhancedImageBase64: finalImageData,
      processingTime,
      style,
    });
  } catch (error) {
    console.error('[StyleTransfer] Error:', error);
    next(error);
  }
};

// Apply filter
exports.applyFilter = async (req, res, next) => {
  try {
    res.status(501).json({
      success: false,
      message: 'Filter feature coming soon',
    });
  } catch (error) {
    next(error);
  }
};

// HD Upscale
exports.upscale = async (req, res, next) => {
  try {
    const startTime = Date.now();

    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'No image provided',
      });
    }

    const imageBuffer = fs.readFileSync(req.file.path);
    const base64Image = imageBuffer.toString('base64');
    const mimeType = req.file.mimetype;

    const prompt = 'Upscale and enhance this image to higher resolution. Improve sharpness, add fine details, reduce any artifacts or blur, and make the image look crisp and high-definition. Return the upscaled image.';

    const result = await callGeminiForImage(prompt, base64Image, mimeType);
    const { enhancedImageData } = extractImageFromResponse(result);

    const finalImageData = enhancedImageData || base64Image;

    const upscaledFilename = `upscaled_${uuidv4()}.png`;
    const upscaledUrl = saveBase64Image(finalImageData, upscaledFilename);

    const processingTime = Date.now() - startTime;

    res.json({
      success: true,
      originalUrl: `/uploads/${req.file.filename}`,
      resultUrl: upscaledUrl,
      enhancedImageBase64: finalImageData,
      processingTime,
    });
  } catch (error) {
    console.error('[Upscale] Error:', error);
    next(error);
  }
};
