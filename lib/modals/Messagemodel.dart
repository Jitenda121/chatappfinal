// class MessageModel {
//   String? messageid;
//   String? sender;
//   String? text;
//   bool? seen;
//   DateTime? createdon;
//   MessageModel(
//       {this.messageid, this.sender, this.text, this.seen, this.createdon});
//   MessageModel.fromMap(Map<String, dynamic> map) {
//     messageid = map["messageid"];
//     sender = map["sender"];
//     text = map["text"];
//     seen = map["seen"];
//     createdon = map["createdon"].toDate();
//   }
//   Map<String, dynamic> toMap() {
//     return {
//       "messageid": messageid,
//       "sender": sender,
//       "text": text,
//       "seen": seen,
//       "createdon": createdon,
//     };
//   }
// }


class MessageModel {
   late String? messageid;
   late String? sender;
  late String text;
  late bool seen;
 late  DateTime createdon; // Making createdon required

  MessageModel({
    required this.messageid,
    required this.sender,
    required this.text,
    required this.seen,
    required this.createdon, // Making createdon required
  });

  MessageModel.fromMap(Map<String, dynamic> map) {
    messageid = map["messageid"];
    sender = map["sender"];
    text = map["text"];
    seen = map["seen"];
    createdon = map["createdon"].toDate();
  }

  Map<String, dynamic> toMap() {
    return {
      "messageid": messageid,
      "sender": sender,
      "text": text,
      "seen": seen,
      "createdon": createdon,
    };
  }
}
