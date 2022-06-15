// ignore_for_file: avoid_print, deprecated_member_use, avoid_unnecessary_containers, prefer_typing_uninitialized_variables, non_constant_identifier_names, camel_case_types, file_names
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:petagonv0_flutter/components/theme_help.dart';
import 'package:petagonv0_flutter/constraints.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:petagonv0_flutter/screens/petCRUD/petListPage.dart';
import 'package:uuid/uuid.dart';
import 'package:petagonv0_flutter/services/global_methods';
import 'package:firebase_auth/firebase_auth.dart';

class addInfoScreen extends StatefulWidget {
  const addInfoScreen({Key? key}) : super(key: key);

  @override
  _addInfoScreen createState() => _addInfoScreen();
}

class _addInfoScreen extends State<addInfoScreen> {
  final User user = FirebaseAuth.instance.currentUser!;
  File? image;
  final _UserformKey = GlobalKey<FormState>();
  final _PetformKey = GlobalKey<FormState>();
  bool checkedValue = false;
  bool checkboxValue = false;
  bool isEditUser = true;
  int currentStep = 0;
  int customID = 0;
  String userID = "";
  String email = "";
  String petID = "";
  String imageUrlUser = "";
  String imageUrlPet = "";
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final mobileNumber = TextEditingController();
  final address = TextEditingController();
  final petName = TextEditingController();
  final petKind = TextEditingController();
  final petBreed = TextEditingController();
  final petDOB = TextEditingController();
  var _pickedImageUser;
  var _pickedImagePet;
  var uuidUser = const Uuid();
  var uuiPet = const Uuid();

  List<String> gender = ['Male', 'Female'];
  String? selectedGender = 'Male';

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

