/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

const firestore = admin.firestore();

exports.deleteOldPosts = functions.pubsub.schedule('every 24 hours')
    .onRun(async (context) => {
        const now = Date.now();
        const cutoffTime = now - 24 * 60 * 60 * 1000; // 24 hours in milliseconds

        const query = firestore.collectionGroup('Posts')
            .where('__name__', '>', cutoffTime.toString()) // Filter for document names greater than cutoff timestamp (as string)
            .where('__name__', '!=', 'init'); // Exclude "init" document

        const snapshot = await query.get();

        if (snapshot.empty) {
            console.log('No old posts found to delete.');
            return null;
        }

        const batch = firestore.batch();

        snapshot.forEach(doc => {
            batch.delete(doc.ref);
        });

        await batch.commit().then(() => {
            console.log(`${snapshot.size} old posts deleted successfully.`);
        }).catch(error => {
            console.error('Error deleting old posts:', error);
        });

        return null;
    });
