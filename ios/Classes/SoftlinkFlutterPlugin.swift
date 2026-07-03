import Flutter
import UIKit
import StoreKit

public class SoftlinkFlutterPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "softlink_flutter",
            binaryMessenger: registrar.messenger()
        )
        let instance = SoftlinkFlutterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "registerSKAdNetwork":
            registerSKAdNetwork(result: result)
        case "getInstallReferrer":
            // iOS doesn't have Play Install Referrer — return nil
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func registerSKAdNetwork(result: @escaping FlutterResult) {
        if #available(iOS 14.0, *) {
            SKAdNetwork.registerAppForAdNetworkAttribution()
            result(true)
        } else if #available(iOS 11.3, *) {
            SKAdNetwork.registerAppForAdNetworkAttribution()
            result(true)
        } else {
            result(false)
        }
    }
}