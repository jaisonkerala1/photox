const express = require('express');
const router = express.Router();

const aiController = require('../controllers/aiProcessingController');
const { auth, requireCredits, requirePro } = require('../middleware/auth');
const { upload } = require('../middleware/upload');

// Enhance photo
router.post(
  '/enhance',
  auth,
  requireCredits(1),
  upload.single('image'),
  aiController.enhance
);

// Restore old photo
router.post(
  '/restore',
  auth,
  requireCredits(1),
  upload.single('image'),
  aiController.restore
);

// Face swap (PRO feature)
router.post(
  '/face-swap',
  auth,
  requirePro,
  requireCredits(1),
  upload.array('images', 2),
  aiController.faceSwap
);

// Age progression (PRO feature)
router.post(
  '/aging',
  auth,
  requirePro,
  requireCredits(1),
  upload.single('image'),
  aiController.aging
);

// Style transfer
router.post(
  '/style-transfer',
  auth,
  requireCredits(1),
  upload.single('image'),
  aiController.styleTransfer
);

// Apply filter
router.post(
  '/apply-filter',
  auth,
  requireCredits(1),
  upload.single('image'),
  aiController.applyFilter
);

// HD Upscale
router.post(
  '/upscale',
  auth,
  requireCredits(1),
  upload.single('image'),
  aiController.upscale
);

module.exports = router;


