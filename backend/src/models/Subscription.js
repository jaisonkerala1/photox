const mongoose = require('mongoose');

const subscriptionSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true,
  },
  planType: {
    type: String,
    enum: ['monthly', 'yearly'],
    required: true,
  },
  status: {
    type: String,
    enum: ['active', 'cancelled', 'expired', 'pending'],
    default: 'pending',
  },
  startDate: {
    type: Date,
    required: true,
  },
  endDate: {
    type: Date,
    required: true,
  },
  paymentId: {
    type: String,
    default: null,
  },
  paymentMethod: {
    type: String,
    default: null,
  },
  amount: {
    type: Number,
    required: true,
  },
  currency: {
    type: String,
    default: 'USD',
  },
  cancelledAt: {
    type: Date,
    default: null,
  },
  autoRenew: {
    type: Boolean,
    default: true,
  },
}, {
  timestamps: true,
});

// Check if subscription is active
subscriptionSchema.methods.isActive = function() {
  return this.status === 'active' && this.endDate > new Date();
};

module.exports = mongoose.model('Subscription', subscriptionSchema);





