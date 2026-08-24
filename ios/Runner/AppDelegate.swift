import UIKit
import Flutter
import AVFoundation

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller = window?.rootViewController as? FlutterViewController
    if let controller = controller {
      // iOS : Agora nécessite une session audio en catégorie playAndRecord
      // pour capturer le micro en visio (sinon échec silencieux de capture).
      // Appelé depuis configureAudioSessionForVideoCall() avant joinChannel.
      let audioChannel = FlutterMethodChannel(
        name: "com.app.amily/audio_session",
        binaryMessenger: controller.binaryMessenger
      )
      audioChannel.setMethodCallHandler { (call, result) in
        if call.method == "configurePlayAndRecord" {
          do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(
              .playAndRecord,
              mode: .voiceChat,
              options: [.allowBluetooth, .defaultToSpeaker]
            )
            try session.setActive(true)
            result(nil)
          } catch {
            result(FlutterError(
              code: "AUDIO_SESSION_ERROR",
              message: error.localizedDescription,
              details: nil
            ))
          }
        } else {
          result(FlutterMethodNotImplemented)
        }
      }

      let channel = FlutterMethodChannel(
        name: "com.app.amily/badge",
        binaryMessenger: controller.binaryMessenger
      )
      channel.setMethodCallHandler { (call, result) in
        if call.method == "setBadgeCount" {
          let args = call.arguments as? [String: Any]
          let count = args?["count"] as? Int ?? 0
          DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = count
          }
          result(nil)
        } else {
          result(FlutterMethodNotImplemented)
        }
      }
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
