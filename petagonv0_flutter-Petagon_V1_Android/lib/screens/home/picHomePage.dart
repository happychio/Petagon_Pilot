// ignore_for_file: file_names, sized_box_for_whitespace, no_logic_in_create_state, avoid_print, avoid_unnecessary_containers, non_constant_identifier_names, unused_local_variable, prefer_typing_uninitialized_variables, deprecated_member_use
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:petagonv0_flutter/constraints.dart';
import 'package:petagonv0_flutter/model/owner.dart';
import 'package:petagonv0_flutter/model/pet.dart';
import 'package:petagonv0_flutter/model/pictures.dart';
import 'package:petagonv0_flutter/screens/Auth/login.dart';
import 'package:petagonv0_flutter/screens/home/petHomePage.dart';
import 'package:petagonv0_flutter/screens/petCRUD/petListPage.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:petagonv0_flutter/services/global_methods';
import 'package:uuid/uuid.dart';

// ignore: camel_case_types
class picHomePage extends StatefulWidget {
  final String petID;
  const picHomePage({Key? key, required this.petID}) : super(key: key);
  @override
  _PicHomePage createState() => _PicHomePage(petID);
}

class _PicHomePage extends State<picHomePage> with TickerProviderStateMixin {
  File? image;
  var _pickedImagePet;
  String imageUrlPet = "";
  String picID = "";
  final String petID;
  _PicHomePage(this.petID);
  final User user = FirebaseAuth.instance.currentUser!;
  int bottomNavBarIndex = 2;
  bool hasInternet = false;
  var uuidPic = const Uuid();

  @override
  void initState() {
    super.initState();
    InternetConnectionChecker().onStatusChange.listen((status) {
      final hasInternet = status == InternetConnectionStatus.connected;

      setState(() {
        this.hasInternet = hasInternet;
        print(hasInternet);
        if (this.hasInternet == false) {
          showCupertinoDialog(context: context, builder: createInternetDialog);
        }
      });
    });
  }

