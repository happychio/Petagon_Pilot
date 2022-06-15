// ignore_for_file: file_names, sized_box_for_whitespace, no_logic_in_create_state, avoid_print, avoid_unnecessary_containers, non_constant_identifier_names, unused_local_variable
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:petagonv0_flutter/constraints.dart';
import 'package:petagonv0_flutter/model/owner.dart';
import 'package:petagonv0_flutter/model/pet.dart';
import 'package:petagonv0_flutter/model/post.dart';
import 'package:petagonv0_flutter/screens/Auth/login.dart';
import 'package:petagonv0_flutter/screens/home/petHomePage.dart';
import 'package:petagonv0_flutter/screens/petCRUD/petListPage.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:petagonv0_flutter/services/global_methods';
import 'package:uuid/uuid.dart';

import '../../components/theme_help.dart';

// ignore: camel_case_types
class postHomePage extends StatefulWidget {
  final String petID;
  const postHomePage({Key? key, required this.petID}) : super(key: key);
  @override
  _PostHomePage createState() => _PostHomePage(petID);
}

class _PostHomePage extends State<postHomePage> with TickerProviderStateMixin {
  final String petID;
  _PostHomePage(this.petID);
  String postID = "";
  int rating = 0;
  final _PostformKey = GlobalKey<FormState>();
  final User user = FirebaseAuth.instance.currentUser!;
  final title = TextEditingController();
  final description = TextEditingController();
  int bottomNavBarIndex = 2;
  var uuidPost = const Uuid();
  bool hasInternet = false;

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

  Future createPost(Post post) async {
    if (title.text == "" || description.text == "") {
      GlobalMethod.showErrorDialog(
          error: 'Please complete all the requirements', ctx: context);
      return;
    }
    try {
      final ownerID = user.uid;
      final _uid = uuidPost.v4();
      final docPost =
          FirebaseFirestore.instance.collection('Pet Posts').doc(_uid);
      postID = docPost.id;
      post.id = postID;
      post.ownerID = ownerID;
      post.petID = petID;
      final json = post.toJson();
      await docPost.set(json);
      print(docPost.id);
      print("Successfully create post document");
    } catch (e) {
      print(e);
      print("error");
    }
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
            'Journal',
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
          Form(
            key: _PostformKey,
            child: Container(
                height: heightScreen * 0.46,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.only(top: 15, left: 20, right: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: Text(
                              'Title: ',
                              style: TextStyle(fontSize: 20),
                              textAlign: TextAlign.end,
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          buildTitleField(widthScreen),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Text(
                            'Rating: ',
                            style: TextStyle(fontSize: 20),
                            textAlign: TextAlign.end,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          RatingBar.builder(
                            minRating: 1,
                            initialRating: 1,
                            itemCount: 5,
                            updateOnDrag: true,
                            itemBuilder: (context, index) {
                              if (index == 1) {
                                return const Icon(
                                  Icons.sentiment_dissatisfied,
                                  color: Colors.redAccent,
                                );
                              } else if (index == 2) {
                                return const Icon(
                                  Icons.sentiment_neutral,
                                  color: Colors.amber,
                                );
                              } else if (index == 3) {
                                return const Icon(
                                  Icons.sentiment_satisfied,
                                  color: Colors.lightGreen,
                                );
                              } else if (index == 4) {
                                return const Icon(
                                  Icons.sentiment_very_satisfied,
                                  color: Colors.green,
                                );
                              } else {
                                return const Icon(
                                  Icons.sentiment_very_dissatisfied,
                                  color: Colors.red,
                                );
                              }
                            },
                            onRatingUpdate: (rating) {
                              print(rating);
                              this.rating = rating.toInt();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text('Description: ',
                          style: TextStyle(fontSize: 20),
                          textAlign: TextAlign.end),
                      const SizedBox(height: 10),
                      buildDescriptionField(widthScreen),
                      const SizedBox(height: 20),
                      buildButtons(),
                    ],
                  ),
                )),
          ),
          if (!isKeyboard)
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
        ],
      ),
    );
  }

  Container buildTitleField(double widthScreen) {
    return Container(
      width: widthScreen * 0.65,
      child: TextFormField(
        controller: title,
        decoration: ThemeHelper().textInputDecoration("Title", ""),
      ),
    );
  }

  Container buildDescriptionField(double widthScreen) {
    return Container(
      width: widthScreen * 0.90,
      child: TextFormField(
        minLines: 3,
        maxLines: 5,
        controller: description,
        decoration: ThemeHelper().textInputDecoration("Description", ""),
      ),
    );
  }

  Center buildButtons() {
    return Center(
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  primary: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20))),
              onPressed: () {
                final post = Post(
                    title: title.text,
                    description: description.text,
                    rating: rating);
                createPost(post);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => petHomePage(petID: petID)));
              },
              child: const Text(
                'SAVE',
                style: TextStyle(color: kPrimaryColor),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  primary: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20))),
              onPressed: () {
                title.clear();
                description.clear();
              },
              child: const Text(
                'CLEAR',
                style: TextStyle(color: kPrimaryColor),
              ),
            ),
          ),
        ],
      ),
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
