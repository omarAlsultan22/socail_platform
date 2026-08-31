import 'package:cloud_firestore/cloud_firestore.dart';


class AccountConverter {
  Map<String, dynamic> modelMap;

  AccountConverter({required this.modelMap});

  factory AccountConverter.fromDocumentSnapshot(DocumentSnapshot snapshot){
    Map <String, dynamic> modelMap = {};
    if (snapshot.data() != null) {
      modelMap = snapshot.data() as Map<String, dynamic>;
    }
    return AccountConverter(modelMap: modelMap);
  }
}