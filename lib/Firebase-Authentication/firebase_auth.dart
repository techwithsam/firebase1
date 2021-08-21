import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_class/Firebase-Authentication/firebase_services.dart';
import 'package:firebase_class/homepage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class FirebaseAuthentication extends StatefulWidget {
  FirebaseAuthentication({Key? key}) : super(key: key);

  @override
  _FirebaseAuthenticationState createState() => _FirebaseAuthenticationState();
}

class _FirebaseAuthenticationState extends State<FirebaseAuthentication> {
  final _formKey = GlobalKey<FormState>();
  FirebaseService service = FirebaseService();
  DatabaseReference db = FirebaseDatabase.instance.reference().child("Users");
  TextEditingController? _fname, _email, _password;
  bool isLoading = false, btnLoad = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Firebase Authentication')),
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 22, 12, 22),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFieldd(_fname, 'Full name'),
                  SizedBox(height: 10),
                  TextFieldd(_email, 'Email'),
                  SizedBox(height: 10),
                  TextFieldd(_password, 'Password'),
                  SizedBox(height: 10),
                  !btnLoad
                      ? TextButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                btnLoad = true;
                              });
                              try {
                                await FirebaseAuth.instance
                                    .createUserWithEmailAndPassword(
                                        email: _email!.text,
                                        password: _password!.text)
                                    .then((value) {
                                  db.child(value.user!.uid).set({
                                    "uid": value.user!.uid,
                                    "email": _email!.text,
                                    "fname": _fname!.text,
                                  }).then((res) {
                                    btnLoad = false;
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => HomePage()),
                                    );
                                  });
                                });
                              } on FirebaseAuthException catch (e) {
                                if (e.code == 'email-already-in-use') {
                                  snackBar(
                                      'The email address is already in use by another account.');
                                  print(e.message);
                                }
                              }
                              setState(() {
                                btnLoad = false;
                              });
                            }
                          },
                          child: Text('Sign up | email & password.'))
                      : Center(
                          child: SizedBox(
                            height: 30,
                            width: 30,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                            ),
                          ),
                        ),
                  SizedBox(height: 12),
                  !isLoading
                      ? TextButton(
                          onPressed: () async {
                            setState(() {
                              isLoading = true;
                            });
                            try {
                              await service.signInwithGoogle();
                              print(
                                  'Sign with Google completed - navigate to home screen');
                            } catch (e) {
                              if (e is FirebaseAuthException) {
                                print(e.message!);
                              } else
                                print('$e');
                            }
                            setState(() {
                              isLoading = false;
                            });
                          },
                          child: Text('Sign in with google'),
                        )
                      : SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  snackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('$msg'),
      action: SnackBarAction(label: 'Close', onPressed: () {}),
    ));
  }

  @override
  void initState() {
    super.initState();
    _fname = TextEditingController();
    _email = TextEditingController();
    _password = TextEditingController();
  }

  @override
  void dispose() {
    _fname!.dispose();
    _email!.dispose();
    _password!.dispose();
    super.dispose();
  }
}

class TextFieldd extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  const TextFieldd(this.controller, this.label);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {
        if (value!.isEmpty)
          return 'Empty field detected';
        else
          return null;
      },
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(5, 8, 10, 5),
        isDense: true,
        labelText: '$label',
      ),
    );
  }
}
