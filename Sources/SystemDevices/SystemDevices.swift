import CUDevices
import System

public class SystemDevices {
    private var handle: OpaquePointer!

    init() throws {
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
}
