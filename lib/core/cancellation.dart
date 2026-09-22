import 'dart:async';

/// Jeton d'annulation passé à une requête réseau.
///
/// L'autocomplétion en crée un par frappe : quand l'utilisateur tape la lettre
/// suivante, le jeton précédent est annulé, la connexion HTTP en cours est
/// réellement coupée et sa réponse n'est jamais interprétée.
class CancellationToken {
  final Completer<void> _completer = Completer<void>();

  bool get isCancelled => _completer.isCompleted;

  /// Se termine au moment de l'annulation. Ne se termine jamais autrement.
  Future<void> get whenCancelled => _completer.future;

  void cancel() {
    if (!_completer.isCompleted) {
      _completer.complete();
    }
  }
}
