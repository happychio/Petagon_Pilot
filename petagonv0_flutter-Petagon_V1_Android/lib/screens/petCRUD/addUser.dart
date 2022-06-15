// ignore_for_file: non_constant_identifier_names, prefer_typing_uninitialized_variables, avoid_print, deprecated_member_use, file_names
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:petagonv0_flutter/components/theme_help.dart';
import 'package:petagonv0_flutter/constraints.dart';
import 'package:petagonv0_flutter/screens/Auth/login.dart';
import 'package:petagonv0_flutter/screens/petCRUD/addPet.dart';
import 'package:petagonv0_flutter/services/global_methods';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({Key? key}) : super(key: key);
  @override
  _AddUserScreen createState() => _AddUserScreen();
}

class _AddUserScreen extends State<AddUserScreen> {
  final User user = FirebaseAuth.instance.currentUser!;
  final _UserformKey = GlobalKey<FormState>();
  File? image;
  String imageUrlUser = "";
  String userID = "";
  String email = "";
  bool hasInternet = false;
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final mobileNumber = TextEditingController();
  final address = TextEditingController();
  var _pickedImageUser;

  @override
  void initState() {
    super.initState();
    InternetConnectionChecker().onStatusChange.listen((status) {
      final hasInternet = status == InternetConnectionStatus.connected;

      setState(() {
        this.hasInternet = hasInternet;
        print(hasInternet);
        if (this.hasInternet == false) {
          createInternetDialog(context);
        }
      });
    });
  }

