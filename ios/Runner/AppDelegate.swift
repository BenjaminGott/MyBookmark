import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "InstagramStoryPlugin") {
      InstagramStoryPlugin.register(with: registrar)
    }
  }
}

/// Partage en story Instagram, le pendant iOS de `MainActivity` sur Android.
///
/// Instagram lit l'image dans le presse-papiers, sous des clés qui lui sont
/// propres, puis on l'ouvre par son lien `instagram-stories://`. Le schéma est
/// déclaré dans Info.plist (LSApplicationQueriesSchemes), sans quoi iOS
/// répond toujours qu'Instagram n'est pas installé.
final class InstagramStoryPlugin: NSObject, FlutterPlugin {
  // Identifiant de l'app Meta, exigé par Instagram pour accepter une story
  // venue d'une autre application. Ce n'est pas un secret.
  private static let facebookAppId = "2201363724596999"

  private static var storyURL: URL? {
    URL(string: "instagram-stories://share?source_application=\(facebookAppId)")
  }

  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "com.libergot.mybookmark/instagram_story",
      binaryMessenger: registrar.messenger()
    )
    registrar.addMethodCallDelegate(InstagramStoryPlugin(), channel: channel)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "isAvailable":
      guard let url = Self.storyURL else {
        result(false)
        return
      }
      result(UIApplication.shared.canOpenURL(url))
    case "share":
      share(call, result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  // En sticker, l'image est posée sur le dégradé décrit par les deux couleurs
  // et garde sa transparence ; sinon elle devient le fond.
  private func share(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard
      let arguments = call.arguments as? [String: Any],
      let path = arguments["path"] as? String,
      let image = FileManager.default.contents(atPath: path),
      let url = Self.storyURL
    else {
      result(FlutterError(code: "bad_args", message: "Image introuvable", details: nil))
      return
    }

    var item: [String: Any] = [:]
    if arguments["asSticker"] as? Bool == true {
      item["com.instagram.sharedSticker.stickerImage"] = image
      if let top = arguments["topColor"] as? String {
        item["com.instagram.sharedSticker.backgroundTopColor"] = top
      }
      if let bottom = arguments["bottomColor"] as? String {
        item["com.instagram.sharedSticker.backgroundBottomColor"] = bottom
      }
    } else {
      item["com.instagram.sharedSticker.backgroundImage"] = image
    }

    // Le presse-papiers s'efface tout seul après cinq minutes.
    UIPasteboard.general.setItems(
      [item],
      options: [.expirationDate: Date().addingTimeInterval(5 * 60)]
    )
    UIApplication.shared.open(url, options: [:]) { opened in
      if opened {
        result(nil)
      } else {
        result(FlutterError(code: "unavailable", message: "Instagram n'est pas installé", details: nil))
      }
    }
  }
}
