import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late FirebaseAuth auth;
  final String _email = "maydin@gmail.com";
  final String _password = "password";
  @override
  void initState() {
    auth = FirebaseAuth.instance;
    auth.authStateChanges().listen((User? user) {
      if (user == null) {
        debugPrint('User is currently signed out!');
      } else {
        debugPrint(
            'User is signed in! ${user.email} ve durum ${user.emailVerified}');
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                createUserEmailAndPassword();
              },
              style: ElevatedButton.styleFrom(primary: Colors.red),
              child: const Text('Email/Sifre Kayıt'),
            ),
            ElevatedButton(
              onPressed: () {
                loginUserEmailAndPassword();
              },
              style: ElevatedButton.styleFrom(primary: Colors.blue),
              child: const Text('Email/Sifre Giris'),
            ),
            ElevatedButton(
              onPressed: () {
                signOutUser();
              },
              style: ElevatedButton.styleFrom(primary: Colors.yellow),
              child: const Text('Oturumu Kapat'),
            ),
            ElevatedButton(
              onPressed: () {
                deleteUser();
              },
              style: ElevatedButton.styleFrom(primary: Colors.purple),
              child: const Text('Kullanıcıyı sil'),
            ),
            ElevatedButton(
              onPressed: () {
                changePasword();
              },
              style: ElevatedButton.styleFrom(primary: Colors.brown),
              child: const Text('Parola Değiştir'),
            ),
            ElevatedButton(
              onPressed: () {
                changeEmail();
              },
              style: ElevatedButton.styleFrom(primary: Colors.pink),
              child: const Text('Email Değiştir'),
            ),
            ElevatedButton(
              onPressed: () {
                googleIleGiris();
              },
              style: ElevatedButton.styleFrom(primary: Colors.green),
              child: const Text('gmail ile giriş '),
            ),
            // ElevatedButton(
            //   onPressed: () {
            //     loginWithPhoneNumber();
            //   },
            //   style: ElevatedButton.styleFrom(primary: Colors.amber),
            //   child: const Text('Tel no ile giriş '),
            // ),
          ],
        ),
      ),
    );
  }

  ElevatedButton newMethod(void fonksiyon, Color renk, String text) {
    return ElevatedButton(
      onPressed: () {
        fonksiyon;
      },
      style: ElevatedButton.styleFrom(primary: renk),
      child: Text(text),
    );
  }

  Future<void> createUserEmailAndPassword() async {
    try {
      var _userCredential = await auth.createUserWithEmailAndPassword(
          email: _email, password: _password);
      var _myUser = await _userCredential.user;
      if (!_myUser!.emailVerified) {
        _myUser.sendEmailVerification();
      } else {
        debugPrint("kullanıcı maili onaylanmış");
      }
      debugPrint(_userCredential.toString());
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void loginUserEmailAndPassword() async {
    try {
      var _userCredential = await auth.signInWithEmailAndPassword(
          email: _email, password: _password);
      debugPrint(_userCredential.toString());
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void signOutUser() async {
    var _user = GoogleSignIn().currentUser;
    if (_user != null) {
      await GoogleSignIn().signOut();
    }

    await auth.signOut();
  }

  void deleteUser() async {
    try {
      if (auth.currentUser != null) {
        await auth.currentUser!.delete();
      } else {
        debugPrint("oturum acmadan silinemez");
      }
    } catch (e) {
      debugPrint(e.toString());
      debugPrint("oturum acmadan silinemez");
    }
  }

  void changePasword() async {
    try {
      await auth.currentUser!.updatePassword("password");
      await auth.signOut();
    } on Exception catch (e) {
      if (e.toString() == 'requires-recent-login') {
        debugPrint("reathentice olmalı ");
        var credential =
            EmailAuthProvider.credential(email: _email, password: _password);
        auth.currentUser!.reauthenticateWithCredential(credential);

        await auth.currentUser!.updatePassword("password");
        await auth.signOut();
        debugPrint("sifre degisti");
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void changeEmail() async {
    try {
      await auth.currentUser!.updateEmail("muhammetaydin1704@gmail.com");
      await auth.signOut();
    } on Exception catch (e) {
      if (e.toString() == 'requires-recent-login') {
        debugPrint("reathentice olmalı ");
        var credential =
            EmailAuthProvider.credential(email: _email, password: _password);
        auth.currentUser!.reauthenticateWithCredential(credential);

        await auth.currentUser!.updateEmail("muhammetaydin1704@gmail.com");
        await auth.signOut();
        debugPrint("mail degisti");
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void googleIleGiris() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    await auth.signInWithCredential(credential);
  }

  loginWithPhoneNumber() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+90 5553332211',
      verificationCompleted: (PhoneAuthCredential credential) async {
        debugPrint(credential.toString());
        await auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {},
      codeSent: (String verificationId, int? resendToken) {
        String _smsCode = "123456";
        debugPrint("code sent tetikledi");
        var _credential = PhoneAuthProvider.credential(
            verificationId: verificationId, smsCode: _smsCode);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }
}