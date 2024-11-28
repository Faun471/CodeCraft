// Please see this file for the latest firebase-js-sdk version:
// https://github.com/firebase/flutterfire/blob/master/packages/firebase_core/firebase_core_web/lib/src/firebase_sdk_version.dart
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js");

firebase.initializeApp({
    apiKey: 'AIzaSyCFgrWGvaACUOliee-7Hv7l03h1mPZKI0w',
    appId: '1:831166027593:web:7efc62ffe3329b07ab6c98',
    messagingSenderId: '831166027593',
    projectId: 'code-craft-bb5b1',
    authDomain: 'code-craft-bb5b1.firebaseapp.com',
    storageBucket: 'code-craft-bb5b1.appspot.com',
    measurementId: 'G-DPZTP8VQ1Y',
});

const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((message) => {
    console.log("onBackgroundMessage", message);
});