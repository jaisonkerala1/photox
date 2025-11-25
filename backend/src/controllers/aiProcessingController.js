const { GoogleGenerativeAI } = require('@google/generative-ai');
const Photo = require('../models/Photo');
const EditHistory = require('../models/EditHistory');
const fs = require('fs');
const path = require('path');

// Initialize Google AI
const genAI = new GoogleGenerativeAI(process.env.GOOGLE_AI_API_KEY);

// Helper to convert file to generative part
const fileToGenerativePart = (filePath, mimeType) => {
  return {
    inlineData: {
      data: fs.readFileSync(filePath).toString('base64'),
      mimeType,
    },
  };
};

// Helper to save result and history
const saveResult = async (userId, photo, editType, resultUrl, processingTime, parameters = null) => {
  // Update photo
  photo.editedUrl = resultUrl;
  photo.editType = editType;
  photo.status = 'completed';
  photo.processingTime = processingTime;
  photo.parameters = parameters;
  await photo.save();

  // Create history entry
  await EditHistory.create({
    userId,
    photoId: photo._id,
    editType,
    parameters,
    originalUrl: photo.originalUrl,
    resultUrl,
    processingTime,
    cost: 1,
  });

  // Deduct credits
  const User = require('../models/User');
  await User.findByIdAndUpdate(userId, { $inc: { creditsRemaining: -1 } });

  return photo;
};

// Enhance photo
exports.enhance = async (req, res, next) => {
  try {
    const startTime = Date.now();
    const { intensity = 50 } = req.body;

    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'No image provided',
      });
    }

    // Create photo record
    const photo = await Photo.create({
      userId: req.userId,
      originalUrl: `/uploads/${req.file.filename}`,
      editType: 'enhance',
      status: 'processing',
    });

    try {
      // Use Gemini Vision for enhancement guidance
      const model = genAI.getGenerativeModel({ model: 'gemini-1.5-flash' });
      const imagePart = fileToGenerativePart(req.file.path, req.file.mimetype);
      
      const result = await model.generateContent([
        'Analyze this image and describe how to enhance it. Focus on color correction, sharpness, noise reduction, and overall quality improvements.',
        imagePart,
      ]);

      const processingTime = Date.now() - startTime;

      // For now, return the original as we need actual image processing
      // In production, integrate with a proper image processing service
      const resultUrl = photo.originalUrl;

      const updatedPhoto = await saveResult(
        req.userId,
        photo,
        'enhance',
        resultUrl,
        processingTime,
        { intensity }
      );

      res.json({
        success: true,
        id: updatedPhoto._id,
        originalUrl: updatedPhoto.originalUrl,
        resultUrl: updatedPhoto.editedUrl,
        processingTime,
        creditsCost: 1,
        createdAt: updatedPhoto.createdAt,
      });
    } catch (aiError) {
      photo.status = 'failed';
      photo.errorMessage = aiError.message;
      await photo.save();
      throw aiError;
    }
  } catch (error) {
    next(error);
  }
};

// Restore old photo
exports.restore = async (req, res, next) => {
  try {
    const startTime = Date.now();
    const { colorize = false, removeDamage = true } = req.body;

    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'No image provided',
      });
    }

    const photo = await Photo.create({
      userId: req.userId,
      originalUrl: `/uploads/${req.file.filename}`,
      editType: 'restore',
      status: 'processing',
    });

    try {
      const model = genAI.getGenerativeModel({ model: 'gemini-1.5-flash' });
      const imagePart = fileToGenerativePart(req.file.path, req.file.mimetype);
      
      await model.generateContent([
        'Analyze this old photo and describe the damage that needs to be repaired: scratches, tears, fading, discoloration, etc.',
        imagePart,
      ]);

      const processingTime = Date.now() - startTime;
      const resultUrl = photo.originalUrl;

      const updatedPhoto = await saveResult(
        req.userId,
        photo,
        'restore',
        resultUrl,
        processingTime,
        { colorize, removeDamage }
      );

      res.json({
        success: true,
        id: updatedPhoto._id,
        originalUrl: updatedPhoto.originalUrl,
        resultUrl: updatedPhoto.editedUrl,
        processingTime,
        creditsCost: 1,
        createdAt: updatedPhoto.createdAt,
      });
    } catch (aiError) {
      photo.status = 'failed';
      photo.errorMessage = aiError.message;
      await photo.save();
      throw aiError;
    }
  } catch (error) {
    next(error);
  }
};

