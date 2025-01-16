// The Swift Programming Language
// https://docs.swift.org/swift-book

import os
import Logging
import Foundation

public let log: Logging.Logger = {
    let osLogHandler = OSLogHandler()
    let multiplexLogHandler = MultiplexLogHandler([osLogHandler])
    return Logger(label: Bundle.main.bundleIdentifier!) { _ in multiplexLogHandler }
}()

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
