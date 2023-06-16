import 'dart:developer';
import 'package:ezzychat/API/Apis.dart';
import 'package:ezzychat/Model/chat_user_model.dart';
import 'package:ezzychat/Screens/auth/login_screen.dart';
import 'package:ezzychat/Screens/profile_screen.dart';
import 'package:ezzychat/Utils/snackbar.dart';
import 'package:ezzychat/main.dart';
import 'package:ezzychat/widgets/chat_user_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUserModel> _list = [];
  final List<ChatUserModel> _searchList = [];
  bool _isSearching = false;
  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();
    //for setting user status to active
    //for updating user active status according to lifecycle events
    //resume --active or online
    //pause -- inactive or offline
    SystemChannels.lifecycle.setMessageHandler((message) {
      log('message${message}');
      if (APIs.auth.currentUser != null) {
        if (message.toString().contains('resume')) {
          APIs.updateActiveStatus(true);
        }
        if (message.toString().contains('pause')) {
          APIs.updateActiveStatus(false);
        }
      }
      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () {
          if (_isSearching) {
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            actions: [
              InkWell(
                  onTap: () {
                    setState(() {
                      _isSearching = !_isSearching;
                    });
                  },
                  child: Icon(_isSearching
                      ? CupertinoIcons.clear_circled_solid
                      : Icons.search)),
              SizedBox(
                width: 5,
              ),
              // InkWell(
              //     onTap: () {
              //       Navigator.push(
              //           context,
              //           MaterialPageRoute(
              //               builder: (context) => ProfileScreen(
              //                     users: APIs.me,
              //                   )));
              //     },
              //     child: Icon(Icons.more_vert_outlined)),
              // SizedBox(
              //   width: 10,
              // ),
            ],
            // leading: Icon(CupertinoIcons.home),
            title: _isSearching
                ? TextFormField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search name,email...',
                    ),
                    autofocus: true,
                    style: TextStyle(fontSize: 17, letterSpacing: 0.5),
                    onChanged: (value) {
                      _searchList.clear();
                      for (var i in _list) {
                        if (i.name
                                .toLowerCase()
                                .contains(value.toLowerCase()) ||
                            i.email
                                .toLowerCase()
                                .contains(value.toLowerCase())) {
                          _searchList.add(i);
                        }
                        setState(() {
                          _searchList;
                        });
                      }
                    },
                  )
                : Text('Eazzy Chat'),
            centerTitle: true,
          ),
          drawer: Drawer(
            child: Padding(
              padding: EdgeInsets.only(top: mq.height * .04),
              child: ListView(
                children: [
                  // ListTile(
                  //   leading: Icon(Icons.newspaper, color: Colors.black87),
                  //   onTap: () {
                  //     Navigator.push(
                  //         context,
                  //         MaterialPageRoute(
                  //             builder: (context) => FireStoreScreen()));
                  //   },
                  //   title: Text('Notes'),
                  // ),

                  ListTile(
                    leading: Icon(Icons.edit, color: Colors.black87),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProfileScreen(
                                    users: APIs.me,
                                  )));
                    },
                    title: Text('Update Profile'),
                  ),
                  ListTile(
                    leading: Image(
                      image: AssetImage(
                        'Assets/user.png',
                      ),
                      height: mq.height * .035,
                    ),
                    onTap: () async {
                      _addChatUserDialog();
                    },
                    title: Text('Add Friend'),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.logout,
                      color: Colors.black,
                    ),
                    onTap: () async {
                      //for showing progress dialog
                      Dialogs.showprogressbar(context);
                      await APIs.updateActiveStatus(false);
                      await APIs.auth.signOut().then((value) async {
                        await GoogleSignIn().signOut().then((value) {
                          //for hiding progress dialog
                          Navigator.pop(context);
                          //for moving to home screen
                          Navigator.pop(context);
                          APIs.auth = FirebaseAuth.instance;
                          //replacing home Screen to login screen
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginScreen()));
                        });
                      });
                    },
                    title: Text('Log Out'),
                  )
                ],
              ),
            ),
          ),
          body: StreamBuilder(
            stream: APIs.getMyUsersId(),

            //get id of only known users
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                //if data is loading
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return const Center(child: CircularProgressIndicator());

                //if some or all data is loaded then show it
                case ConnectionState.active:
                case ConnectionState.done:
                  return StreamBuilder(
                    stream: APIs.getAllUsers(
                        snapshot.data?.docs.map((e) => e.id).toList() ?? []),

                    //get only those user, who's ids are provided
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        //if data is loading
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                        // return const Center(
                        //     child: CircularProgressIndicator());

                        //if some or all data is loaded then show it
                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data?.docs;
                          _list = data
                                  ?.map((e) => ChatUserModel.fromJson(e.data()))
                                  .toList() ??
                              [];

                          if (_list.isNotEmpty) {
                            return ListView.builder(
                                itemCount: _isSearching
                                    ? _searchList.length
                                    : _list.length,
                                padding: EdgeInsets.only(top: mq.height * .01),
                                physics: const BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return ChatUser(
                                      user: _isSearching
                                          ? _searchList[index]
                                          : _list[index]);
                                });
                          } else {
                            return const Center(
                              child: Text('No Contact Found!',
                                  style: TextStyle(fontSize: 20)),
                            );
                          }
                      }
                    },
                  );
              }
            },
          ),
          // floatingActionButton: Padding(
          //   padding: const EdgeInsets.only(bottom: 20),
          //   child: FloatingActionButton(
          //     backgroundColor: Colors.blueGrey.shade200,
          //     onPressed: () async {
          //       _addChatUserDialog();
          //     },
          //     child: Icon(Icons.add),
          //   ),
          // ),
        ),
      ),
    );
  }

  void _addChatUserDialog() {
    String email = '';

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding: const EdgeInsets.only(
                  left: 24, right: 24, top: 20, bottom: 10),

              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),

              //title
              title: Row(
                children: [
                  Icon(
                    Icons.person_add,
                    color: Colors.blueGrey.shade200,
                    size: 28,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    ' Add User',
                    style: TextStyle(color: Colors.blueGrey.shade200),
                  )
                ],
              ),

              //content
              content: TextFormField(
                maxLines: null,
                onChanged: (value) => email = value,
                decoration: InputDecoration(
                    hintText: 'Enter Email to add....',
                    prefixIcon:
                        Icon(Icons.email, color: Colors.blueGrey.shade200),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blueGrey.shade200),
                        borderRadius: BorderRadius.circular(15)),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blueGrey.shade200),
                        borderRadius: BorderRadius.circular(15)),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blueGrey.shade200),
                        borderRadius: BorderRadius.circular(15))),
              ),

              //actions
              actions: [
                //cancel button
                MaterialButton(
                    onPressed: () {
                      //hide alert dialog
                      Navigator.pop(context);
                    },
                    child: Text('Cancel',
                        style: TextStyle(
                            color: Colors.blueGrey.shade200, fontSize: 16))),

                //add button
                MaterialButton(
                    onPressed: () async {
                      //hide alert dialog
                      Navigator.pop(context);
                      if (email.isNotEmpty) {
                        await APIs.addChatUser(email).then((value) {
                          if (!value) {
                            Dialogs.showsnackbar(
                                context, 'User does not Exists!');
                          }
                        });
                      }
                    },
                    child: Text(
                      'Add',
                      style: TextStyle(
                          color: Colors.blueGrey.shade200, fontSize: 16),
                    ))
              ],
            ));
  }
}
