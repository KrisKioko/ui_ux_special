import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package::provider/provider.dart';
import 'package:provider/provider.dart';
import 'package:reply/model/router_provider.dart';

import 'bottom_drawer.dart';
import 'colors.dart';
import 'compose_page.dart';
import 'mail_view_router.dart';
import 'model/email_store.dart';
import 'router.dart';
import 'settings_bottom_sheet.dart';
import 'waterfall_notched_rectangle.dart';

const _assetPackage = 'gallery';
const _iconAssetLocation = 'reply/icons';
const _folderIconAssetLocation = '$_iconAssetLocation/2tone_folder.png';
final mobileMailNavKey = GlobalKey<NavigatorState>();
const double _kFlingVelocity = 2.0;
const _kAnimationDuration =Duration(microseconds: 300);


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => HomePageState();
}



class HomePageState extends State<HomePage> {
  late final AnimationController _drawerController;
  late final AnimationController _dropArrowController;
  late final AnimatedContainer _bottomAppBarController;
  late final Animation<double> _drawerCurve;
  late final Animation<double> _dropArrowCurve;
  late final Animation<double> _bottomAppBarCurve;

  final _bottomDrawerKey = GlobalKey(debugLabel: 'Bottom Drawer');
  final _navigationDestinations = const <_Destination>[
    _Destination(
      name: 'Inbox',
      icon: '$_iconAssetLocation/2tone_inbox.png',
      index: 0,
    ),
    _Destination(
      name: 'Starred',
      icon: '$_iconAssetLocation/2tone_star.png',
      index: 1,
    ),
    _Destination(
      name: 'Sent',
      icon: '$_iconAssetLocation/2tone_send.png',
      index: 2,
    ),
    _Destination(
      name: 'Trash',
      icon: '$_iconAssetLocation/2tone_delete.png',
      index: 3,
    ),
    _Destination(
      name: 'Spam',
      icon: '$_iconAssetLocation/2tone_erro.png',
      index: 4,
    ),
    _Destination(
      name: 'Drafts',
      icon: '$_iconAssetLocation/2tone_drafts.png',
      index: 5,
    ),
  ];

  final _folders = <String, String>{
    'Receipts': _folderIconAssetLocation,
    'Pine Elementary': _folderIconAssetLocation,
    'Taxes': _folderIconAssetLocation,
    'Vacation': _folderIconAssetLocation,
    'Mortgage': _folderIconAssetLocation,
    'Freelance': _folderIconAssetLocation,
  };

  @override
  void initState() {
    super.initState();

    _drawerController = AnimationController(
      duration: _kAnimationDuration,
      value: 0,
      vsync: this,
    )..addListener(() {
      if (_drawerController.status == AnimationStatus.dismissed && _drawerController.value == 0) {
        Provider.of<EmailStore>(
          context,
          listen: false,
        ).bottomDrawerVisible = false;
      }

      if (_drawerController.value < 0.01) {
        setState(() {
          //Reload state when drawer is at its smallest to toggle visibility
          //If state is reloaded before this drawer closes abruptly instead
          //of animating.
        });
      }
    });

    _dropArrowController = AnimationController(
      duration: _kAnimationDuration,
      vsync: this,
    );

    _bottomAppBarController = AnimationController(
      vsync: this,
      value: 1,
      duration: const Duration(milliseconds: 250),      
    );

    _drawerCurve = CurvedAnimation(
      parent: _drawerController,
      curve: standardEasing,
      reverseCurve: standardEasing.flipped,
    );

    _dropArrowCurve = CurvedAnimation(
      parent: _dropArrowController,
      curve: standardEasing,
      reverseCurve: standardEasing.flipped,
    );

    _bottomAppBarCurve = CurvedAnimation(
      parent: _bottomAppBarController,
      curve: standardEasing,
      reverseCurve: standardEasing.flipped,
    );
  }

  @override
  void dispose() {
    _drawerController.dispose();
    _dropArrowController.dispose();
    _bottomAppBarController.dispose();
    super.dispose();
  }

