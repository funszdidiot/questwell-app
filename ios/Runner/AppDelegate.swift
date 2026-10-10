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
       let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first,
       let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
      let picker = QuestwellExportPicker(presenter: controller, caches: caches, documents: documents)
      let channel = FlutterMethodChannel(name: "questwell/account_export", binaryMessenger: controller.binaryMessenger)
      channel.setMethodCallHandler { call, result in picker.handle(call, result: result) }
      exportPicker = picker
      exportChannel = channel
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
