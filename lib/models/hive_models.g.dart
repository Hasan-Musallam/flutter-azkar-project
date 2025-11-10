// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveBookmarkAdapter extends TypeAdapter<HiveBookmark> {
  @override
  final int typeId = 0;

  @override
  HiveBookmark read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveBookmark(
      id: fields[0] as String,
      type: fields[1] as String,
      title: fields[2] as String,
      subtitle: fields[3] as String,
      arabicText: fields[4] as String,
      translation: fields[5] as String,
      dateAdded: fields[6] as DateTime,
      surahName: fields[7] as String?,
      verseNumber: fields[8] as int?,
      surahNumber: fields[9] as int?,
      adhkarCategory: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, HiveBookmark obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.subtitle)
      ..writeByte(4)
      ..write(obj.arabicText)
      ..writeByte(5)
      ..write(obj.translation)
      ..writeByte(6)
      ..write(obj.dateAdded)
      ..writeByte(7)
      ..write(obj.surahName)
      ..writeByte(8)
      ..write(obj.verseNumber)
      ..writeByte(9)
      ..write(obj.surahNumber)
      ..writeByte(10)
      ..write(obj.adhkarCategory);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveBookmarkAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HiveUserProgressAdapter extends TypeAdapter<HiveUserProgress> {
  @override
  final int typeId = 1;

  @override
  HiveUserProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveUserProgress(
      pagesRead: fields[0] as int,
      adhkarCompleted: fields[1] as int,
      readingStreak: fields[2] as int,
      lastReadSurah: fields[3] as String,
      lastReadVerse: fields[4] as int,
      lastReadSurahNumber: fields[5] as int,
      dailyAdhkar: (fields[6] as Map).cast<String, bool>(),
      lastActivityDate: fields[7] as DateTime?,
      weeklyProgress: (fields[8] as Map).cast<String, int>(),
    );
  }

  @override
  void write(BinaryWriter writer, HiveUserProgress obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.pagesRead)
      ..writeByte(1)
      ..write(obj.adhkarCompleted)
      ..writeByte(2)
      ..write(obj.readingStreak)
      ..writeByte(3)
      ..write(obj.lastReadSurah)
      ..writeByte(4)
      ..write(obj.lastReadVerse)
      ..writeByte(5)
      ..write(obj.lastReadSurahNumber)
      ..writeByte(6)
      ..write(obj.dailyAdhkar)
      ..writeByte(7)
      ..write(obj.lastActivityDate)
      ..writeByte(8)
      ..write(obj.weeklyProgress);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveUserProgressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HiveAppSettingsAdapter extends TypeAdapter<HiveAppSettings> {
  @override
  final int typeId = 2;

  @override
  HiveAppSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveAppSettings(
      isDarkMode: fields[0] as bool,
      fontSize: fields[1] as double,
      language: fields[2] as String,
      notificationsEnabled: fields[3] as bool,
      morningAdhkar: fields[4] as bool,
      eveningAdhkar: fields[5] as bool,
      prayerReminders: fields[6] as bool,
      morningTime: fields[7] as String,
      eveningTime: fields[8] as String,
      audioReciter: fields[9] as String,
      translationLanguage: fields[10] as String,
    );
  }

  @override
  void write(BinaryWriter writer, HiveAppSettings obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.isDarkMode)
      ..writeByte(1)
      ..write(obj.fontSize)
      ..writeByte(2)
      ..write(obj.language)
      ..writeByte(3)
      ..write(obj.notificationsEnabled)
      ..writeByte(4)
      ..write(obj.morningAdhkar)
      ..writeByte(5)
      ..write(obj.eveningAdhkar)
      ..writeByte(6)
      ..write(obj.prayerReminders)
      ..writeByte(7)
      ..write(obj.morningTime)
      ..writeByte(8)
      ..write(obj.eveningTime)
      ..writeByte(9)
      ..write(obj.audioReciter)
      ..writeByte(10)
      ..write(obj.translationLanguage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveAppSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HiveReadingSessionAdapter extends TypeAdapter<HiveReadingSession> {
  @override
  final int typeId = 3;

  @override
  HiveReadingSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveReadingSession(
      id: fields[0] as String,
      surahNumber: fields[1] as int,
      surahName: fields[2] as String,
      startVerse: fields[3] as int,
      endVerse: fields[4] as int,
      startTime: fields[5] as DateTime,
      endTime: fields[6] as DateTime?,
      pagesRead: fields[7] as int,
      isCompleted: fields[8] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, HiveReadingSession obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.surahNumber)
      ..writeByte(2)
      ..write(obj.surahName)
      ..writeByte(3)
      ..write(obj.startVerse)
      ..writeByte(4)
      ..write(obj.endVerse)
      ..writeByte(5)
      ..write(obj.startTime)
      ..writeByte(6)
      ..write(obj.endTime)
      ..writeByte(7)
      ..write(obj.pagesRead)
      ..writeByte(8)
      ..write(obj.isCompleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveReadingSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
