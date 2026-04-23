import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/// Each verse is mapped to a fixed virtual slot in the seekbar.
/// This ensures the full surah range is visible from the start.
const Duration _kSlotDuration = Duration(seconds: 10);

/// AudioHandler that integrates just_audio with audio_service
/// to provide media notification controls for Quran playback.
///
/// The notification seekbar uses a virtual timeline based on verse count,
/// so the full surah length is known immediately (totalVerses × 10s).
class QuranAudioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player = AudioPlayer();

  int? currentSurahNumber;
  int _totalVerses = 0;

  /// Callbacks for surah navigation from the notification
  void Function()? onSkipToNextSurah;
  void Function()? onSkipToPreviousSurah;

  /// Cached artwork URI for the notification
  Uri? _artworkUri;

  AudioPlayer get player => _player;

  QuranAudioHandler() {
    // Forward playback state changes to the media notification.
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);

    // When a new verse starts, update the notification info
    _player.currentIndexStream.listen((index) {
      if (index != null && currentSurahNumber != null) {
        _updateMediaItemInfo();
      }
    });
  }

  /// Computes the virtual position for the seekbar.
  /// Each completed verse = 1 full slot, current verse = fraction of a slot.
  Duration _getVirtualPosition() {
    final index = _player.currentIndex ?? 0;
    final verseDuration = _player.duration ?? const Duration(seconds: 1);
    final position = _player.position;

    // Fraction of current verse completed (0.0 to 1.0)
    double fraction = 0.0;
    if (verseDuration.inMilliseconds > 0) {
      fraction = (position.inMilliseconds / verseDuration.inMilliseconds)
          .clamp(0.0, 1.0);
    }

    // Virtual position = completed slots + fraction of current slot
    final completedMs = index * _kSlotDuration.inMilliseconds;
    final currentMs = (fraction * _kSlotDuration.inMilliseconds).round();
    return Duration(milliseconds: completedMs + currentMs);
  }

  /// Total virtual duration = totalVerses × slot duration
  Duration _getVirtualTotalDuration() {
    return Duration(
      milliseconds: _totalVerses * _kSlotDuration.inMilliseconds,
    );
  }

  /// Updates the MediaItem with virtual duration and current verse info.
  void _updateMediaItemInfo() {
    final currentItem = mediaItem.value;
    if (currentItem == null) return;
    final index = _player.currentIndex ?? 0;
    mediaItem.add(
      currentItem.copyWith(
        duration: _getVirtualTotalDuration(),
        extras: {
          ...?currentItem.extras,
          'currentVerse': index + 1,
        },
      ),
    );
  }

  /// Copies the app logo from assets to a temp file and caches its URI.
  Future<Uri> _getArtworkUri() async {
    if (_artworkUri != null) return _artworkUri!;

    try {
      final tempDir = await getTemporaryDirectory();
      final artFile = File('${tempDir.path}/quran_artwork.png');

      if (!await artFile.exists()) {
        final byteData = await rootBundle.load(
          'assets/data/appLogo/أذكار آمنة.png',
        );
        await artFile.writeAsBytes(
          byteData.buffer.asUint8List(
            byteData.offsetInBytes,
            byteData.lengthInBytes,
          ),
        );
      }

      _artworkUri = artFile.uri;
      return _artworkUri!;
    } catch (e) {
      return Uri();
    }
  }

  /// Sets the audio source for a surah and updates the media notification metadata.
  Future<void> setSurahSource({
    required ConcatenatingAudioSource source,
    required int surahNumber,
    required String surahName,
    required String reciterName,
    required int totalVerses,
  }) async {
    currentSurahNumber = surahNumber;
    _totalVerses = totalVerses;

    // Get the artwork URI for the notification
    final artUri = await _getArtworkUri();

    // Set the media item metadata for the notification.
    // Duration is set immediately to totalVerses × slot so slider shows full range.
    mediaItem.add(
      MediaItem(
        id: 'surah_$surahNumber',
        album: 'القرآن الكريم',
        title: 'سورة $surahName',
        artist: reciterName,
        artUri: artUri,
        duration: _getVirtualTotalDuration(),
        extras: {
          'surahNumber': surahNumber,
          'totalVerses': totalVerses,
          'currentVerse': 1,
        },
      ),
    );

    await _player.setAudioSource(source);
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    currentSurahNumber = null;
    _totalVerses = 0;
    return super.stop();
  }

  /// Seek using the virtual timeline.
  /// Maps the virtual position back to a verse index and seeks to that verse.
  @override
  Future<void> seek(Duration position) async {
    if (_totalVerses == 0) return;

    // Which verse slot does this position fall in?
    final slotMs = _kSlotDuration.inMilliseconds;
    final posMs = position.inMilliseconds.clamp(0, _totalVerses * slotMs);
    final verseIndex = (posMs ~/ slotMs).clamp(0, _totalVerses - 1);

    // Fraction within that verse's slot
    final fractionInSlot = (posMs % slotMs) / slotMs;

    // Map fraction to actual verse duration (if known)
    final verseDuration = _player.duration ?? Duration.zero;
    final seekPosition = Duration(
      milliseconds: (fractionInSlot * verseDuration.inMilliseconds).round(),
    );

    await _player.seek(
      verseIndex == _player.currentIndex ? seekPosition : Duration.zero,
      index: verseIndex,
    );
  }

  /// Next surah — called from notification "skip next" button
  @override
  Future<void> skipToNext() async {
    if (onSkipToNextSurah != null) {
      onSkipToNextSurah!();
    }
  }

  /// Previous surah — called from notification "skip previous" button
  @override
  Future<void> skipToPrevious() async {
    if (onSkipToPreviousSurah != null) {
      onSkipToPreviousSurah!();
    }
  }

  /// Transforms just_audio PlaybackEvent into audio_service PlaybackState.
  /// Reports the virtual cumulative position for the seekbar.
  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _getVirtualPosition(),
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    );
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}

/// Global audio handler instance — initialized once in main().
late QuranAudioHandler audioHandler;

/// Initializes the audio handler with audio_service.
Future<void> initAudioService() async {
  audioHandler = await AudioService.init<QuranAudioHandler>(
    builder: () => QuranAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId:
          'com.example.flutter_application_1.quran_audio',
      androidNotificationChannelName: 'تلاوة القرآن',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
      androidNotificationIcon: 'mipmap/launcher_icon',
    ),
  );
}
