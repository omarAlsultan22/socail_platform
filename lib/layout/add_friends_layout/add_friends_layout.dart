import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../modules/new_friends_screen/cubit.dart';
import '../../shared/componentes/public_components.dart';
import '../../shared/networks/local/shared_preferences.dart';
import 'package:social_app/shared/cubit_states/cubit_states.dart';
import '../../layout/interactions_layout/likes_layout/likes_layout.dart';
import '../main_layout/main_layout.dart';


class AddNewFriendsLayout extends StatefulWidget {
  const AddNewFriendsLayout({super.key});

  @override
  State<AddNewFriendsLayout> createState() => _AddNewFriendsLayoutState();
}

class _AddNewFriendsLayoutState extends State<AddNewFriendsLayout> {
  bool isActive = false;

  Future<void> addFriendsNumber() async {
    await CacheHelper.serIntValue(key: 'friendsCount', value: 10);
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
    return BlocBuilder<AddNewFriendsCubit, CubitStates>(
        builder: (context, state) {
          final cubit = AddNewFriendsCubit.get(context);
          final dataList = cubit.dataList;
          var addsNumber = cubit.addsNumber;
          return Scaffold(
            appBar: AppBar(
              scrolledUnderElevation: 0.0,
              title: Text('Add New Friends'),
            ),
            body: Column(
              children: [
                Expanded(
                  child: Container(
                    child: ListBuilder(
                        list: dataList,
                        object: (object) =>
                            LikesModel(
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
                ),
                Container(
                  width: double.infinity,
                  color: isActive ? Colors.amber : null,
                  child: MaterialButton(
                    onPressed: checkButtonIsActive(addsNumber) ? () =>
                    {
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => MainLayout()))
                    } : null,
                    child: Text('Finish'),
                  ),
                )
              ],
            ),
          );
        });
  }
}

