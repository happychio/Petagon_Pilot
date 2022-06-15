// ignore_for_file: file_names, avoid_print
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:petagonv0_flutter/constraints.dart';
import 'package:petagonv0_flutter/model/pet.dart';
import 'package:petagonv0_flutter/screens/Auth/login.dart';
import 'package:petagonv0_flutter/screens/petCRUD/addPet.dart';
import 'package:petagonv0_flutter/screens/home/petHomePage.dart';

class PetListView extends StatefulWidget {
  const PetListView({Key? key}) : super(key: key);

  @override
  _PetListViewState createState() => _PetListViewState();
}

class _PetListViewState extends State<PetListView> {
  final user = FirebaseAuth.instance.currentUser!;
  bool hasInternet = false;
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
  List profiles = [];
  readData() {
    DefaultAssetBundle.of(context)
        .loadString('assets/json/sampleProfile.json')
        .then((value) => {
              setState(() {
                profiles = json.decode(value);
              })
            });
  }

  @override
  void initState() {
    super.initState();
    readData();
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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Object>(
        stream: readPets(),
        builder: (context, snapshot) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              floatingActionButton: FloatingActionButton(
                backgroundColor: kPrimaryColor,
                child: const Icon(
                  Icons.add,
                  size: 40,
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AddPetScreen()));
                },
              ),
              body: SafeArea(
                child: WillPopScope(
                  onWillPop: () async {
                    final shouldPop = await showWarning(context);
                    return shouldPop ?? false;
                  },
                  child: Scaffold(
                    appBar: AppBar(
                      actions: [
                        IconButton(
                            onPressed: () => setState(() {
                                  FirebaseAuth.instance.signOut();
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          const LoginScreen()));
                                }),
                            icon: const Icon(
                              Icons.logout,
                              color: Colors.black,
                            ))
                      ],
                      backgroundColor: Colors.white,
                      title: const Text(
                        'My Pets',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 30,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    backgroundColor: Colors.white,
                    body: Center(
                        child: StreamBuilder<List<Pet>>(
                            stream: readPets(),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                print(snapshot.error);
                                return const Text('Something Went Wrong');
                              } else if (snapshot.hasData) {
                                final pets = snapshot.data!;
                                print(pets);
                                return ListView(
                                    children: pets.map(buildPets).toList());
                              } else {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                            })),
                  ),
                ),
              ),
            ),
          );
        });
  }

  Widget buildPets(Pet pets) => GestureDetector(
        onTap: () => Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => petHomePage(petID: pets.id))),
        child: Container(
          padding: const EdgeInsets.only(top: 35),
          child: Column(children: [
            CircleAvatar(
              radius: 70,
              backgroundImage: NetworkImage(pets.imageUrl),
            ),
            const SizedBox(height: 5),
            Text(
              pets.petName,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black),
            )
          ]),
        ),
      );
  Stream<List<Pet>> readPets() {
    return FirebaseFirestore.instance.collection('Pets').snapshots().map(
        (snapshot) => snapshot.docs
            .where((QueryDocumentSnapshot<Object?> element) =>
                element['ownerID'].toString().contains(user.uid))
            .map((doc) => Pet.fromJson(doc.data()))
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
