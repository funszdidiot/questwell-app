import Flutter
import UIKit

final class QuestwellExportPicker: NSObject, UIDocumentPickerDelegate,
                                   UIAdaptivePresentationControllerDelegate {
  private let files: QuestwellExportFiles
  private let documents: URL
  private let privateDocuments: Bool
  private weak var presenter: UIViewController?
  private var pending: FlutterResult?
  private var picker: UIDocumentPickerViewController?

  init(presenter: UIViewController, caches: URL, documents: URL) {
    self.presenter = presenter
    self.documents = documents
    privateDocuments = !["UIFileSharingEnabled", "LSSupportsOpeningDocumentsInPlace",
                         "UISupportsDocumentBrowser"].contains {
      Bundle.main.object(forInfoDictionaryKey: $0) as? Bool == true
    }
    files = QuestwellExportFiles(caches: caches)
    super.init()
    // Recovery runs even when no account is signed in. A locked filesystem may
    // prevent cleanup now; every save must retry successfully before staging.
    try? recover()
  }

  private func recover() throws {
    try files.recover()
    try QuestwellExportFiles.recoverLegacy(documents: documents, isPrivate: privateDocuments)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard call.method == "save" else { result(FlutterMethodNotImplemented); return }
    guard pending == nil, let presenter = presenter,
          presenter.viewIfLoaded?.window != nil,
          presenter.presentedViewController == nil else {
      result(failure()); return
    }
    guard let bytes = call.arguments as? FlutterStandardTypedData else {
      result(failure()); return
    }
    do {
      try recover()
      let source = try files.stage(bytes.data)
      let controller = UIDocumentPickerViewController(forExporting: [source], asCopy: true)
      controller.delegate = self
      // Cancel remains available; prevent an interactive dismissal escaping the
      // document-picker delegate on providers with different sheet behavior.
      controller.isModalInPresentation = true
      pending = result
      picker = controller
      presenter.present(controller, animated: true)
      controller.presentationController?.delegate = self
    } catch {
      try? files.recover()
      result(failure())
    }
  }

  func documentPicker(_ controller: UIDocumentPickerViewController,
                      didPickDocumentsAt urls: [URL]) {
    guard controller === picker else { return }
    finish(!urls.isEmpty)
  }

  func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
    guard controller === picker else { return }
    finish(false)
  }

  func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
    guard presentationController.presentedViewController === picker else { return }
    finish(false)
  }

  private func finish(_ saved: Bool) {
    guard let result = pending else { return }
    pending = nil
    picker = nil
    do {
      try files.recover()
      result(saved)
    } catch {
      result(failure())
    }
  }

  private func failure() -> FlutterError {
    FlutterError(code: "export_save_failed", message: "Could not save your data. Please try again.",
                 details: nil)
  }
}
