const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema({
  email: {
    type: String,
    required: [true, 'Email is required'],
    unique: true,
    lowercase: true,
    trim: true,
    match: [/^\S+@\S+\.\S+$/, 'Please enter a valid email'],
  },
  password: {
    type: String,
    required: [true, 'Password is required'],
    minlength: [8, 'Password must be at least 8 characters'],
    select: false,
  },
  name: {
    type: String,
    required: [true, 'Name is required'],
    trim: true,
    maxlength: [50, 'Name cannot exceed 50 characters'],
  },
  profilePicture: {
    type: String,
    default: null,
  },
  subscriptionType: {
    type: String,
    enum: ['free', 'pro'],
    default: 'free',
  },
  subscriptionExpiry: {
    type: Date,
    default: null,
  },
  creditsRemaining: {
    type: Number,
    default: 3,
  },
  lastCreditReset: {
    type: Date,
    default: Date.now,
  },
  refreshToken: {
    type: String,
    select: false,
  },
}, {
  timestamps: true,
});

// Hash password before saving
userSchema.pre('save', async function(next) {
  if (!this.isModified('password')) return next();
  
  const salt = await bcrypt.genSalt(12);
  this.password = await bcrypt.hash(this.password, salt);
  next();
});

// Compare password method
userSchema.methods.comparePassword = async function(candidatePassword) {
  return await bcrypt.compare(candidatePassword, this.password);
};

// Check if user has active pro subscription
userSchema.methods.isPro = function() {
  return this.subscriptionType === 'pro' && 
         this.subscriptionExpiry && 
         this.subscriptionExpiry > new Date();
};

// Reset daily credits
userSchema.methods.resetDailyCredits = function() {
  const now = new Date();
  const lastReset = new Date(this.lastCreditReset);
  
  // Check if 24 hours have passed
  if (now - lastReset >= 24 * 60 * 60 * 1000) {
    this.creditsRemaining = this.isPro() ? 100 : 3;
    this.lastCreditReset = now;
    return true;
  }
  return false;
};

// Use credits
userSchema.methods.useCredits = function(amount = 1) {
  if (this.creditsRemaining >= amount) {
    this.creditsRemaining -= amount;
    return true;
  }
  return false;
};

module.exports = mongoose.model('User', userSchema);


