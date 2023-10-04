import 'dart:developer';
import 'dart:io';
import 'package:chat_app1/modals/Messagemodel.dart';
import 'package:chat_app1/modals/Messagemodel.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app1/main.dart';
import 'package:chat_app1/modals/userModals.dart';
import 'package:chat_app1/pages/user_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../modals/ChatRoomModal.dart';
import '../modals/Messagemodel.dart';
import '../modals/Messagemodel.dart';

class ChatRoomPage extends StatefulWidget {
  final UserModal targetUser;
  final ChatRoomModel chatroom;
  final UserModal userModal;
  final User firebaseUser;
  final MessageModel? messageModel;

  const ChatRoomPage({
    Key? key,
    required this.targetUser,
    required this.chatroom,
    required this.userModal,
    required this.firebaseUser,
    this.messageModel,
  }) : super(key: key);

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

String forward = "";

class _ChatRoomPageState extends State<ChatRoomPage> {
  File? pickedImage;
  String copy = "";
  TextEditingController messageController = TextEditingController();
  bool isemoji = false;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool seen = false;

  void sendMessage() async {
    String msg = messageController.text.trim();
    messageController.clear();

    if (msg != "") {
      DateTime currentDateTime = DateTime.now();
      MessageModel newMessage = MessageModel(
        messageid: uuid.v1(),
        sender: widget.targetUser.uid,
        createdon: currentDateTime,
        text: msg,
        seen: false,
      );
      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatroomid)
          .collection("messages")
          .doc(newMessage.messageid)
          .set(newMessage.toMap());
      widget.chatroom.lastMessage = msg;
      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatroomid)
          .set(widget.chatroom.toMap());

