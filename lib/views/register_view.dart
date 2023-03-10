import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/constants/router.dart';
import 'dart:developer' as devtools;
import '../firebase_options.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  
  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: FutureBuilder(
        future: Firebase.initializeApp(
                options: DefaultFirebaseOptions.currentPlatform,
              ),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return Column(
                  children: [
                    TextField(
                      controller: _email,
                      enableSuggestions: false,
                      autocorrect: false,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: "Enter your email here"
                      ),
                    ),
                    TextField(
                      controller: _password,
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        hintText: "Enter your password here"
                      ),
                    ),
                    TextButton(onPressed: () async {
                      final email = _email.text;
                      final password = _password.text;
                      try{
                        final userCredential = 
                          await FirebaseAuth.instance.createUserWithEmailAndPassword(
                            email: email,
                            password: password
                          );

                        devtools.log(userCredential.toString());
                      } on FirebaseAuthException catch(e){
                        if (e.code == "weak-password"){
                          devtools.log("Weak password");
                        }
                        else if (e.code == "email-already-in-use"){
                          devtools.log("Email you provided already exists");
                        }
                        else if (e.code == "invalid-email"){
                          devtools.log("Provide valid email");
                        }
                        else{
                          devtools.log(e.toString());
                        }
                      }
                    }, child: const Text("Register")),
                    TextButton(onPressed: () {
                      Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (route) => false);
                    }, child: const Text("Already an user? Login"))
                  ],
                );
            default: 
              return const Text("Loading.....");
          }
        },
      )
    );
  }
}