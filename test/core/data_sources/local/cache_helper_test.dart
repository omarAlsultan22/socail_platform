import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_app/core/domain/data_sources/local/cache_helper.dart';
import 'package:social_app/core/data/data_sources/local/cache_helper_impl.dart';


void main() {
  late CacheHelper cacheHelper;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    cacheHelper = CacheHelperImpl(prefs: prefs);
  });

  group('CacheHelper - Success', () {
    test('setString then getString returns same value', () async {
      await cacheHelper.setString(key: 'token', value: 'abc123');
      expect(await cacheHelper.getString(key: 'token'), 'abc123');
    });

    test('getString returns empty when key missing', () async {
      expect(await cacheHelper.getString(key: 'missing'), '');
    });

    test('setBool and getBool work', () async {
      await cacheHelper.setBool(key: 'isDark', value: true);
      expect(await cacheHelper.getBool(key: 'isDark'), true);
    });

    test('removeValue deletes the key', () async {
      await cacheHelper.setString(key: 'token', value: 'abc');
      await cacheHelper.removeValue(key: 'token');
      expect(await cacheHelper.getString(key: 'token'), '');
    });
  });
}