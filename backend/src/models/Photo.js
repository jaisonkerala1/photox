const mongoose = require('mongoose');

const photoSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true,
  },
  originalUrl: {
    type: String,
    required: true,
  },
  editedUrl: {
    type: String,
    default: null,
  },
  thumbnailUrl: {
    type: String,
    default: null,
  },
  editType: {
    type: String,
    enum: [
      'none',
      'enhance',
      'restore',
      'selfieEdit',
      'faceSwap',
      'aging',
      'babyGenerator',
      'animate',
      'styleTransfer',
      'upscale',
      'filter',
    ],
    default: 'none',
  },
  status: {
    type: String,
    enum: ['pending', 'processing', 'completed', 'failed'],
    default: 'pending',
  },
  parameters: {
    type: mongoose.Schema.Types.Mixed,
    default: null,
  },
  processingTime: {
    type: Number,
    default: 0,
  },
  errorMessage: {
    type: String,
    default: null,
  },
}, {
  timestamps: true,
});

// Index for efficient queries
photoSchema.index({ userId: 1, createdAt: -1 });
photoSchema.index({ status: 1 });

module.exports = mongoose.model('Photo', photoSchema);


