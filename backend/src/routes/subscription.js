const express = require('express');
const router = express.Router();

const subscriptionController = require('../controllers/subscriptionController');
const { auth } = require('../middleware/auth');

// Get subscription plans
router.get('/plans', subscriptionController.getPlans);

// Get subscription status
router.get('/status', auth, subscriptionController.getStatus);

// Purchase subscription
router.post('/purchase', auth, subscriptionController.purchase);

// Cancel subscription
router.post('/cancel', auth, subscriptionController.cancel);

module.exports = router;





