import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:petagonv0_flutter/constraints.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petagonv0_flutter/screens/Auth/addInfo.dart';
import 'package:petagonv0_flutter/screens/Auth/components/google_sign_in.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:petagonv0_flutter/screens/Auth/login.dart';
import 'package:petagonv0_flutter/screens/petCRUD/petHomePage.dart';
import 'package:petagonv0_flutter/screens/petCRUD/petListPage.dart';
import 'package:provider/provider.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

final messengerKey = GlobalKey<ScaffoldMessengerState>();
final navigatorKey = GlobalKey<NavigatorState>();
bool newUser = true;

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GoogleSignInProvider(),
      child: MaterialApp(
        scaffoldMessengerKey: messengerKey,
        navigatorKey: navigatorKey,
        title: 'Petagon',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            primaryColor: kPrimaryColor,
            textTheme:
                GoogleFonts.robotoTextTheme(Theme.of(context).textTheme)),
        home: MainPage(),
      ),
    );
  }
}

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Something Went Wrong'));
          } else if (snapshot.hasData) {
            if (newUser == true) {
              return const PetListView();
            } else {
              return addInfoScreen();
            }
          } else {
            return LoginScreen();
          }
        },
      ),
    );
  }
}
