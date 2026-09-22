import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/files/share_plus_image_sharing.dart';
import '../../domain/repositories/image_sharing.dart';

final Provider<ImageSharing> imageSharingProvider =
    Provider<ImageSharing>((ref) => const SharePlusImageSharing());

/// Comment obtenir l'image d'une couverture à partir de son URL.
///
/// Passer par un provider permet aux tests de fournir une image locale : sans
/// cela, ils dépendraient du réseau, que le binding de test refuse de toute
/// façon.
final Provider<ImageProvider Function(String url)> coverImageProviderFactory =
    Provider<ImageProvider Function(String url)>(
  (ref) => CachedNetworkImageProvider.new,
);
