# Logy

![Swift 6.4](https://img.shields.io/badge/Swift-6.4-F05138?logo=swift&logoColor=white)
![iOS 18+](https://img.shields.io/badge/iOS-18%2B-007AFF)
![SPM](https://img.shields.io/badge/SPM-Compatible-blue)
![License: MIT](https://img.shields.io/badge/License-MIT-yellow)

The logger my libraries share. Each library declares its events and icons; Logy filters them by level, lays them out in columns, applies privacy and writes them to the unified log (`os.Logger`). It also measures intervals for Instruments.

No dependencies. Used by [Beam](https://github.com/markos92i/Beam) and [Stor](https://github.com/markos92i/Stor).

## Requirements

| Requirement | Version |
|---|---|
| Swift | 6.4+ |
| Xcode | 27+ |
| iOS | 18.0+ |
| macOS | 15.0+ |

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/markos92i/Logy.git", from: "1.0.0")
]
```

## Pieces

| Type | What it is |
|---|---|
| `LogLevel` | `.debug`, `.info`, `.warning`, `.error`, `.off` |
| `LogSubsystem` | A library's identity in the log (`com.beam`) and its minimum level, changeable at runtime |
| `LogChannel` | A category inside a subsystem (`http`, `disk`): where its lines and intervals go |
| `LogEntry` | What a library logs: level, channel and lines. Usually one enum per library |
| `Logy<Entry>` | Writes entries. An owner (e.g. one API) can have its own level |
| `LogBuilder` | Result builder for the lines of an entry |
| `LogColumns` | Aligns the `\t`-separated columns of the first line |

## Logging from a library

```swift
import Logy

extension LogSubsystem {
    public static let stor = LogSubsystem("com.stor")
}

extension LogChannel {
    static let disk = LogChannel(.stor, "disk")
}

enum StorLog: LogEntry {
    case write(key: String, bytes: Int, elapsed: Duration)
    case failed(key: String, detail: String)

    var level: LogLevel {
        switch self {
        case .write: .debug
        case .failed: .error
        }
    }

    var channel: LogChannel { .disk }

    @LogBuilder
    func lines(bodies: Bool) -> [String] {
        switch self {
        case .write(let key, let bytes, let elapsed):
            "􀤂 write\t􀈕 \(key)\t\(bytes.byteFormatted)\t􀐫 \(elapsed.logFormatted)"
        case .failed(let key, let detail):
            "􀇾 write\t􀈕 \(key)"
            "􀺾 \(detail)"
        }
    }
}

let log = Logy<StorLog>()
log.log(.write(key: "user.profile", bytes: 2048, elapsed: .milliseconds(3)))
```

- Write `@LogBuilder` on `lines(bodies:)`: Swift only infers it from the protocol when the method is declared in the same block as the conformance.
- Icons go as literal SF Symbols in the text, so a line reads like what the console shows.
- Separate columns with `\t`. Only the first line is aligned; the rest are printed as they are.
- `bodies` is `true` when the effective level is `.debug`: show payloads only then.

## Levels and privacy

| | Debug | Release |
|---|---|---|
| Default `LogSubsystem.level` | `.debug` | `.warning` |
| Message privacy | `.public` | `.private`: `<private>` without a logging profile |

- An entry is written when its level is at or above the owner's level (`Logy(level:)`), or the subsystem's when the owner has none.
- A subsystem at `.off` silences everything in it, also owners with their own level.
- `.warning` and `.error` reach the unified log as `OSLogType.error`; Logy never logs `.fault`.

```swift
LogSubsystem.beam.level = .off    // silences Beam; Stor keeps logging
let api = Logy<LogEvent>(level: .error)
```

## Measurements

An interval is a bar in Instruments and the time it took:

```swift
let interval = log.begin("request", "GET [A1F3]", detail: "/users/42", on: .http)
...
let elapsed = log.end(interval, "200")

let (value, elapsed) = try await log.measure("write", key, on: .disk) { try await backend.write(data, for: key) }
```

- `label` and the result passed to `end` are always public; `detail` is private outside Debug.
- `measure` closes the interval with `failed` when `work` throws, and rethrows the typed error.
- Each channel chooses where its intervals appear:

| `LogChannel(…, signposts:)` | Where in Instruments |
|---|---|
| `.pointsOfInterest` (default) | The "Points of Interest" lane, present in the usual templates |
| `.ownCategory` | The "os_signpost" instrument, filtered by the channel's category |

## Formatting

| Helper | Example |
|---|---|
| `Int.byteFormatted` | `2KB` |
| `Duration.logFormatted` | `1s 500ms` |
| `Data.logText` | Pretty-printed JSON, UTF-8 text, or `nil` |

## Icons

The same meaning uses the same SF Symbol in every library:

| Meaning | Symbol |
|---|---|
| Sent / request | 􀁶 |
| Received / response | 􀁸 |
| Success | 􀁢 |
| Redirect | 􀅴 |
| Failure status | 􀁞 |
| Error | 􀇾 |
| Warning | 􀇿 |
| Error detail | 􀺾 |
| Retry / reconnect | 􀅈 |
| Elapsed time | 􀐫 |
| Path / key | 􀈕 |
| Headers | 􁒠 |
| Body / payload | 􁒡 |
| Nothing | 􀓔 |
| File | 􀈷 |
| Credentials | 􁠱 |
| Disk | 􀤂 |
| Keychain | 􀎡 |

## License

Logy is available under the MIT license.
