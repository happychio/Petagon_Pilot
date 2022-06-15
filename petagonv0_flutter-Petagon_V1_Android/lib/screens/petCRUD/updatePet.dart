// ignore_for_file: non_constant_identifier_names, avoid_print, deprecated_member_use, avoid_unnecessary_containers, prefer_typing_uninitialized_variables, file_names, no_logic_in_create_state
import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cupertino_datetime_picker/flutter_cupertino_datetime_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';
import 'package:petagonv0_flutter/components/theme_help.dart';
import 'package:petagonv0_flutter/constraints.dart';
import 'package:petagonv0_flutter/model/pet.dart';
import 'package:petagonv0_flutter/screens/Auth/login.dart';
import 'package:petagonv0_flutter/screens/petCRUD/petListPage.dart';
import 'package:petagonv0_flutter/services/global_methods';
import 'package:uuid/uuid.dart';

class UpdatePetScreen extends StatefulWidget {
  final String petCurrentID;
  const UpdatePetScreen({Key? key, required this.petCurrentID})
      : super(key: key);
  @override
  _UpdatePetScreen createState() => _UpdatePetScreen(petCurrentID);
}

class _UpdatePetScreen extends State<UpdatePetScreen> {
  final User user = FirebaseAuth.instance.currentUser!;
  final _PetformKey = GlobalKey<FormState>();
  File? image;
  String imageUrlPet = "";
  String birthDate = "";
  int age = -1;
  final String petCurrentID;
  _UpdatePetScreen(this.petCurrentID);
  final _petNameTEC = TextEditingController();
  final _petKindTEC = TextEditingController();
  final _petBreedTEC = TextEditingController();
  var _petDOBTEC = TextEditingController();
  String petName = "";
  String petKind = "";
  String petBreed = "";
  String petDOB = "";
  var _pickedImagePet;
  bool hasInternet = false;
  var uuiPet = const Uuid();
  List<String> gender = ['Male', 'Female'];
  String? selectedGender = '';

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
                'Previous changes will not be save, do you want to exit?'),
            actions: [
              ElevatedButton(
                  child: const Text('Yes'),
                  onPressed: () => Navigator.pop(context, true)),
              ElevatedButton(
                  child: const Text('No'),
                  onPressed: () => Navigator.pop(context, false)),
            ],
          ));

  Future createPet(Pet pet) async {
    if (petName == "" || petKind == "" || petBreed == "" || petDOB == "") {
      print('Please complete all the requirements');
      GlobalMethod.showErrorDialog(
          error: 'Please complete all the requirements', ctx: context);
      return;
    } else if (_pickedImagePet == null) {
      try {
        final ownerID = user.uid;
        final docPet =
            FirebaseFirestore.instance.collection('Pets').doc(petCurrentID);
        pet.id = petCurrentID;
        final userID = ownerID;
        print("Pet Id" + petCurrentID);
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
      return;
    }
    try {
      final ownerID = user.uid;
      final _uid = uuiPet.v4();
      final docPet =
          FirebaseFirestore.instance.collection('Pets').doc(petCurrentID);
      final ref = FirebaseStorage.instance
          .ref()
          .child('petImages')
          .child(_uid + '.jpg');
      await ref.putFile(_pickedImagePet!);
      imageUrlPet = await ref.getDownloadURL();
      // take too much time
      pet.id = petCurrentID;
      final userID = ownerID;
      print("Pet Id" + petCurrentID);
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
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () async {
                  final shouldPop = await showWarning(context);
                  if (shouldPop == true) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const PetListView()));
                  }
                },
                icon: const Icon(
                  Icons.logout,
                  color: Colors.black,
                ))
          ],
          backgroundColor: Colors.white,
          title: const Text(
            'Update Pet',
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
                key: _PetformKey,
                child: SingleChildScrollView(
                  child: StreamBuilder<List<Pet>>(
                      stream: readPet(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          print(snapshot.error);
                          return const Text('Something Went Wrong');
                        } else if (snapshot.hasData) {
                          final pets = snapshot.data!;

                          return buildBody(pets.first);
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      }),
                ),
              ),
            ),
          ),
        ),
      )),
    );
  }

  Column buildBody(Pet pets) {
    return Column(
      children: [
        Stack(
          children: [buildPetPictureContainer(pets), buildPetAddIcon()],
        ),
        const SizedBox(height: 30),
        buildPetNameField(pets),
        const SizedBox(
          height: 30,
        ),
        buildPetKindField(pets),
        const SizedBox(height: 20.0),
        buildPetBreedField(pets),
        const SizedBox(height: 20.0),
        buildPetGenderDropdown(pets),
        const SizedBox(height: 20.0),
        buildPetDateOfBirthField(pets),
        const SizedBox(height: 30.0),
        buildButton(pets),
      ],
    );
  }

  Row buildButton(Pet pet) {
    final currentPetName = pet.petName;
    final currentPetBreed = pet.petBreed;
    final currentPetKind = pet.petKind;
    final currentPetDOB = pet.petDOB;
    imageUrlPet = pet.imageUrl;
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30))),
            onPressed: () {
              final pet = Pet(
                  petName: _petNameTEC.text == ""
                      ? currentPetName
                      : _petNameTEC.text,
                  petKind: _petKindTEC.text == ""
                      ? currentPetKind
                      : _petKindTEC.text,
                  petBreed: _petBreedTEC.text == ""
                      ? currentPetBreed
                      : _petBreedTEC.text,
                  petGender: selectedGender.toString(),
                  petDOB:
                      _petDOBTEC.text == "" ? currentPetDOB : _petDOBTEC.text);
              createPet(pet);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const PetListView()));
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
              _petBreedTEC.clear();
              _petDOBTEC.clear();
              _petKindTEC.clear();
              selectedGender = 'Male';
              _petNameTEC.clear();
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

  Container buildPetDateOfBirthField(Pet pet) {
    petDOB = pet.petDOB;
    return Container(
      child: TextFormField(
        onTap: () async {
          DateTime birthDate = await selectDate(context, DateTime.now(),
              lastDate: DateTime.now());
          this.birthDate = DateFormat('dd-MM-yyyy').format(birthDate);
          age = calculateAge(birthDate);
          setState(() {
            print(this.birthDate);
            _petDOBTEC = TextEditingController()..text = this.birthDate;
          });
        },
        controller: _petDOBTEC,
        decoration: ThemeHelper().textInputDecoration2(petDOB, "Date of Birth"),
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
    );
  }

  Container buildPetGenderDropdown(Pet pet) {
    selectedGender = pet.petGender;
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

  Container buildPetBreedField(Pet pet) {
    petBreed = pet.petBreed;
    return Container(
      child: TextFormField(
        controller: _petBreedTEC,
        decoration: ThemeHelper().textInputDecoration2(
          petBreed,
          "Breed",
        ),
        keyboardType: TextInputType.emailAddress,
      ),
    );
  }

  Container buildPetKindField(Pet pet) {
    petKind = pet.petKind;
    return Container(
      child: TextFormField(
        controller: _petKindTEC,
        decoration: ThemeHelper().textInputDecoration2(petKind, 'Kind of Pet'),
      ),
    );
  }

  Container buildPetNameField(Pet pet) {
    petName = pet.petName;
    return Container(
      child: TextFormField(
        controller: _petNameTEC,
        decoration: ThemeHelper().textInputDecoration2(petName, 'Pet Name'),
      ),
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

  Container buildPetPictureContainer(Pet pets) {
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
          backgroundImage: _pickedImagePet == null
              ? NetworkImage(pets.imageUrl) as ImageProvider
              : FileImage(_pickedImagePet),
          child: null),
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
  Stream<List<Pet>> readPet() {
    return FirebaseFirestore.instance.collection('Pets').snapshots().map(
        (snapshot) => snapshot.docs
            .where((QueryDocumentSnapshot<Object?> element) =>
                element['id'].toString().contains(petCurrentID))
            .map((doc) => Pet.fromJson(doc.data()))
            .toList());
  }

  calculateAge(DateTime birthDate) {
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;
    int month1 = currentDate.month;
    int month2 = birthDate.month;
    if (month2 > month1) {
      age--;
    } else if (month1 == month2) {
      int day1 = currentDate.day;
      int day2 = birthDate.day;
      if (day2 > day1) {
        age--;
      }
    }
    return age;
  }

  selectDate(BuildContext context, DateTime initialDateTime,
      {DateTime? lastDate}) async {
    Completer completer = Completer();
    if (Platform.isAndroid) {
      showDatePicker(
              context: context,
              initialDate: initialDateTime,
              firstDate: DateTime(1970),
              // ignore: prefer_if_null_operators
              lastDate: lastDate == null
                  ? DateTime(initialDateTime.year + 10)
                  : lastDate)
          .then((temp) {
        if (temp == null) return null;
        completer.complete(temp);
        setState(() {});
      });
    } else {
      DatePicker.showDatePicker(
        context,
        dateFormat: 'yyyy-mmm-dd',
        onConfirm: (temp, selectedIndex) {
          // ignore: unnecessary_null_comparison
          if (temp == null) {
            return null;
          }
          completer.complete(temp);

          setState(() {});
        },
      );
    }
    return completer.future;
  }
}