  Future createPic(Pictures pic) async {
    if (_pickedImagePet == null) {
      GlobalMethod.showErrorDialog(
          error: ' Please pick an image', ctx: context);
      return;
    }
    try {
      final ownerID = user.uid;
      final _uid = uuidPic.v4();
      final docPic =
          FirebaseFirestore.instance.collection('Pet Photos').doc(_uid);
      final ref = FirebaseStorage.instance
          .ref()
          .child('petImages')
          .child(_uid + '.jpg');
      await ref.putFile(_pickedImagePet!);
      imageUrlPet = await ref.getDownloadURL();
      // take too much time
      picID = docPic.id;
      pic.ownerID = ownerID;
      pic.id = picID;
      pic.petID = petID;
      pic.imageUrl = imageUrlPet;
      final json = pic.toJson();
      await docPic.set(json);
      print("Successfully create photo document");
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
    final widthScreen = MediaQuery.of(context).size.width;
    final heightScreen = MediaQuery.of(context).size.height;
    final isKeyboard = MediaQuery.of(context).viewInsets.bottom != 0;
    TabController _tabcontroller = TabController(length: 4, vsync: this);
    final items = <Widget>[
      const FaIcon(FontAwesomeIcons.bone, size: 28, color: Colors.orange),
      const FaIcon(
        FontAwesomeIcons.heartPulse,
        size: 28,
        color: Colors.red,
      ),
      const FaIcon(
        FontAwesomeIcons.houseChimney,
        size: 28,
        color: kPrimaryColor,
      ),
      const FaIcon(
        FontAwesomeIcons.moneyCheckDollar,
        size: 28,
        color: Colors.green,
      ),
      const FaIcon(FontAwesomeIcons.paw, size: 28, color: Colors.brown)
    ];
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        floatingActionButton: SpeedDial(
          backgroundColor: kPrimaryColor,
          child: const FaIcon(FontAwesomeIcons.dog),
          spaceBetweenChildren: 6,
          spacing: 6,
          overlayColor: kBackgroundColor,
          overlayOpacity: 0.4,
          children: [
            SpeedDialChild(
                child: const Icon(Icons.menu_book_rounded),
                label: 'Journal',
                backgroundColor: Colors.pink),
            SpeedDialChild(
                child: const FaIcon(FontAwesomeIcons.image),
                label: 'Picture',
                backgroundColor: Colors.orange),
            SpeedDialChild(
                child: const FaIcon(FontAwesomeIcons.folder),
                label: 'Document',
                backgroundColor: Colors.yellow),
            SpeedDialChild(
                child: const Icon(Icons.update),
                label: 'Update',
                backgroundColor: Colors.blue),
          ],
        ),
        extendBody: true,
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (context) => petHomePage(petID: petID))),
                icon: const Icon(
                  Icons.logout,
                  color: Colors.white,
                ))
          ],
          centerTitle: true,
          title: const Text(
            'Gallery',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30),
          ),
          backgroundColor: kPrimaryColor,
        ),
        drawer: NavigationDrawer(),
        body: StreamBuilder<List<Pet>>(
            stream: readPet(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                print(snapshot.error);
                return const Text('Something Went Wrong');
              } else if (snapshot.hasData) {
                final pets = snapshot.data!;
                return buildUpperUi(heightScreen, widthScreen, pets.first);
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            }),
        bottomNavigationBar: CurvedNavigationBar(
          backgroundColor: Colors.transparent,
          items: items,
          height: 60,
          index: bottomNavBarIndex,
          onTap: (bottomIndex) =>
              setState(() => bottomNavBarIndex = bottomIndex),
          animationDuration: const Duration(milliseconds: 500),
          animationCurve: Curves.easeInOut,
        ),
      ),
    );
  }

  Theme buildUpperUi(double heightScreen, double widthScreen, Pet pets) {
    bool isKeyboard = MediaQuery.of(context).viewInsets.bottom != 0;
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: const ColorScheme.light(primary: kPrimaryColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: widthScreen,
            height: heightScreen * 0.40,
            color: kBackgroundColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  children: [buildPictureContainer(), buildPetAddIcon()],
                ),
                const SizedBox(height: 20),
                buildSaveButton(),
              ],
            ),
          ),
          if (!isKeyboard)
            Container(
              height: heightScreen * 0.46,
              width: widthScreen,
              child: StreamBuilder<List<Pictures>>(
                  stream: readPic(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      print(snapshot.error);
                      return const Text('Something Went Wrong');
                    } else if (snapshot.hasData) {
                      final photos = snapshot.data!;
                      final photosLength = photos.length;
                      if (photos.isNotEmpty) {
                        return GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2),
                          itemCount: photosLength,
                          itemBuilder: (BuildContext context, int index) {
                            return GridTile(
                                child: Image(
                              image: NetworkImage(photos[index].imageUrl),
                              fit: BoxFit.cover,
                            ));
                          },
                        );
                      } else {
                        return const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 80),
                          child: Center(
                            child: Text(
                              'You have an empty gallery!   Save your first picture now',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      }
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  }),
            ),
        ],
      ),
    );
  }

  Row buildSaveButton() {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 100),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(40),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30))),
              onPressed: () {
                final pic = Pictures();
                createPic(pic);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => petHomePage(petID: petID)));
              },
              child: const Text(
                'SAVE',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }

  RawMaterialButton buildPetAddIcon() {
    return RawMaterialButton(
      padding: const EdgeInsets.fromLTRB(140, 140, 0, 0),
      child: Icon(
        Icons.add_circle,
        color: Colors.grey.shade700,
        size: 40,
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

  Container buildPictureContainer() {
    final widthScreen = MediaQuery.of(context).size.width;
    final heightScreen = MediaQuery.of(context).size.height;
    return Container(
      width: widthScreen * 0.50,
      height: heightScreen * 0.25,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(width: 5, color: Colors.white),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
              color: Colors.black12, blurRadius: 20, offset: Offset(5, 5)),
        ],
      ),
      child: ClipRRect(
          child: _pickedImagePet != null
              ? Image.file(
                  _pickedImagePet,
                  width: widthScreen * 0.50,
                  height: heightScreen * 0.25,
                )
              : Icon(
                  Icons.image,
                  color: Colors.grey.shade300,
                  size: 100.0,
                )),
    );
  }

  Stream<List<Pet>> readPet() {
    return FirebaseFirestore.instance.collection('Pets').snapshots().map(
        (snapshot) => snapshot.docs
            .where((QueryDocumentSnapshot<Object?> element) =>
                element['id'].toString().contains(petID))
            .map((doc) => Pet.fromJson(doc.data()))
            .toList());
  }

  Stream<List<Pictures>> readPic() {
    return FirebaseFirestore.instance.collection('Pet Photos').snapshots().map(
        (snapshot) => snapshot.docs
            .where((QueryDocumentSnapshot<Object?> element) =>
                element['petID'].toString().contains(petID))
            .map((doc) => Pictures.fromJson(doc.data()))
            .toList());
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

class NavigationDrawer extends StatelessWidget {
  final user = FirebaseAuth.instance.currentUser!;
  NavigationDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Drawer(
        child: SingleChildScrollView(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            buildHeader(context),
            buildMenuItems(context),
          ],
        )),
      ),
    );
  }

  Widget buildHeader(BuildContext context) {
    return StreamBuilder<List<Owner>>(
        stream: readUser(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error);
            return const Text('Something Went Wrong');
          } else if (snapshot.hasData) {
            final owner = snapshot.data!;
            return buildHeaderDetails(context, owner.first);
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }

  Material buildHeaderDetails(BuildContext context, Owner owner) {
    return Material(
      color: kPrimaryColor,
      child: InkWell(
        onTap: () {},
        child: Container(
          padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top, bottom: 24),
          child: Column(children: [
            const SizedBox(height: 25),
            CircleAvatar(
                radius: 60, backgroundImage: NetworkImage(owner.imageUrl)),
            const SizedBox(height: 10),
            Text('${owner.firstname} ${owner.lastname}',
                style: const TextStyle(
                    fontSize: 25,
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(owner.email,
                style: const TextStyle(fontSize: 16, color: Colors.white)),
          ]),
        ),
      ),
    );
  }

  Widget buildMenuItems(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(24),
        child: Wrap(
          runSpacing: 16,
          children: [
            ListTile(
              leading: const Icon(Icons.home_outlined),
              title: const Text('Home'),
              onTap: () =>
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => const petHomePage(
                            petID: '',
                          ))),
            ),
            ListTile(
              leading: const Icon(Icons.person_rounded),
              title: const Text('My Profile'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.pets),
              title: const Text('My Pets'),
              onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const PetListView())),
            ),
            ListTile(
              leading: const Icon(Icons.location_city),
              title: const Text('Visited Places'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {},
            ),
          ],
        ));
  }

  Stream<List<Owner>> readUser() {
    return FirebaseFirestore.instance.collection('Pet Owner').snapshots().map(
        (snapshot) => snapshot.docs
            .where((QueryDocumentSnapshot<Object?> element) =>
                element['id'].toString().contains(user.uid))
            .map((doc) => Owner.fromJson(doc.data()))
            .toList());
  }
}
