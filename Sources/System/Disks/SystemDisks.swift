import SystemDevices

public class SystemDisks {

    public init() {}

    public func getAllDisks() throws -> [Disk] {
        let blockDevices = findAllBlockDevices()
        var deviceMap: [String: Disk.Builder] = [:]

        for device in blockDevices {
            if device.deviceType == "disk" {
                deviceMap[device.deviceNode] = Disk.builder(device: device)

                continue
            }

            if device.deviceType == "partition" {
                let tree = getDiskTreeFor(device: device)
                let root = tree.first!

                var currentBuilder = deviceMap[
                    root.deviceNode, default: Disk.builder(device: root)]

                // Store root builder if it doesn't exist
                deviceMap[root.deviceNode] = currentBuilder

                for current in tree.dropFirst() {
                    let builder = Disk.builder(device: current)
                        .set(parent: currentBuilder)

                    _ = currentBuilder.add(partition: builder)
                    currentBuilder = builder
                }

                continue
            }

            print("Unhandled device type: \(device.deviceType ?? "")")
        }

        return deviceMap.map { $1.build() }
    }

    func getDiskTreeFor(device: Device) -> [Device] {
        var tree: [Device] = []
        var current: Device? = device

        while current != nil {
            tree.insert(current!, at: 0)

            if current!.deviceType == "disk" { break }

            current = current!.parent
        }

        return tree
    }

    /// Get all block devices using udev
    func findAllBlockDevices() -> [Device] {
        let devices = try! SystemDevices()
        let enumerator = devices.makeEnumerator()

        _ = enumerator.match(subsystem: "block")

        return enumerator.scanDevices()
    }

}
