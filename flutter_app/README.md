Collecting workspace informationFiltering to most relevant information```markdown
# Holberton Quiz App

A modern, modular Flutter quiz application focused on Quiz Zone gameplay, multi-language support, and configurable system settings.

Key entry points and core symbols
- App entry: [`main()`](lib/main.dart) — [lib/main.dart](lib/main.dart)
- Root app widget: [`MyApp`](lib/app/app.dart) — [lib/app/app.dart](lib/app/app.dart)
- Routing: [`Routes`](lib/app/routes.dart) — [lib/app/routes.dart](lib/app/routes.dart)
- System config: [`SystemConfigCubit`](lib/features/system_config/cubits/system_config_cubit.dart) — [lib/features/system_config/cubits/system_config_cubit.dart](lib/features/system_config/cubits/system_config_cubit.dart)
- Assets constants: [`Assets`](lib/utils/constants/assets_constants.dart) — [lib/utils/constants/assets_constants.dart](lib/utils/constants/assets_constants.dart)
- Quiz data layer: [`QuizRepository`](lib/features/quiz/quiz_repository.dart) — [lib/features/quiz/quiz_repository.dart](lib/features/quiz/quiz_repository.dart)
- Quiz types: [`QuizTypes`](lib/features/quiz/models/quiz_type.dart) — [lib/features/quiz/models/quiz_type.dart](lib/features/quiz/models/quiz_type.dart)
- Main quiz screen: [`QuizScreen`](lib/ui/screens/quiz/quiz_screen.dart) — [lib/ui/screens/quiz/quiz_screen.dart](lib/ui/screens/quiz/quiz_screen.dart)
- Pubspec / assets: [pubspec.yaml](pubspec.yaml)

Features
- Quiz Zone gameplay with levels, subcategories and lifelines.
- Multi-language support and quiz-language selector.
- Profile management with avatar images (default assets under `assets/images/profile/`).
- Remote-driven system configuration (via `SystemConfigCubit`).
- Modular architecture: features split into `features/*`, UI under `lib/ui/*`, utilities under `lib/utils/*`.

Quick start (development)
1. Install Flutter (matching the project SDK).
2. Get packages:
   ```sh
   flutter pub get
   ```
3. Run on Android:
   ```sh
   flutter run
   ```
   or select a device in your IDE (VS Code / Android Studio).
4. Run on iOS:
   - Install pods:
     ```sh
     cd ios && pod install
     ```
   - Then:
     ```sh
     flutter run
     ```

Important files and where to look
- App bootstrap: main.dart
- App state & Theme: app.dart, `ThemeCubit` — theme_cubit.dart
- Routes: routes.dart
- System config & assets: system_config_repository.dart and `SystemConfigCubit`
- Quiz flow: quiz_repository.dart, quiz_screen.dart, result_screen.dart
- UI widgets: custom_appbar.dart, questions_container.dart, option_container.dart
- Constants & labels: string_labels.dart, constants.dart

Configuration & environment
- Backend base URL: defined in constants.dart (`databaseUrl` / `baseUrl`).
- Assets are declared in: pubspec.yaml — ensure images, files, etc. exist.
- Firebase: project contains Android google-services.json; ensure you configure Firebase for local dev if using auth / messaging.

Common commands
- Format:
  ```sh
  flutter format .
  ```
- Analyze:
  ```sh
  flutter analyze
  ```
- Run tests (if added):
  ```sh
  flutter test
  ```

Debugging tips
- If system config fails on startup, check network + the repository: system_config_repository.dart.
- To inspect routing behavior, review `Routes` and screen `route` factories (many screens expose static `route`).
- For localization issues, check `AppLocalizationCubit` and `QuizLanguageCubit`.

Contributing
- Follow the existing file organization: features, ui, utils.
- Add new strings in string_labels.dart.
- When adding assets, update pubspec.yaml and place files under assets.

Notes & gotchas
- iOS deployment target and Swift settings are set in Xcode project files (see Runner.xcodeproj).
- Android signing config is in build.gradle — update `key.properties` for release builds.

License & contact
- Licensed under the MIT License. 

Author
- Name: Taha Khezami
- Email: khezamitaha10@gmail.com
- GitHub: https://github.com/KhezamiTaha/


Support & contributions
- Report bugs or request features by opening an issue on GitHub.
- Contributions via pull requests are welcome—please follow the code style and run `flutter analyze` and `flutter format .` before submitting.

