/// La vidéo du bilan annuel : assemblée sur le téléphone, puis partagée ou
/// enregistrée dans la galerie.
abstract class YearReviewVideo {
  /// Faux là où la vidéo ne sait pas encore se faire (hors Android).
  bool get isSupported;

  /// Assemble [frames] (des PNG de [width] × [height]), chacun montré
  /// [slide], avec la musique [audioPath], dans le MP4 [outputPath].
  Future<void> encode({
    required List<String> frames,
    required int width,
    required int height,
    required Duration slide,
    required String outputPath,
    String? audioPath,
    void Function(double progress)? onProgress,
  });

  Future<void> share(String path);

  Future<void> saveToGallery(String path);
}
