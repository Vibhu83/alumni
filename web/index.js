
   const firebase = require("firebase");
   // Required for side-effects
   require("firebase/firestore");
const firebaseApp = firebase.initializeApp({ 

  apiKey: "AIzaSyDMhaq9b7w5Xw2pK6tKLcOFIBJ0z6T5lPI",
  
  authDomain: "alumni-npgc-flutter.firebaseapp.com",
  
  databaseURL: "https://alumni-npgc-flutter-default-rtdb.asia-southeast1.firebasedatabase.app",
  
  projectId: "alumni-npgc-flutter",
  
  storageBucket: "alumni-npgc-flutter.appspot.com",
  
  messagingSenderId: "247294125141",
  
  appId: "1:247294125141:web:c2e565df731babf65ae0dc",
  
  measurementId: "G-YTDRM34MZT"

   });
   
const db = firebaseApp.firestore();
const auth = firebaseApp.auth();


// Add a new document with a generated id.
db.collection("cities").add({
    name: "Tokyo",
    country: "Japan"
})
.then((docRef) => {
  alert("It worked");
    console.log("Document written with ID: ", docRef.id);
})
.catch((error) => {
    console.error("Error adding document: ", error);
});
