const Photo = require('../models/Photo');

// Get all photos for user
exports.getPhotos = async (req, res, next) => {
  try {
    const { page = 1, limit = 20, editType } = req.query;
    const skip = (page - 1) * limit;

    const query = { userId: req.userId };
    if (editType) query.editType = editType;

    const [photos, total] = await Promise.all([
      Photo.find(query)
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(parseInt(limit)),
      Photo.countDocuments(query),
    ]);

    res.json({
      success: true,
      photos,
      total,
      page: parseInt(page),
      limit: parseInt(limit),
      hasMore: skip + photos.length < total,
    });
  } catch (error) {
    next(error);
  }
};

// Get single photo
exports.getPhoto = async (req, res, next) => {
  try {
    const photo = await Photo.findOne({
      _id: req.params.id,
      userId: req.userId,
    });

    if (!photo) {
      return res.status(404).json({
        success: false,
        message: 'Photo not found',
      });
    }

    res.json({
      success: true,
      photo,
    });
  } catch (error) {
    next(error);
  }
};

// Upload photo
exports.uploadPhoto = async (req, res, next) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'No file uploaded',
      });
    }

    // TODO: Upload to Firebase Storage and get URL
    const originalUrl = `/uploads/${req.file.filename}`;

    const photo = await Photo.create({
      userId: req.userId,
      originalUrl,
      status: 'pending',
    });

    res.status(201).json({
      success: true,
      photo,
    });
  } catch (error) {
    next(error);
  }
};

// Delete photo
exports.deletePhoto = async (req, res, next) => {
  try {
    const photo = await Photo.findOneAndDelete({
      _id: req.params.id,
      userId: req.userId,
    });

    if (!photo) {
      return res.status(404).json({
        success: false,
        message: 'Photo not found',
      });
    }

    // TODO: Delete from Firebase Storage

    res.json({
      success: true,
      message: 'Photo deleted successfully',
    });
  } catch (error) {
    next(error);
  }
};





