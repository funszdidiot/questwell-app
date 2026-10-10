import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var exportPicker: QuestwellExportPicker?
  private var exportChannel: FlutterMethodChannel?
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    if let controller = window?.rootViewController as? FlutterViewController,
       let caches = try? FileManager.default.url(for: .cachesDirectory, in: .userDomainMask,
                                               appropriateFor: nil, create: true),
       let documents = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask,
                                                  appropriateFor: nil, create: true) {
      let picker = QuestwellExportPicker(presenter: controller, caches: caches, documents: documents)
      let channel = FlutterMethodChannel(name: "questwell/account_export", binaryMessenger: controller.binaryMessenger)
      channel.setMethodCallHandler { call, result in picker.handle(call, result: result) }
      exportPicker = picker
      exportChannel = channel
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
