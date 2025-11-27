const Subscription = require('../models/Subscription');
const User = require('../models/User');

// Get subscription plans
exports.getPlans = async (req, res, next) => {
  try {
    const plans = [
      {
        id: 'free',
        name: 'Free',
        description: 'Basic access with limited features',
        monthlyPrice: 0,
        yearlyPrice: 0,
        features: [
          '3 AI edits per day',
          'Standard quality export',
          'Basic filters',
          'Ad-supported',
        ],
        dailyCredits: 3,
        hdExport: false,
        noAds: false,
        priorityProcessing: false,
      },
      {
        id: 'pro',
        name: 'PRO',
        description: 'Unlimited access to all features',
        monthlyPrice: 9.99,
        yearlyPrice: 59.99,
        features: [
          'Unlimited AI edits',
          'HD quality export',
          'All filters & styles',
          'No ads',
          'Priority processing',
          'Advanced face tools',
          'Batch processing',
          'Cloud storage',
        ],
        dailyCredits: 9999,
        hdExport: true,
        noAds: true,
        priorityProcessing: true,
      },
    ];

    res.json({
      success: true,
      plans,
    });
  } catch (error) {
    next(error);
  }
};

// Get subscription status
exports.getStatus = async (req, res, next) => {
  try {
    const subscription = await Subscription.findOne({
      userId: req.userId,
      status: 'active',
    }).sort({ createdAt: -1 });

    if (!subscription) {
      return res.json({
        success: true,
        subscription: {
          id: null,
          planId: 'free',
          status: 'active',
          startDate: req.user.createdAt,
          endDate: null,
          isActive: false,
        },
      });
    }

    res.json({
      success: true,
      subscription: {
        id: subscription._id,
        planId: 'pro',
        status: subscription.status,
        startDate: subscription.startDate,
        endDate: subscription.endDate,
        isActive: subscription.isActive(),
        paymentId: subscription.paymentId,
        cancelledAt: subscription.cancelledAt,
      },
    });
  } catch (error) {
    next(error);
  }
};

// Purchase subscription
exports.purchase = async (req, res, next) => {
  try {
    const { planId, paymentMethod, isYearly = false } = req.body;

    if (planId !== 'pro') {
      return res.status(400).json({
        success: false,
        message: 'Invalid plan',
      });
    }

    const amount = isYearly ? 59.99 : 9.99;
    const duration = isYearly ? 365 : 30;

    const startDate = new Date();
    const endDate = new Date(startDate.getTime() + duration * 24 * 60 * 60 * 1000);

    // Create subscription
    const subscription = await Subscription.create({
      userId: req.userId,
      planType: isYearly ? 'yearly' : 'monthly',
      status: 'active',
      startDate,
      endDate,
      paymentMethod,
      amount,
      // paymentId would come from payment processor
    });

    // Update user
    await User.findByIdAndUpdate(req.userId, {
      subscriptionType: 'pro',
      subscriptionExpiry: endDate,
      creditsRemaining: 100,
    });

    res.json({
      success: true,
      subscription: {
        id: subscription._id,
        planId: 'pro',
        status: subscription.status,
        startDate: subscription.startDate,
        endDate: subscription.endDate,
        isActive: true,
      },
    });
  } catch (error) {
    next(error);
  }
};

// Cancel subscription
exports.cancel = async (req, res, next) => {
  try {
    const subscription = await Subscription.findOne({
      userId: req.userId,
      status: 'active',
    });

    if (!subscription) {
      return res.status(404).json({
        success: false,
        message: 'No active subscription found',
      });
    }

    subscription.status = 'cancelled';
    subscription.cancelledAt = new Date();
    subscription.autoRenew = false;
    await subscription.save();

    res.json({
      success: true,
      message: 'Subscription cancelled. You will retain access until the end of your billing period.',
    });
  } catch (error) {
    next(error);
  }
};





