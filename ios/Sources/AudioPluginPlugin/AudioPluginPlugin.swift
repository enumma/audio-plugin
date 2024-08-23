import Foundation
import Capacitor
import AVFoundation

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(AudioPluginPlugin)
public class AudioPluginPlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "AudioPluginPlugin"
    public let jsName = "AudioPlugin"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "echo", returnType: CAPPluginReturnPromise)
    ]
    private let implementation = AudioPlugin()

    @objc func echo(_ call: CAPPluginCall) {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .voiceChat, options: [.allowBluetooth, .allowBluetoothA2DP])
            try audioSession.setActive(true)

            // Optionally handle route changes or additional setup
            call.resolve(["status": "Audio session configured"])
        } catch {
            call.reject("Error configuring audio session: \(error)")
        }
        let value = call.getString("value") ?? ""
        call.resolve([
            "value": implementation.echo(value)
        ])
    }

    func setupNotifications(_ call: CAPPluginCall) {
        // Get the default notification center instance.
        let nc = NotificationCenter.default
        nc.addObserver(self,
                    selector: #selector(handleRouteChange),
                    name: AVAudioSession.routeChangeNotification,
                    object: nil)
        call.resolve();
    }

    var headphonesConnected: Bool = false;

    @objc func handleRouteChange(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
            let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
                return
        }
        
        // Switch over the route change reason.
        switch reason {


        case .newDeviceAvailable: // New device found.
            let session = AVAudioSession.sharedInstance()
            headphonesConnected = hasHeadphones(in: session.currentRoute)
        
        case .oldDeviceUnavailable: // Old device removed.
            if let previousRoute =
                userInfo[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription {
                headphonesConnected = hasHeadphones(in: previousRoute)
            }
        
        default: ()
        }
    }

    func hasHeadphones(in routeDescription: AVAudioSessionRouteDescription) -> Bool {
        // Filter the outputs to only those with a port type of headphones.
        return !routeDescription.outputs.filter({$0.portType == .headphones}).isEmpty
    }
}
