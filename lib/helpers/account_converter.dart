import 'package:cloud_firestore/cloud_firestore.dart';


class AccountModelConverter {
  Map<String, dynamic> modelMap;

  AccountModelConverter({required this.modelMap});

  factory AccountModelConverter.fromDocumentSnapshot(DocumentSnapshot snapshot){
    Map <String, dynamic> modelMap = {};
    if (snapshot.data() != null) {
      modelMap = snapshot.data() as Map<String, dynamic>;
    }
    return AccountModelConverter(modelMap: modelMap);
  }
}