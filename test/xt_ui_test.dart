import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:xt_ui/xt_ui.dart';
// import '../lib/wdgt/xtInfoBox.dart';
// import '../lib/xt_helpers.dart';

void main() {
  // test('adds one to input values', () {
  //   final calculator = Calculator();
  //   expect(calculator.addOne(2), 3);
  //   expect(calculator.addOne(-7), -6);
  //   expect(calculator.addOne(0), 1);
  // });
  testWidgets('MyWidget has a title and message', (tester) async {
    // Test code goes here.
    await tester.pumpWidget(
      const MaterialApp(
        home: xtInfoBox(
          width: 300,
          boarderColor: xtLightGreen2,
          borderRadius: 15,
          text: 'Meter Reading',
          textColor: Colors.white,
          icon: Icon(
            Icons.check_circle,
            color: xtLightGreen2,
          ),
        ),
      ),
    );
  });
}
