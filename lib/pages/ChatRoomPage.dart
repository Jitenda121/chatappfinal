import 'dart:developer';
import 'dart:io';
import 'package:chat_app1/modals/Messagemodel.dart';
import 'package:chat_app1/modals/UIHelper.dart';
import 'package:chat_app1/pages/ChatRoomPage.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:chat_app1/main.dart';
import 'package:chat_app1/modals/userModals.dart';
import 'package:chat_app1/pages/user_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
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
String message = "";
String read = "";

class _ChatRoomPageState extends State<ChatRoomPage> {
  File? pickedImage;
  String copy = "";
  MessageModel? selectedMessage;

  TextEditingController messageController = TextEditingController();
  bool isemoji = false;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool seen = false;
  bool _isMessageSeen = false;

  void sendMessage() async {
    String msg = messageController.text.trim();
    messageController.clear();

    String imageUrl = '';

    if (msg != "" || pickedImage != null) {
      
      DateTime currentDateTime = DateTime.now();
      MessageModel newMessage = MessageModel(
        messageid: uuid.v1(),
        sender: widget.targetUser.uid,
        createdon: currentDateTime,
        text: msg,
        seen: false,
        imageUrl: '',
        fromId: widget.targetUser.uid,
        toId: widget.firebaseUser.uid,
        read: '',
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
    }
  }

  void copyMessage(MessageModel message) {
    // Copy the message text to the clipboard
    final textToCopy =
        message.text ?? ''; // Provide an empty string as a default value
    Clipboard.setData(ClipboardData(text: textToCopy));

    // Show a notification or confirmation to the user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Message copied to clipboard'),
      ),
    );
  }

  void forwardMessage(MessageModel message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Forward Message'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Select Recipient'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final selectedRecipient = await selectRecipient(context);
                  if (selectedRecipient != null) {
                    //sendForwardedMessage(message, selectedRecipient);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void replyToMessage(MessageModel message) {
    // Set the selected message for replying
    setState(() {
      selectedMessage = message;
    });

    // Update the message input field with a prefix for the reply
    messageController.text = 'Replying to: ${message.text}\n';
  }

  Future<UserModal?> selectRecipient(BuildContext context) async {
    try {
      // final QuerySnapshot chatListSnapshot = await FirebaseFirestore.instance.collection("")
      // .collection("chatroom")
      // .where("participants", arrayContains: widget.userModal.uid)
      // .get();
      final QuerySnapshot chatListSnapshot = await FirebaseFirestore.instance
          .collection("chatrooms")
          .where("participants.${widget.userModal.uid}", isEqualTo: true)
          .get();

      if (chatListSnapshot.docs.isEmpty) {
        print("No chat data found.");
        return null;
      }

      final List<UserModal> chatList = chatListSnapshot.docs.map((doc) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return UserModal(
          uid: data['uid'],
          fullname: data['fullname'],
          profilepic: data['profilepic'],
          //blockedId: false, // Add other properties as needed.
        );
      }).toList();

      final selectedUser = await showDialog<UserModal>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Select Recipient'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                itemCount: chatList.length,
                itemBuilder: (context, index) {
                  final user = chatList[index];
                  // UserModal targetUser = user;

                  //var targetUser;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(user.profilepic.toString()),
                    ),
                    title: Text(widget.userModal.fullname.toString()),
                    onTap: () {
                      Navigator.of(context)
                          .pop(user); // Return the selected user
                    },
                  );
                },
              ),
            ),
          );
        },
      );

      return selectedUser;
    } catch (e) {
      print("Error fetching chat list: $e");
      return null; // Handle the error gracefully in your application.
    }
  }

//  void sendForwardedMessage(MessageModel message, UserModal recipient) async {
//  try {
//  // Create a new chat room if it doesn't exist between the sender and recipient.
//  final chatroomCollection =
//  FirebaseFirestore.instance.collection("chatrooms");
//  final chatroomQuery = await chatroomCollection.where("users",
//  arrayContainsAny: [widget.userModal.uid, recipient.uid]).get();

//  String chatroomId;

