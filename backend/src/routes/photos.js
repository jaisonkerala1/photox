const express = require('express');
const router = express.Router();

const photoController = require('../controllers/photoController');
const { auth } = require('../middleware/auth');
const { upload } = require('../middleware/upload');

// Get all photos
router.get('/', auth, photoController.getPhotos);

// Get single photo
router.get('/:id', auth, photoController.getPhoto);

// Upload photo
router.post('/upload', auth, upload.single('photo'), photoController.uploadPhoto);

// Delete photo
router.delete('/:id', auth, photoController.deletePhoto);

module.exports = router;


