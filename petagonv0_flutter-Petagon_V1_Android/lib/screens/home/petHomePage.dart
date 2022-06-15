// ignore_for_file: file_names, sized_box_for_whitespace, no_logic_in_create_state, avoid_print, unnecessary_null_comparison
import 'package:flutter/services.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:petagonv0_flutter/components/pdf_api.dart';
import 'package:petagonv0_flutter/constraints.dart';
import 'package:petagonv0_flutter/model/documents.dart';
import 'package:petagonv0_flutter/model/owner.dart';
import 'package:petagonv0_flutter/model/pet.dart';
import 'package:petagonv0_flutter/model/pictures.dart';
import 'package:file_picker/file_picker.dart';
import 'package:petagonv0_flutter/screens/home/picHomePage.dart';
import 'package:petagonv0_flutter/screens/home/postHomePage.dart';
import 'package:petagonv0_flutter/screens/pdf_viewer_page.dart';
import 'package:petagonv0_flutter/screens/petCRUD/petListPage.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:petagonv0_flutter/screens/petCRUD/updatePet.dart';
import 'package:uuid/uuid.dart';
import '../../model/post.dart';
import '../Auth/login.dart';

// ignore: camel_case_types
class petHomePage extends StatefulWidget {
  final String petID;
  const petHomePage({Key? key, required this.petID}) : super(key: key);
  @override
  _PetHomePage createState() => _PetHomePage(petID);
}

class _PetHomePage extends State<petHomePage> with TickerProviderStateMixin {
  final User user = FirebaseAuth.instance.currentUser!;
  final String petID;
  PlatformFile? pickedFile;
  _PetHomePage(this.petID);
  int bottomNavBarIndex = 2;
  String fileSrc = "";
  String dateUploaded = "";
  String filePath = "";
  bool isVerified = false;
  bool hasInternet = false;
  var uuiDoc = const Uuid();

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

