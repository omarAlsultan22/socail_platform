class PhotoSection {
  static const int posts = 0;
  static const int profile = 1;
  static const int cover = 2;

  static const Map<String, int> byKey = {
    'post': posts,
    'profileImage': profile,
    'coverImage': cover
  };
}