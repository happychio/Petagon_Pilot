import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:petagonv0_flutter/components/input_container.dart';
import 'package:petagonv0_flutter/components/rounded_username_input.dart';
import 'package:petagonv0_flutter/components/utils.dart';
import 'package:petagonv0_flutter/constraints.dart';
import 'package:petagonv0_flutter/main.dart';
import 'package:petagonv0_flutter/screens/Auth/Register.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Future<bool?> showWarning(BuildContext context) async => showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
            title: const Text('Do you want to exit the application?'),
            actions: [
              ElevatedButton(
                  child: const Text('Yes'),
                  onPressed: () => Navigator.pop(context, true)),
              ElevatedButton(
                  child: const Text('No'),
                  onPressed: () => Navigator.pop(context, false)),
            ],
          ));
  bool isLogin = true;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscuredText = true;
  Color obscuredIconColor = Colors.grey;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    double defaultLoginSize = size.height - (size.height * 0.2);
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          final shouldPop = await showWarning(context);
          return shouldPop ?? false;
        },
        child: Scaffold(
          body: Center(
            child: SingleChildScrollView(
              reverse: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  buildLogo(),
                  const SizedBox(height: 15),
                  text_title(),
                  const SizedBox(height: 20),
                  RoundedInput(
                    icon: Icons.mail,
                    hint: 'Username',
                    controller: emailController,
                  ),
                  passwordField(),
                  const SizedBox(height: 10),
                  loginButton(size),
                  richText_Register(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Container richText_Register(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 20, 10, 20),
      //child: Text('Don\'t have an account? Create'),
      child: Text.rich(TextSpan(children: [
        const TextSpan(
            text: "Don't have an account? ",
            style: TextStyle(fontWeight: FontWeight.w500)),
        TextSpan(
          text: 'Create',
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => RegisterScreen()));
            },
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: kPrimaryColor),
        ),
      ])),
    );
  }

  Text text_title() {
    return const Text(
      'Petagon',
      style: TextStyle(
          fontWeight: FontWeight.bold, fontSize: 40, color: kPrimaryColor),
    );
  }

  InkWell loginButton(Size size) {
    return InkWell(
      onTap: signIn,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: size.width * 0.8,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: kPrimaryColor,
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        alignment: Alignment.center,
        child: const Text(
          'LOGIN',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }

  InputContainer passwordField() {
    return InputContainer(
        child: TextField(
      controller: passwordController,
      cursorColor: kPrimaryColor,
      obscureText: obscuredText,
      decoration: InputDecoration(
          prefixIcon: const Icon(Icons.lock, color: kPrimaryColor),
          hintText: 'Password',
          border: InputBorder.none,
          suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                if (obscuredText == true) {
                  obscuredText = !obscuredText;
                  obscuredIconColor = kPrimaryColor;
                } else {
                  obscuredText = !obscuredText;
                  obscuredIconColor = Colors.grey;
                }
              });
            },
            icon: Icon(
              Icons.visibility_off,
              color: obscuredIconColor,
            ),
          )),
    ));
  }

  Image buildLogo() {
    return Image.asset('assets/images/pLogo4x4.png',
        width: 220, height: 220, fit: BoxFit.cover);
  }

  Future signIn() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) =>
          const Center(child: CircularProgressIndicator()),
    );
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim());
    } on FirebaseAuthException catch (e) {
      utils.showSnackBar(e.message);
    }

    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }
}
