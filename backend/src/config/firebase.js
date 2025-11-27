const admin = require('firebase-admin');

let firebaseApp = null;

const initializeFirebase = () => {
  if (firebaseApp) return firebaseApp;

  try {
    const serviceAccount = {
      projectId: process.env.FIREBASE_PROJECT_ID,
      privateKey: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
      clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
    };

    firebaseApp = admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
      storageBucket: process.env.FIREBASE_STORAGE_BUCKET,
    });

    console.log('Firebase initialized successfully');
    return firebaseApp;
  } catch (error) {
    console.error('Firebase initialization error:', error.message);
    return null;
  }
};

const getStorage = () => {
  if (!firebaseApp) initializeFirebase();
  return admin.storage().bucket();
};

module.exports = {
  initializeFirebase,
  getStorage,
};





