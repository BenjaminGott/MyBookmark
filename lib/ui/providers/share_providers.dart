import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/files/gal_image_saving.dart';
import '../../data/files/instagram_story_sharing.dart';
import '../../data/files/share_plus_image_sharing.dart';
import '../../domain/repositories/image_saving.dart';
import '../../domain/repositories/image_sharing.dart';
import '../../domain/repositories/story_sharing.dart';
import '../widgets/book_cover.dart';

final Provider<ImageSharing> imageSharingProvider =
    Provider<ImageSharing>((ref) => const SharePlusImageSharing());

final Provider<ImageSaving> imageSavingProvider =
    Provider<ImageSaving>((ref) => const GalImageSaving());

final Provider<StorySharing> storySharingProvider =
    Provider<StorySharing>((ref) => const InstagramStorySharing());

/// Comment obtenir l'image d'une couverture à partir de son URL.
///
/// Passer par un provider permet aux tests de fournir une image locale : sans
/// cela, ils dépendraient du réseau, que le binding de test refuse de toute
/// façon.
final Provider<ImageProvider Function(String url)> coverImageProviderFactory =
    Provider<ImageProvider Function(String url)>(
  (ref) => coverImageProvider,
);
