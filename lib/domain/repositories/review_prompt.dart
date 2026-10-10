/// La fenêtre « Noter l'application » de Google Play, sans quitter l'app.
abstract class ReviewPrompt {
  /// Demande l'avis. Google décide seul d'afficher la fenêtre ou non (il en
  /// limite le nombre) : rien ne garantit qu'elle apparaisse.
  Future<void> request();
}
