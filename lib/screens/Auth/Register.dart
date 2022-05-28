import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:petagonv0_flutter/components/input_container.dart';
import 'package:petagonv0_flutter/components/rounded_username_input.dart';
import 'package:petagonv0_flutter/components/signup_divider.dart';
import 'package:petagonv0_flutter/constraints.dart';
import 'package:petagonv0_flutter/main.dart';
import 'package:petagonv0_flutter/screens/Auth/login.dart';
import 'package:provider/provider.dart';
import 'package:petagonv0_flutter/components/utils.dart';
import 'components/google_sign_in.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final regEmailController = TextEditingController();
  final regPassworController = TextEditingController();
  final regConfirmPasswordController = TextEditingController();
  bool regPassobscuredText = true;
  bool regConfirmPassobscuredText = true;
  Color regPassobscuredIconColor = Colors.grey;
  Color regConfirmPassobscuredIconColor = Colors.grey;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        backgroundColor: kBackgroundColor,
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildHeader(),
                const SizedBox(height: 10),
                buildSubheading(),
                const SizedBox(height: 20),
                RoundedInput(
                  icon: Icons.mail,
                  hint: 'Email',
                  controller: regEmailController,
                ),
                buildPasswordField(),
                buildConfirmPasswordField(),
                const SizedBox(height: 20),
                buildSignUpButton(size),
                const SizedBox(height: 20),
                build_RichText_Login(context),
                const SizedBox(height: 10),
                OrDivider(),
                /*          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                SocalIcon(
                                  iconSrc: "assets/facebook.svg",
                                  press: () {},
                                ),
                                SocalIcon(
                                  iconSrc: "assets/twitter.svg",
                                  press: () {},
                                ),
                                SocalIcon(
                                  iconSrc: "assets/google-plus.svg",
                                  press: () {
                                    final provider =
                                        Provider.of<GoogleSignInProvider>(context,
                                            listen: false);
                                    provider.googleLogin();
                                  },
                                ),
                              ],
                            ) */
                const SizedBox(height: 10),
                buildSignUpGoogle(context)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container buildSignUpGoogle(BuildContext context) {
    newUser = false;
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          primary: Colors.white,
          onPrimary: Colors.black,
          minimumSize: const Size(double.infinity, 50),
        ),
        icon: const FaIcon(
          FontAwesomeIcons.google,
          color: Colors.red,
        ),
        label: const Text('Sign Up with Google'),
        onPressed: () {
          setState(() {
            final provider =
                Provider.of<GoogleSignInProvider>(context, listen: false);
            provider.googleLogin();
            navigatorKey.currentState!.popUntil((route) => route.isFirst);
          });
        },
      ),
    );
  }

  RichText build_RichText_Login(BuildContext context) {
    return RichText(
      text: TextSpan(
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.normal,
            fontSize: 17,
          ),
          text: 'Already have an account? ',
          children: [
            TextSpan(
                recognizer: TapGestureRecognizer()
                  ..onTap = (() {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()));
                  }),
                text: 'Log In',
                style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 17,
                    decoration: TextDecoration.underline,
                    color: kPrimaryColor)),
          ]),
    );
  }

  InkWell buildSignUpButton(Size size) {
    return InkWell(
      onTap: signUp,
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
          'SIGN UP',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }

  InputContainer buildConfirmPasswordField() {
    return InputContainer(
        child: TextField(
      controller: regConfirmPasswordController,
      cursorColor: kPrimaryColor,
      obscureText: regConfirmPassobscuredText,
      decoration: InputDecoration(
          prefixIcon: const Icon(
            Icons.lock,
            color: kPrimaryColor,
          ),
          hintText: 'Confirm Password',
          border: InputBorder.none,
          suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                if (regConfirmPassobscuredText == true) {
                  regConfirmPassobscuredText = !regConfirmPassobscuredText;
                  regConfirmPassobscuredIconColor = kPrimaryColor;
                } else {
                  regConfirmPassobscuredText = !regConfirmPassobscuredText;
                  regConfirmPassobscuredIconColor = Colors.grey;
                }
              });
            },
            icon: Icon(
              Icons.visibility_off,
              color: regConfirmPassobscuredIconColor,
            ),
          )),
    ));
  }

  InputContainer buildPasswordField() {
    return InputContainer(
        child: TextField(
      controller: regPassworController,
      cursorColor: kPrimaryColor,
      obscureText: regPassobscuredText,
      decoration: InputDecoration(
          prefixIcon: const Icon(Icons.lock, color: kPrimaryColor),
          hintText: 'Password',
          border: InputBorder.none,
          suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                if (regPassobscuredText == true) {
                  regPassobscuredText = !regPassobscuredText;
                  regPassobscuredIconColor = kPrimaryColor;
                } else {
                  regPassobscuredText = !regPassobscuredText;
                  regPassobscuredIconColor = Colors.grey;
                }
              });
            },
            icon: Icon(
              Icons.visibility_off,
              color: regPassobscuredIconColor,
            ),
          )),
    ));
  }

  Text buildSubheading() {
    return const Text(
      'Create an Account, its free',
      style: TextStyle(fontWeight: FontWeight.normal, fontSize: 20),
    );
  }

  Text buildHeader() {
    return const Text(
      'Welcome',
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35),
    );
  }

  Future signUp() async {
    newUser = false;
    if (regPassworController.text.trim() ==
        regConfirmPasswordController.text.trim()) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) =>
            const Center(child: CircularProgressIndicator()),
      );
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: regEmailController.text.trim(),
            password: regPassworController.text.trim());
      } on FirebaseAuthException catch (e) {
        utils.showSnackBar(e.message);
      }
      navigatorKey.currentState!.popUntil((route) => route.isFirst);
    } else {
      utils.showSnackBar('Passwords Don\'t Match');
    }
  }
}