  void _onDestinationSelected(String destination) {
    var emailStore = Provider.of<EmailStore>(
      context,
      listen: false,
    );

    if (emailStore.onMailView) {
      emailStore.currentlySelectedEmailId = -1;
    }

    if (emailStore.currentlySelectedInbox != destination) {
      emailStore.currentlySelectedInbox = destination;
    }

    setState(() {});
  }

  bool get _bottomDrawerVisible {
    final status = _drawerController.status;
    return status == AnimationStatus.completed || status == AnimationStatus.forward;
  }

  void _toggleBottomDrawerVisibility() {
    if (_drawerController.value < 0.4) {
      Provider.of<EmailStore>(
        context,
        listen: false,
      ).bottomDrawerVisible = true;
      _drawerController.animateTo(0.4, curve: standardEasing);
      _dropArrowController.animateTo(0.35, curve: standardEasing);
      return;
    }

    _dropArrowController.forward();
    _drawerController.fling(
      velocity: _bottomDrawerVisible ? -_kFlingVelocity : _kFlingVelocity,
    );
  }

  double get _bottomDrawerHeight {
    final renderBox = _bottomDrawerKey.currentContext!.findRenderObject() as RenderBox;
    return renderBox.size.height;
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    _drawerController.value -= details.primaryDelta! / _bottomDrawerHeight;
  }

