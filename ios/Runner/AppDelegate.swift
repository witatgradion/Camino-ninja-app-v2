import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let channelName = "camino_ninja/screenshot"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: channelName,
        binaryMessenger: controller.binaryMessenger
      )

      channel.setMethodCallHandler { [weak self] (call, result) in
        guard call.method == "captureScreen" else {
          result(FlutterMethodNotImplemented)
          return
        }
        self?.captureScreenNative(result: result)
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func captureScreenNative(result: @escaping FlutterResult) {
    guard let window = self.window else {
      result(FlutterError(code: "NO_WINDOW", message: "No main window", details: nil))
      return
    }

    // Snapshot the whole window, which includes Flutter content and any
    // embedded platform views (e.g. Google Maps) with correct z-order.
    let rendererFormat = UIGraphicsImageRendererFormat()
    rendererFormat.scale = UIScreen.main.scale
    let renderer = UIGraphicsImageRenderer(size: window.bounds.size, format: rendererFormat)

    let image = renderer.image { _ in
      window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
    }

    guard let pngData = image.pngData() else {
      result(FlutterError(code: "ENCODE_FAILED", message: "Failed to encode PNG", details: nil))
      return
    }

    result(FlutterStandardTypedData(bytes: pngData))
  }
}
