import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/profile_management/cubits/update_score_and_coins_cubit.dart';
import 'package:flutterquiz/features/profile_management/cubits/update_user_details_cubit.dart';
import 'package:flutterquiz/features/profile_management/cubits/user_details_cubit.dart';
import 'package:flutterquiz/features/profile_management/profile_management_local_data_source.dart';
import 'package:flutterquiz/features/profile_management/profile_management_repository.dart';
import 'package:flutterquiz/features/quiz/cubits/quiz_category_cubit.dart';
import 'package:flutterquiz/features/quiz/cubits/quizzone_category_cubit.dart';
import 'package:flutterquiz/features/quiz/models/quiz_type.dart';
import 'package:flutterquiz/features/system_config/cubits/system_config_cubit.dart';
import 'package:flutterquiz/ui/screens/home/widgets/all.dart';
import 'package:flutterquiz/ui/widgets/all.dart';
import 'package:flutterquiz/utils/constants/constants.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({required this.isGuest, super.key});

  final bool isGuest;

  @override
  State<HomeScreen> createState() => _HomeScreenState();

  static Route<HomeScreen> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider<UpdateScoreAndCoinsCubit>(
            create: (_) =>
                UpdateScoreAndCoinsCubit(ProfileManagementRepository()),
          ),
          BlocProvider<UpdateUserDetailCubit>(
            create: (_) => UpdateUserDetailCubit(ProfileManagementRepository()),
          ),
        ],

        // * enter to home screen as user or as guest if isGuest true or false
        child: HomeScreen(isGuest: routeSettings.arguments! as bool),
      ),
    );
  }
}

