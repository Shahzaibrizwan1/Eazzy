import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:ezzychat/API/Apis.dart';
import 'package:ezzychat/Model/chat_user_model.dart';
import 'package:ezzychat/Utils/snackbar.dart';
import 'package:ezzychat/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUserModel users;
  const ProfileScreen({Key? key, required this.users}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _image;
  final _formkey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          title: Text('Profile Screen'),
        ),
        body: Form(
          key: _formkey,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
              child: Column(
                children: [
                  SizedBox(
                    width: mq.width,
                    height: mq.height * .08,
                  ),
                  Stack(
                    children: [
                      _image != null
                          ? ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(mq.height * .1),
                              child: Image.file(
                                File(_image!),
                                width: mq.height * .15,
                                height: mq.height * .15,
                                fit: BoxFit.cover,
                              ),
                            )
                          : ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(mq.height * .1),
                              child: CachedNetworkImage(
                                width: mq.height * .15,
                                height: mq.height * .15,
                                fit: BoxFit.cover,
                                imageUrl: widget.users.image,
                                // placeholder: (context, url) => CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    CircleAvatar(
                                  child: Icon(CupertinoIcons.person),
                                ),
                              ),
                            ),
                      Positioned(
                        left: 65,
                        top: 80,
                        child: MaterialButton(
                          elevation: 1,
                          shape: CircleBorder(),
                          color: Colors.grey.shade100,
                          onPressed: () {
                            _showBottomSheet();
                          },
                          child: Icon(
                            Icons.edit,
                            size: 22,
                            color: Colors.blueGrey.shade200,
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: mq.height * .03,
                  ),
                  Text(
                    widget.users.email,
                    style: TextStyle(color: Colors.black54, fontSize: 16),
                  ),
                  SizedBox(
                    height: mq.height * .05,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.name,
                    initialValue: widget.users.name,
                    onSaved: (Value) => APIs.me.name = Value ?? '',
                    validator: (value) =>
                        value != null && value.isNotEmpty ? null : "Required*",
                    cursorColor: Colors.blueGrey.shade200,
                    decoration: InputDecoration(
                        hintText: 'Your Name',
                        labelText: 'Name',
                        labelStyle: TextStyle(color: Colors.blueGrey.shade700),
                        prefixIcon: Icon(
                          Icons.person,
                          color: Colors.blueGrey.shade200,
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.blueGrey.shade200),
                            borderRadius: BorderRadius.circular(12)),
                        enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.blueGrey.shade200),
                            borderRadius: BorderRadius.circular(12)),
                        border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.blueGrey.shade200),
                            borderRadius: BorderRadius.circular(12))),
                  ),
                  SizedBox(
                    height: mq.height * .04,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.multiline,
                    onSaved: (Value) => APIs.me.about = Value ?? '',
                    validator: (value) =>
                        value != null && value.isNotEmpty ? null : "Required*",
                    cursorColor: Colors.blueGrey.shade200,
                    initialValue: widget.users.about,
                    decoration: InputDecoration(
                        hintText: 'About',
                        labelText: 'About',
                        labelStyle: TextStyle(color: Colors.blueGrey.shade700),
                        prefixIcon: Icon(
                          Icons.info_outline,
                          color: Colors.blueGrey.shade200,
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.blueGrey.shade200),
                            borderRadius: BorderRadius.circular(12)),
                        enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.blueGrey.shade200),
                            borderRadius: BorderRadius.circular(12)),
                        border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.blueGrey.shade200),
                            borderRadius: BorderRadius.circular(12))),
                  ),
                  SizedBox(
                    height: mq.height * .06,
                  ),
                  ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey.shade200,
                          shape: StadiumBorder(),
                          minimumSize: Size(mq.width * .5, mq.height * .06)),
                      onPressed: () {
                        if (_formkey.currentState!.validate()) {
                          _formkey.currentState!.save();
                          APIs.updateUserInfo();
                          Dialogs.showsnackbar(
                              context, 'Profile updated successfully');
                          Navigator.pop(context);
                        }
                      },
                      icon: Icon(
                        Icons.edit,
                        size: 28,
                      ),
                      label: Text(
                        'Update',
                        style: TextStyle(fontSize: 16),
                      ))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showBottomSheet() {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            padding:
                EdgeInsets.only(top: mq.height * .03, bottom: mq.height * .04),
            children: [
              Text(
                'Pick Profile Picture ',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: mq.height * .02),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: CircleBorder(),
                          backgroundColor: Colors.white,
                          fixedSize: Size(mq.width * .3, mq.height * .15)),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        // Open a camera
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.camera, imageQuality: 80);
                        if (image != null) {
                          log('Image path ${image.path}');
                          setState(() {
                            _image = image.path;
                          });
                          APIs.updateProfilePicture(File(_image!));

                          Navigator.pop(context);
                        }
                      },
                      child: Image.asset('Assets/camera.png')),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: CircleBorder(),
                          backgroundColor: Colors.white,
                          fixedSize: Size(mq.width * .3, mq.height * .15)),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        // Pick an image.
                        final XFile? image =
                            await picker.pickImage(source: ImageSource.gallery);
                        if (image != null) {
                          log('Image path ${image.path} -- Mimetype ${image.mimeType}');
                          setState(() {
                            _image = image.path;
                          });
                          APIs.updateProfilePicture(File(_image!));

                          Navigator.pop(context);
                        }
                      },
                      child: Image.asset('Assets/picture.png'))
                ],
              )
            ],
          );
        });
  }
}
