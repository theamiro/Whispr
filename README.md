# Whispr - Swift Simple Logger

This repository provides a custom logging setup in Swift using the `os` and `Logging` frameworks. The implementation allows for structured logging with metadata, different log levels, and uses emoji for enhanced readability.

## Features
- Integration with Apple's `os_log` for logging to the unified logging system.
- Support for log levels: `trace`, `debug`, `info`, `notice`, `warning`, `error`, `critical`.
- Metadata support for structured logging.
- Emojis to visually distinguish log levels.
- Multiplex logging for multiple log handlers.

## Implementation
### Logger Initialization
```swift
import os
import Logging
import Foundation

public let log: Logging.Logger = {
    let osLogHandler = OSLogHandler()
    let multiplexLogHandler = MultiplexLogHandler([osLogHandler])
    return Logger(label: Bundle.main.bundleIdentifier!) { _ in multiplexLogHandler }
}()
```
The `log` object is a global logger initialized with a multiplex handler. It uses the app's `bundleIdentifier` as the label.

### Custom Log Handler
The custom `OSLogHandler` implements the `LogHandler` protocol to handle log messages and route them to `os_log`.

#### Key Methods and Properties
```swift
private final class OSLogHandler: @unchecked Sendable, LogHandler {
    subscript(metadataKey metadataKey: String) -> Logging.Logger.Metadata.Value? {
        get { metadata[metadataKey] }
        set(newValue) { metadata[metadataKey] = newValue }
    }

    var metadata = Logger.Metadata()
    var logLevel = Logger.Level.debug

    private let osLog = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "app")

    func log(level: Logging.Logger.Level,
             message: Logging.Logger.Message,
             metadata: Logging.Logger.Metadata?,
             source: String,
             file: String,
             function: String,
             line: UInt) {
        let (emoji, osLogType): (String, OSLogType) = {
            switch level {
                case .trace: return ("🖤", .debug)
                case .debug: return ("💚", .debug)
                case .info: return ("💙", .info)
                case .notice: return ("💜", .default)
                case .warning: return ("💛", .default)
                case .error: return ("❤️", .error)
                case .critical: return ("💔", .fault)
            }
        }()

        let filename = URL(fileURLWithPath: file).lastPathComponent
        let detailsString = metadata.map {
            return "\n" + $0.map { pair in
                "\(pair.key): \(pair.value)"
            }
            .joined(separator: "\n")
        }

        os_log(
            "%@ [%@:%d] %{public}@%@",
            log: osLog,
            type: osLogType,
            emoji,
            filename,
            line,
            message.description,
            detailsString ?? ""
        )
    }
}
```

## Usage
### Logging Messages
You can use the `log` object to log messages at different levels:
```swift
log.trace("This is a trace message.")
log.debug("Debugging information.")
log.info("Informational message.")
log.notice("Notice something important.")
log.warning("A warning occurred.")
log.error("An error occurred.")
log.critical("Critical failure.")
```

### Adding Metadata
Include metadata to provide additional context:
```swift
log.info("User logged in", metadata: ["userID": "12345"])
```
This will append metadata details to the log output.

### Sample Output
Here is an example of how logs might look in the console:
```
💙 [ViewController.swift:45] User logged in
userID: 12345
```

## Requirements
- Swift 5.5+
- iOS 13.0+ or macOS 10.15+

## Installation
Include this implementation in your project by copying the provided code into your Swift files.

## License
This implementation is open-source and available under the MIT license. See `LICENSE` for details.

