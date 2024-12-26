import 'package:flutter/material.dart';
import 'package:prestige_prenew_frontend/components/customs/text_widget.dart';
import 'package:prestige_prenew_frontend/components/prenew_logo.dart';

class DeleteAccountWebView extends StatelessWidget {
  const DeleteAccountWebView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PrenewLogo(
            size: 250,
          ),
          TextWidget(
            text: 'DELETE ACCOUNT',
            fontSize: 28,
          ),
          TextWidget(
            text: 'Your account will be deleted in 10 to 12 business days.',
            textAlign: TextAlign.center,
            fontSize: 16,
          ),
        ],
      ),
    );
  }
}
