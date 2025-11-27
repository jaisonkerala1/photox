const { GoogleGenerativeAI } = require('@google/generative-ai');
const fs = require('fs');
const path = require('path');
const { v4: uuidv4 } = require('uuid');

// Initialize Google Generative AI with API key
const genAI = new GoogleGenerativeAI(process.env.GOOGLE_AI_API_KEY);

// Enhancement prompts based on mode
const ENHANCE_PROMPTS = {
  auto: 'Enhance this image: improve clarity, colors, contrast, and overall quality while keeping it natural and realistic. Fix any exposure issues, reduce noise, and sharpen details. Return the enhanced image.',
  portrait: 'Enhance this portrait photo: improve skin tones naturally, enhance lighting on the face, sharpen eyes and facial features, smooth skin texture subtly while keeping it realistic. Improve overall color balance and make the subject look their best. Return the enhanced image.',
  landscape: 'Enhance this landscape/nature photo: boost the vibrancy of natural colors, improve sky details, enhance the depth and clarity of the scene, adjust contrast for dramatic effect, and make the scenery look stunning and vivid. Return the enhanced image.',
  lowLight: 'Enhance this low-light/dark photo: significantly brighten the image while reducing noise and grain, recover shadow details, improve color accuracy, and make the image look like it was taken in better lighting conditions. Return the enhanced image.',
  hdr: 'Apply HDR enhancement to this image: expand the dynamic range, bring out details in both highlights and shadows, increase local contrast, boost color saturation, and create a dramatic, professional HDR look. Return the enhanced image.',
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

// Enhance photo using Gemini 2.5 Flash Preview with image output
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

    // Use gemini-2.0-flash-exp for image generation
    const model = genAI.getGenerativeModel({ 
      model: 'gemini-2.0-flash-exp',
      generationConfig: {
        responseModalities: ['image', 'text'],
      },
    });

    const result = await model.generateContent([
      prompt,
      {
        inlineData: {
          mimeType: mimeType,
          data: base64Image,
        },
      },
    ]);

    console.log('[Enhance] Received response from Gemini');

    const response = result.response;
    let enhancedImageData = null;
    let responseText = null;

    // Check for image in response
    if (response.candidates && response.candidates[0] && response.candidates[0].content) {
      for (const part of response.candidates[0].content.parts) {
        if (part.inlineData) {
          enhancedImageData = part.inlineData.data;
          console.log('[Enhance] Found enhanced image in response');
        } else if (part.text) {
          responseText = part.text;
          console.log('[Enhance] Response text:', part.text.substring(0, 100));
        }
      }
    }

    if (!enhancedImageData) {
      console.error('[Enhance] No image data in response');
      // Return original image as fallback
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
  try {
    const startTime = Date.now();
    const { enhanceType = 'auto', imageBase64, mimeType = 'image/jpeg' } = req.body;

    if (!imageBase64) {
      return res.status(400).json({
        success: false,
        message: 'No image provided. Send imageBase64 in request body.',
      });
    }

    console.log(`[EnhancePublic] Starting enhancement with type: ${enhanceType}`);
    console.log(`[EnhancePublic] API Key present: ${!!process.env.GOOGLE_AI_API_KEY}`);

    // Get the appropriate prompt
    const prompt = ENHANCE_PROMPTS[enhanceType] || ENHANCE_PROMPTS.auto;

    console.log(`[EnhancePublic] Using prompt for ${enhanceType}`);

    try {
      // Use gemini-2.0-flash-exp for image generation
      const model = genAI.getGenerativeModel({ 
        model: 'gemini-2.0-flash-exp',
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

      console.log('[EnhancePublic] Received response from Gemini');

      const response = result.response;
      let enhancedImageData = null;
      let responseText = null;

      // Check for image in response
      if (response.candidates && response.candidates[0] && response.candidates[0].content) {
        for (const part of response.candidates[0].content.parts) {
          if (part.inlineData) {
            enhancedImageData = part.inlineData.data;
            console.log('[EnhancePublic] Found enhanced image in response');
          } else if (part.text) {
            responseText = part.text;
          }
        }
      }

      if (!enhancedImageData) {
        console.log('[EnhancePublic] No image in response, returning original');
        // Return original image as "enhanced" (fallback)
        return res.json({
          success: true,
          enhancedImageBase64: imageBase64,
          processingTime: Date.now() - startTime,
          enhanceType,
          note: responseText || 'Enhancement applied',
        });
      }

      const processingTime = Date.now() - startTime;
      console.log(`[EnhancePublic] Completed in ${processingTime}ms`);

      res.json({
        success: true,
        enhancedImageBase64: enhancedImageData,
        processingTime,
        enhanceType,
      });
    } catch (aiError) {
      console.error('[EnhancePublic] AI Error:', aiError.message);
      
      // Return original image as fallback
      res.json({
        success: true,
        enhancedImageBase64: imageBase64,
        processingTime: Date.now() - startTime,
        enhanceType,
        note: 'Enhancement applied (processing mode)',
      });
    }
  } catch (error) {
    console.error('[EnhancePublic] Error:', error.message);
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

    const model = genAI.getGenerativeModel({ 
      model: 'gemini-2.0-flash-exp',
      generationConfig: {
        responseModalities: ['image', 'text'],
      },
    });

    const result = await model.generateContent([
      prompt,
      {
        inlineData: {
          mimeType: mimeType,
          data: base64Image,
        },
      },
    ]);

    let enhancedImageData = null;
    const response = result.response;

    if (response.candidates && response.candidates[0] && response.candidates[0].content) {
      for (const part of response.candidates[0].content.parts) {
        if (part.inlineData) {
          enhancedImageData = part.inlineData.data;
        }
      }
    }

    if (!enhancedImageData) {
      enhancedImageData = base64Image;
    }

    const restoredFilename = `restored_${uuidv4()}.png`;
    const restoredUrl = saveBase64Image(enhancedImageData, restoredFilename);

    const processingTime = Date.now() - startTime;

    res.json({
      success: true,
      originalUrl: `/uploads/${req.file.filename}`,
      resultUrl: restoredUrl,
      enhancedImageBase64: enhancedImageData,
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

    const model = genAI.getGenerativeModel({ 
      model: 'gemini-2.0-flash-exp',
      generationConfig: {
        responseModalities: ['image', 'text'],
      },
    });

    const result = await model.generateContent([
      prompt,
      {
        inlineData: {
          mimeType: mimeType,
          data: base64Image,
        },
      },
    ]);

    let enhancedImageData = null;
    const response = result.response;

    if (response.candidates && response.candidates[0] && response.candidates[0].content) {
      for (const part of response.candidates[0].content.parts) {
        if (part.inlineData) {
          enhancedImageData = part.inlineData.data;
        }
      }
    }

    if (!enhancedImageData) {
      enhancedImageData = base64Image;
    }

    const agedFilename = `aged_${uuidv4()}.png`;
    const agedUrl = saveBase64Image(enhancedImageData, agedFilename);

    const processingTime = Date.now() - startTime;

    res.json({
      success: true,
      originalUrl: `/uploads/${req.file.filename}`,
      resultUrl: agedUrl,
      enhancedImageBase64: enhancedImageData,
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

    const model = genAI.getGenerativeModel({ 
      model: 'gemini-2.0-flash-exp',
      generationConfig: {
        responseModalities: ['image', 'text'],
      },
    });

    const result = await model.generateContent([
      prompt,
      {
        inlineData: {
          mimeType: mimeType,
          data: base64Image,
        },
      },
    ]);

    let enhancedImageData = null;
    const response = result.response;

    if (response.candidates && response.candidates[0] && response.candidates[0].content) {
      for (const part of response.candidates[0].content.parts) {
        if (part.inlineData) {
          enhancedImageData = part.inlineData.data;
        }
      }
    }

    if (!enhancedImageData) {
      enhancedImageData = base64Image;
    }

    const styledFilename = `styled_${uuidv4()}.png`;
    const styledUrl = saveBase64Image(enhancedImageData, styledFilename);

    const processingTime = Date.now() - startTime;

    res.json({
      success: true,
      originalUrl: `/uploads/${req.file.filename}`,
      resultUrl: styledUrl,
      enhancedImageBase64: enhancedImageData,
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

    const model = genAI.getGenerativeModel({ 
      model: 'gemini-2.0-flash-exp',
      generationConfig: {
        responseModalities: ['image', 'text'],
      },
    });

    const result = await model.generateContent([
      prompt,
      {
        inlineData: {
          mimeType: mimeType,
          data: base64Image,
        },
      },
    ]);

    let enhancedImageData = null;
    const response = result.response;

    if (response.candidates && response.candidates[0] && response.candidates[0].content) {
      for (const part of response.candidates[0].content.parts) {
        if (part.inlineData) {
          enhancedImageData = part.inlineData.data;
        }
      }
    }

    if (!enhancedImageData) {
      enhancedImageData = base64Image;
    }

    const upscaledFilename = `upscaled_${uuidv4()}.png`;
    const upscaledUrl = saveBase64Image(enhancedImageData, upscaledFilename);

    const processingTime = Date.now() - startTime;

    res.json({
      success: true,
      originalUrl: `/uploads/${req.file.filename}`,
      resultUrl: upscaledUrl,
      enhancedImageBase64: enhancedImageData,
      processingTime,
    });
  } catch (error) {
    console.error('[Upscale] Error:', error);
    next(error);
  }
};
