import 'package:flutter/material.dart';


mixin LikeMixin<T extends StatefulWidget> on State<T> {
  bool isActive = false;
  int likes = 0;

  bool get initialIsActive;
  int get initialLikes;
  void onLikeToggle(bool isActive);

  void initLikeState() {
    isActive = initialIsActive;
    likes = initialLikes;
  }

  void likeToggle() {
    setState(() {
      isActive = !isActive;
      likes += isActive ? 1 : -1;
    });
    onLikeToggle(isActive);
  }
}