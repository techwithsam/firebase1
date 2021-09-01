import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_class/admin/admin_panel.dart';
import 'package:firebase_class/dropdowns.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'Firebase-Authentication/sign_up.dart';
import 'Firebase-Authentication/firebase_services.dart';
import 'Firebase-Firestore/edit_product.dart';

class HomePage extends StatefulWidget {
  final String uid;
  HomePage({Key? key, required this.uid}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FirebaseService service = FirebaseService();
  final dbRef = FirebaseDatabase.instance.reference().child("Users");

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> _dataStream =
        FirebaseFirestore.instance.collection('new_products').snapshots();
    return Scaffold(
      appBar: AppBar(
        title: Text('Homepage'),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AdminPanel(),
              ),
            );
          },
          icon: Icon(Icons.admin_panel_settings),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await service.signOutFromGoogle().then(
                (value) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DropDownExample(),
                    ),
                  );
                },
              );
            },
            icon: Icon(Icons.pin_drop),
          ),
          IconButton(
            onPressed: () async {
              await service.signOutFromGoogle().then(
                (value) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SingUpScreen(),
                    ),
                  );
                },
              );
            },
            icon: Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _dataStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Oops! Something went wrong 🥴'),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(
              backgroundColor: Color(0xffD6D6D6),
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
            ));
          }
          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;

              return Container(
                margin: EdgeInsets.all(12),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12)),
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(0, 1),
                      color: Colors.grey.shade400,
                      blurRadius: 10,
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12)),
                        image: DecorationImage(
                          image: NetworkImage(data['image_url']),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(data['name'],
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w700)),
                          SizedBox(height: 4),
                          Text(
                            data['description'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "₦" + data['actual_price'],
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w900),
                          ),
                          Row(
                            children: [
                              Text(
                                "₦" + data['discount_price'],
                                style: TextStyle(
                                  fontSize: 12,
                                  decoration: TextDecoration.lineThrough,
                                  decorationStyle: TextDecorationStyle.double,
                                ),
                              ),
                              SizedBox(width: 6),
                              Container(
                                color: Colors.blue.withOpacity(0.2),
                                padding: const EdgeInsets.all(2.3),
                                child: Text('-32%'),
                              )
                            ],
                          ),
                          SizedBox(height: 10),
                          Center(
                            child: MaterialButton(
                              minWidth: double.infinity,
                              onPressed: () {},
                              child: Text('Buy Now!'),
                              color: Colors.blue,
                            ),
                          ),
                          Center(
                            child: MaterialButton(
                              minWidth: double.infinity,
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        EditProducts(pID: document.id),
                                  ),
                                );
                              },
                              child: Text('Edit Product'),
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),

      // body: FutureBuilder(
      //   future: dbRef.child(widget.uid).once(),
      //   builder: (context, AsyncSnapshot<DataSnapshot> snapshot) {
      //     if (snapshot.hasData) {
      //       return Padding(
      //         padding: const EdgeInsets.all(8.0),
      //         child: Column(
      //           mainAxisAlignment: MainAxisAlignment.center,
      //           crossAxisAlignment: CrossAxisAlignment.start,
      //           children: <Widget>[
      //             Text("Full Name: " + snapshot.data!.value["fname"]),
      //             Text("User Email: " + snapshot.data!.value["email"]),
      //             Text("User ID: " + snapshot.data!.value["uid"]),
      //             TextButton(
      //                 onPressed: () {
      //                   Navigator.push(
      //                     context,
      //                     MaterialPageRoute(
      //                       builder: (_) => FirestoreDataState(),
      //                     ),
      //                   );
      //                 },
      //                 child: Text('data'))
      //           ],
      //         ),
      //       );
      //     }
      //     return Center(child: CircularProgressIndicator());
      //   },
      // ),
    );
  }
}