typedef ZoneType = ({String title, String img, String desc});

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  /// Quiz Zone globals
  int oldCategoriesToShowCount = 0;
  bool isCateListExpanded = false;
  bool canExpandCategoryList = false;

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Screen dimensions
  double get scrWidth => context.width;

  double get scrHeight => context.height;

  // HomeScreen horizontal margin, change from here
  double get hzMargin => scrWidth * UiUtils.hzMarginPct;

  double get _statusBarPadding => MediaQuery.of(context).padding.top;

  // TextStyles
  // check build() method
  late var _boldTextStyle = TextStyle(
    fontWeight: FontWeights.bold,
    fontSize: 18,
    color: Theme.of(context).colorScheme.onTertiary,
  );

  ///
  late String _currLangId;
  late final SystemConfigCubit _sysConfigCubit;
  final _quizZoneId =
      UiUtils.getCategoryTypeNumberFromQuizType(QuizTypes.quizZone);

  @override
  void initState() {
    super.initState();

    setQuizMenu();

    WidgetsBinding.instance.addObserver(this);

    ///
    _currLangId = UiUtils.getCurrentQuizLanguageId(context);
    _sysConfigCubit = context.read<SystemConfigCubit>();
    final quizCubit = context.read<QuizCategoryCubit>();
    final quizZoneCubit = context.read<QuizoneCategoryCubit>();

    if (widget.isGuest) {
      quizCubit.getQuizCategory(languageId: _currLangId, type: _quizZoneId);
      quizZoneCubit.getQuizCategory(languageId: _currLangId);
    } else {
      fetchUserDetails();

      quizCubit.getQuizCategoryWithUserId(
        languageId: _currLangId,
        type: _quizZoneId,
      );
      quizZoneCubit.getQuizCategoryWithUserId(languageId: _currLangId);
    }
  }

  void setQuizMenu() {
    // ! remove this later
    Future.delayed(Duration.zero, () {
      setState(() {});
    });
  }

  @override
  void dispose() {
    ProfileManagementLocalDataSource.updateReversedCoins(0);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    //show you left the game
    if (state == AppLifecycleState.resumed) {
      UiUtils.needToUpdateCoinsLocally(context);
    } else {
      ProfileManagementLocalDataSource.updateReversedCoins(0);
    }
  }

  void _onTapProfile() => Navigator.of(context).pushNamed(
        Routes.menuScreen,
        arguments: widget.isGuest,
      );



   // * show login dialog every time is not logged in for UX
  Future<void> _showLoginDialog() {
    return showLoginDialog(
      context,
      onTapYes: () {
        Navigator.of(context).pop();
        Navigator.of(context).pushNamed(Routes.login);
      },
    );
  }

  late String _userName = context.tr('guest')!;
  late String _userProfileImg = Assets.profile('7.png');

  Widget _buildProfileContainer() {
    return Align(
      alignment: Alignment.topCenter,
      child: GestureDetector(
        onTap: _onTapProfile,
        child: Container(
          margin: EdgeInsets.only(
            top: _statusBarPadding * .2,
            left: hzMargin,
            right: hzMargin,
          ),
          width: scrWidth,
          child: LayoutBuilder(
            builder: (_, constraint) {
              final size = context;

              return Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    width: constraint.maxWidth * 0.15,
                    height: constraint.maxWidth * 0.15,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .onTertiary
                            .withValues(alpha: 0.3),
                      ),
                    ),
                    child: QImage.circular(imageUrl: _userProfileImg),
                  ),
                  SizedBox(width: size.width * .03),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: constraint.maxWidth * 0.5,
                        child: Text(
                          '${context.tr(helloKey)!}, ${widget.isGuest ? 'Challenger' : _getFirstName(_userName)}', //taha
                          maxLines: 1,
                          style: _boldTextStyle,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        context.tr(letsPlay)!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context)
                              .colorScheme
                              .onTertiary
                              .withValues(alpha: 0.3),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),

                  const Spacer(),

                  /// Leader


                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // Define _getFirstName inside the _HomeScreenState class
  String _getFirstName(String fullName) {
    //taha
    // Split the full name by spaces and return the first part.
    return fullName.split(' ')[0];
  }

  Widget _buildCategory() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: hzMargin),
          child: Row(
            children: [
              Text(
                context.tr('quizZone')!,
                style: _boldTextStyle,
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  widget.isGuest
                      ? _showLoginDialog()
                      : Navigator.of(context).pushNamed(
                          Routes.category,
                          arguments: {'quizType': QuizTypes.quizZone},
                        );
                },
                child: Text(
                  context.tr(viewAllKey) ?? viewAllKey,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context)
                        .colorScheme
                        .onTertiary
                        .withValues(alpha: .6),
                  ),
                ),
              ),
            ],
          ),
        ),
        Wrap(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Theme.of(context).colorScheme.surface,
                    ),
                    margin: EdgeInsets.only(
                      left: hzMargin,
                      right: hzMargin,
                      top: 10,
                      bottom: 26,
                    ),
                    width: context.width,
                    child: quizZoneCategories(),
                  ),
                ),

                /// Expand Arrow
                if (canExpandCategoryList) ...[
                  Positioned(
                    left: 0,
                    right: 0,
                    // Position the center bottom arrow, from here
                    bottom: -9,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.transparent),
                        shape: BoxShape.circle,
                        color: Theme.of(context).scaffoldBackgroundColor,
                      ),
                      child: GestureDetector(
                        onTap: () => setState(() {
                          isCateListExpanded = !isCateListExpanded;
                        }),
                        child: Container(
                          width: 30,
                          height: 30,
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            !isCateListExpanded
                                ? Icons.keyboard_arrow_down_rounded
                                : Icons.keyboard_arrow_up_rounded,
                            color: Theme.of(context).primaryColor,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget quizZoneCategories() {
    return BlocConsumer<QuizoneCategoryCubit, QuizoneCategoryState>(
      bloc: context.read<QuizoneCategoryCubit>(),
      listener: (context, state) {
        if (state is QuizoneCategoryFailure) {
          if (state.errorMessage == errorCodeUnauthorizedAccess) {
            showAlreadyLoggedInDialog(context);
          }
        }
      },
      builder: (context, state) {
        if (state is QuizoneCategoryFailure) {
          return ErrorContainer(
            showRTryButton: false,
            showBackButton: false,
            showErrorImage: false,
            errorMessage: convertErrorCodeToLanguageKey(state.errorMessage),
            onTapRetry: () {
              context.read<QuizoneCategoryCubit>().getQuizCategoryWithUserId(
                    languageId: UiUtils.getCurrentQuizLanguageId(context),
                  );
            },
          );
        }

        if (state is QuizoneCategorySuccess) {
          final categories = state.categories;
          final int categoriesToShowCount;

          /// Min/Max Categories to Show.
          const minCount = 5;
          const maxCount = 7;

          /// need to check old cate list with new cate list, when we change languages.
          /// and rebuild the list.
          if (oldCategoriesToShowCount != categories.length) {
            Future.delayed(Duration.zero, () {
              oldCategoriesToShowCount = categories.length;
              canExpandCategoryList = oldCategoriesToShowCount > minCount;
              setState(() {});
            });
          }

          if (!isCateListExpanded) {
            categoriesToShowCount =
                categories.length <= minCount ? categories.length : minCount;
          } else {
            categoriesToShowCount =
                categories.length <= maxCount ? categories.length : maxCount;
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 10),
            shrinkWrap: true,
            itemCount: categoriesToShowCount,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, i) {
              final category = categories[i];

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                onTap: () {
                  if (widget.isGuest) {
                    _showLoginDialog();
                    return;
                  }

                  if (category.isPremium && !category.hasUnlocked) {
                    showUnlockPremiumCategoryDialog(
                      context,
                      categoryId: category.id!,
                      categoryName: category.categoryName!,
                      requiredCoins: category.requiredCoins,
                      isQuizZone: true,
                    );
                    return;
                  }

                  //noOf means how many subcategory it has
                  //if subcategory is 0 then check for level
                  if (category.noOf == '0') {
                    //means this category does not have level
                    if (category.maxLevel == '0') {
                      //direct move to quiz screen pass level as 0
                      Navigator.of(context).pushNamed(
                        Routes.quiz,
                        arguments: {
                          'numberOfPlayer': 1,
                          'quizType': QuizTypes.quizZone,
                          'categoryId': category.id,
                          'subcategoryId': '',
                          'level': '0',
                          'subcategoryMaxLevel': '0',
                          'unlockedLevel': 0,
                          'quizName': 'Quiz Zone',
                          'showRetryButton': category.noOfQues! != '0',
                        },
                      );
                    } else {
                      Navigator.of(context).pushNamed(
                        Routes.levels,
                        arguments: {
                          'Category': category,
                        },
                      );
                    }
                  } else {
                    Navigator.of(context).pushNamed(
                      Routes.subcategoryAndLevel,
                      arguments: {
                        'category_id': category.id,
                        'category_name': category.categoryName,
                      },
                    );
                  }
                },
                horizontalTitleGap: 15,
                leading: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Theme.of(context).scaffoldBackgroundColor,
                      ),
                    ),
                    padding: const EdgeInsets.all(5),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(1),
                      child: QImage(
                        imageUrl: category.image!,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),

                /// right_arrow
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PremiumCategoryAccessBadge(
                      hasUnlocked: category.hasUnlocked,
                      isPremium: category.isPremium,
                    ),
                    const SizedBox(width: 10),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Theme.of(context).scaffoldBackgroundColor,
                        ),
                      ),
                      padding: const EdgeInsets.all(2),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 20,
                        color: Theme.of(context).colorScheme.onTertiary,
                      ),
                    ),
                  ],
                ),
                title: Text(
                  category.categoryName!,
                  style: _boldTextStyle.copyWith(fontSize: 16),
                ),
                subtitle: Text(
                  category.noOf == '0'
                      ? "${context.tr("questionLbl")}: ${category.noOfQues!}"
                      : "${context.tr('subCategoriesLbl')}: ${category.noOf}",
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context)
                        .colorScheme
                        .onTertiary
                        .withValues(alpha: 0.6),
                  ),
                ),
              );
            },
          );
        }

        return const Center(child: CircularProgressContainer());
      },
    );
  }

  String _userRank = '0';
  String _userCoins = '0';
  String _userScore = '0';

  Widget _buildHome() {
    return Stack(
      children: [
        RefreshIndicator(
          color: Theme.of(context).primaryColor,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          onRefresh: () async {
            fetchUserDetails();

            _currLangId = UiUtils.getCurrentQuizLanguageId(context);
            final quizCubit = context.read<QuizCategoryCubit>();
            final quizZoneCubit = context.read<QuizoneCategoryCubit>();

            if (widget.isGuest) {
              await quizCubit.getQuizCategory(
                languageId: _currLangId,
                type: _quizZoneId,
              );
              await quizZoneCubit.getQuizCategory(languageId: _currLangId);
            } else {
              await quizCubit.getQuizCategoryWithUserId(
                languageId: _currLangId,
                type: _quizZoneId,
              );

              await quizZoneCubit.getQuizCategoryWithUserId(
                languageId: _currLangId,
              );
            }
            setState(() {});
          },
          child: ListView(
            children: [
              _buildProfileContainer(),
              UserAchievements(
                userRank: _userRank,
                userCoins: _userCoins,
                userScore: _userScore,
              ),
              BlocBuilder<QuizoneCategoryCubit, QuizoneCategoryState>(
                builder: (context, state) {
                  if (state is QuizoneCategoryFailure &&
                      state.errorMessage == errorCodeDataNotFound) {
                    return const SizedBox.shrink();
                  }

                  if (_sysConfigCubit.isQuizZoneEnabled) {
                    return _buildCategory();
                  }

                  return const SizedBox.shrink();
                },
              ),
            ],
            //taha
          ),
        ),
      ],
    );
  }

  void fetchUserDetails() {
    context.read<UserDetailsCubit>().fetchUserDetails();
  }

  bool profileComplete = false;

  @override
  Widget build(BuildContext context) {
    /// need to add this here, cause textStyle doesn't update automatically when changing theme.
    _boldTextStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18,
      color: Theme.of(context).colorScheme.onTertiary,
    );

    return Scaffold(
      body: SafeArea(
        child: widget.isGuest
            ? _buildHome()

            /// Build home with User
            : BlocConsumer<UserDetailsCubit, UserDetailsState>(
                bloc: context.read<UserDetailsCubit>(),
                listener: (context, state) {
                  if (state is UserDetailsFetchSuccess) {
                    if (state.userProfile.profileUrl!.isEmpty ||
                        state.userProfile.name!.isEmpty) {
                      if (!profileComplete) {
                        profileComplete = true;

                        Navigator.of(context).pushNamed(
                          Routes.selectProfile,
                          arguments: false,
                        );
                      }
                      return;
                    }
                  } else if (state is UserDetailsFetchFailure) {
                    if (state.errorMessage == errorCodeUnauthorizedAccess) {
                      showAlreadyLoggedInDialog(context);
                    }
                  }
                },
                builder: (context, state) {
                  if (state is UserDetailsFetchInProgress ||
                      state is UserDetailsInitial) {
                    return const Center(child: CircularProgressContainer());
                  }
                  if (state is UserDetailsFetchFailure) {
                    return Center(
                      child: ErrorContainer(
                        showBackButton: true,
                        errorMessage:
                            convertErrorCodeToLanguageKey(state.errorMessage),
                        onTapRetry: fetchUserDetails,
                        showErrorImage: true,
                      ),
                    );
                  }

                  final user = (state as UserDetailsFetchSuccess).userProfile;

                  _userName = user.name!;
                  _userProfileImg = user.profileUrl!;
                  _userRank = user.allTimeRank!;
                  _userCoins = user.coins!;
                  _userScore = user.allTimeScore!;

                  return _buildHome();
                },
              ),
      ),
    );
  }
}
