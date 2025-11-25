const jwt = require('jsonwebtoken');
const User = require('../models/User');

const auth = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        message: 'Access denied. No token provided.',
      });
    }

    const token = authHeader.split(' ')[1];
    
    try {
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      const user = await User.findById(decoded.userId);
      
      if (!user) {
        return res.status(401).json({
          success: false,
          message: 'User not found.',
        });
      }

      // Reset daily credits if needed
      if (user.resetDailyCredits()) {
        await user.save();
      }

      req.user = user;
      req.userId = user._id;
      next();
    } catch (error) {
      if (error.name === 'TokenExpiredError') {
        return res.status(401).json({
          success: false,
          message: 'Token expired.',
          code: 'TOKEN_EXPIRED',
        });
      }
      throw error;
    }
  } catch (error) {
    console.error('Auth middleware error:', error);
    res.status(401).json({
      success: false,
      message: 'Invalid token.',
    });
  }
};

const optionalAuth = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    
    if (authHeader && authHeader.startsWith('Bearer ')) {
      const token = authHeader.split(' ')[1];
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      const user = await User.findById(decoded.userId);
      
      if (user) {
        req.user = user;
        req.userId = user._id;
      }
    }
    next();
  } catch (error) {
    next();
  }
};

const requirePro = async (req, res, next) => {
  if (!req.user.isPro()) {
    return res.status(403).json({
      success: false,
      message: 'This feature requires a PRO subscription.',
      code: 'PRO_REQUIRED',
    });
  }
  next();
};

const requireCredits = (amount = 1) => {
  return async (req, res, next) => {
    if (req.user.creditsRemaining < amount) {
      return res.status(403).json({
        success: false,
        message: 'Insufficient credits.',
        code: 'INSUFFICIENT_CREDITS',
        creditsRequired: amount,
        creditsRemaining: req.user.creditsRemaining,
      });
    }
    next();
  };
};

module.exports = { auth, optionalAuth, requirePro, requireCredits };


