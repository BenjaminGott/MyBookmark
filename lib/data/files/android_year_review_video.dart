import 'dart:io';

import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/failure.dart';
import '../../domain/repositories/year_review_video.dart';
import 'gal_image_saving.dart';

/// La vidéo du bilan, assemblée par l'encodeur matériel d'Android
/// (`YearReviewVideoEncoder.kt`, derrière un canal de méthodes).
class AndroidYearReviewVideo implements YearReviewVideo {
  AndroidYearReviewVideo() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'progress') {
        _onProgress?.call((call.arguments as num).toDouble());
      }
    });
  }

  static const MethodChannel _channel = MethodChannel(
    'com.libergot.mybookmark/year_review_video',
  );

  void Function(double)? _onProgress;

  @override
  bool get isSupported => Platform.isAndroid;

  @override
  Future<void> encode({
    required List<String> frames,
    required int width,
    required int height,
    required Duration slide,
    required String outputPath,
    String? audioPath,
    void Function(double progress)? onProgress,
  }) async {
    _onProgress = onProgress;
    try {
      await _channel.invokeMethod<String>('encode', <String, Object?>{
        'frames': frames,
        'width': width,
        'height': height,
        'slideMillis': slide.inMilliseconds,
        'output': outputPath,
        'audio': audioPath,
      });
    } on PlatformException {
      throw const FileAccessException(AppErrorReason.videoFailed);
    } on MissingPluginException {
      throw const FileAccessException(AppErrorReason.videoFailed);
    } finally {
      _onProgress = null;
    }
  }

  @override
  Future<void> share(String path) async {
    try {
      await SharePlus.instance.share(
        ShareParams(files: <XFile>[XFile(path, mimeType: 'video/mp4')]),
      );
    } on PlatformException {
      throw const FileAccessException(AppErrorReason.shareFailed);
    }
  }

  @override
  Future<void> saveToGallery(String path) async {
    try {
      if (!await Gal.hasAccess(toAlbum: true) &&
          !await Gal.requestAccess(toAlbum: true)) {
        throw const FileAccessException(AppErrorReason.photoAccess);
      }
      await Gal.putVideo(path, album: GalImageSaving.album);
    } on GalException catch (error) {
      throw FileAccessException(switch (error.type) {
        GalExceptionType.accessDenied => AppErrorReason.photoAccess,
        GalExceptionType.notEnoughSpace => AppErrorReason.notEnoughSpace,
        _ => AppErrorReason.imageSaveFailed,
      });
    } on MissingPluginException {
      throw const FileAccessException(AppErrorReason.imageSaveFailed);
    }
  }
}
