
import Foundation

enum Browser: String {
    case Chrome = "com.google.Chrome"
    case ChromeCanary = "com.google.Chrome.canary"
    case Brave = "com.brave.Browser"
    case BraveDev = "com.brave.Browser.dev"
    case Safari = "com.apple.Safari"
    case Firefox = "org.mozilla.firefox"
    case FirefoxDeveloperEdition = "org.mozilla.firefoxdeveloperedition"
    case Opera = "com.operasoftware.Opera"
}

public func getBrowserCommand(_ browserOpts: BrowserOpts, url: URL) -> [String] {
    var command = ["open"]

    // Append options first.
    // appPath takes priority over bundleId as it is always unique.
    if let appPath = browserOpts.appPath {
        command.append(contentsOf: ["-a", appPath])
    } else if let bundleId = browserOpts.bundleId {
        command.append(contentsOf: ["-b", bundleId])
    } else {}

    if browserOpts.openInBackground {
        command.append("-g")
    }
    
    // Pass URL using --args when profileName is defined and supported browser used
    // because arguments are ignored when URL pass to open commmand as filename.
    if let profileName = browserOpts.profileName {
        let usedName = browserOpts.appPath ?? browserOpts.bundleId ?? ""
        if usedName.lowercased().contains("firefox") {
            command.append(contentsOf: ["-n", "--args", "-P", profileName, url.absoluteString])
        } else if usedName.lowercased().contains("chrome") {
            command.append(contentsOf: ["-n", "--args", "--profile-directory=\(profileName)", url.absoluteString])
        } else {
            command.append(url.absoluteString)
        }
    } else {
        command.append(url.absoluteString)
    }

    return command
}
