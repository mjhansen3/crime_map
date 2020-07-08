import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rxdart/rxdart.dart';

class AuthServices {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final Firestore _dbFireStore = Firestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<FirebaseUser> user;
  Stream<Map<String, dynamic>> profile;
  PublishSubject loading = PublishSubject();

  AuthServices() {
    user = Stream.castFrom(_auth.onAuthStateChanged);

    profile = user.switchMap((FirebaseUser u) {
      if(u != null) {
        return _dbFireStore.collection('users').document(u.uid).snapshots().map((snap) => snap.data);
      } else {
        return Stream.empty();
      }
    });
  }

  Future<FirebaseUser> googleSignIn() async {
    loading.add(true);

    GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final AuthResult authResult = await _auth.signInWithCredential(credential);
    FirebaseUser user = authResult.user;
    addUserData(user);
    print("signed in " + user.displayName);
    loading.add(false);

    return user;
  }

  void addUserData(FirebaseUser user) async {
    DocumentReference reference = _dbFireStore.collection('users').document(user.uid);

    return reference.setData({
      'uid': user.uid,
      'email': user.email,
      'name': user.displayName,
    }, merge: true);
  }

  void signOutUser() async {
    await FirebaseAuth.instance.signOut();
    _googleSignIn.signOut();
  }
}

final AuthServices authServices = AuthServices();