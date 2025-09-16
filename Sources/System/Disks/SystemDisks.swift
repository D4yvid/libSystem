import SystemDevices

public class SystemDisks {

    public init() {}

    public func getAllDisks() throws -> [Disk] {
        let blockDevices = findAllBlockDevices()
        var deviceMap: [String: Disk.Builder] = [:]

        loop: for device in blockDevices {
            switch device.deviceType {
            case "disk":
                deviceMap[device.deviceNode!] = Disk.builder(device: device)
                break

            case "partition":
                var tree = getDiskTreeFor(device: device)
                let root = tree.removeFirst()

                if !deviceMap.contains(where: { $0.key == root.deviceNode }) {
                    deviceMap[root.deviceNode!] = Disk.builder(device: root)
                }

                var current: Device? = tree.removeFirst()
                var currentBuilder = deviceMap[root.deviceNode!]

                while current != nil {
                    let builder =
                        Disk
                        .builder(device: current!)
                        .set(parent: currentBuilder!)

                    _ = currentBuilder?.add(partition: builder)

                    currentBuilder = builder
                    current = tree.first != nil ? tree.removeFirst() : nil
                }

                break

            default:
                print("Unhandled device type: \(device.deviceType ?? "")")
                continue loop
            }
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
