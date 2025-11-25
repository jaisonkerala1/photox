const express = require('express');
const router = express.Router();

const EditHistory = require('../models/EditHistory');
const { auth } = require('../middleware/auth');

// Get edit history
router.get('/', auth, async (req, res, next) => {
  try {
    const { page = 1, limit = 20 } = req.query;
    const skip = (page - 1) * limit;

    const [history, total] = await Promise.all([
      EditHistory.find({ userId: req.userId })
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(parseInt(limit)),
      EditHistory.countDocuments({ userId: req.userId }),
    ]);

    res.json({
      success: true,
      history,
      total,
      page: parseInt(page),
      limit: parseInt(limit),
      hasMore: skip + history.length < total,
    });
  } catch (error) {
    next(error);
  }
});

// Delete history item
router.delete('/:id', auth, async (req, res, next) => {
  try {
    const item = await EditHistory.findOneAndDelete({
      _id: req.params.id,
      userId: req.userId,
    });

    if (!item) {
      return res.status(404).json({
        success: false,
        message: 'History item not found',
      });
    }

    res.json({
      success: true,
      message: 'History item deleted',
    });
  } catch (error) {
    next(error);
  }
});

module.exports = router;


