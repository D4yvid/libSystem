import CUDevices

public class SystemDevices {
    private var handle: OpaquePointer!

    public init() throws {
        self.handle = udev_new()

        guard self.handle != nil else {
            throw DeviceError.udevError(details: "udev_new() failed")
        }
    }

    deinit {
        udev_unref(self.handle)
    }

    public func makeEnumerator() -> DeviceEnumerator {
        return DeviceEnumerator(handle: self.handle)
    }

    public func makeMonitor() -> DeviceMonitor {
        return DeviceMonitor(udev: self.handle)
    }
}
