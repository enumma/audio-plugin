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
        CAPPluginMethod(name: "setupNotifications", returnType: CAPPluginReturnPromise)
    ]

    var headphonesConnected: Bool = false;

    @objc func setupNotifications(_ call: CAPPluginCall) {
        let session = AVAudioSession.sharedInstance()
        do {
          try session.setActive(false)
          try session.setCategory(.playAndRecord, mode: .videoChat, options: [.allowBluetooth, .allowAirPlay, .mixWithOthers, .defaultToSpeaker])
          try session.setActive(true)
          try session.overrideOutputAudioPort(.none)
        } catch {
            print("Error setting audio session: \(error)")
        }
        checkCurrentAudioRoute()

        // Get the default notification center instance.
        let nc = NotificationCenter.default
        nc.addObserver(self,
                    selector: #selector(handleRouteChange),
                    name: AVAudioSession.routeChangeNotification,
                    object: nil)
        call.resolve(["status": "Audio session configured"]);
    }

    func checkCurrentAudioRoute() {
        let session = AVAudioSession.sharedInstance()
        headphonesConnected = hasHeadphones(in: session.currentRoute)

        // If headphones are connected, adjust the audio session settings
        if headphonesConnected {
          print("Headphones detected!")
        } else {
          print("Headphones not detected!")
        }
        print(session.currentRoute.outputs)
    }

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
          print(session.currentRoute.outputs)
        case .oldDeviceUnavailable: // Old device removed.
            if let previousRoute =
                userInfo[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription {
                headphonesConnected = hasHeadphones(in: previousRoute)
            }
        default:
          checkCurrentAudioRoute()
        }

        let reasonText = getRouteChangeReasonText(reason: reason)
        print("Audio route changed for reason: \(reasonText)")
    }

    func hasHeadphones(in routeDescription: AVAudioSessionRouteDescription) -> Bool {
      // Filter the outputs to only those with a port type of headphones.
      return !routeDescription.outputs.filter({$0.portType == .headphones}).isEmpty
    }

    func getRouteChangeReasonText(reason: AVAudioSession.RouteChangeReason) -> String {
      switch reason {
      case .unknown:
          return "Unknown"
      case .newDeviceAvailable:
          return "New Device Available"
      case .oldDeviceUnavailable:
          return "Old Device Unavailable"
      case .categoryChange:
          return "Category Change"
      case .override:
          return "Override"
      case .wakeFromSleep:
          return "Wake from Sleep"
      case .noSuitableRouteForCategory:
          return "No Suitable Route for Category"
      case .routeConfigurationChange:
          return "Route Configuration Change"
      @unknown default:
          return "Unknown Reason"
      }
  }

    deinit {
        NotificationCenter.default.removeObserver(self, name: AVAudioSession.routeChangeNotification, object: nil)
    }
}
