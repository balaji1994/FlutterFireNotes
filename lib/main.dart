import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/views/login_view.dart';
import 'package:mynotes/views/register_view.dart';
import 'package:mynotes/views/verify_email_view.dart';
import 'constants/router.dart';
import 'firebase_options.dart';
import 'dart:developer' as devtools; 

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const HomePageView(),
      routes: {
        loginRoute:(context) => const LoginView(),
        registerRoute:(context) => const RegisterView(),
        notesRoute:(context) => const NotesView()
      },
    )
  );
}

class HomePageView extends StatefulWidget {
  const HomePageView({super.key});

  @override
  State<HomePageView> createState() => _HomePageViewState();
}

class _HomePageViewState extends State<HomePageView> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Firebase.initializeApp(
                options: DefaultFirebaseOptions.currentPlatform,
              ),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              final user = FirebaseAuth.instance.currentUser;
              // final verificationMailSent = true;
              if (user != null)
              {
                if (user.emailVerified){
                  return const NotesView();
                  // return const LoginView();
                }else{
                  return const VerifyEmailView();
                }
              }
              else{
                return const LoginView();
              }
              
            default: 
              return const Text("Loading.....");
          }
        },
      );
  }
}

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}
enum MenuItem {logout}

class _NotesViewState extends State<NotesView> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Welcome to notes app"),
        actions: [
          PopupMenuButton<MenuItem>(
            onSelected: (value) async {
              switch (value){
                case MenuItem.logout:
                  final shouldLogout = await showLogoutDialog(context);
                  devtools.log(shouldLogout.toString());
                  if (shouldLogout){
                    await FirebaseAuth.instance.signOut();
                    Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (route) => false);
                  }
              }
            },
            itemBuilder: (context){
              return const [
                PopupMenuItem(value: MenuItem.logout, child: Text("Logout"))
              ];
            })
        ],
        ),
      body: Column(children: [
        const Text("Welcome to Notes app")
      ],)
    );
  }
}

Future<bool> showLogoutDialog(BuildContext context){
  return showDialog<bool>(context: context, builder: (context) {
    return  AlertDialog(
      title: const Text("Sign out"),
      content: const Text("Are you sure you want to log out?"),
      actions: [
        TextButton(onPressed: () {
          Navigator.of(context).pop(false);
        }, child: const Text("Cancel")),
        TextButton(onPressed: () {
          Navigator.of(context).pop(true);
        }, child: const Text("Log out"))
      ],
    );
  }).then((value) => value ?? false);
}