  Future createUser() async {
    if (firstName.text == "" ||
        lastName.text == "" ||
        mobileNumber.text == "" ||
        address.text == "") {
      GlobalMethod.showErrorDialog(
          error: 'Please complete all the requirements', ctx: context);
      setState(() => currentStep -= 1);
      return;
    } else if (_pickedImageUser == null) {
      GlobalMethod.showErrorDialog(
          error: ' Please pick an image', ctx: context);
      setState(() => currentStep -= 1);
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

  Future createPet(Pet pet) async {
    if (petName.text == "" ||
        petKind.text == "" ||
        petBreed.text == "" ||
        petDOB.text == "") {
      GlobalMethod.showErrorDialog(
          error: 'Please complete all the requirements', ctx: context);
      return;
    } else if (_pickedImagePet == null) {
      GlobalMethod.showErrorDialog(
          error: ' Please pick an image', ctx: context);
      return;
    }
    try {
      final ownerID = user.uid;
      final _uid = uuiPet.v4();
      final docPet = FirebaseFirestore.instance.collection('Pets').doc(_uid);
      final ref = FirebaseStorage.instance
          .ref()
          .child('petImages')
          .child(_uid + '.jpg');
      await ref.putFile(_pickedImagePet!);
      imageUrlPet = await ref.getDownloadURL();
      // take too much time
      petID = docPet.id;
      pet.id = petID;
      final userID = ownerID;
      print("Pet Id" + petID);
      pet.ownerID = userID;
      pet.imageUrl = imageUrlPet;
      final json = pet.toJson();
      await docPet.set(json);
      print(docPet.id);
      print("Successfully create pet database");
    } catch (e) {
      print(e);
      print("error");
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

  void _pickImageCameraPet() async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(source: ImageSource.camera);
    final pickedImageFile = File(pickedImage!.path);
    setState(() {
      _pickedImagePet = pickedImageFile;
    });
    Navigator.pop(context);
  }

  void _pickImageGalleryPet() async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(source: ImageSource.gallery);
    final pickedImageFile = File(pickedImage!.path);
    setState(() {
      _pickedImagePet = pickedImageFile;
    });
    Navigator.pop(context);
  }

  void _removeImagePet() {
    setState(() {
      _pickedImagePet = null;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SafeArea(
          child: Scaffold(
            backgroundColor: Colors.white,
            body: Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(primary: kPrimaryColor),
              ),
              child: buildStepper(),
            ),
          ),
        ));
  }

  Stepper buildStepper() {
    return Stepper(
      type: StepperType.horizontal,
      steps: getSteps(),
      currentStep: currentStep,
      onStepContinue: () {
        if (currentStep == 2) {
          createUser();
          final pet = Pet(
              petName: petName.text,
              petKind: petKind.text,
              petBreed: petBreed.text,
              petGender: selectedGender.toString(),
              petDOB: petDOB.text);
          createPet(pet);
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const PetListView()));
        } else {
          setState(() => currentStep += 1);
        }
      },
      onStepTapped: (step) => setState(() => currentStep = step),
      onStepCancel: () {
        if (isEditUser == true) {
          firstName.clear();
          lastName.clear();
          mobileNumber.clear();
          address.clear();
        } else {
          petName.clear();
          petKind.clear();
          petBreed.clear();
          selectedGender = 'Male';
          petDOB.clear();
        }
      },
      controlsBuilder: controlsBuilder,
    );
  }

  List<Step> getSteps() => [
        Step(
          state: currentStep > 0 ? StepState.complete : StepState.indexed,
          isActive: currentStep >= 0,
          title: const Text(
            'User',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          content: Container(
            margin: const EdgeInsets.symmetric(horizontal: 25),
            child: Center(
              child: Column(
                children: [buildUserForm()],
              ),
            ),
          ),
        ),
        Step(
          state: currentStep > 1 ? StepState.complete : StepState.indexed,
          isActive: currentStep >= 1,
          title: const Text(
            'Pet',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          content: Container(
            margin: const EdgeInsets.symmetric(horizontal: 25),
            child: Center(
              child: Column(
                children: [buildPetForm()],
              ),
            ),
          ),
        ),
        Step(
          state: currentStep > 2 ? StepState.complete : StepState.indexed,
          isActive: currentStep >= 2,
          title: const Text(
            'Complete',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          content: buildCompleteStep(),
        ),
      ];

  Form buildPetForm() {
    return Form(
      key: _PetformKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [buildPetPictureContainer(), buildPetAddIcon()],
            ),
            const SizedBox(height: 30),
            buildPetNameField(),
            const SizedBox(
              height: 30,
            ),
            buildPetKindField(),
            const SizedBox(height: 20.0),
            buildPetBreedField(),
            const SizedBox(height: 20.0),
            buildPetGenderDropdown(),
            const SizedBox(height: 20.0),
            buildPetDateOfBirthField(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Container buildCompleteStep() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        // ignore: prefer_const_literals_to_create_immutables
        children: [
          const SizedBox(
            height: 80,
          ),
          const Image(
            image: AssetImage('assets/images/success.gif'),
            height: 200.0,
          ),
          const Padding(
            padding: EdgeInsets.only(top: 20),
            child: Text(
              'Successful',
              style: TextStyle(
                  color: kPrimaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 30),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          const Text(
            'your information was saved successfully',
            style: TextStyle(
                color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 40,
          ),
        ],
      ),
    );
  }

  Container buildPetDateOfBirthField() {
    return Container(
      child: TextFormField(
        controller: petDOB,
        decoration:
            ThemeHelper().textInputDecoration("Date of Birth", "mm/dd/yyyy"),
        keyboardType: TextInputType.emailAddress,
        validator: (val) {
          if ((val!.isNotEmpty) &&
              !RegExp(r"^(?:(?:31(\/|-|\.)(?:0?[13578]|1[02]|(?:Jan|Mar|May|Jul|Aug|Oct|Dec)))\1|(?:(?:29|30)(\/|-|\.)(?:0?[1,3-9]|1[0-2]|(?:Jan|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec))\2))(?:(?:1[6-9]|[2-9]\d)?\d{2})$|^(?:29(\/|-|\.)(?:0?2|(?:Feb))\3(?:(?:(?:1[6-9]|[2-9]\d)?(?:0[48]|[2468][048]|[13579][26])|(?:(?:16|[2468][048]|[3579][26])00))))$|^(?:0?[1-9]|1\d|2[0-8])(\/|-|\.)(?:(?:0?[1-9]|(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep))|(?:1[0-2]|(?:Oct|Nov|Dec)))\4(?:(?:1[6-9]|[2-9]\d)?\d{2})$")
                  .hasMatch(val)) {
            return "Enter a valid date";
          }
          return null;
        },
      ),
      decoration: ThemeHelper().inputBoxDecorationShaddow(),
    );
  }

  Container buildPetGenderDropdown() {
    return Container(
        child: DropdownButtonFormField<String>(
      value: selectedGender,
      items: gender
          .map((item) => DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                ),
              ))
          .toList(),
      onChanged: (gender) => setState((() => selectedGender = gender)),
      decoration: InputDecoration(
          contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(100),
              borderSide: const BorderSide(color: Colors.grey))),
    ));
  }

  Container buildPetBreedField() {
    return Container(
      child: TextFormField(
        controller: petBreed,
        decoration:
            ThemeHelper().textInputDecoration("Breed", "Enter your Pets breed"),
        keyboardType: TextInputType.emailAddress,
      ),
      decoration: ThemeHelper().inputBoxDecorationShaddow(),
    );
  }

  Container buildPetKindField() {
    return Container(
      child: TextFormField(
        controller: petKind,
        decoration: ThemeHelper().textInputDecoration(
            'Kind of Pet', 'Enter your Pets Classification'),
      ),
      decoration: ThemeHelper().inputBoxDecorationShaddow(),
    );
  }

  Container buildPetNameField() {
    return Container(
      child: TextFormField(
        controller: petName,
        decoration: ThemeHelper()
            .textInputDecoration('Pet Name', 'Enter your Pet\'s name'),
      ),
      decoration: ThemeHelper().inputBoxDecorationShaddow(),
    );
  }

  RawMaterialButton buildPetAddIcon() {
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
                      onTap: _pickImageCameraPet,
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
                      onTap: _pickImageGalleryPet,
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
                      onTap: _removeImagePet,
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

  Container buildPetPictureContainer() {
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
              _pickedImagePet == null ? null : FileImage(_pickedImagePet),
          child: _pickedImagePet == null
              ? Icon(
                  Icons.person,
                  color: Colors.grey.shade300,
                  size: 80.0,
                )
              : null),
    );
  }

  Form buildUserForm() {
    return Form(
      key: _UserformKey,
      child: SingleChildScrollView(
        child: Column(
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
          ],
        ),
      ),
    );
  }

  Container buildAddressField() {
    return Container(
      child: TextFormField(
        controller: address,
        decoration: ThemeHelper()
            .textInputDecoration("Street Address", "Enter your local address"),
        keyboardType: TextInputType.streetAddress,
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
        keyboardType: TextInputType.phone,
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
        keyboardType: TextInputType.name,
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
        maxLines: 1,
        controller: firstName,
        keyboardType: TextInputType.name,
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

  Widget controlsBuilder(
      BuildContext context, ControlsDetails controlsDetails) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: Row(
        children: [
          if (currentStep == 2)
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30))),
                onPressed: controlsDetails.onStepContinue,
                child: const Text(
                  'PROCEED',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            )
          else
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30))),
                onPressed: controlsDetails.onStepContinue,
                child: const Text(
                  'Next',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          const SizedBox(width: 20),
          if (currentStep < 2)
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30))),
                onPressed: controlsDetails.onStepCancel,
                child: const Text(
                  'CLEAR',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class Owner {
  String id;
  String imageUrl;
  String email;
  final String firstname;
  final String lastname;
  final String mobile;
  final String address;

  Owner({
    this.id = '',
    this.imageUrl = '',
    this.email = '',
    required this.firstname,
    required this.lastname,
    required this.mobile,
    required this.address,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'imageUrl': imageUrl,
        'firstName': firstname,
        'lastName': lastname,
        'email': email,
        'contactNumber': mobile,
        'address': address
      };
}

class Pet {
  String id;
  String ownerID;
  String imageUrl;
  final String petName;
  final String petKind;
  final String petBreed;
  final String petGender;
  final String petDOB;

  Pet({
    this.id = '',
    this.ownerID = '',
    this.imageUrl = '',
    required this.petName,
    required this.petKind,
    required this.petBreed,
    required this.petGender,
    required this.petDOB,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'ownerID': ownerID,
        'imageUrl': imageUrl,
        'Name': petName,
        'Kind': petKind,
        'Breed': petBreed,
        'Gender': petGender,
        'DateOfBirth': petDOB
      };
}
