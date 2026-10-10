import 'package:url_launcher/url_launcher.dart';

import '../../domain/repositories/external_links.dart';

/// [ExternalLinks] adossé à `url_launcher`.
class UrlLauncherLinks implements ExternalLinks {
  const UrlLauncherLinks();

  @override
  Future<bool> open(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Object {
      return false;
    }
  }
}
