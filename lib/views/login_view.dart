import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/constants/router.dart';
import 'package:mynotes/views/register_view.dart';
import "dart:developer" as devtools;
import '../firebase_options.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
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
      appBar: AppBar(title: const Text("Login")),
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
                          await FirebaseAuth.instance.signInWithEmailAndPassword(
                            email: email,
                            password: password
                          );
                        Navigator.of(context).pushNamedAndRemoveUntil(notesRoute, (route) => false);
                      } on FirebaseAuthException catch(e){
                        if(e.code == "user-not-found"){
                          await showErrorDialog(context, "User name is incorrect");
                        }
                        else if (e.code == "wrong-password"){
                          await showErrorDialog(context, "Wrong Password");
                        }
                        devtools.log(e.toString());
                        
                      }
                    }, child: const Text("Login")),
                    TextButton(onPressed: () {
                      // Navigator.of(context).push(MaterialPageRoute(builder: (context)=> const RegisterView()));
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        registerRoute, (route) => false);
                    }, child: const Text("Not an user yet? Register here"))
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

Future<void> showErrorDialog(BuildContext context, String text){
  return showDialog(context: context, builder: (context) {
    return AlertDialog(
    title: const Text("Oops!"),
    content: Text(text),
    actions: [
      TextButton(onPressed: () {
        Navigator.of(context).pop();
      }, child: const Text("Ok"))
    ],
  );
  });
}