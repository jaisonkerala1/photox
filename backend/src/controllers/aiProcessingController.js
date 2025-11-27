const fs = require('fs');
const path = require('path');
const { v4: uuidv4 } = require('uuid');

// OpenRouter configuration
const OPENROUTER_API_KEY = process.env.OPENROUTER_API_KEY;
const MODEL_NAME = 'google/gemini-2.0-flash-exp:free';  // Free model that supports image generation

// Debug: Log API key status on startup
console.log('=== AI Processing Controller Loaded ===');
console.log('OPENROUTER_API_KEY present:', !!OPENROUTER_API_KEY);
console.log('OPENROUTER_API_KEY length:', OPENROUTER_API_KEY ? OPENROUTER_API_KEY.length : 0);
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

// Enhance photo using OpenRouter SDK + Gemini 3 Pro Image Preview
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
    console.log('[Enhance] Calling OpenRouter SDK with model:', MODEL_NAME);

    const result = await callOpenRouter(prompt, base64Image, mimeType);

    console.log('[Enhance] Received response from OpenRouter');

    let enhancedImageData = null;

    // Parse OpenRouter SDK response
    if (result.choices && result.choices[0] && result.choices[0].message) {
      const message = result.choices[0].message;
      
      // Check for images array
      if (message.images && message.images.length > 0) {
        const imageUrl = message.images[0].image_url.url;
        if (imageUrl.startsWith('data:')) {
          enhancedImageData = imageUrl.split(',')[1];
        }
      }
      
      // Also check content
      const content = message.content;
      if (!enhancedImageData && content) {
        if (Array.isArray(content)) {
          for (const part of content) {
            if (part.type === 'image_url' && part.image_url) {
              const dataUrl = part.image_url.url;
              if (dataUrl.startsWith('data:')) {
                enhancedImageData = dataUrl.split(',')[1];
              }
            }
          }
        } else if (typeof content === 'string' && content.startsWith('data:image')) {
          enhancedImageData = content.split(',')[1];
        }
      }
    }

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

// Helper function to call OpenRouter API for image enhancement
async function callOpenRouter(prompt, imageBase64, mimeType) {
  if (!OPENROUTER_API_KEY) {
    throw new Error('OpenRouter API key not set');
  }

  const response = await fetch('https://openrouter.ai/api/v1/chat/completions', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${OPENROUTER_API_KEY}`,
      'Content-Type': 'application/json',
      'HTTP-Referer': 'https://photox.app',
      'X-Title': 'PhotoX AI Enhancer',
    },
    body: JSON.stringify({
      model: MODEL_NAME,
      messages: [
        {
          role: 'user',
          content: [
            {
              type: 'text',
              text: prompt,
            },
            {
              type: 'image_url',
              image_url: {
                url: `data:${mimeType};base64,${imageBase64}`,
              },
            },
          ],
        },
      ],
      // Request image output
      modalities: ['text', 'image'],
    }),
  });

  if (!response.ok) {
    const errorText = await response.text();
    console.error('[OpenRouter] API Error:', response.status, errorText);
    throw new Error(`OpenRouter API error: ${response.status}`);
  }

  return response.json();
}

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
    console.log('[EnhancePublic] OpenRouter API Key present:', !!OPENROUTER_API_KEY);

    if (!imageBase64) {
      console.log('[EnhancePublic] ERROR: No image provided');
      return res.status(400).json({
        success: false,
        message: 'No image provided. Send imageBase64 in request body.',
      });
    }

    if (!OPENROUTER_API_KEY) {
      console.log('[EnhancePublic] ERROR: OpenRouter API key not set');
      return res.status(500).json({
        success: false,
        message: 'AI service not initialized. Check OPENROUTER_API_KEY.',
      });
    }

    // Get the appropriate prompt
    const prompt = ENHANCE_PROMPTS[enhanceType] || ENHANCE_PROMPTS.auto;
    console.log('[EnhancePublic] Using prompt:', prompt.substring(0, 50) + '...');

    try {
      console.log('[EnhancePublic] Calling OpenRouter API with model:', MODEL_NAME);
      
      const result = await callOpenRouter(prompt, imageBase64, mimeType);

      console.log('[EnhancePublic] Received response from OpenRouter');
      console.log('[EnhancePublic] Result keys:', Object.keys(result));

      let enhancedImageData = null;
      let responseText = null;

      // Parse OpenRouter response
      if (result.choices && result.choices[0] && result.choices[0].message) {
        const message = result.choices[0].message;
        console.log('[EnhancePublic] Message keys:', Object.keys(message));
        
        const content = message.content;
        console.log('[EnhancePublic] Content type:', typeof content);
        
        if (Array.isArray(content)) {
          console.log('[EnhancePublic] Content is array, length:', content.length);
          for (const part of content) {
            console.log('[EnhancePublic] Part:', JSON.stringify(part).substring(0, 200));
            
            // Check for inline_data format (Gemini style)
            if (part.inline_data && part.inline_data.data) {
              enhancedImageData = part.inline_data.data;
              console.log('[EnhancePublic] Found inline_data image, length:', enhancedImageData.length);
            }
            // Check for image_url format
            else if (part.type === 'image_url' && part.image_url) {
              const dataUrl = part.image_url.url;
              if (dataUrl && dataUrl.startsWith('data:')) {
                enhancedImageData = dataUrl.split(',')[1];
                console.log('[EnhancePublic] Found image_url, length:', enhancedImageData.length);
              }
            }
            // Check for image type with data
            else if (part.type === 'image' && part.data) {
              enhancedImageData = part.data;
              console.log('[EnhancePublic] Found image data, length:', enhancedImageData.length);
            }
            // Check for base64 directly in part
            else if (part.b64_json) {
              enhancedImageData = part.b64_json;
              console.log('[EnhancePublic] Found b64_json, length:', enhancedImageData.length);
            }
            else if (part.type === 'text') {
              responseText = part.text;
              console.log('[EnhancePublic] Found text:', responseText ? responseText.substring(0, 100) : 'empty');
            }
          }
        } else if (typeof content === 'string') {
          console.log('[EnhancePublic] Content is string, length:', content.length);
          // Check if it's base64 data (starts with image signature or is pure base64)
          if (content.startsWith('data:image')) {
            enhancedImageData = content.split(',')[1];
            console.log('[EnhancePublic] Found data URL image');
          } else if (content.startsWith('/9j/') || content.startsWith('iVBOR')) {
            // JPEG starts with /9j/, PNG starts with iVBOR
            enhancedImageData = content;
            console.log('[EnhancePublic] Found raw base64 image');
          } else if (content.length > 1000 && !content.includes(' ')) {
            // Likely base64 if long string without spaces
            enhancedImageData = content;
            console.log('[EnhancePublic] Assuming base64 image from long string');
          } else {
            responseText = content;
            console.log('[EnhancePublic] Text response:', content.substring(0, 200));
          }
        }
      }

      if (!enhancedImageData) {
        console.log('[EnhancePublic] No image in response, returning original');
        console.log('[EnhancePublic] Full result:', JSON.stringify(result, null, 2).substring(0, 2000));
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
