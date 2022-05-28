// ignore_for_file: file_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:petagonv0_flutter/constraints.dart';
import 'package:petagonv0_flutter/model/pet.dart';
import 'package:petagonv0_flutter/screens/petCRUD/petListPage.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

// ignore: camel_case_types
class petHomePage extends StatefulWidget {
  const petHomePage({Key? key}) : super(key: key);
  @override
  _PetHomePage createState() => _PetHomePage();
}

class _PetHomePage extends State<petHomePage> with TickerProviderStateMixin {
  int bottomNavBarIndex = 2;
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
                child: Icon(Icons.menu_book_rounded),
                label: 'Journal',
                backgroundColor: Colors.pink),
            SpeedDialChild(
                child: FaIcon(FontAwesomeIcons.image),
                label: 'Picture',
                backgroundColor: Colors.orange),
            SpeedDialChild(
                child: FaIcon(FontAwesomeIcons.folder),
                label: 'Document',
                backgroundColor: Colors.yellow),
            SpeedDialChild(
                child: Icon(Icons.update),
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
        drawer: const NavigationDrawer(),
        body: buildUpperUi(heightScreen, widthScreen, _tabcontroller),
        bottomNavigationBar: CurvedNavigationBar(
          backgroundColor: Colors.transparent,
          items: items,
          height: 60,
          index: bottomNavBarIndex,
          onTap: (bottomIndex) =>
              setState(() => bottomNavBarIndex = bottomIndex),
          animationDuration: Duration(milliseconds: 500),
          animationCurve: Curves.easeInOut,
        ),
      ),
    );
  }

  Column buildUpperUi(
      double heightScreen, double widthScreen, TabController _tabcontroller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: heightScreen * 0.2,
          color: kPrimaryColor,
          child: const Center(
              child: CircleAvatar(
            radius: 62,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 57,
              backgroundImage: AssetImage('assets/images/sample_dogImage4.jpg'),
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
                    const Text(
                      'Soba',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 45),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text('Chow Chow', style: TextStyle(fontSize: 18)),
                        Text('/', style: TextStyle(fontSize: 18)),
                        Text('Female', style: TextStyle(fontSize: 18))
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
                Tab(text: 'Posts'),
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
            _postListView(),
            _imageGridView(),
            _documentsView(),
            _aboutMeView(),
          ]),
        ),
      ],
    );
  }

  Widget _postView() {
    const double avatarDiameter = 65;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Container(
            width: avatarDiameter,
            height: avatarDiameter,
            decoration: const BoxDecoration(
                color: kPrimaryColor, shape: BoxShape.circle),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(avatarDiameter / 2),
              child: const Image(
                  image: AssetImage('assets/images/sample_dogImage4.jpg'),
                  fit: BoxFit.cover),
            ),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: const Text(
                'Just got out of shower',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: const Text(
                'Love hate relationship with showers',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        )
      ],
    );
  }

  _imageGridView() {
    return GridView.builder(
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      itemCount: 14,
      itemBuilder: (BuildContext context, int index) {
        return GridTile(
            child: Image(
          image: NetworkImage('https://source.unsplash.com/random?sig=$index'),
          fit: BoxFit.cover,
        ));
      },
    );
  }

  ListView _postListView() {
    return ListView.builder(
      itemCount: 3,
      itemBuilder: (BuildContext context, int index) {
        return _postView();
      },
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
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 15),
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
              Column(
                children: [
                  Container(
                    width: widthScreen * 0.35,
                    height: heightScreen * 0.18,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black12,
                            blurRadius: 20,
                            offset: Offset(5, 5)),
                      ],
                    ),
                    child: Center(
                      child: Image(
                        image: AssetImage('assets/images/pcci_Image.png'),
                        width: widthScreen * 0.30,
                        height: heightScreen * 0.18,
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    'PCCI Papers',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(width: 30),
              Column(
                children: [
                  Container(
                    width: widthScreen * 0.35,
                    height: heightScreen * 0.18,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black12,
                            blurRadius: 20,
                            offset: Offset(5, 5)),
                      ],
                    ),
                    child: Center(
                      child: Image(
                        image: AssetImage(
                            'assets/images/vaccineRecords_Image.png'),
                        width: widthScreen * 0.30,
                        height: heightScreen * 0.18,
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Vaccination Records',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  Container(
                    width: widthScreen * 0.35,
                    height: heightScreen * 0.18,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black12,
                            blurRadius: 20,
                            offset: Offset(5, 5)),
                      ],
                    ),
                    child: Center(
                      child: Image(
                        image: AssetImage(
                            'assets/images/medicalHistory_Image.png'),
                        width: widthScreen * 0.30,
                        height: heightScreen * 0.18,
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Medical History',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(width: 30),
              Column(
                children: [
                  Container(
                    width: widthScreen * 0.35,
                    height: heightScreen * 0.18,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black12,
                            blurRadius: 20,
                            offset: Offset(5, 5)),
                      ],
                    ),
                    child: Center(
                      child: Image(
                        image: AssetImage('assets/images/infoSheet_Image.png'),
                        width: widthScreen * 0.30,
                        height: heightScreen * 0.18,
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Info Sheet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          )
        ])
      ],
    );
  }

  _aboutMeView() {
    final widthScreen = MediaQuery.of(context).size.width;
    final heightScreen = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 55,
                backgroundImage:
                    AssetImage('assets/images/birthdaycake_Image.png'),
              ),
              Container(
                width: widthScreen * 0.65,
                height: 45,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Color.fromARGB(255, 114, 43, 144),
                ),
                child: Center(
                  child: Text(
                    'Age: 1',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 55,
                backgroundImage: AssetImage('assets/images/needle_Image.png'),
              ),
              Container(
                width: widthScreen * 0.65,
                height: 45,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Color.fromARGB(255, 116, 195, 243),
                ),
                child: Center(
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
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 55,
                backgroundImage: AssetImage('assets/images/folder_Image.png'),
              ),
              Container(
                width: widthScreen * 0.65,
                height: 45,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Color.fromARGB(255, 49, 177, 230),
                ),
                child: Center(
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
  }
}

class NavigationDrawer extends StatelessWidget {
  const NavigationDrawer({Key? key}) : super(key: key);

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
    return Material(
      color: kPrimaryColor,
      child: InkWell(
        onTap: () {},
        child: Container(
          padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top, bottom: 24),
          child: Column(children: const [
            CircleAvatar(
                radius: 52,
                backgroundImage: NetworkImage(
                    'https://images.unsplash.com/photo-1548142813-c348350df52b?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=689&q=80')),
            SizedBox(height: 10),
            Text('Yor Forger',
                style: TextStyle(fontSize: 28, color: Colors.white)),
            SizedBox(height: 5),
            Text('YorForger@gmail.com',
                style: TextStyle(fontSize: 16, color: Colors.white)),
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
              onTap: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const petHomePage())),
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

  Stream<List<Pet>> readPets() {
    return FirebaseFirestore.instance.collection('Pets').snapshots().map(
        (snapshot) =>
            snapshot.docs.map((doc) => Pet.fromJson(doc.data())).toList());
  }
}
