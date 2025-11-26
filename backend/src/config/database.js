const mongoose = require('mongoose');

const connectDB = async () => {
  try {
    // Railway provides MONGO_URL (public) or MONGO_URL_INTERNAL (internal)
    // Also support MONGODB_URI for custom setups
    const mongoUri = 
      process.env.MONGO_URL || 
      process.env.MONGO_URL_INTERNAL || 
      process.env.MONGODB_URI || 
      'mongodb://localhost:27017/photox';
    
    if (!mongoUri || mongoUri === 'mongodb://localhost:27017/photox') {
      console.warn('⚠️  Using default MongoDB URI. Make sure to set MONGO_URL or MONGODB_URI in Railway!');
    }
    
    const conn = await mongoose.connect(mongoUri, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });

    console.log(`✅ MongoDB Connected: ${conn.connection.host}`);
  } catch (error) {
    console.error('❌ MongoDB connection error:', error.message);
    process.exit(1);
  }
};

module.exports = connectDB;




