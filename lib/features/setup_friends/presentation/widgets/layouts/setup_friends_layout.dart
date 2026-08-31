import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../main/presentation/screens/main_screen.dart';
import '../../../../../shared/componentes/public_components.dart';
import '../../../../../core/presentation/widgets/list_builder.dart';
import '../../../../../core/data/data_sources/local/cache_helper.dart';
import '../../../../interactions/interactions_layout/like_model_layout.dart';


class AddNewFriendsLayout extends StatefulWidget {
  const AddNewFriendsLayout({super.key});

  @override
  State<AddNewFriendsLayout> createState() => _AddNewFriendsLayoutState();
}

class _AddNewFriendsLayoutState extends State<AddNewFriendsLayout> {
  bool isActive = false;

  Future<void> addFriendsNumber() async {
    await CacheHelper.setBool(key: 'friends', value: true);
  }

  bool checkButtonIsActive(int addsNumber) {
    if (addsNumber >= 10) {
      setState(() {
        isActive = true;
      });
      addFriendsNumber();
      return isActive;
    }
    return isActive;
  }

  @override
  Widget build(BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              scrolledUnderElevation: 0.0,
              title: Text('Add New Friends'),
            ),
            body: Column(
              children: [
                Expanded(
                  child: ListBuilder(
                      list: dataList,
                      object: (object) =>
                          LikeModelLayout(/change this name
                            like: object,
                            onPressed: () =>
                            cubit
                              ..addFriend(1)
                              ..confirmNewFriend(uId: object.userId!),
                          ),
                      fallback: const Center(
                          child: CircularProgressIndicator())
                  ),
                ),
                Container(
                  width: double.infinity,
                  color: isActive ? Colors.amber : null,
                  child: MaterialButton(
                    onPressed: checkButtonIsActive(addsNumber) ? () =>
                    {
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => MainScreen()))
                    } : null,
                    child: Text('Finish'),
                  ),
                )
              ],
            ),
          );
  }
}