  void _handleDragEnd(DragUpdateDetails details) {
    if (_drawerController.isAnimating || _drawerController.status == AnimationStatus.completed) {
      return;
    }

    final flingVelocity = details.velocity.pixelsPerSecond.dy / _bottomDrawerHeight;

    if (flingVelocity < 0.0) {
      _drawerController.fling(
        velocity: math.max(_kFlingVelocity, -flingVelocity),
      );
    } else if (flingVelocity > 0.0) {
      _dropArrowController.forward();
      _drawerController.fling(
        velocity: math.min(-_kFlingVelocity, -flingVelocity),
      );
    } else {
      if (_drawerController.value < 0.6) {
        _dropArrowController.forward();
      }
      _dropArrowController.fling(
        velocity: _drawerController.value < 0.6 ? -_kFlingVelocity : _kFlingVelocity,
      );
    }
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.depth == 0) {
      if (notification is UserScrollNotification) {
        switch (notification.direction) {
          case ScrollDirection.forward: _bottomAppBarController.forward();
            break;
          case ScrollDirection.reverse: _bottomAppBarController.reverse();
            break;
          case ScrollDirection.idle: 
            break;
        }
      }
    }
    return false;
  }

  Widget _buildStack(BuildContext context, BoxConstraints constraints) {
    final drawerSize = constraints.biggest;
    final drawerTop = drawerSize.height;
    final ValueChanged<String> updateMailbox = _onDestinationSelected;

    final drawerAnimation = RelativeRectTween(
      begin: RelativeRect.fromLTRB(0.0, drawerTop, 0.0, 0.0),
      end: const RelativeRect.fromLTRB(0.0, 0.0, 0.0, 0.0),
    ).animate(_drawerCurve);

    return Stack(
      clipBehavior: Clip.none,
      key: _bottomDrawerKey,
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: _handleScrollNotification,
          child: _MailRouter(
            drawerController: _drawerController,
          ),
        ),

        GestureDetector(
          onTap: () {
            _drawerController.reverse();
            _dropArrowController.reverse();
          },
          child: Visibility(
            maintainAnimation: true,
            maintainState: true,
            visible: _bottomDrawerVisible,
            child: FadeTransition(
              opacity: _drawerCurve,
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                color:  Theme.of(context).bottomSheetTheme.modalBackgroundColor,
              ),
            ),
          ),
        ),
        PositionedTransition(
          rect: drawerAnimation,
          child: Visibility(
            visible: _bottomDrawerVisible,
            child: BottomDrawer(
              onVerticalDragEnd: _handleDragUpdate,
              onVerticalDragEnd: _handleDragEnd,
              leading: _BottomDrawerDestinations(
                destinations: _navigationDestinations,
                drawerController: _drawerController,
                dropArrowController: _dropArrowController,
                onItemTapped: _updateMailbox,
              ),
              trailing: _BottomDrawerFolderSection(folders: _folders),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: LayoutBuilder(
        builder: _buildStack,
      ),
      bottomNavigationBar: _AnimatedBottomAppBar(
        bottomAppBarController: _bottomAppBarController,
        bottomAppBarCurve: _bottomAppBarCurve,
        bottomDrawerVisible: _bottomDrawerVisible,
        drawerController: _drawerController,
        dropArrowCurve: _dropArrowCurve,
        toggleBottomDrawerVisibility: _toggleBottomDrawerVisibility,
      ),
      floatingActionButton: _bottomDrawerVisible ? null : const Padding(
        padding: EdgeInsetsDirectional.only(bottom: 8),
        child: _ReplyFab(),
      ),
      floatingActionButtonAnimator: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class _AnimatedBottomAppBar extends StatelessWidget {
  const _AnimatedBottomAppBar({
    required this.bottomAppBarController,
    required this.bottomAppBarCurve,
    required this.bottomDrawerVisible,
    required this.drawerController,
    required this.dropArrowCurve,
    required this.toggleBottomDrawerVisibility,
  });

  final AnimationController bottomAppBarController;
  final Animation<double> bottomAppBarCurve;
  final bool bottomDrawerVisible;
  final AnimationController drawerController;
  final Animation<double> dropArrowCurve;
  final VoidCallback toggleBottomDrawerVisibility;

  @override
  Widget build(BuildContext context) {
    var fadeOut = Tween<double>(begin: 1, end: -1).animate(
      drawerController.drive(CurveTween(curve: standardEasing)),
    );

    return Selector<EmailStore, bool>(
      selector: (context, emailStore) => emailStore.onMailView,
      builder: (context, onMailView, child) {
        bottomAppBarController.forward();

        return SizeTransition(
          sizeFactor: bottomAppBarCurve,
          axisAlignment: -1,
          child: Padding(
            padding: const EdgeInsetsDirectional.only(top: 2),
            child: BottomAppBar(
              shape: const WaterfallNotchedRectangle(),
              notchMargin: 6,
              child: Container(
                color: Colors.transparent,
                height: kToolbarHeight,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      borderRadius: const BorderRadius.all(Radius.circular(16)),
                      onTap: toggleBottomDrawerVisibility,
                      child: Row(
                        children: [
                          const SizedBox(width: 16),

                          RotationTransition(
                            turns: Tween(
                              begin: 0.0,
                              end: 1.0,
                            ).animate(dropArrowCurve),
                            child: Icon(
                              Icons.arrow_drop_up,
                              color: ReplyColors.white50,
                            ),
                          ),

                          const SizedBox(width: 8),

                          const _ReplyLogo(),

                          const SizedBox(width: 10),

                          // TODO: Add Fade through transition between disappearing mailbox title (Motion)

                          onMailView ? const SizedBox(width: 48) : FadeTransition(
                            opacity: fadeOut,
                            child: Selector<EmailStore, String>(
                              selector: (context, emailStore) => emailStore.currentlySelectedInbox,
                              builder: (context, currentlySelectedInbox, child) {
                                return Text(
                                  currentlySelectedInbox,
                                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                    color: ReplyColors.white50,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: Container(
                        color: Colors.transparent,
                        child: _BottomAppBarActionItems(
                          drawerController: drawerController,
                          drawerVisible: bottomDrawerVisible,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }, 
    );
  }
}

class _BottomAppBarActionItems extends StatelessWidget {
  const _BottomAppBarActionItems({required this.drawerController, required this.drawerVisible});
  

  final AnimationController drawerController;
  final bool drawerVisible;

  @override
  Widget build(BuildContext context) {
    return Consumer<EmailStore>(
      builder: (context, model, child) {
        final onMailView = model.onMailView;
        var radius = const Radius.circular(12);
        final modalBorder = BorderRadius.only(
          topRight: radius,
          topLeft: radius,          
        );

        Color? starIconColor;

        if (onMailView) {
          var currentEmailStarred = false;

          if (model.emails[model.currentlySelectedInbox]!.isNotEmpty) {
            
          }
        }
      },
    );
  }
}