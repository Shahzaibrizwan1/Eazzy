// ignore_for_file: unnecessary_import, unused_import, unused_field, unused_local_variable, dead_code, unused_element

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:ezzychat/API/Apis.dart';
import 'package:ezzychat/Model/chat_user_model.dart';
import 'package:ezzychat/Screens/auth/login_screen.dart';
import 'package:ezzychat/Utils/date_time.dart';
import 'package:ezzychat/Utils/snackbar.dart';
import 'package:ezzychat/main.dart';
import 'package:ezzychat/widgets/chat_user_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

class ViewProfileScreen extends StatefulWidget {
  final ChatUserModel users;
  const ViewProfileScreen({Key? key, required this.users}) : super(key: key);

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          title: Text(widget.users.name),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
            child: Column(
              children: [
                SizedBox(
                  width: mq.width,
                  height: mq.height * .08,
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(mq.height * .1),
                  child: CachedNetworkImage(
                    width: mq.height * .15,
                    height: mq.height * .15,
                    fit: BoxFit.cover,
                    imageUrl: widget.users.image,
                    // placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => CircleAvatar(
                      child: Icon(CupertinoIcons.person),
                    ),
                  ),
                ),
                SizedBox(
                  height: mq.height * .03,
                ),
                Text(
                  widget.users.email,
                  style: TextStyle(color: Colors.black54, fontSize: 16),
                ),
                SizedBox(
                  height: mq.height * .02,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'About: ',
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500),
                    ),
                    Text(
                      widget.users.about,
                      style: TextStyle(color: Colors.black54, fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Joined On : ',
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500),
            ),
            Text(
              MyDateUtil.getLastMessageTime(
                  showYear: true,
                  context: context,
                  time: widget.users.createdAt),
              style: TextStyle(color: Colors.black54, fontSize: 16),
            ),
          ],
        ),
        // floatingActionButton: Padding(
        //   padding: const EdgeInsets.only(bottom: 20),
        //   child: FloatingActionButton.extended(
        //     backgroundColor: Colors.blueGrey.shade200,
        //     onPressed: () async {
        //       //for showing progress dialog
        //       Dialogs.showprogressbar(context);
        //       await Apis.updateActiveStatus(false);
        //       await Apis.auth.signOut().then((value) async {
        //         await GoogleSignIn().signOut().then((value) {
        //           //for hiding progress dialog
        //           Navigator.pop(context);
        //           //for moving to home screen
        //           Navigator.pop(context);
        //           Apis.auth = FirebaseAuth.instance;
        //           //replacing home Screen to login screen
        //           Navigator.pushReplacement(context,
        //               MaterialPageRoute(builder: (context) => LoginScreen()));
        //         });
        //       });
        //     },
        //     icon: Icon(Icons.logout),
        //     label: Text('Logout'),
        //   ),
        // ),
      ),
    );
  }
}
