import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'color.dart';
import 'home.dart';
import 'mail_view_page.dart';
import 'model/email_store.dart';
import 'profile_avatar.dart';

class MailPreviewCard extends StatelessWidget {
  const MailPreviewCard({
    Key? key,
    required this.id,
    required this.email,
    required this.onDelete,
    required this.onStar,
  }) : super(key: key);

  final int id;
  final Email email;
  final VoidCallback onDelete;
  final VoidCallback onStar;

  @override
  
}