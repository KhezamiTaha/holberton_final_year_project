// if you make any changes here in keys make sure to update in all languages files
//

import 'package:flutterquiz/utils/constants/string_labels.dart';

const accountExistCredentialKey = 'account-exists-with-different-credential';
const accountHasBeenDeactivatedKey = 'accountHasBeenDeactive';

const canNotMakeRequestKey = 'canNotMakeRequest';
const canNotStartGameKey = 'canNotStartGame';

const dataNotFoundKey = 'dataNotFound';
const defaultErrorMessageKey = 'defaultErrorMessage'; //something went wrong
const emailExistKey = 'email-already-in-use';
const fileUploadFailKey = 'fileUploadFail';
const fillAllDataKey = 'fillAllData';
const gameStartedKey = 'gameStarted';

const invalidPhoneNumberLblKey = 'invalid-phone-number';
const invalidCredentialKey = 'invalid-credential';
const invalidEmailKey = 'invalid-email';
const invalidHashKey = 'invalidHash';
const invalidVerificationCodeKey = 'invalid-verification-code';
const invalidVerificationIdKey = 'invalid-verification-id';
const levelLockedKey = 'levelLocked';
const lifeLineUsedKey = 'lifeLineUsed';


const noInternetKey = 'noInternet';
const noMatchesPlayedKey = 'noMatchesPlayed';
const noTransactionsKey = 'noTransactions';

const notEnoughCoinsKey = 'notEnoughCoins';

const notesNotAvailableKey = 'notesNotAvailable';
const operationNotAllowedKey = 'operation-not-allowed';
const requireRecentLoginKey = 'requires-recent-login';
const roomAlreadyCreatedKey = 'roomAlreadyCreated';
const roomCodeInvalidKey = 'roomCodeInvalid';
const roomIsFullKey = 'roomIsFull';
const selectAllValuesKey = 'selectAllValues';
const unauthorizedAccessKey = 'unauthorizedAccess';
const updateBookmarkFailureKey = 'updateBookmarkFailure';
const userDisabledKey = 'user-disabled';
const userNotFoundKey = 'user-not-found';
const verifyEmailKey = 'verifyEmail';
const weakPasswordKey = 'weak-password';
const wrongPasswordKey = 'wrong-password';

///
/// Not Used in Localisation or for showing message

const _dataInsertSuccess = 'DataInsertSuccess';
const _dataUpdateSuccess = 'DataUpdateSuccess';
const _loginSuccess = 'login-success';
const _playAndWinExcitingPrizes = 'PlayAndWinExcitingPrizes';
const _profileUpdatedSuccessfully = 'profile-update-success';
const _reportSubmittedSuccess = 'ReportSubmittedSuccess';
const _userRegisteredSuccessfully = 'user-registered-successfully';
const _roomCreatedSuccessfully = 'RoomCreatedSuccessfully';
const _roomDestroyedSuccessfully = 'RoomDestroyedSuccessfully';
const _notificationSentSuccessfully = 'NotificationSentSuccessfully';
const _categoryAlreadyPlayed = 'CategoryAlreadyPlayed';
const _userExists = 'UserExists';
const _userDoesNotExists = 'UserDoesNotExists';
// - End

/// APP & Firebase Error Codes
const errorCodeNoInternet = '000';
const errorCodeInvalidCredential = '001';
const errorCodeOperationNotAllowed = '002';
const errorCodeInvalidVerificationCode = '003';
const errorCodeVerifyEmail = '004';
const errorCodeEmailExists = '005';
const errorCodeWeakPassword = '006';
const errorCodeLevelLocked = '007';
const errorCodeUpdateBookmarkFailure = '008';
const errorCodeLifeLineUsed = '009';
const errorCodeNotEnoughCoins = '010';
const errorCodeNotesNotAvailable = '011';
const errorCodeSelectAllValues = '012';
const errorCodeCanNotStartGame = '013';
const errorCodeRoomCodeInvalid = '014';
const errorCodeGameStarted = '015';
const errorCodeRoomIsFull = '016';
const errorCodeUnableToCreateRoom = '017';
const errorCodeUnableToFindRoom = '018';
const errorCodeUnableToJoinRoom = '019';
const errorCodeUnableToSubmitAnswer = '020';
const errorCodeRequireRecentLogin = '024';
const errorCodeNoTransactions = '025';
const errorCodeInvalidEmail = '026';
const errorCodeUserNotFound = '027';
const errorCodeWrongPassword = '028';
const errorCodeAccountExistsCredential = '029';
const errorCodeInvalidPhoneNumber = '030';

/// Note: Some of these are Admin Panel's internal Codes.
/// for consistency i have prefixed them with 'errorCode'
const errorCodeInvalidAccessKey = '101';
const errorCodeDataNotFound = '102';
const errorCodeFillAllData = '103';
const errorCodeUserRegisteredSuccessfully = '104';
const errorCodeLoginSuccess = '105';
const errorCodeProfileUpdateSuccess = '106';
const errorCodeFileUploadFail = '107';

