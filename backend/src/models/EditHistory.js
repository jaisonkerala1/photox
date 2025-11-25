const mongoose = require('mongoose');

const editHistorySchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true,
  },
  photoId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Photo',
    required: true,
  },
  editType: {
    type: String,
    enum: [
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
    required: true,
  },
  parameters: {
    type: mongoose.Schema.Types.Mixed,
    default: null,
  },
  originalUrl: {
    type: String,
    required: true,
  },
  resultUrl: {
    type: String,
    required: true,
  },
  processingTime: {
    type: Number,
    default: 0,
  },
  cost: {
    type: Number,
    default: 1,
  },
}, {
  timestamps: true,
});

// Index for efficient queries
editHistorySchema.index({ userId: 1, createdAt: -1 });

module.exports = mongoose.model('EditHistory', editHistorySchema);


