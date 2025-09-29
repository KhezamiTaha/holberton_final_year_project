import 'package:flutterquiz/utils/constants/constants.dart';

const _api = '$databaseUrl/Api/';

const addUserUrl = '${_api}user_signup';
const checkUserExistUrl = '${_api}check_user_exists';
const deleteUserAccountUrl = '${_api}delete_user_account';
const getAllTimeLeaderboardUrl = '${_api}get_globle_leaderboard';
const getAppSettingsUrl = '${_api}get_settings';
const getBookmarkUrl = '${_api}get_bookmark';
const getCategoryUrl = '${_api}get_categories';
const getCoinHistoryUrl = '${_api}get_tracker_data';
const getCoinStoreData = '${_api}get_coin_store_data';


const getLevelUrl = '${_api}get_level_data';
const getMonthlyLeaderboardUrl = '${_api}get_monthly_leaderboard';
const getNotificationUrl = '${_api}get_notifications';
const getQuestionByTypeUrl = '${_api}get_questions_by_type';


const getQuestionsByCategoryOrSubcategory = '${_api}get_questions';
const getQuestionsByLevelUrl = '${_api}get_questions_by_level';
const getStatisticUrl = '${_api}get_users_statistics';
const getSubCategoryUrl = '${_api}get_subcategory_by_maincategory';
const getSupportedLanguageListUrl = '${_api}get_system_language_list';
const getSupportedQuestionLanguageUrl = '${_api}get_languages';
const getSystemConfigUrl = '${_api}get_system_configurations';
const getSystemLanguageJson = '${_api}get_system_language_json';

const getUserBadgesUrl = '${_api}get_user_badges';
const getUserDetailsByIdUrl = '${_api}get_user_by_id';
const reportQuestionUrl = '${_api}report_question';
const setQuizCategoryPlayedUrl = '${_api}set_quiz_categories';
const setUserBadgesUrl = '${_api}set_badges';
const unlockPremiumCategoryUrl = '${_api}unlock_premium_category';
const updateBookmarkUrl = '${_api}set_bookmark';
const updateFcmIdUrl = '${_api}update_fcm_id';
const updateLevelUrl = '${_api}set_level_data';
const updateProfileUrl = '${_api}update_profile';
const updateStatisticUrl = '${_api}set_users_statistics';
const updateUserCoinsAndScoreUrl = '${_api}set_user_coin_score';
const uploadProfileUrl = '${_api}upload_profile_image';
