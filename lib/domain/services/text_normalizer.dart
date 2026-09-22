/// Normalisation du texte saisi avant un appel à Open Library.
///
/// Les règles appliquées, dans l'ordre :
///  1. passage en minuscules ;
///  2. développement des ligatures (œ → oe, æ → ae, ß → ss, ﬁ → fi…) ;
///  3. suppression des diacritiques **latins** uniquement : le cyrillique,
///     le grec et l'arabe passent au travers sans être touchés ;
///  4. remplacement de toute ponctuation et de tout symbole par une espace ;
///  5. réduction des espaces multiples et suppression des espaces de bord.
class TextNormalizer {
  const TextNormalizer();

  /// Ligatures et lettres composées qui se développent en plusieurs caractères.
  static const Map<String, String> _ligatures = <String, String>{
    'œ': 'oe',
    'æ': 'ae',
    'ĳ': 'ij',
    'ﬀ': 'ff',
    'ﬁ': 'fi',
    'ﬂ': 'fl',
    'ﬃ': 'ffi',
    'ﬄ': 'ffl',
    'ß': 'ss',
  };

  /// Lettres latines accentuées ou barrées, en minuscules, vers leur base ASCII.
  ///
  /// La table ne couvre volontairement que le latin : aucune entrée n'existe
  /// pour le cyrillique, le grec ou l'arabe, qui restent donc intacts.
  static const Map<String, String> _latinBase = <String, String>{
    'à': 'a', 'á': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a', 'å': 'a', 'ā': 'a',
    'ă': 'a', 'ą': 'a',
    'ç': 'c', 'ć': 'c', 'ĉ': 'c', 'ċ': 'c', 'č': 'c',
    'ď': 'd', 'đ': 'd', 'ð': 'd',
    'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e', 'ē': 'e', 'ĕ': 'e', 'ė': 'e',
    'ę': 'e', 'ě': 'e',
    'ĝ': 'g', 'ğ': 'g', 'ġ': 'g', 'ģ': 'g',
    'ĥ': 'h', 'ħ': 'h',
    'ì': 'i', 'í': 'i', 'î': 'i', 'ï': 'i', 'ĩ': 'i', 'ī': 'i', 'ĭ': 'i',
    'į': 'i', 'ı': 'i',
    'ĵ': 'j',
    'ķ': 'k',
    'ĺ': 'l', 'ļ': 'l', 'ľ': 'l', 'ŀ': 'l', 'ł': 'l',
    'ñ': 'n', 'ń': 'n', 'ņ': 'n', 'ň': 'n', 'ŋ': 'n',
    'ò': 'o', 'ó': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o', 'ø': 'o', 'ō': 'o',
    'ŏ': 'o', 'ő': 'o',
    'ŕ': 'r', 'ŗ': 'r', 'ř': 'r',
    'ś': 's', 'ŝ': 's', 'ş': 's', 'š': 's', 'ș': 's',
    'ţ': 't', 'ť': 't', 'ŧ': 't', 'ț': 't',
    'ù': 'u', 'ú': 'u', 'û': 'u', 'ü': 'u', 'ũ': 'u', 'ū': 'u', 'ŭ': 'u',
    'ů': 'u', 'ű': 'u', 'ų': 'u',
    'ŵ': 'w',
    'ý': 'y', 'ÿ': 'y', 'ŷ': 'y',
    'ź': 'z', 'ż': 'z', 'ž': 'z',
    'þ': 'th',
  };

  /// Marques diacritiques combinantes (U+0300–U+036F).
  ///
  /// Elles ne sont retirées que lorsqu'elles suivent une lettre ASCII, afin de
  /// ne pas dépouiller un texte grec ou cyrillique écrit en forme décomposée.
  static final RegExp _combiningAfterAscii =
      RegExp(r'([a-z0-9])[̀-ͯ]+');

  /// Tout ce qui n'est ni lettre ni chiffre, au sens Unicode.
  static final RegExp _nonAlphanumeric = RegExp(r'[^\p{L}\p{N}]+', unicode: true);

  String normalize(String input) {
    if (input.isEmpty) {
      return '';
    }

    var text = input.toLowerCase();

    for (final entry in _ligatures.entries) {
      if (text.contains(entry.key)) {
        text = text.replaceAll(entry.key, entry.value);
      }
    }

    // Deux passes : la forme décomposée est d'abord recomposée en base ASCII,
    // puis la table couvre la forme précomposée.
    text = text.replaceAllMapped(
      _combiningAfterAscii,
      (match) => match.group(1)!,
    );

    final buffer = StringBuffer();
    for (final rune in text.runes) {
      final character = String.fromCharCode(rune);
      buffer.write(_latinBase[character] ?? character);
    }
    text = buffer.toString();

    text = text.replaceAll(_nonAlphanumeric, ' ');

    return text.trim();
  }
}
