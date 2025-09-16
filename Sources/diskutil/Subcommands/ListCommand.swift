import ArgumentParser
import Foundation
import System

struct ListCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List all block devices in a hierarchical format"
    )

    @Option(name: .shortAndLong, help: "The indentation size for the tree output format")
    var indentSize: Int = 2

    @Flag(name: .shortAndLong, help: "Output in JSON format")
    var json: Bool = false

    func run() throws {
        let systemDisks = SystemDisks()
        let disks = try systemDisks.getAllDisks()

        if json {
            try outputJSON(disks)
        } else {
            try outputSimple(disks)
        }
    }

    private func outputJSON(_ disks: [Disk]) throws {
        func infoOf(disk: Disk) -> [String: Any] {
            var diskInfo: [String: Any] = [:]

            diskInfo["name"] = disk.name
            diskInfo["device_id"] = disk.deviceId
            diskInfo["removable"] = disk.removable
            diskInfo["readonly"] = disk.readOnly
            diskInfo["type"] = disk.type
            diskInfo["filesystem"] = disk.fileSystem
            diskInfo["uuid"] = disk.uniqueId
            diskInfo["device_node"] = disk.deviceNode

            var partitions: [[String: Any]] = []

            for partition in disk.partitions {
                partitions.append(infoOf(disk: partition))
            }

            diskInfo["partitions"] = partitions

            return diskInfo
        }

        let devices = disks.map { infoOf(disk: $0) }

        let data = try JSONSerialization.data(
            withJSONObject: devices,

            options: [
                .prettyPrinted,
                .withoutEscapingSlashes,
                .sortedKeys,
            ]
        )

        if let jsonData = String(data: data, encoding: .utf8) {
            print(jsonData)
        }
    }

    private func outputSimple(_ disks: [Disk]) throws {
        let columns = ["Name", "File System", "Device Path", "MAJ:MIN"]
        func flattenPartitions(partitions: [Disk]) -> [Disk] {
            var flattened: [Disk] = []

            for part in partitions {
                flattened.append(contentsOf: flattenPartitions(partitions: part.partitions))
                flattened.append(part)
            }

            return flattened
        }

        let columnSizes =
            disks.reduce([0, 0, 0, 0, 0]) { value, disk in
                // For the name
                var name = disk.name
                var fs = disk.fileSystem
                var node = disk.deviceNode
                var major = disk.deviceMajor
                var minor = disk.deviceMinor

                for partition in flattenPartitions(partitions: disk.partitions) {
                    if (name + partition.name).count > name.count {
                        name = disk.name + partition.name
                    }

                    if partition.fileSystem?.count ?? 0 > fs?.count ?? 0 {
                        fs = partition.fileSystem
                    }

                    if partition.deviceNode.count > node.count {
                        node = partition.deviceNode
                    }

                    if partition.deviceMajor.count > major.count {
                        major = partition.deviceMajor
                    }

                    if partition.deviceMinor.count > minor.count {
                        minor = partition.deviceMinor
                    }
                }

                return [
                    max(columns[0].count + 4, max(value[0], name.count)),
                    max(columns[1].count + 4, max(value[1], fs?.count ?? 0)),
                    max(columns[2].count + 4, max(value[2], node.count)),
                    max(4, max(value[3], major.count)),
                    max(4, max(value[4], minor.count)),
                ]
            }

        func printDisk(_ disk: Disk, indentLevel: Int = 0, partition: Bool = false) {
            var line = ""

            if indentLevel > 0 {
                line += String(repeating: " ", count: indentLevel)
                line += partition ? "└─" : ""
            }

            line += disk.name.padding(
                toLength: columnSizes[0] - line.count,
                withPad: " ",
                startingAt: 0
            )

            if disk.fileSystem != nil {
                let fs = disk.fileSystem!.padding(
                    toLength: columnSizes[1],
                    withPad: " ",
                    startingAt: 0
                )

                line += "\(fs)"
            } else {
                line += String(repeating: " ", count: columnSizes[1])
            }

            let node = disk.deviceNode.padding(
                toLength: columnSizes[2],
                withPad: " ",
                startingAt: 0
            )

            line += "\(node)"
            line += String(repeating: " ", count: max(0, columnSizes[3] - disk.deviceMajor.count))
            line += "\(disk.deviceMajor):"
            line +=
                "\(disk.deviceMinor.padding(toLength: columnSizes[4], withPad: " ", startingAt: 0)) "

            print(line)

            for partition in disk.partitions {
                printDisk(partition, indentLevel: indentLevel + indentSize, partition: true)
            }
        }

        var heading = ""

        for index in 0...columns.count - 2 {
            heading += columns[index].padding(
                toLength: columnSizes[index],
                withPad: " ",
                startingAt: 0
            )
        }

        heading += " \(columns.last!)"

        print(heading)

        for disk in disks.sorted(by: { $0.name > $1.name }) {
            printDisk(disk)
        }
    }

}
