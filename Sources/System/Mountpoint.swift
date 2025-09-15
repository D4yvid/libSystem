import Foundation

public struct MountpointOption {
    public enum Value {
        case boolean(Bool)
        case number(Int)
        case string(String)
        case list([String])
    }

    public let name: String
    public let value: Value

    public func string() -> String {
        switch self.value {
        case .list(let items):
            return "\(self.name)=\(items.joined(separator: ":"))"

        case .number(let value):
            return "\(self.name)=\(value)"

        case .string(let value):
            return "\(self.name)=\(value)"

        case .boolean(let value):
            return value ? self.name : "no\(self.name)"
        }
    }

    public static func from(string: String) -> MountpointOption {
        guard let equals = string.firstIndex(of: "=") else {
            if string.starts(with: "no") {
                return MountpointOption(name: string, value: .boolean(false))
            }

            return MountpointOption(name: string, value: .boolean(true))
        }

        let before = string.index(before: equals)
        let after = string.index(after: equals)

        let name = String(string[...before])
        let value = String(string[after...])

        let values = value.split(separator: ":").map { String($0) }

        if values.count > 0 {
            return MountpointOption(name: name, value: .list(values))
        }

        guard let number = Int(value) else {
            return MountpointOption(name: name, value: .string(value))
        }

        return MountpointOption(name: name, value: .number(number))
    }
}

public struct Mountpoint {
    public let fileSystem: String
    public let directory: URL
    public let type: String
    public let options: [MountpointOption]
    public let dump: Int
    public let pass: Int
}