  Future selectFile(String fileType) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result == null) return;

    setState(() {
      pickedFile = result.files.first;
    });
    try {
      // save file to firbase storage
      final path = 'files/$petID/$fileType/${pickedFile!.name}';
      final file = File(pickedFile!.path!);
      final ref = FirebaseStorage.instance.ref().child(path);
      await ref.putFile(file);

      // initialize variables
      filePath = path;
      fileSrc = await ref.getDownloadURL();
      final uploadTime = DateTime.now();
      dateUploaded = DateFormat('dd-MM-yyyy').format(uploadTime);
      final ownerID = user.uid;
      final _uid = uuiDoc.v4();

      //initialize firbase collection
      final petDocument =
          FirebaseFirestore.instance.collection('Pet Documents').doc(_uid);

      //convert to JSON Object
      final data = {
        'id': _uid,
        'srcFile': fileSrc,
        'documentType': fileType,
        'dateUploaded': dateUploaded,
        'filePath': filePath,
        'petID': petID,
        'ownerID': ownerID,
        'isVerified': isVerified
      };
      //Save JSON Object to petDocument Collection
      petDocument.set(data);
    } catch (e) {
      print('Error: $e');
    }
  }

  Future updateFile(String fileType, Documents documents) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result == null) return;

    setState(() {
      pickedFile = result.files.first;
    });
    try {
      // save file to firbase storage
      final path = 'files/$petID/$fileType/${pickedFile!.name}';
      final file = File(pickedFile!.path!);
      final ref = FirebaseStorage.instance.ref().child(path);
      await ref.putFile(file);

      // initialize variables
      filePath = path;
      fileSrc = await ref.getDownloadURL();
      final uploadTime = DateTime.now();
      dateUploaded = DateFormat('dd-MM-yyyy').format(uploadTime);
      final ownerID = user.uid;

      //initialize firbase collection
      final updateDocument = FirebaseFirestore.instance
          .collection('Pet Documents')
          .doc(documents.id);

      //convert to JSON Object
      final data = {
        'id': documents.id,
        'srcFile': fileSrc,
        'documentType': fileType,
        'dateUploaded': dateUploaded,
        'filePath': filePath,
        'petID': petID,
        'ownerID': ownerID,
        'isVerified': isVerified
      };
      //Save JSON Object to petDocument Collection
      updateDocument.set(data);
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final widthScreen = MediaQuery.of(context).size.width;
    final heightScreen = MediaQuery.of(context).size.height;
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
                onTap: () {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => postHomePage(petID: petID)));
                },
                child: const Icon(Icons.menu_book_rounded),
                label: 'Journal',
                backgroundColor: Colors.pink),
            SpeedDialChild(
                onTap: () {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => picHomePage(petID: petID)));
                },
                child: const FaIcon(FontAwesomeIcons.image),
                label: 'Picture',
                backgroundColor: Colors.orange),
            SpeedDialChild(
                onTap: (() {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => UpdatePetScreen(
                            petCurrentID: petID,
                          )));
                }),
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
                        builder: (context) => const PetListView())),
                icon: const Icon(
                  Icons.logout,
                  color: Colors.white,
                ))
          ],
          centerTitle: true,
          title: const Text(
            'Profile',
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
                return buildUpperUi(
                    heightScreen, widthScreen, _tabcontroller, pets.first);
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

  Column buildUpperUi(double heightScreen, double widthScreen,
      TabController _tabcontroller, Pet pets) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: heightScreen * 0.2,
          color: kPrimaryColor,
          child: Center(
              child: CircleAvatar(
            radius: 62,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 57,
              backgroundImage: NetworkImage(pets.imageUrl),
            ),
          )),
        ),
        Container(
          height: heightScreen * 0.2,
          color: Colors.white,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: widthScreen * 0.5,
                child: const Image(
                  image: AssetImage('assets/images/qr_code.png'),
                ),
              ),
              SizedBox(
                width: widthScreen * 0.5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      pets.petName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 45),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(pets.petBreed,
                            style: const TextStyle(fontSize: 18)),
                        const Text('/', style: TextStyle(fontSize: 18)),
                        Text(pets.petGender,
                            style: const TextStyle(fontSize: 18))
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
        Container(
          color: Colors.white,
          child: Align(
            alignment: Alignment.center,
            child: TabBar(
              controller: _tabcontroller,
              labelPadding: const EdgeInsets.only(left: 20, right: 20, top: 0),
              isScrollable: true,
              indicatorColor: kPrimaryColor,
              unselectedLabelStyle:
                  const TextStyle(fontWeight: FontWeight.normal, fontSize: 15),
              labelStyle:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              labelColor: kPrimaryColor,
              unselectedLabelColor: Colors.black,
              tabs: const [
                Tab(text: 'Journal'),
                Tab(text: 'Photos'),
                Tab(text: 'Documents'),
                Tab(text: 'About Me'),
              ],
            ),
          ),
        ),
        Container(
          color: Colors.white,
          width: double.maxFinite,
          height: heightScreen * 0.34,
          child: TabBarView(controller: _tabcontroller, children: [
            Container(
              height: heightScreen * 0.30,
              width: widthScreen,
              child: StreamBuilder<List<Post>>(
                  stream: readPost(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      print(snapshot.error);
                      return const Text('Something Went Wrong');
                    } else if (snapshot.hasData) {
                      final post = snapshot.data!;
                      print(post);
                      if (post.isNotEmpty) {
                        return ListView(children: post.map(_postView).toList());
                      } else {
                        return const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 80),
                          child: Center(
                            child: Text(
                              'You have an empty journal!   Input your first journal now',
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
            Container(
              height: heightScreen * 0.30,
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
            _documentsView(),
            StreamBuilder<List<Pet>>(
                stream: readPet(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    print(snapshot.error);
                    return const Text('Something Went Wrong');
                  } else if (snapshot.hasData) {
                    final pet = snapshot.data!;
                    return SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const CircleAvatar(
                                radius: 55,
                                backgroundImage: AssetImage(
                                    'assets/images/birthdaycake_Image.png'),
                              ),
                              Container(
                                width: widthScreen * 0.65,
                                height: 45,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  color:
                                      const Color.fromARGB(255, 114, 43, 144),
                                ),
                                child: Center(
                                  child: Text(
                                    '${pet.first.age.toString()} years old',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const CircleAvatar(
                                radius: 55,
                                backgroundImage: AssetImage(
                                    'assets/images/needle_Image.png'),
                              ),
                              Container(
                                width: widthScreen * 0.65,
                                height: 45,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  color:
                                      const Color.fromARGB(255, 116, 195, 243),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Fully Vaccinated',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const CircleAvatar(
                                radius: 55,
                                backgroundImage: AssetImage(
                                    'assets/images/folder_Image.png'),
                              ),
                              Container(
                                width: widthScreen * 0.65,
                                height: 45,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  color:
                                      const Color.fromARGB(255, 49, 177, 230),
                                ),
                                child: const Center(
                                  child: Text(
                                    'No Pending Reports',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                })
          ]),
        ),
      ],
    );
  }

  Widget _postView(Post post) {
    const double avatarDiameter = 90;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StreamBuilder<List<Pet>>(
            stream: readPet(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                print(snapshot.error);
                return const Text('Something Went Wrong');
              } else if (snapshot.hasData) {
                final pet = snapshot.data!;
                return buildListPetInformation(avatarDiameter, pet.first);
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            }),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  post.title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Row(
                  children: [
                    const Text(
                      'Rating: ',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      width: 2,
                    ),
                    if (post.rating == 1)
                      const Icon(Icons.sentiment_dissatisfied,
                          color: Colors.redAccent)
                    else if (post.rating == 2)
                      const Icon(
                        Icons.sentiment_neutral,
                        color: Colors.amber,
                      )
                    else if (post.rating == 3)
                      const Icon(
                        Icons.sentiment_satisfied,
                        color: Colors.lightGreen,
                      )
                    else if (post.rating == 4)
                      const Icon(
                        Icons.sentiment_very_satisfied,
                        color: Colors.green,
                      )
                    else
                      const Icon(Icons.sentiment_very_satisfied,
                          color: Colors.green)
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 2, right: 5),
                child: Text(
                  post.description,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Column buildListPetInformation(double avatarDiameter, Pet pet) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, right: 8, top: 10),
          child: Container(
            width: avatarDiameter,
            height: avatarDiameter,
            decoration: const BoxDecoration(
                color: kPrimaryColor, shape: BoxShape.circle),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(avatarDiameter / 2),
              child:
                  Image(image: NetworkImage(pet.imageUrl), fit: BoxFit.cover),
            ),
          ),
        ),
      ],
    );
  }

  _documentsView() {
    final widthScreen = MediaQuery.of(context).size.width;
    final heightScreen = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: _documentsDesign(widthScreen, heightScreen),
    );
  }

  Column _documentsDesign(double widthScreen, double heightScreen) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 10, bottom: 15),
          child: Text(
            'Important Documents',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
        ),
        Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              StreamBuilder<List<Documents>>(
                  stream: readDocPCCI(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      print(snapshot.error);
                      return const Text('Something Went Wrong');
                    } else if (snapshot.hasData) {
                      final document = snapshot.data!;
                      if (document.isNotEmpty) {
                        return Column(
                          children: [
                            buildPCCIPaperContainerData(
                                widthScreen, heightScreen, document.first),
                            const SizedBox(height: 15),
                            const Text(
                              'PCCI Papers',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            buildPCCIPaperContainer(widthScreen, heightScreen),
                            const SizedBox(height: 15),
                            const Text(
                              'PCCI Papers',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        );
                      }
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  }),
              const SizedBox(width: 30),
              StreamBuilder<List<Documents>>(
                  stream: readDocVacRecord(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      print(snapshot.error);
                      return const Text('Something Went Wrong');
                    } else if (snapshot.hasData) {
                      final document = snapshot.data!;
                      if (document.isNotEmpty) {
                        return Column(
                          children: [
                            buildVacRecordContainerData(
                                widthScreen, heightScreen, document.first),
                            const SizedBox(height: 15),
                            const Text(
                              'Vaccination Records',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            buildVacRecordContainer(widthScreen, heightScreen),
                            const SizedBox(height: 15),
                            const Text(
                              'Vaccination Records',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        );
                      }
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  }),
            ],
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              StreamBuilder<List<Documents>>(
                  stream: readDocMH(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      print(snapshot.error);
                      return const Text('Something Went Wrong');
                    } else if (snapshot.hasData) {
                      final document = snapshot.data!;
                      if (document.isNotEmpty) {
                        return Column(
                          children: [
                            buildMedicalHistoryContainerData(
                                widthScreen, heightScreen, document.first),
                            const SizedBox(height: 15),
                            const Text(
                              'Medical History',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            buildMedicalHistoryContainer(
                                widthScreen, heightScreen),
                            const SizedBox(height: 15),
                            const Text(
                              'Medical History',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        );
                      }
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  }),
              const SizedBox(width: 30),
              StreamBuilder<List<Documents>>(
                  stream: readDocIS(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      print(snapshot.error);
                      return const Text('Something Went Wrong');
                    } else if (snapshot.hasData) {
                      final document = snapshot.data!;
                      if (document.isNotEmpty) {
                        return Column(
                          children: [
                            buildInfoSheetContainerData(
                                widthScreen, heightScreen, document.first),
                            const SizedBox(height: 15),
                            const Text(
                              'Info Sheet',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            buildInfoSheetContainer(widthScreen, heightScreen),
                            const SizedBox(height: 15),
                            const Text(
                              'Info Sheet',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        );
                      }
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  }),
            ],
          )
        ])
      ],
    );
  }

  GestureDetector buildPCCIPaperContainer(
      double widthScreen, double heightScreen) {
    return GestureDetector(
      onTap: () {
        showCupertinoDialog(context: context, builder: createAddDialogPCCI);
      },
      child: Container(
        width: widthScreen * 0.35,
        height: heightScreen * 0.18,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 20, offset: Offset(5, 5)),
          ],
        ),
        child: Center(
          child: Image(
            image: const AssetImage('assets/images/pcci_Image.png'),
            width: widthScreen * 0.30,
            height: heightScreen * 0.18,
          ),
        ),
      ),
    );
  }

  GestureDetector buildPCCIPaperContainerData(
      double widthScreen, double heightScreen, Documents doc) {
    return GestureDetector(
      onTap: () {
        if (doc.isVerified == false) {
          showCupertinoDialog(context: context, builder: createPendingDialog);
        } else {
          showCupertinoDialog(
              context: context,
              builder: (BuildContext context) => CupertinoAlertDialog(
                    title: const Text('Document Succesfully Verified',
                        style: TextStyle(fontSize: 20)),
                    content: const Text(
                        'The document that you have uploaded is successfully verified you may update and view the current document',
                        style: TextStyle(fontSize: 14)),
                    actions: [
                      CupertinoDialogAction(
                        child: const Text('Update'),
                        onPressed: () async {
                          updateFile('PCCI Papers', doc);
                          Navigator.pop(context);
                        },
                      ),
                      CupertinoDialogAction(
                        child: const Text('View'),
                        onPressed: () async {
                          final file = await PDFApi.loadFirebase(doc.filePath);
                          if (file == null) return;
                          openPDF(context, file);
                        },
                      ),
                      CupertinoDialogAction(
                        child: const Text('Close'),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ));
        }
      },
      child: Container(
        width: widthScreen * 0.35,
        height: heightScreen * 0.18,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 20, offset: Offset(5, 5)),
          ],
        ),
        child: Center(
          child: Image(
            image: const AssetImage('assets/images/pcci_Image.png'),
            width: widthScreen * 0.30,
            height: heightScreen * 0.18,
          ),
        ),
      ),
    );
  }

  GestureDetector buildVacRecordContainer(
      double widthScreen, double heightScreen) {
    return GestureDetector(
      onTap: () {
        showCupertinoDialog(context: context, builder: createAddDialogVR);
      },
      child: Container(
        width: widthScreen * 0.35,
        height: heightScreen * 0.18,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 20, offset: Offset(5, 5)),
          ],
        ),
        child: Center(
          child: Image(
            image: const AssetImage('assets/images/vaccineRecords_Image.png'),
            width: widthScreen * 0.30,
            height: heightScreen * 0.18,
          ),
        ),
      ),
    );
  }

  GestureDetector buildVacRecordContainerData(
      double widthScreen, double heightScreen, Documents doc) {
    return GestureDetector(
      onTap: () {
        if (doc.isVerified == false) {
          showCupertinoDialog(context: context, builder: createPendingDialog);
        } else {
          showCupertinoDialog(
              context: context,
              builder: (BuildContext context) => CupertinoAlertDialog(
                    title: const Text('Document Succesfully Verified',
                        style: TextStyle(fontSize: 20)),
                    content: const Text(
                        'The document that you have uploaded is successfully verified you may update and view the current document',
                        style: TextStyle(fontSize: 14)),
                    actions: [
                      CupertinoDialogAction(
                        child: const Text('Update'),
                        onPressed: () {
                          updateFile('Vaccination Records', doc);
                          Navigator.pop(context);
                        },
                      ),
                      CupertinoDialogAction(
                        child: const Text('View'),
                        onPressed: () async {
                          final file = await PDFApi.loadFirebase(doc.filePath);
                          if (file == null) return;
                          openPDF(context, file);
                        },
                      ),
                      CupertinoDialogAction(
                        child: const Text('Close'),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ));
        }
      },
      child: Container(
        width: widthScreen * 0.35,
        height: heightScreen * 0.18,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 20, offset: Offset(5, 5)),
          ],
        ),
        child: Center(
          child: Image(
            image: const AssetImage('assets/images/vaccineRecords_Image.png'),
            width: widthScreen * 0.30,
            height: heightScreen * 0.18,
          ),
        ),
      ),
    );
  }

  GestureDetector buildMedicalHistoryContainer(
      double widthScreen, double heightScreen) {
    return GestureDetector(
      onTap: () {
        showCupertinoDialog(context: context, builder: createAddDialogMH);
      },
      child: Container(
        width: widthScreen * 0.35,
        height: heightScreen * 0.18,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 20, offset: Offset(5, 5)),
          ],
        ),
        child: Center(
          child: Image(
            image: const AssetImage('assets/images/medicalHistory_Image.png'),
            width: widthScreen * 0.30,
            height: heightScreen * 0.18,
          ),
        ),
      ),
    );
  }

  GestureDetector buildMedicalHistoryContainerData(
      double widthScreen, double heightScreen, Documents doc) {
    return GestureDetector(
      onTap: () {
        if (doc.isVerified == false) {
          showCupertinoDialog(context: context, builder: createPendingDialog);
        } else {
          showCupertinoDialog(
              context: context,
              builder: (BuildContext context) => CupertinoAlertDialog(
                    title: const Text('Document Succesfully Verified',
                        style: TextStyle(fontSize: 20)),
                    content: const Text(
                        'The document that you have uploaded is successfully verified you may update and view the current document',
                        style: TextStyle(fontSize: 14)),
                    actions: [
                      CupertinoDialogAction(
                        child: const Text('Update'),
                        onPressed: () {
                          updateFile('Medical History', doc);
                          Navigator.pop(context);
                        },
                      ),
                      CupertinoDialogAction(
                        child: const Text('View'),
                        onPressed: () async {
                          final file = await PDFApi.loadFirebase(doc.filePath);
                          if (file == null) return;
                          openPDF(context, file);
                        },
                      ),
                      CupertinoDialogAction(
                        child: const Text('Close'),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ));
        }
      },
      child: Container(
        width: widthScreen * 0.35,
        height: heightScreen * 0.18,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 20, offset: Offset(5, 5)),
          ],
        ),
        child: Center(
          child: Image(
            image: const AssetImage('assets/images/medicalHistory_Image.png'),
            width: widthScreen * 0.30,
            height: heightScreen * 0.18,
          ),
        ),
      ),
    );
  }

  GestureDetector buildInfoSheetContainer(
    double widthScreen,
    double heightScreen,
  ) {
    return GestureDetector(
      onTap: () {
        showCupertinoDialog(context: context, builder: createAddDialogIS);
      },
      child: Container(
        width: widthScreen * 0.35,
        height: heightScreen * 0.18,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 20, offset: Offset(5, 5)),
          ],
        ),
        child: Center(
          child: Image(
            image: const AssetImage('assets/images/infoSheet_Image.png'),
            width: widthScreen * 0.30,
            height: heightScreen * 0.18,
          ),
        ),
      ),
    );
  }

  GestureDetector buildInfoSheetContainerData(
      double widthScreen, double heightScreen, Documents doc) {
    return GestureDetector(
      onTap: () {
        if (doc.isVerified == false) {
          showCupertinoDialog(context: context, builder: createPendingDialog);
        } else {
          showCupertinoDialog(
              context: context,
              builder: (BuildContext context) => CupertinoAlertDialog(
                    title: const Text('Document Succesfully Verified',
                        style: TextStyle(fontSize: 20)),
                    content: const Text(
                        'The document that you have uploaded is successfully verified you may update and view the current document',
                        style: TextStyle(fontSize: 14)),
                    actions: [
                      CupertinoDialogAction(
                        child: const Text('Update'),
                        onPressed: () {
                          updateFile('Info Sheet', doc);
                          Navigator.pop(context);
                        },
                      ),
                      CupertinoDialogAction(
                        child: const Text('View'),
                        onPressed: () async {
                          final file = await PDFApi.loadFirebase(doc.filePath);
                          if (file == null) return;
                          openPDF(context, file);
                        },
                      ),
                      CupertinoDialogAction(
                        child: const Text('Close'),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ));
        }
      },
      child: Container(
        width: widthScreen * 0.35,
        height: heightScreen * 0.18,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 20, offset: Offset(5, 5)),
          ],
        ),
        child: Center(
          child: Image(
            image: const AssetImage('assets/images/infoSheet_Image.png'),
            width: widthScreen * 0.30,
            height: heightScreen * 0.18,
          ),
        ),
      ),
    );
  }

  Widget createAddDialogPCCI(BuildContext context) => CupertinoAlertDialog(
        title: const Text('Add Document', style: TextStyle(fontSize: 20)),
        content: const Text(
            'The added PCCI Papers will be check by our team for authentication and will be marked as pending until we have checked the document ',
            style: TextStyle(fontSize: 14)),
        actions: [
          CupertinoDialogAction(
            child: const Text('Upload'),
            onPressed: () {
              selectFile('PCCI Papers');
              Navigator.pop(context);
            },
          ),
          CupertinoDialogAction(
            child: const Text('Close'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      );

  Widget createAddDialogVR(BuildContext context) => CupertinoAlertDialog(
        title: const Text('Add Document', style: TextStyle(fontSize: 22)),
        content: const Text(
            'The added Vaccination Records  will be check by our team for authentication and will be marked as pending until we have checked the document ',
            style: TextStyle(fontSize: 14)),
        actions: [
          CupertinoDialogAction(
            child: const Text('Upload'),
            onPressed: () {
              selectFile('Vaccination Records');
              Navigator.pop(context);
            },
          ),
          CupertinoDialogAction(
            child: const Text('Close'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      );

  Widget createAddDialogMH(BuildContext context) => CupertinoAlertDialog(
        title: const Text('Add Document', style: TextStyle(fontSize: 22)),
        content: const Text(
            'The added Medical History Documents will be check by our team for authentication and will be marked as pending until we have checked the document ',
            style: TextStyle(fontSize: 14)),
        actions: [
          CupertinoDialogAction(
            child: const Text('Upload'),
            onPressed: () {
              selectFile('Medical History');
              Navigator.pop(context);
            },
          ),
          CupertinoDialogAction(
            child: const Text('Close'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      );
  Widget createAddDialogIS(BuildContext context) => CupertinoAlertDialog(
        title: const Text('Add Document', style: TextStyle(fontSize: 22)),
        content: const Text(
            'The added Info Sheet will be check by our team for authentication and will be marked as pending until we have checked the document ',
            style: TextStyle(fontSize: 14)),
        actions: [
          CupertinoDialogAction(
            child: const Text('Upload'),
            onPressed: () {
              selectFile('Info Sheet');
              Navigator.pop(context);
            },
          ),
          CupertinoDialogAction(
            child: const Text('Close'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      );
  void openPDF(BuildContext context, File file) => Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => PDFViewerPage(file: file)),
      );
  Widget createPendingDialog(BuildContext context) => CupertinoAlertDialog(
        title: const Text('Pending for Verification',
            style: TextStyle(fontSize: 22)),
        content: const Text(
            'The document that you have uploaded is still pending for verification, please wait for atleast 3-5 working days for the approval',
            style: TextStyle(fontSize: 14)),
        actions: [
          CupertinoDialogAction(
            child: const Text('Close'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      );

  Stream<List<Pet>> readPet() {
    return FirebaseFirestore.instance.collection('Pets').snapshots().map(
        (snapshot) => snapshot.docs
            .where((QueryDocumentSnapshot<Object?> element) =>
                element['id'].toString().contains(petID))
            .map((doc) => Pet.fromJson(doc.data()))
            .toList());
  }

  Stream<List<Post>> readPost() {
    return FirebaseFirestore.instance.collection('Pet Posts').snapshots().map(
        (snapshot) => snapshot.docs
            .where((QueryDocumentSnapshot<Object?> element) =>
                element['petID'].toString().contains(petID))
            .map((doc) => Post.fromJson(doc.data()))
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

  Stream<List<Documents>> readDocVacRecord() {
    return FirebaseFirestore.instance
        .collection('Pet Documents')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .where((QueryDocumentSnapshot<Object?> element) =>
                element['petID'].toString().contains(petID))
            .where((QueryDocumentSnapshot<Object?> element) =>
                element['documentType']
                    .toString()
                    .contains('Vaccination Records'))
            .map((doc) => Documents.fromJson(doc.data()))
            .toList());
  }

  Stream<List<Documents>> readDocPCCI() {
    return FirebaseFirestore.instance
        .collection('Pet Documents')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .where((QueryDocumentSnapshot<Object?> element) =>
                element['petID'].toString().contains(petID))
            .where((QueryDocumentSnapshot<Object?> element) =>
                element['documentType'].toString().contains('PCCI Papers'))
            .map((doc) => Documents.fromJson(doc.data()))
            .toList());
  }

  Stream<List<Documents>> readDocMH() {
    return FirebaseFirestore.instance
        .collection('Pet Documents')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .where((QueryDocumentSnapshot<Object?> element) =>
                element['petID'].toString().contains(petID))
            .where((QueryDocumentSnapshot<Object?> element) =>
                element['documentType'].toString().contains('Medical History'))
            .map((doc) => Documents.fromJson(doc.data()))
            .toList());
  }

  Stream<List<Documents>> readDocIS() {
    return FirebaseFirestore.instance
        .collection('Pet Documents')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .where((QueryDocumentSnapshot<Object?> element) =>
                element['petID'].toString().contains(petID))
            .where((QueryDocumentSnapshot<Object?> element) =>
                element['documentType'].toString().contains('Info Sheet'))
            .map((doc) => Documents.fromJson(doc.data()))
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