  Future<bool?> showWarning(BuildContext context) async => showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
            title: const Text(
                'User Account will not be saved, do you want to exit?'),
            actions: [
              ElevatedButton(
                  child: const Text('Yes'),
                  onPressed: () => Navigator.pop(context, true)),
              ElevatedButton(
                  child: const Text('No'),
                  onPressed: () => Navigator.pop(context, false)),
            ],
          ));

  Future createUser() async {
    if (firstName.text == "" ||
        lastName.text == "" ||
        mobileNumber.text == "" ||
        address.text == "") {
      GlobalMethod.showErrorDialog(
          error: 'Please complete all the requirements', ctx: context);
      return;
    } else if (_pickedImageUser == null) {
      GlobalMethod.showErrorDialog(
          error: ' Please pick an image', ctx: context);
      return;
    }
    try {
      final _uid = user.uid;
      final docOwner =
          FirebaseFirestore.instance.collection('Pet Owner').doc(_uid);
      final ref = FirebaseStorage.instance
          .ref()
          .child('ownerImages')
          .child(_uid + '.jpg');
      await ref.putFile(_pickedImageUser!);
      imageUrlUser = await ref.getDownloadURL();
      userID = _uid;
      email = user.email!;
      print("User Id: " + userID);
      print("User Doc Id: " + docOwner.id);
      print("User Email: " + email);
      print("User ImageUrl: " + imageUrlUser);

      final data = {
        'id': userID,
        'imageUrl': imageUrlUser,
        'firstName': firstName.text,
        'lastName': lastName.text,
        'email': email,
        'contactNumber': mobileNumber.text,
        'address': address.text
      };
      print("JSON " + data.entries.toString());
      docOwner.set(data);
      print("Successfully create user database");
    } catch (e) {
      print(e);
      print("error");
    }
  }

  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image == null) return;
      final imageTemporary = File(image.path);
      setState(() => this.image = imageTemporary);
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  void _pickImageCameraUser() async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(source: ImageSource.camera);
    final pickedImageFile = File(pickedImage!.path);
    setState(() {
      _pickedImageUser = pickedImageFile;
    });
    Navigator.pop(context);
  }

  void _pickImageGalleryUser() async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(source: ImageSource.gallery);
    final pickedImageFile = File(pickedImage!.path);
    setState(() {
      _pickedImageUser = pickedImageFile;
    });
    Navigator.pop(context);
  }

  void _removeImageUser() {
    setState(() {
      _pickedImageUser = null;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
          child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () async {
                  final shouldPop = await showWarning(context);
                  if (shouldPop == true) {
                    FirebaseAuth.instance.signOut();
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const LoginScreen()));
                  }
                },
                icon: const Icon(
                  Icons.logout,
                  color: Colors.black,
                ))
          ],
          backgroundColor: Colors.white,
          title: const Text(
            'Setting up Account',
            style: TextStyle(
                color: Colors.black, fontSize: 30, fontWeight: FontWeight.bold),
          ),
        ),
        body: Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: kPrimaryColor),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Form(
                key: _UserformKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Stack(
                        children: [
                          buildUserPictureContainer(),
                          buildUserAddPictureIcon()
                        ],
                      ),
                      const SizedBox(height: 30),
                      buildFirstNameField(),
                      const SizedBox(
                        height: 30,
                      ),
                      buildLastNameField(),
                      const SizedBox(height: 20.0),
                      buildMobileNumField(),
                      const SizedBox(height: 20.0),
                      buildAddressField(),
                      const SizedBox(height: 30.0),
                      buildButton(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      )),
    );
  }

  Row buildButton() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30))),
            onPressed: () {
              createUser();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddPetScreen()));
            },
            child: const Text(
              'SAVE',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30))),
            onPressed: () {
              firstName.clear();
              lastName.clear();
              mobileNumber.clear();
              address.clear();
            },
            child: const Text(
              'CLEAR',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Container buildAddressField() {
    return Container(
      child: TextFormField(
        controller: address,
        decoration: ThemeHelper()
            .textInputDecoration("Street Address", "Enter your local address"),
        validator: (val) {
          if ((val!.isNotEmpty) && !RegExp(r"^(\d+)*$").hasMatch(val)) {
            return "Enter a valid phone number";
          }
          return null;
        },
      ),
      decoration: ThemeHelper().inputBoxDecorationShaddow(),
    );
  }

  Container buildMobileNumField() {
    return Container(
      child: TextFormField(
        controller: mobileNumber,
        decoration: ThemeHelper()
            .textInputDecoration("Mobile Number", "Enter your mobile number"),
        validator: (val) {
          if ((val!.isNotEmpty) && !RegExp(r"^(\d+)*$").hasMatch(val)) {
            return "Enter a valid phone number";
          }
          return null;
        },
      ),
      decoration: ThemeHelper().inputBoxDecorationShaddow(),
    );
  }

  Container buildLastNameField() {
    return Container(
      child: TextFormField(
        controller: lastName,
        decoration: ThemeHelper()
            .textInputDecoration('Last Name', 'Enter your last name'),
      ),
      decoration: ThemeHelper().inputBoxDecorationShaddow(),
    );
  }

  Container buildFirstNameField() {
    return Container(
      child: TextFormField(
        controller: firstName,
        decoration: ThemeHelper()
            .textInputDecoration('First Name', 'Enter your first name'),
      ),
      decoration: ThemeHelper().inputBoxDecorationShaddow(),
    );
  }

  RawMaterialButton buildUserAddPictureIcon() {
    return RawMaterialButton(
      padding: const EdgeInsets.fromLTRB(85, 85, 0, 0),
      child: Icon(
        Icons.add_circle,
        color: Colors.grey.shade700,
        size: 35,
      ),
      onPressed: () {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text(
                  'Choose option',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, color: kPrimaryColor),
                ),
                content: SingleChildScrollView(
                  child: ListBody(children: [
                    InkWell(
                      onTap: _pickImageCameraUser,
                      splashColor: kPrimaryColor,
                      child: Row(
                        children: const [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.camera,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            'Camera',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.black),
                          )
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: _pickImageGalleryUser,
                      splashColor: kPrimaryColor,
                      child: Row(
                        children: const [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.image,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            'Gallery',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.black),
                          )
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: _removeImageUser,
                      splashColor: kPrimaryColor,
                      child: Row(
                        children: const [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.remove_circle,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            'Remove',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.black),
                          )
                        ],
                      ),
                    )
                  ]),
                ),
              );
            });
      },
    );
  }

  Container buildUserPictureContainer() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        border: Border.all(width: 5, color: Colors.white),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
              color: Colors.black12, blurRadius: 20, offset: Offset(5, 5)),
        ],
      ),
      child: CircleAvatar(
          radius: 55,
          backgroundColor: Colors.white,
          backgroundImage:
              _pickedImageUser == null ? null : FileImage(_pickedImageUser),
          child: _pickedImageUser == null
              ? Icon(
                  Icons.person,
                  color: Colors.grey.shade300,
                  size: 80.0,
                )
              : null),
    );
  }

  Widget createInternetDialog(BuildContext context) => CupertinoAlertDialog(
        title: const Text('Internet Connection Error',
            style: TextStyle(fontSize: 22)),
        content: const Text(
            'There is no internet connection available, please check your internet connection and try again',
            style: TextStyle(fontSize: 14)),
        actions: [
          CupertinoDialogAction(
            child: const Text('Close'),
            onPressed: () {
              if (Platform.isAndroid) {
                SystemNavigator.pop();
              } else {
                setState(() {
                  FirebaseAuth.instance.signOut();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const LoginScreen()));
                });
              }
            },
          ),
        ],
      );
}
