import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:social_app/core/constants/app_durations.dart';
import 'package:social_app/features/search/presentation/utils/search_debouncer.dart';


void main() {
  group('SearchDebounce', () {
    test('calls onSearch after delay when text is not empty', () {
      fakeAsync((async) {
        var searchCalled = false;
        var clearCalled = false;

        final debounce = SearchDebounce(
          delay: const Duration(milliseconds: 500),
          onSearch: () => searchCalled = true,
          onClear: () => clearCalled = true,
        );

        debounce.controller.text = 'Ali';

        // قبل delay — لا شيء
        async.elapse(const Duration(milliseconds: 499));
        expect(searchCalled, false);

        // بعد delay — onSearch
        async.elapse(const Duration(milliseconds: 1));
        expect(searchCalled, true);
        expect(clearCalled, false);

        debounce.dispose();
      });
    });

    test('calls onClear after delay when text is empty', () {
      fakeAsync((async) {
        var searchCalled = false;
        var clearCalled = false;

        final debounce = SearchDebounce(
          delay: const Duration(milliseconds: 500),
          onSearch: () => searchCalled = true,
          onClear: () => clearCalled = true,
        );

        debounce.controller.text = '';

        async.elapse(const Duration(milliseconds: 500));

        expect(searchCalled, false);
        expect(clearCalled, true);

        debounce.dispose();
      });
    });

    test('cancels previous timer on rapid typing', () {
      fakeAsync((async) {
        var searchCount = 0;

        final debounce = SearchDebounce(
          delay: const Duration(milliseconds: 500),
          onSearch: () => searchCount++,
          onClear: () {},
        );

        // 3 تغييرات سريعة
        debounce.controller.text = 'A';
        async.elapse(const Duration(milliseconds: 100));
        debounce.controller.text = 'Al';
        async.elapse(const Duration(milliseconds: 100));
        debounce.controller.text = 'Ali';

        // بعد 500ms من آخر تغيير
        async.elapse(const Duration(milliseconds: 500));

        // onSearch مرة واحدة فقط (debounce)
        expect(searchCount, 1);

        debounce.dispose();
      });
    });

    test('uses default delay from AppDurations', () {
      fakeAsync((async) {
        var searchCalled = false;

        final debounce = SearchDebounce(
          onSearch: () => searchCalled = true,
          onClear: () {},
        );

        debounce.controller.text = 'Ali';

        // قبل AppDurations.debounce — لا شيء
        async.elapse(AppDurations.debounce - const Duration(milliseconds: 1));
        expect(searchCalled, false);

        // بعد — onSearch
        async.elapse(const Duration(milliseconds: 1));
        expect(searchCalled, true);

        debounce.dispose();
      });
    });

    test('text getter returns controller text', () {
      final debounce = SearchDebounce(
        onSearch: () {},
        onClear: () {},
      );

      debounce.controller.text = 'Ali';
      expect(debounce.text, 'Ali');

      debounce.dispose();
    });

    test('clear calls onClear and clears text', () {
      var clearCalled = false;

      final debounce = SearchDebounce(
        onSearch: () {},
        onClear: () => clearCalled = true,
      );

      debounce.controller.text = 'Ali';
      debounce.clear();

      expect(debounce.text, '');
      expect(clearCalled, true);

      debounce.dispose();
    });

    test('dispose cancels timer so callback does not fire', () {
      fakeAsync((async) {
        var searchCalled = false;

        final debounce = SearchDebounce(
          delay: const Duration(milliseconds: 500),
          onSearch: () => searchCalled = true,
          onClear: () {},
        );

        debounce.controller.text = 'Ali';
        async.elapse(const Duration(milliseconds: 100));

        debounce.dispose();  // ← إلغاء

        async.elapse(const Duration(seconds: 1));
        expect(searchCalled, false);
      });
    });

    test('dispose is safe when no timer is pending', () {
      fakeAsync((async) {
        final debounce = SearchDebounce(
          onSearch: () {},
          onClear: () {},
        );

        // لا تغيير — لا timer
        expect(() => debounce.dispose(), returnsNormally);
      });
    });
  });
}