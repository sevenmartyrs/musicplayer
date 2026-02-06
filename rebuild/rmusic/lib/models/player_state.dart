import 'song.dart';

enum PlayMode {
  sequence,
  shuffle,
  repeat,
}

class PlayerState {
  final Song? currentSong;
  final bool isPlaying;
  final int currentPosition; // in seconds
  final PlayMode playMode;
  final List<Song> playlist;
  final int currentIndex;

  PlayerState({
    this.currentSong,
    this.isPlaying = false,
    this.currentPosition = 0,
    this.playMode = PlayMode.sequence,
    this.playlist = const [],
    this.currentIndex = 0,
  });

  String get formattedPosition {
    final minutes = currentPosition ~/ 60;
    final seconds = currentPosition % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  PlayerState copyWith({
    Song? currentSong,
    bool? isPlaying,
    int? currentPosition,
    PlayMode? playMode,
    List<Song>? playlist,
    int? currentIndex,
  }) {
    return PlayerState(
      currentSong: currentSong ?? this.currentSong,
      isPlaying: isPlaying ?? this.isPlaying,
      currentPosition: currentPosition ?? this.currentPosition,
      playMode: playMode ?? this.playMode,
      playlist: playlist ?? this.playlist,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}