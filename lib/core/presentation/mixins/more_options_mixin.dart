import 'package:flutter/material.dart';
import '../../data/models/post_model.dart';
import '../widgets/small_menu_widget.dart';
import '../screens/create_post_screen.dart';
import '../widgets/exit_dialog_helper.dart';
import '../widgets/navigation/navigator.dart';
import 'package:social_app/core/constants/app_colors.dart';
import 'package:social_app/core/constants/app_borders.dart';
import 'package:social_app/core/presentation/mixins/post_context.dart';


mixin MoreOptionsMixin <T extends StatefulWidget> on State<T>, TickerProvider implements PostContext{
  bool isOpen = false;
  double value = 35.0;

  late Animation<double> animation;
  late AnimationController controller;

  //Getters
  String get postType;

  String get titleName;

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
      value = 70.0;
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
              borderRadius: AppBorders.borderRadius_10,
              color: AppColors.lightGrey300
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