//  if (chatroomQuery.docs.isNotEmpty) {
//  // Chat room already exists
//  chatroomId = chatroomQuery.docs[0].id;
//  } else {
//  // Create a new chat room
//  final newChatroom = ChatRoomModel(
//  chatroomid: uuid.v1(),
//  //users: [widget.userModal.uid, recipient.uid],
//  lastMessage: message.text, participants: {},
//  // You may need to set other properties of the chat room here.
//  );

//  await chatroomCollection
//  .doc(newChatroom.chatroomid)
//  .set(newChatroom.toMap());
//  //chatroomId = newChatroom.chatroomid;
//  }
//  }
//  }

//   final forwardedMessage = MessageModel(
//  messageid: message.messageid,
//  sender: message.sender,
//  createdon: DateTime.now(),
//  text: message.text,
//  seen: false,

//  );

//  await chatroomCollection
//  .doc(chatroomId)
//  .collection("messages")
//  .doc(forwardedMessage.messageid)
//  .set(forwardedMessage.toMap());

//  // Optionally, update the lastMessage field of the chat room.
//  await chatroomCollection
//  .doc(chatroomId)
//  .set({"lastmessage" = forwardedMessage.text}, SetOptions(merge: true));

//  print("Forwarded message sent!");
//  } catch (e) {
//  print("Error sending forwarded message: $e");
//  }
//  }
//  }

  void sendForwardedMessage(MessageModel message, UserModal recipient) async {
    try {
      // Create a new chat room if it doesn't exist between the sender and recipient.
      final chatroomCollection =
          FirebaseFirestore.instance.collection("chatrooms");
      final chatroomQuery = await chatroomCollection.where("users",
          arrayContainsAny: [widget.userModal.uid, recipient.uid]).get();

      String chatroomId;

      if (chatroomQuery.docs.isNotEmpty) {
        // Chat room already exists
        chatroomId = chatroomQuery.docs[0].id;
      } else {
        // Create a new chat room
        final newChatroom = ChatRoomModel(
          chatroomid: uuid.v1(),
          users: [widget.userModal.uid, recipient.uid],
          lastMessage: message.text, participants: {},
          // You may need to set other properties of the chat room here.
        );

        await chatroomCollection
            .doc(newChatroom.chatroomid)
            .set(newChatroom.toMap());
        chatroomId = newChatroom.chatroomid!;
      }

      // Add the forwarded message to the chat room
      final forwardedMessage = MessageModel(
        messageid: message.messageid,
        sender: message.sender,
        createdon: DateTime.now(),
        text: message.text,
        seen: false,
        fromId: '',
        toId: '',
        read: '',
      );

      await chatroomCollection
          .doc(chatroomId)
          .collection("messages")
          .doc(forwardedMessage.messageid)
          .set(forwardedMessage.toMap());

      // Optionally, update the lastMessage field of the chat room.
      await chatroomCollection
          .doc(chatroomId)
          .set({"lastmessage": forwardedMessage.text}, SetOptions(merge: true));

      print("Forwarded message sent!");
    } catch (e) {
      print("Error sending forwarded message: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 5, 35, 59),
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
                          //deleteChat();
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
          // color: Colors.amber,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                  "https://img.freepik.com/premium-vector/social-networks-dating-apps-vector-seamless-pattern_341076-469.jpg"),
              fit: BoxFit.cover,
            ),
          ),

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
                        if (snapshot.hasData) {
                          QuerySnapshot dataSnapshot =
                              snapshot.data as QuerySnapshot;
                          for (DocumentSnapshot doc in dataSnapshot.docs) {
                            MessageModel newMessage = MessageModel.fromMap(
                              doc.data() as Map<String, dynamic>,
                            );
                          }

                          return ListView.builder(
                            reverse: true,
                            itemCount: dataSnapshot.docs.length,
                            itemBuilder: (context, index) {
                              MessageModel currentMessage =
                                  MessageModel.fromMap(
                                dataSnapshot.docs[index].data()
                                    as Map<String, dynamic>,
                              );

                              String formattedTime = DateFormat('hh:mm a')
                                  .format(currentMessage.createdon);

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
                                    // GestureDetector(
                                    //   onLongPress: () {
                                    //     //showOptionsDialog(currentMessage);
                                    //   },
                                    // ),
                                    InkWell(
                                      onTap: () {
                                        showOptionsDialog(currentMessage);
                                      },
                                      child: Container(
                                        margin:
                                            EdgeInsets.symmetric(vertical: 2),
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
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          children: [
                                            Text(
                                              '${currentMessage.text.toString()} - $formattedTime',
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                            if (currentMessage.sender !=
                                                widget.userModal.uid)
                                              Icon(
                                                Icons.done_all,
                                              ),
                                          ],
                                        ),
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
              Container(
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
                        
                        // Check if there's an image in the TextField
                        // if (pickedImage != null &&
                        //     messageController.text.isEmpty) {
                        //   // Call checkValue function
                        //   checkValues();
                        // } else {
                        //   // Call sendMessage function
                        //   sendMessage();
                        // }
                      },
                      icon: Icon(
                        Icons.send,
                        color: const Color.fromARGB(255, 4, 92, 7),
                      ),
                    )
                    // IconButton(
                    //   onPressed: () {
                    //     sendMessage();
                    //   },
                    //   icon: Icon(
                    //     Icons.send,
                    //     color: const Color.fromARGB(255, 4, 92, 7),
                    //   ),
                    // )
                  ],
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

  Future<void> updateMessageReadStatus(String messageId) async {
    DocumentReference messageRef = FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(widget.chatroom.chatroomid)
        .collection("messages")
        .doc(messageId);

    DocumentSnapshot messageSnapshot = await messageRef.get();
    if (messageSnapshot.exists) {
      await messageRef.update({
        "seen": true,
        "read": DateTime.now().millisecondsSinceEpoch.toString(),
      });
    } else {
      // Handle the case where the document does not exist
      print("Document with ID $messageId does not exist.");
    }
  }

  void showOptionsDialog(MessageModel message) {
    // Display a dialog with options for copying, forwarding, and replying to the message
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Message Options'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.copy),
                title: Text('Copy Message'),
                onTap: () {
                  Navigator.of(context).pop();
                  copyMessage(message);
                },
              ),
              ListTile(
                leading: Icon(Icons.forward),
                title: Text('Forward Message'),
                onTap: () {
                  Navigator.of(context).pop();
                  forwardMessage(message);
                },
              ),
              ListTile(
                leading: Icon(Icons.reply),
                title: Text('Reply to Message'),
                onTap: () {
                  Navigator.of(context).pop();
                  replyToMessage(message);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Future<void> getImage(ImageSource source) async {
  //   try {
  //     final image = await ImagePicker().pickImage(source: source);
  //     if (image == null) return;

  //     final imageTemporary = File(image.path);
  //     setState(() {
  //       pickedImage = imageTemporary;
  //     });
  //   } on PlatformException {
  //     print("Failed to pick image");
  //   }
  // }

  void checkValues() {
    if (pickedImage == null) {
      UIHelper.showAlertDialog(context, "Incomplete data",
          "Please fill all the fields and upload a profile");
    } else {
      //debugPrint(imageurl)
      //log("Uploading Data.. ");
      //uploadData();
    }
  }

  // void uploadData() async {
  //   UIHelper.showLoadingDialog(context, "Uploading Image..");
  //   UploadTask uploadTask = FirebaseStorage.instance
  //       .ref("profilepicture")
  //       .child(widget.userModal.uid.toString())
  //       .putFile(pickedImage!);
  //   TaskSnapshot snapshot = await uploadTask;

  //   String? imageUrl = await snapshot.ref.getDownloadURL();
  //   widget.userModal.profilepic = imageUrl;
  //   await FirebaseFirestore.instance
  //       .collection("users")
  //       .doc(widget.userModal.uid)
  //       .set(widget.userModal.toMap())
  //       .then((value) {});
  //   debugPrint(imageUrl);
  // }
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
 Future<String> uploadImageToStorage(File imageFile) async {
 try {
 // Generate a unique filename for the image (you can use a UUID library)
 String fileName = "${uuid.v4()}.jpg";
 
 // Reference to Firebase Storage
 final storageRef = FirebaseStorage.instance.ref().child(fileName);
 
 // Upload the image
 await storageRef.putFile(imageFile);
 
 // Get the download URL of the uploaded image
 String imageUrl = await storageRef.getDownloadURL();
 
 return imageUrl;
 } catch (e) {
 print("Error uploading image: $e");
 return "";
 }
}
}
