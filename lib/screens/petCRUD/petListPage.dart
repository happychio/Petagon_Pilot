// ignore: file_names
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:petagonv0_flutter/constraints.dart';
import 'package:petagonv0_flutter/model/owner.dart';
import 'package:petagonv0_flutter/model/pet.dart';
import 'package:petagonv0_flutter/screens/petCRUD/addPet.dart';
import 'package:petagonv0_flutter/screens/petCRUD/petHomePage.dart';

class PetListView extends StatefulWidget {
  const PetListView({Key? key}) : super(key: key);

  @override
  _PetListViewState createState() => _PetListViewState();
}

class _PetListViewState extends State<PetListView> {
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
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Object>(
        stream: readPets(),
        builder: (context, snapshot) {
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
                      child: Icon(Icons.add),
                      label: 'Add',
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AddPetScreen()));
                      },
                      backgroundColor: Colors.green),
                ],
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
                                return Text('Something Went Wrong');
                              } else if (snapshot.hasData) {
                                final pets = snapshot.data!;
                                return ListView(
                                    children: pets.map(buildPets).toList());
                              } else {
                                return Center(
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
        onTap: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const petHomePage())),
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
        (snapshot) =>
            snapshot.docs.map((doc) => Pet.fromJson(doc.data())).toList());
  }
}
