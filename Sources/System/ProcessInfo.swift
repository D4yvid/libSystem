import Foundation

extension ProcessInfo {
    public func mountpoints() throws -> [Mountpoint] {
        let procMounts = String(
            data: try Data(contentsOf: URL(filePath: "/proc/self/mounts")),
            encoding: .utf8
        )!.split(separator: "\n")

        return procMounts.map { $0.split(separator: " ") }
            .map { parts in
                let options = parts[3].split(separator: ",").map {
                    MountpointOption.from(string: String($0))
                }

                return Mountpoint(
                    fileSystem: String(parts[0]),
                    directory: URL(filePath: String(parts[1])),
                    type: String(parts[2]),

                    options: options,

                    dump: Int(parts[4])!,
                    pass: Int(parts[5])!
                )
            }

    }
}
