import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Register with email & password
  Future<User?> registerWithEmail(String email, String password, String name) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (result.user != null) {
        // Save user data to Firestore
        await _firestore.collection('users').doc(result.user!.uid).set({
          'email': email,
          'name': name,
          'photoUrl': '',
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
          'settings': {
            'reminderEnabled': true,
            'pushEnabled': true,
            'waEnabled': true,
            'reminderHour': 8,
            'currency': 'IDR',
          }
        });
        
        await result.user!.updateDisplayName(name);
        notifyListeners();
        return result.user;
      }
      return null;
    } catch (e) {
      debugPrint('Register error: $e');
      return null;
    }
  }
  
  // Login with email & password
  Future<User?> loginWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update last login
      await _firestore.collection('users').doc(result.user!.uid).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });
      
      notifyListeners();
      return result.user;
    } catch (e) {
      debugPrint('Login error: $e');
      return null;
    }
  }
  
  // Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;
      
      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;
      
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      UserCredential result = await _auth.signInWithCredential(credential);
      
      // Check if user exists in Firestore
      final userDoc = await _firestore.collection('users').doc(result.user!.uid).get();
      
      if (!userDoc.exists) {
        await _firestore.collection('users').doc(result.user!.uid).set({
          'email': result.user!.email,
          'name': result.user!.displayName ?? '',
          'photoUrl': result.user!.photoURL ?? '',
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
          'settings': {
            'reminderEnabled': true,
            'pushEnabled': true,
            'waEnabled': true,
            'reminderHour': 8,
            'currency': 'IDR',
          }
        });
      } else {
        await _firestore.collection('users').doc(result.user!.uid).update({
          'lastLogin': FieldValue.serverTimestamp(),
        });
      }
      
      notifyListeners();
      return result.user;
    } catch (e) {
      debugPrint('Google sign in error: $e');
      return null;
    }
  }
  
  // Logout
  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    notifyListeners();
  }
}