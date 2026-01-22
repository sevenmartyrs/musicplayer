import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import '../models/song.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();
  final StreamController<Duration> _positionController = StreamController.broadcast();
  final StreamController<Duration?> _durationController = StreamController.broadcast();
  final StreamController<bool> _playingController = StreamController.broadcast();
  final StreamController<void> _completionController = StreamController.broadcast();

  Stream<Duration> get positionStream => _positionController.stream;
  Stream<Duration?> get durationStream => _durationController.stream;
  Stream<bool> get playingStream => _playingController.stream;
  Stream<void> get completionStream => _completionController.stream;

  Duration get position => _player.position;
  Duration? get duration => _player.duration;
  bool get isPlaying => _player.playing;

  final List<StreamSubscription> _subscriptions = [];

  AudioService() {
    _init();
  }

  Future<void> _init() async {
    // 设置音频会话
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    
    // 监听播放状态变化
    _subscriptions.add(_player.positionStream.listen((position) {
      _positionController.add(position);
    }));

    _subscriptions.add(_player.durationStream.listen((duration) {
      _durationController.add(duration);
    }));

    _subscriptions.add(_player.playingStream.listen((playing) {
      _playingController.add(playing);
    }));

    _subscriptions.add(_player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _completionController.add(null);
      }
    }));
  }

  Future<void> play(Song song) async {
    try {
      // 优先使用本地文件路径
      if (song.audioUrl != null && song.audioUrl!.startsWith('/')) {
        // 本地文件路径
        await _player.setFilePath(song.audioUrl!);
      } else {
        // 网络URL或示例音频
        final audioUrl = song.audioUrl ?? 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';
        await _player.setUrl(audioUrl);
      }
      
      await _player.play();
    } catch (e) {
      // Error handling
    }
  }

  // 加载歌曲但不播放
  Future<void> load(Song song, {Duration? initialPosition}) async {
    try {
      // 优先使用本地文件路径
      if (song.audioUrl != null && song.audioUrl!.startsWith('/')) {
        // 本地文件路径
        await _player.setFilePath(song.audioUrl!, initialPosition: initialPosition);
      } else {
        // 网络URL或示例音频
        final audioUrl = song.audioUrl ?? 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';
        await _player.setUrl(audioUrl, initialPosition: initialPosition);
      }
    } catch (e) {
      // Error handling
    }
  }
  
  // 预加载下一首歌曲（使用ConcatenatingAudioSource）
  Future<void> preloadNext(Song? currentSong, Song? nextSong) async {
    if (nextSong == null) return;
    
    try {
      final currentSource = currentSong != null 
          ? AudioSource.uri(Uri.file(currentSong.audioUrl!))
          : null;
          
      final nextSource = AudioSource.uri(Uri.file(nextSong.audioUrl!));
      
      // 如果有当前歌曲，创建拼接源；否则只预加载下一首
      if (currentSource != null) {
        await _player.setAudioSource(
          ConcatenatingAudioSource(children: [currentSource, nextSource]),
          initialIndex: 0,
          initialPosition: _player.position,
        );
      } else {
        await _player.setAudioSource(nextSource, preload: true);
      }
    } catch (e) {
      // 如果预加载失败，不影响当前播放
      debugPrint('Failed to preload next song: $e');
    }
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> resume() async {
    await _player.play();
  }

  Future<void> stop() async {
    await _player.stop();
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume);
  }

  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed);
  }

  void dispose() {
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    _positionController.close();
    _durationController.close();
    _playingController.close();
    _completionController.close();
    _player.dispose();
  }
}