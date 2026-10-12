import 'package:flutter/material.dart';
import '../../data/models/post_model.dart';
import '../screens/create_post_screen.dart';
import '../../services/session_service.dart';
import '../widgets/navigation/navigator.dart';
import '../widgets/new/small_menu_widget.dart';
import '../../data/models/message_result.dart';
import '../widgets/new/exit_dialog_helper.dart';
import '../../../features/public/data/models/user_details.dart';


mixin MoreOptionsMixin <T extends StatefulWidget> on State<T>, TickerProvider{
  bool isOpen = false;
  double value = 35.0;

  late Animation<double> animation;
  late AnimationController controller;

  //Getters
  String get postType;

  String get titleName;

  PostModel get postModel;

  UserDetails get userDetails;

  MessageResult get messageResult;

  SessionService get sessionService;

  void Function(PostModel) get onUpsert;

  void Function(PostModel)? get onRemove;

  @override
  void initState() {
    super.initState();

    addAnimationValue();
    controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    animation = Tween(begin: 0.0, end: value).animate(controller)
      ..addListener(() {
        setState(() {});
      });
  }

  void addAnimationValue() {
    if (postModel.myId == sessionService.currentUid) {
      setState(() {
        value = 70.0;
      });
    }
  }

  void _toggleAnimation(bool isOpen) {
    if (isOpen) {
      controller.forward();
    } else {
      controller.reverse();
    }
  }

  void _animationController() {
    setState(() {
      isOpen = !isOpen;
      _toggleAnimation(isOpen);
    });
  }

  Widget buildMoreOptions() {
    return Column(
      children: [
        IconButton(
          onPressed: () => _animationController(),
          icon: Icon(Icons.more_horiz),
        ),
        Container(
          width: 100.0,
          height: isOpen ? animation.value : animation.value,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Colors.grey.shade300
          ),
          child: Column(
            children: [
              animation.value == value &&
                  postModel.myId == sessionService.currentUid ?
              SmallMenuWidget(
                  context: context,
                  buttonName: 'Edit',
                  onPressed: () async {
                    BuildNavigator.build(
                      context: context,
                      link: CreatePostScreen(
                          buttonName: 'Save',
                          titleName: titleName,
                          onPressed: onUpsert,
                          postModel: postModel,
                          userDetails: userDetails,
                          messageResult: messageResult,
                          currentId: sessionService.currentUid
                      ),
                    );
                    _animationController();
                  }
              ) : SizedBox(),
              animation.value == value ?
              SmallMenuWidget(
                context: context,
                buttonName: 'Delete',
                onPressed: () async {
                  await ExitDialogHelper.showExitDialog(
                      context: context,
                      onPressed: (val) {
                        if (!val) return;
                        if (postModel.myId == sessionService.currentUid) {
                          onRemove!.call(postModel);
                        }
                      },
                      type: postType,
                      messageResult: messageResult
                  );
                  _animationController();
                },
              ) : SizedBox(),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}