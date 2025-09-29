import 'package:flutterquiz/utils/constants/string_labels.dart';

export 'api_body_parameter_labels.dart';
export 'api_endpoints_constants.dart';
export 'assets_constants.dart';
export 'error_message_keys.dart';
export 'fonts.dart';
export 'hive_constants.dart';
export 'sound_constants.dart';
export 'string_labels.dart';

const appName = 'Holberton Quiz';
const packageName = 'com.holbertonpfe.quiz';

/// Add your database url
// NOTE: make sure to not add '/' at the end of url
// NOTE: make sure to check if admin panel is http or https
const databaseUrl = 'https://holbertonquiz.mobicomx.me';

// Enter 2 Letter ISO Country Code
const defaultCountryCodeForPhoneLogin = 'TN';

/// Default App Theme : lightThemeKey or darkThemeKey
const defaultThemeKey = lightThemeKey;

//Database related constants
const baseUrl = '$databaseUrl/Api/';

//lifelines
const fiftyFifty = 'fiftyFifty';
const audiencePoll = 'audiencePoll';
const skip = 'skip';
const resetTime = 'resetTime';

//firestore collection names

const messagesCollection = 'messages';

// Phone Number
const maxPhoneNumberLength = 16;

const inBetweenQuestionTimeInSeconds = 1;


//To add
