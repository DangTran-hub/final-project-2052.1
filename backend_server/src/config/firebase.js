import admin from 'firebase-admin';
import { config } from './config.js';
import fs from 'fs';

// Kiểm tra xem file credential có tồn tại không
if (fs.existsSync(config.firebase.credentialPath)) {
  const serviceAccount = JSON.parse(fs.readFileSync(config.firebase.credentialPath, 'utf8'));

  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
  console.log('Firebase Admin Initialized successfully');
} else {
  console.warn(`Warning: Firebase credential file not found at ${config.firebase.credentialPath}. Firebase features will be disabled.`);
}

export const db = admin.firestore();
export const messaging = admin.messaging();