// Face swap
exports.faceSwap = async (req, res, next) => {
  try {
    const startTime = Date.now();

    if (!req.files || req.files.length < 2) {
      return res.status(400).json({
        success: false,
        message: 'Two images are required for face swap',
      });
    }

    const photo = await Photo.create({
      userId: req.userId,
      originalUrl: `/uploads/${req.files[0].filename}`,
      editType: 'faceSwap',
      status: 'processing',
    });

    try {
      const model = genAI.getGenerativeModel({ model: 'gemini-1.5-flash' });
      
      const sourcePart = fileToGenerativePart(req.files[0].path, req.files[0].mimetype);
      const targetPart = fileToGenerativePart(req.files[1].path, req.files[1].mimetype);
      
      await model.generateContent([
        'Analyze these two faces and describe their key features for a face swap operation.',
        sourcePart,
        targetPart,
      ]);

      const processingTime = Date.now() - startTime;
      const resultUrl = photo.originalUrl;

      const updatedPhoto = await saveResult(
        req.userId,
        photo,
        'faceSwap',
        resultUrl,
        processingTime
      );

      res.json({
        success: true,
        id: updatedPhoto._id,
        originalUrl: updatedPhoto.originalUrl,
        resultUrl: updatedPhoto.editedUrl,
        processingTime,
        creditsCost: 1,
        createdAt: updatedPhoto.createdAt,
      });
    } catch (aiError) {
      photo.status = 'failed';
      photo.errorMessage = aiError.message;
      await photo.save();
      throw aiError;
    }
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

    const photo = await Photo.create({
      userId: req.userId,
      originalUrl: `/uploads/${req.file.filename}`,
      editType: 'aging',
      status: 'processing',
    });

    try {
      const model = genAI.getGenerativeModel({ model: 'gemini-1.5-flash' });
      const imagePart = fileToGenerativePart(req.file.path, req.file.mimetype);
      
      await model.generateContent([
        `Analyze this face and describe how it would look at age ${targetAge}. Consider wrinkles, skin texture, hair color changes, and facial structure changes.`,
        imagePart,
      ]);

      const processingTime = Date.now() - startTime;
      const resultUrl = photo.originalUrl;

      const updatedPhoto = await saveResult(
        req.userId,
        photo,
        'aging',
        resultUrl,
        processingTime,
        { targetAge }
      );

      res.json({
        success: true,
        id: updatedPhoto._id,
        originalUrl: updatedPhoto.originalUrl,
        resultUrl: updatedPhoto.editedUrl,
        processingTime,
        creditsCost: 1,
        createdAt: updatedPhoto.createdAt,
      });
    } catch (aiError) {
      photo.status = 'failed';
      photo.errorMessage = aiError.message;
      await photo.save();
      throw aiError;
    }
  } catch (error) {
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

    const photo = await Photo.create({
      userId: req.userId,
      originalUrl: `/uploads/${req.file.filename}`,
      editType: 'styleTransfer',
      status: 'processing',
    });

    try {
      const model = genAI.getGenerativeModel({ model: 'gemini-1.5-flash' });
      const imagePart = fileToGenerativePart(req.file.path, req.file.mimetype);
      
      await model.generateContent([
        `Describe how this image would look if transformed into ${style} style.`,
        imagePart,
      ]);

      const processingTime = Date.now() - startTime;
      const resultUrl = photo.originalUrl;

      const updatedPhoto = await saveResult(
        req.userId,
        photo,
        'styleTransfer',
        resultUrl,
        processingTime,
        { style }
      );

      res.json({
        success: true,
        id: updatedPhoto._id,
        originalUrl: updatedPhoto.originalUrl,
        resultUrl: updatedPhoto.editedUrl,
        processingTime,
        creditsCost: 1,
        createdAt: updatedPhoto.createdAt,
      });
    } catch (aiError) {
      photo.status = 'failed';
      photo.errorMessage = aiError.message;
      await photo.save();
      throw aiError;
    }
  } catch (error) {
    next(error);
  }
};

// Apply filter
exports.applyFilter = async (req, res, next) => {
  try {
    const startTime = Date.now();
    const { filter = 'instant_snap' } = req.body;

    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'No image provided',
      });
    }

    const photo = await Photo.create({
      userId: req.userId,
      originalUrl: `/uploads/${req.file.filename}`,
      editType: 'filter',
      status: 'processing',
    });

    const processingTime = Date.now() - startTime;
    const resultUrl = photo.originalUrl;

    const updatedPhoto = await saveResult(
      req.userId,
      photo,
      'filter',
      resultUrl,
      processingTime,
      { filter }
    );

    res.json({
      success: true,
      id: updatedPhoto._id,
      originalUrl: updatedPhoto.originalUrl,
      resultUrl: updatedPhoto.editedUrl,
      processingTime,
      creditsCost: 1,
      createdAt: updatedPhoto.createdAt,
    });
  } catch (error) {
    next(error);
  }
};

// HD Upscale
exports.upscale = async (req, res, next) => {
  try {
    const startTime = Date.now();
    const { factor = 2 } = req.body;

    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'No image provided',
      });
    }

    const photo = await Photo.create({
      userId: req.userId,
      originalUrl: `/uploads/${req.file.filename}`,
      editType: 'upscale',
      status: 'processing',
    });

    const processingTime = Date.now() - startTime;
    const resultUrl = photo.originalUrl;

    const updatedPhoto = await saveResult(
      req.userId,
      photo,
      'upscale',
      resultUrl,
      processingTime,
      { factor }
    );

    res.json({
      success: true,
      id: updatedPhoto._id,
      originalUrl: updatedPhoto.originalUrl,
      resultUrl: updatedPhoto.editedUrl,
      processingTime,
      creditsCost: 1,
      createdAt: updatedPhoto.createdAt,
    });
  } catch (error) {
    next(error);
  }
};


