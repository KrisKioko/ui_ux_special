import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reply/custom_transition_page.dart';

import 'home.dart';
import 'inbox.dart';
import 'model/email_store.dart';

class MailViewRouterDelegate extends RouterDelegate<void> with ChangeNotifier, PopNavigatorRouterDelegateMixin {
  MailViewRouterDelegate({required this.drawerController});

  final AnimationController drawerController;

  @verride
  Widget build(BuildContext context) {
    bool handlePopPage(Route<dynamic> route, dynamic result) {
      return false;
    }
    return Selector<EmailStore, String>(
      selector: (context, emailStore) => emailStore.currentlySelectedInbox,
      builder:(context, currentlySelectedInbox, child) {
        return Navigator(
          key: navigatorKey,
          onPopPage: handlePopPage,
          pages: [
            // TODO: Add Fade through transition between mailbox pages (Motion)
            CustomTransitionPage(
              transitionKey: ValueKey(currentlySelectedInbox),
              screen: InboxPage(
                destination: currentlySelectedInbox,
              ),
            ),
          ],
        );
      }
    );
  }

  @override
  GlobalKey<NavigatorState> get navigatorKey => mobileMailNavKey;

  @override
  Future<bool> popRoute() {
    
  }
}