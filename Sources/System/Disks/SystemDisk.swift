import SystemDevices

public class Disk {
    /// The underlying device of this disk
    public let device: Device

    /// If this disk is a partition, `parentDisk` will be the partitioned disk
    private(set) var parentDisk: Disk? = nil

    /// If this disk is a partition
    public var isPartition: Bool { parentDisk != nil }

    /// All the partitions of this specific disk
    private(set) var partitions: [Disk] = []

    public var name: String {
        device.systemName!
    }

    public var deviceMajor: String {
        device.propertyValue(of: "MAJOR") ?? "0"
    }

    public var deviceMinor: String {
        device.propertyValue(of: "MINOR") ?? "0"
    }

    public var deviceId: String {
        "\(deviceMajor):\(deviceMinor)"
    }

    public var removable: Bool {
        device.systemAttributeValue(of: "removable") == "1"
    }

    public var readOnly: Bool {
        device.systemAttributeValue(of: "ro") == "1"
    }

    public var type: String {
        device.deviceType!
    }

    public var fileSystem: String? {
        device.propertyValue(of: "ID_FS_TYPE")
    }

    public var uniqueId: String? {
        device.propertyValue(of: "ID_FS_UUID")
    }

    public var deviceNode: String {
        device.deviceNode
    }

    init(device: Device) {
        self.device = device
    }

    static func builder(device: Device) -> Builder {
        return Builder(device: device)
    }

    /// A disk builder
    class Builder {
        public let device: Device
        public var partitions: [Builder] = []
        public var parent: Disk.Builder? = nil

        init(device: Device) {
            self.device = device
        }

        func set(parent: Disk.Builder) -> Self {
            self.parent = parent

            return self
        }

        func add(partition: Builder) -> Self {
            self.partitions.append(partition)

            return self
        }

        func build(parent: Disk? = nil) -> Disk {
            let disk = Disk(device: self.device)

            disk.parentDisk = parent

            let partitions = self.partitions
                .map { $0.build(parent: disk) }

            disk.partitions = partitions

            return disk
        }
    }

}