const errorCodeReportSubmittedSuccess = '109';
const errorCodeDataInsertSuccess = '110';
const errorCodeDataUpdateSuccess = '111';
const errorCodeNoMatchesPlayed = '113';
const errorCodePlayAndWinExcitingPrizes = '118';
const errorCodeRoomAlreadyCreated = '119';
const errorCodeRoomCreatedSuccessfully = '120';
const errorCodeRoomDestroyedSuccessfully = '121';
const errorCodeDefaultMessage = '122';
const errorCodeNotificationSentSuccessfully = '123';
const errorCodeInvalidHash = '124';
const errorCodeAccountHasBeenDeactivated = '126';
const errorCodeCanNotMakeRequest = '127';
const errorCodeCategoryAlreadyPlayed = '128';
const errorCodeUnauthorizedAccess = '129';
const errorCodeUserExists = '130';
const errorCodeUserDoesNotExists = '131';
const errorCodeDataExists = '132'; // Not used in app.
const errorCodeUserCanContinue = '134';

//
//firebase auth exceptions code
//
String firebaseErrorCodeToNumber(String code) => switch (code) {
      accountExistCredentialKey => errorCodeAccountExistsCredential,
      emailExistKey => errorCodeEmailExists,
      invalidCredentialKey => errorCodeInvalidCredential,
      invalidEmailKey => errorCodeInvalidEmail,
      invalidVerificationCodeKey => errorCodeInvalidVerificationCode,
      operationNotAllowedKey => errorCodeOperationNotAllowed,
      requireRecentLoginKey => errorCodeRequireRecentLogin,
      userDisabledKey => errorCodeAccountHasBeenDeactivated,
      userNotFoundKey => errorCodeUserNotFound,
      verifyEmailKey => errorCodeVerifyEmail,
      weakPasswordKey => errorCodeWeakPassword,
      wrongPasswordKey => errorCodeWrongPassword,
      _ => errorCodeDefaultMessage,
    };

//
//to convert error code into error keys for localization
//every error occurs in app will have code assign to it
//
String convertErrorCodeToLanguageKey(String code) => switch (code) {
      errorCodeAccountExistsCredential => accountExistCredentialKey,
      errorCodeAccountHasBeenDeactivated => accountHasBeenDeactivatedKey,

      errorCodeCanNotMakeRequest => canNotMakeRequestKey,
      errorCodeCanNotStartGame => canNotStartGameKey,
      errorCodeCategoryAlreadyPlayed => _categoryAlreadyPlayed,
    
      errorCodeDataInsertSuccess => _dataInsertSuccess,
      errorCodeDataNotFound => dataNotFoundKey,
      errorCodeDataUpdateSuccess => _dataUpdateSuccess,
      errorCodeDefaultMessage => defaultErrorMessageKey,
      errorCodeEmailExists => emailExistKey,
      errorCodeFileUploadFail => fileUploadFailKey,
      errorCodeFillAllData => fillAllDataKey,
      errorCodeGameStarted => gameStartedKey,
     
      errorCodeInvalidAccessKey => invalidHashKey,
      errorCodeInvalidCredential => invalidCredentialKey,
      errorCodeInvalidEmail => invalidEmailKey,
      errorCodeInvalidHash => invalidHashKey,
      errorCodeInvalidVerificationCode => invalidVerificationCodeKey,
      errorCodeLevelLocked => levelLockedKey,
      errorCodeLifeLineUsed => lifeLineUsedKey,
      errorCodeLoginSuccess => _loginSuccess,
      errorCodeNoInternet => noInternetKey,
      errorCodeNoMatchesPlayed => noMatchesPlayedKey,
      errorCodeNoTransactions => noTransactionsKey,
      errorCodeNotEnoughCoins => notEnoughCoinsKey,
      errorCodeNotesNotAvailable => notesNotAvailableKey,
      errorCodeNotificationSentSuccessfully => _notificationSentSuccessfully,
      errorCodeOperationNotAllowed => operationNotAllowedKey,
      errorCodePlayAndWinExcitingPrizes => _playAndWinExcitingPrizes,
      errorCodeProfileUpdateSuccess => _profileUpdatedSuccessfully,
      errorCodeReportSubmittedSuccess => _reportSubmittedSuccess,
      errorCodeRequireRecentLogin => requireRecentLoginKey,
      errorCodeRoomAlreadyCreated => roomAlreadyCreatedKey,
      errorCodeRoomCodeInvalid => roomCodeInvalidKey,
      errorCodeRoomCreatedSuccessfully => _roomCreatedSuccessfully,
      errorCodeRoomDestroyedSuccessfully => _roomDestroyedSuccessfully,
      errorCodeRoomIsFull => roomIsFullKey,
      errorCodeSelectAllValues => selectAllValuesKey,
      errorCodeUnableToCreateRoom => unableToCreateRoomKey,
      errorCodeUnableToFindRoom => unableToFindRoomKey,
      errorCodeUnableToJoinRoom => errorCodeUnableToJoinRoom,
      errorCodeUnableToSubmitAnswer => errorCodeUnableToSubmitAnswer,
      errorCodeUnauthorizedAccess => unauthorizedAccessKey,
      errorCodeUpdateBookmarkFailure => updateBookmarkFailureKey,
      errorCodeUserDoesNotExists => _userDoesNotExists,
      errorCodeUserExists => _userExists,
      errorCodeUserNotFound => userNotFoundKey,
      errorCodeUserRegisteredSuccessfully => _userRegisteredSuccessfully,
      errorCodeVerifyEmail => verifyEmailKey,
      errorCodeWeakPassword => weakPasswordKey,
      errorCodeWrongPassword => wrongPasswordKey,
      errorCodeInvalidPhoneNumber => invalidPhoneNumberLblKey,
      _ => defaultErrorMessageKey,
    };
