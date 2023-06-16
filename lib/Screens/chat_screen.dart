// ignore_for_file: unnecessary_import, unused_import, unused_field

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:ezzychat/API/Apis.dart';
import 'package:ezzychat/Model/chat_user_model.dart';
//import 'package:ezzychat/Screens/mic.dart';
import 'package:ezzychat/Screens/view_profile_screen.dart';
import 'package:ezzychat/Utils/date_time.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:image_picker/image_picker.dart';
//import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../Model/message_model.dart';
import '../main.dart';
import '../widgets/message_card.dart';

class ChatScreen extends StatefulWidget {
  final ChatUserModel user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController _controller = TextEditingController();
  //final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  List<Message> _list = [];
  bool _showemoji = false, _isuploading = false;
  @override
  void initState() {
    super.initState();
    //  _speech.initialize(
    //  onError: (error) => print('Error: $error'),
    //onStatus: (status) {
    //if (status == 'notListening') {
    //_isListening = false;
    //} else {
    //_isListening = true;
    // }
    //},
    //);
  }

  // void _toggleListening() async {
  //   if (_isListening) {
  //     await _speech.stop();
  //     _isListening = false;
  //   } else {
  //     await _speech.listen(
  //       onResult: (result) {
  //         if (result.finalResult) {
  //           _controller.text = result.recognizedWords;
  //           _controller.selection = TextSelection.fromPosition(
  //             TextPosition(offset: _controller.text.length),
  //           );
  //         }
  //       },
  //     );
  //     _isListening = true;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: WillPopScope(
          onWillPop: () {
            if (_showemoji) {
              setState(() {
                _showemoji = !_showemoji;
              });
              return Future.value(false);
            } else {
              return Future.value(true);
            }
          },
          child: Scaffold(
            backgroundColor: Color.fromARGB(255, 236, 242, 245),
            appBar: AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: _appBar(),
            ),
            body: Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                      stream: APIs.getAllMessages(widget.user),
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                          case ConnectionState.none:
                            return Center(
                              child: SizedBox(),
                            );
                          case ConnectionState.active:
                          case ConnectionState.done:
                            final data = snapshot.data?.docs;
                            //    log('message${jsonEncode(data![0].data())}');
                            _list = data
                                    ?.map((e) => Message.fromJson(e.data()))
                                    .toList() ??
                                [];
                            //final _list = ['hi', 'hello'];
                            // _list.clear();
                            // _list.add(Message(
                            //     msg: 'Hii',
                            //     read: '',
                            //     told: 'xyz',
                            //     type: Type.text,
                            //     sent: '12:00 AM',
                            //     fromId: Apis.user.uid));
                            // _list.add(Message(
                            //     msg: 'Hello',
                            //     read: '',
                            //     told: Apis.user.uid,
                            //     type: Type.text,
                            //     sent: '12:05 AM',
                            //     fromId: 'xyz'));
                            if (_list.isNotEmpty) {
                              return ListView.builder(
                                  reverse: true,
                                  itemCount: _list.length,
                                  physics: BouncingScrollPhysics(),
                                  padding:
                                      EdgeInsets.only(top: mq.height * .01),
                                  itemBuilder: (context, index) {
                                    return MessageCard(
                                      message: _list[index],
                                    );
                                  });
                            } else {
                              return Center(
                                  child: Text(
                                'Say Hi 👋',
                                style: TextStyle(fontSize: 20),
                              ));
                            }
                        }
                      }),
                ),
                if (_isuploading)
                  Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 20),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )),
                _chatInput(),
                if (_showemoji)
                  SizedBox(
                    height: mq.height * .35,
                    // width: mq.width*,
                    child: EmojiPicker(
                      textEditingController:
                          _controller, // pass here the same [TextEditingController] that is connected to your input field, usually a [TextFormField]
                      config: Config(
                        columns: 9,
                        emojiSizeMax: 32 *
                            (Platform.isIOS
                                ? 1.30
                                : 1.0), // Issue: https://github.com/flutter/flutter/issues/28894
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _appBar() {
    return InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ViewProfileScreen(
                        users: widget.user,
                      )));
        },
        child: StreamBuilder(
            stream: APIs.getUserInfo(widget.user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              final list =
                  data?.map((e) => ChatUserModel.fromJson(e.data())).toList() ??
                      [];

              return Row(
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.black54,
                      )),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .3),
                    child: CachedNetworkImage(
                      width: mq.height * .05,
                      height: mq.height * .05,
                      imageUrl:
                          list.isNotEmpty ? list[0].image : widget.user.image,
                      // placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => CircleAvatar(
                        child: Icon(CupertinoIcons.person),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        list.isNotEmpty ? list[0].name : widget.user.name,
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500),
                      ),
                      SizedBox(
                        height: 2,
                      ),
                      Text(
                          list.isNotEmpty
                              ? list[0].isOnline
                                  ? 'Online'
                                  : MyDateUtil.getLastActiveTime(
                                      context: context,
                                      lastActive: list[0].lastActive)
                              : MyDateUtil.getLastActiveTime(
                                  context: context,
                                  lastActive: widget.user.lastActive),
                          style: const TextStyle(
                              fontSize: 13, color: Colors.black54)),
                    ],
                  )
                ],
              );
            }));
  }

  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: mq.height * .01, horizontal: mq.width * .025),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  IconButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        setState(() => _showemoji = !_showemoji);
                      },
                      icon: Icon(
                        Icons.emoji_emotions,
                        color: Colors.blueGrey.shade200,
                      )),
                  Expanded(
                      child: TextFormField(
                    controller: _controller,
                    maxLines: null,
                    onTap: () {
                      if (_showemoji) setState(() => _showemoji = !_showemoji);
                    },
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                        // suffixIcon: IconButton(
                        //   icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
                        //   onPressed: _toggleListening,
                        // ),
                        hintText: 'Message',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.blueGrey)),
                  )),
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        // Open a gallery
                        final List<XFile> images =
                            await picker.pickMultiImage(imageQuality: 70);
                        for (var i in images) {
                          log('Image path ${i.path}');
                          setState(() => _isuploading = true);
                          await APIs.sendChatImage(widget.user, File(i.path));
                          setState(() => _isuploading = false);
                        }
                      },
                      icon: Icon(
                        Icons.image,
                        color: Colors.blueGrey.shade200,
                      )),
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        // Open a camera
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.camera, imageQuality: 70);
                        if (image != null) {
                          log('Image path ${image.path}');
                          setState(() => _isuploading = true);
                          await APIs.sendChatImage(
                              widget.user, File(image.path));
                          setState(() => _isuploading = false);
                          // Navigator.pop(context);
                        }
                      },
                      icon: Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.blueGrey.shade200,
                      )),
                  SizedBox(width: mq.width * .02),
                ],
              ),
            ),
          ),
          // MaterialButton(
          //   onPressed: () {
          //     _toggleListening();
          //     //WS SpeechToTextFormField();
          //   },
          //   minWidth: 0,
          //   padding: EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
          //   shape: CircleBorder(),
          //   color: Colors.blueGrey.shade200,
          //   child: Padding(
          //     padding: const EdgeInsets.only(right: 4),
          //     child: Icon(
          //       _isListening ? Icons.mic : Icons.mic_none,
          //       color: Colors.white,
          //     ),
          //   ),
          // ),
          MaterialButton(
            onPressed: () {
              if (_controller.text.isNotEmpty) {
                if (_list.isEmpty) {
                  APIs.sendFirstMessage(
                      widget.user, _controller.text, Type.text);
                  // _controller.text = '';
                } else {
                  APIs.sendMessage(widget.user, _controller.text, Type.text);
                }
                _controller.text = '';
              }
            },
            minWidth: 0,
            padding: EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
            shape: CircleBorder(),
            color: Colors.blueGrey.shade200,
            child: Icon(
              Icons.send,
              size: 27,
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }
}
