class SettingsModel {
  const SettingsModel({
    required this.playAreaFontSize,
    
    required this.sound,
    required this.showIntroSlider,
    required this.vibration,
    required this.theme,
  });

  SettingsModel.fromJson(Map<String, dynamic> json)
      : playAreaFontSize = json['playAreaFontSize'] as double,
        theme = json['theme'] as String,

        sound = json['sound'] as bool? ?? true,
        showIntroSlider = json['showIntroSlider'] as bool,
        vibration = json['vibration'] as bool;

  final bool showIntroSlider;
  final bool sound;
  final bool vibration;
  final double playAreaFontSize;

  final String theme;

  SettingsModel copyWith({
    String? theme,
    bool? showIntroSlider,
    bool? sound,
    bool? vibration,
    double? playAreaFontSize,

  }) {
    return SettingsModel(
      theme: theme ?? this.theme,

      playAreaFontSize: playAreaFontSize ?? this.playAreaFontSize,
      sound: sound ?? this.sound,
      showIntroSlider: showIntroSlider ?? this.showIntroSlider,
      vibration: vibration ?? this.vibration,
    );
  }
}
