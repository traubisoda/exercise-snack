import Foundation
import AppKit

class UpdateManager {
    static let shared = UpdateManager()

    private var isChecking = false

    private init() {}

    func checkForUpdates(userInitiated: Bool) {
        guard !isChecking else { return }
        isChecking = true

        let urlString = "https://api.github.com/repos/traubisoda/exercise-snack/releases/latest"
        guard let url = URL(string: urlString) else {
            isChecking = false
            return
        }

        var request = URLRequest(url: url)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            defer { self?.isChecking = false }

            guard let data = data, error == nil else {
                if userInitiated {
                    DispatchQueue.main.async {
                        self?.showErrorAlert(message: error?.localizedDescription ?? "Unknown error")
                    }
                }
                return
            }

            guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let tagName = json["tag_name"] as? String,
                  let htmlURL = json["html_url"] as? String else {
                if userInitiated {
                    DispatchQueue.main.async {
                        self?.showErrorAlert(message: "Could not parse release information.")
                    }
                }
                return
            }

            let remoteVersion = tagName.hasPrefix("v") ? String(tagName.dropFirst()) : tagName
            let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.0.0"

            DispatchQueue.main.async {
                if Self.isNewer(remote: remoteVersion, current: currentVersion) {
                    self?.showUpdateAlert(version: tagName, url: htmlURL)
                } else if userInitiated {
                    self?.showUpToDateAlert()
                }
            }
        }.resume()
    }

    static func isNewer(remote: String, current: String) -> Bool {
        let remoteParts = remote.split(separator: ".").compactMap { Int($0) }
        let currentParts = current.split(separator: ".").compactMap { Int($0) }
        let maxLen = max(remoteParts.count, currentParts.count)

        for i in 0..<maxLen {
            let r = i < remoteParts.count ? remoteParts[i] : 0
            let c = i < currentParts.count ? currentParts[i] : 0
            if r > c { return true }
            if r < c { return false }
        }
        return false
    }

    private func showUpdateAlert(version: String, url: String) {
        let alert = NSAlert()
        alert.messageText = "Update Available"
        alert.informativeText = "A new version (\(version)) is available. Would you like to download it?"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Download")
        alert.addButton(withTitle: "Later")

        NSApplication.shared.activate(ignoringOtherApps: true)
        let response = alert.runModal()

        if response == .alertFirstButtonReturn, let downloadURL = URL(string: url) {
            NSWorkspace.shared.open(downloadURL)
        }
    }

    private func showUpToDateAlert() {
        let alert = NSAlert()
        alert.messageText = "You're Up to Date"
        alert.informativeText = "You're running the latest version of Exercise Snack."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")

        NSApplication.shared.activate(ignoringOtherApps: true)
        alert.runModal()
    }

    private func showErrorAlert(message: String) {
        let alert = NSAlert()
        alert.messageText = "Update Check Failed"
        alert.informativeText = "Could not check for updates: \(message)"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")

        NSApplication.shared.activate(ignoringOtherApps: true)
        alert.runModal()
    }
}