      log("send message!");
    }
  }

  // Future<void> markMessageAsSeen(MessageModel message) async {
  //   if (!message.seen && message.sender != widget.userModal.uid) {
  //     // Update the 'seen' field of the specific message in Firestore
  //     await FirebaseFirestore.instance
  //         .collection("chatrooms")
  //         .doc(widget.chatroom.chatroomid)
  //         .collection("messages")
  //         .doc(message.messageid)
  //         .update({"seen": true});
  //   }
  // }

  // Future<void> markMessageAsUnseen(MessageModel message) async {
  //   if (message.seen && message.sender != widget.userModal.uid) {
  //     // Update the 'seen' field of the specific message in Firestore
  //     await FirebaseFirestore.instance
  //         .collection("chatrooms")
  //         .doc(widget.chatroom.chatroomid)
  //         .collection("messages")
  //         .doc(message.messageid)
  //         .update({"seen": false});
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => User_Profile(
                  userModal: widget.userModal,
                  targetUser: widget.targetUser,
                ),
              ),
            );
          },
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey,
                backgroundImage:
                    NetworkImage(widget.targetUser.profilepic.toString()),
                child: GestureDetector(
                  onTap: () {
                    setState(() {});
                  },
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Text(widget.targetUser.fullname.toString()),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return SimpleDialog(
                    children: <Widget>[
                      SimpleDialogOption(
                        onPressed: () {
                          deleteChat();
                        },
                        child: Text(
                          'Clear Chat',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("chatrooms")
                        .doc(widget.chatroom.chatroomid)
                        .collection("messages")
                        .orderBy("createdon", descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.active) {
                        // markMessageAsSeen(
                        //     currentMessage.messageid.toString());

                        if (snapshot.hasData) {
                          QuerySnapshot dataSnapshot =
                              snapshot.data as QuerySnapshot;

                          return ListView.builder(
                            reverse: true,
                            itemCount: dataSnapshot.docs.length,
                            itemBuilder: (context, index) {
                              MessageModel currentMessage =
                                  MessageModel.fromMap(
                                dataSnapshot.docs[index].data()
                                    as Map<String, dynamic>,
                              );
                              markMessageAsSeen(currentMessage);

                              String formattedTime = DateFormat('hh:mm a')
                                  .format(currentMessage.createdon);
                              //debugPrint("mark");
                              return Dismissible(
                                key: UniqueKey(),
                                background: Container(
                                  color: Colors.red,
                                  child: Align(
                                    child: Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                    ),
                                    alignment: Alignment.centerLeft,
                                  ),
                                ),
                                onDismissed: (direction) async {
                                  if (direction ==
                                          DismissDirection.startToEnd &&
                                      currentMessage.sender !=
                                          widget.userModal.uid) {
                                    DocumentReference chatRoomRef =
                                        FirebaseFirestore.instance
                                            .collection("chatrooms")
                                            .doc(widget.chatroom.chatroomid);

                                    // Delete a message
                                    await FirebaseFirestore.instance
                                        .collection("chatrooms")
                                        .doc(widget.chatroom.chatroomid)
                                        .collection("messages")
                                        .doc(currentMessage.messageid)
                                        .delete();

                                    QuerySnapshot messagesSnapshot =
                                        await chatRoomRef
                                            .collection("messages")
                                            .orderBy("createdon",
                                                descending: true)
                                            .get();

                                    if (messagesSnapshot.docs.isNotEmpty) {
                                      String latestMessage =
                                          messagesSnapshot.docs.first["text"];

                                      await FirebaseFirestore.instance
                                          .collection("chatrooms")
                                          .doc(widget.chatroom.chatroomid)
                                          .set(
                                        {"lastmessage": latestMessage},
                                        SetOptions(merge: true),
                                      );
                                    } else {
                                      await chatRoomRef.update({
                                        "lastmessage": "",
                                      });
                                    }

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Message deleted'),
                                      ),
                                    );
                                  }
                                },
                                child: Row(
                                  mainAxisAlignment: (currentMessage.sender ==
                                          widget.userModal.uid)
                                      ? MainAxisAlignment.start
                                      : MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.symmetric(vertical: 2),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: (currentMessage.sender ==
                                                widget.userModal.uid)
                                            ? Theme.of(context)
                                                .colorScheme
                                                .secondary
                                            : Color.fromARGB(
                                                255, 108, 219, 112),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            '${currentMessage.text.toString()} - $formattedTime',
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                          Icon(
                                            Icons.done_all,
                                            color: currentMessage.seen
                                                ? Colors.blue
                                                : Colors.grey,
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              );
                            },
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text(
                                "An error occurred. Please check your internet connection."),
                          );
                        } else {
                          return Center(
                            child: Text("Say hi to your new friend!"),
                          );
                        }
                      } else {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  ),
                ),
              ),
              InkWell(
                onLongPress: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          content: SizedBox(
                            height: 60,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                    onTap: () {
                                      messageController.text = copy;
                                      Navigator.pop(context);
                                    },
                                    child: const Text('paste')),
                                InkWell(
                                    onTap: () {
                                      setState(() {
                                        messageController.text = forward;
                                      });

                                      Navigator.pop(context);
                                    },
                                    child: Text('copy forwarded message')),
                              ],
                            ),
                          ),
                        );
                      });
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.grey[200],
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {});
                        },
                        icon: Icon(
                          Icons.emoji_emotions,
                          color: Colors.grey,
                        ),
                      ),
                      Flexible(
                        child: TextField(
                          controller: messageController,
                          maxLines: 1,
                          decoration: InputDecoration(
                            hintText: "Enter Message",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          getImage(ImageSource.gallery);
                        },
                        icon: Icon(
                          Icons.image,
                          color: Colors.grey,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          getImage(ImageSource.camera);
                        },
                        icon: Icon(
                          Icons.camera_alt,
                          color: Colors.grey,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          sendMessage();
                        },
                        icon: Icon(
                          Icons.send,
                          color: const Color.fromARGB(255, 4, 92, 7),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> deleteChat() async {
    final messagesCollection = FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(widget.chatroom.chatroomid)
        .collection("messages");

    final messagesSnapshot = await messagesCollection.get();
    for (final doc in messagesSnapshot.docs) {
      await doc.reference.delete();
    }
    await FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(widget.chatroom.chatroomid)
        .set({"lastmessage": ""}, SetOptions(merge: true));
    setState(() {});
  }

  Future<void> getImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;

      final imageTemporary = File(image.path);
      setState(() {
        pickedImage = imageTemporary;
      });
    } on PlatformException {
      print("Failed to pick image");
    }
  }
  // static Future<void>updateMessageReadStatus(Message  message )async{
  //   firestore.collection('chat')

  // }
  //
  Future<void> markMessageAsSeen(MessageModel message) async {
    if (!message.seen && message.sender != widget.userModal.uid) {
      // Update the 'seen' field of the specific message in Firestore
      await FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatroomid)
          .collection("messages")
          .doc(message.messageid)
          .update({"seen": true});
    }
    Future<void> markMessageAsSeen(MessageModel message) async {
      if (!message.seen && message.sender != widget.userModal.uid) {
        // Update the 'seen' field of the specific message in Firestore
        await FirebaseFirestore.instance
            .collection("chatrooms")
            .doc(widget.chatroom.chatroomid)
            .collection("messages")
            .doc(message.messageid)
            .update({"seen": true});
      }
    }

    Future<void> markMessageAsUnseen(MessageModel message) async {
      if (message.seen && message.sender != widget.userModal.uid) {
        // Update the 'seen' field of the specific message in Firestore
        await FirebaseFirestore.instance
            .collection("chatrooms")
            .doc(widget.chatroom.chatroomid)
            .collection("messages")
            .doc(message.messageid)
            .update({"seen": false});
      }
    }
  }
}
