/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */
// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
const { onRequest } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");



const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

const firestore = admin.firestore();

exports.deleteOldPosts = functions.pubsub.schedule('* * * * *').onRun(async (context) => {
    console.log('started999');
  const usersSnapshot = await firestore.collection('Users').get();
//   const batch = firestore.batch();

  usersSnapshot.forEach(async (userDoc) => {
    const batch = firestore.batch();
    console.log('here1');
    const postsRef = userDoc.ref.collection('Posts');
    const postsSnapshot = await postsRef.get();

    // Check if there are any posts before iterating
    if (postsSnapshot.empty) {
      console.log(`No posts found for user: ${userDoc.id}`);
      return;
    }

    postsSnapshot.forEach((postDoc) => {
      try {
        console.log('here2');
        const postDate = new Date(postDoc.id);
        const twentyFourHoursAgo = new Date();
        twentyFourHoursAgo.setDate(twentyFourHoursAgo.getDate() - 1);

        if (postDate < twentyFourHoursAgo && postDoc.id !== 'init') {
          batch.delete(postDoc.ref);
          console.log('here3');
        }
      } catch (error) {
        console.error(`Error deleting post: ${postDoc.id}`, error);
      }
    });
    console.log('here4');
    return batch.commit();
  });
  console.log('here5');
//   return batch.commit();
});


// const functions = require('firebase-functions');
// const admin = require('firebase-admin');

// admin.initializeApp();

// const firestore = admin.firestore();

// exports.deleteOldPosts = functions.pubsub.schedule('* * * * *')
//     .onRun(async (context) => {
//         const now = Date.now();
//         const cutoffTime = now - 1 * 60 * 1000;//24 * 60 * 60 * 1000; // 24 hours in milliseconds

//         //new
//         const cutoffTimestamp = admin.firestore.Timestamp.fromDate(new Date(cutoffTime));

//         const query = firestore.collectionGroup('Posts')
//         .where('__name__', '>', cutoffTimestamp) // Use the extracted timestamp
//         .where('__name__', '!=', 'init');
      
     
//         // const query = firestore.collectionGroup('Posts')
//         //     .where('__name__', '>', admin.firestore.Timestamp.fromDate(new Date(cutoffTime))) // Use Firestore Timestamp
//         //     .where('__name__', '!=', 'init');

//         const snapshot = await query.get();

//         if (snapshot.empty) {
//             console.log('No old posts found to delete.');
//             return null;
//         }

//         const batch = firestore.batch();

//         snapshot.forEach(doc => {
//             batch.delete(doc.ref);
//         });

//         await batch.commit().then(() => {
//             console.log(`${snapshot.size} old posts deleted successfully.`);
//         }).catch(error => {
//             console.error('Error deleting old posts:', error);
//         });

//         return null;
//     });



//        // const query = firestore.collectionGroup('Posts')
//         //     .where('__name__', '>', cutoffTime.toString()) // Filter for document names greater than cutoff timestamp (as string)
//         //     .where('__name__', '!=', 'init'); // Exclude "init" document