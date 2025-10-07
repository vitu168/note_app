/// Simple test to verify the DynamicFriendlyDialog can be imported and used
import 'package:flutter/material.dart';
import 'dynamic_friendly_dialog.dart';
import '../../constants/enum_constant.dart';

class DialogTestWidget extends StatelessWidget {
  const DialogTestWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dialog Test')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Test that the dialog can be shown
            DynamicFriendlyDialog.show(
              context: context,
              type: DialogType.info,
              title: 'Test Dialog',
              message:
                  'This is a test message to verify the dialog works correctly.',
              confirmText: 'OK',
              onConfirm: () => Navigator.pop(context),
            );
          },
          child: const Text('Show Test Dialog'),
        ),
      ),
    );
  }
}
