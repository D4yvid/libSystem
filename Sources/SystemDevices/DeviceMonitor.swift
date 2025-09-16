import CUDevices
import Foundation

public class DeviceMonitor {
    private let udevHandle: OpaquePointer
    private let handle: OpaquePointer!

    /// Get the file descriptor of this device monitor
    /// - SeeAlso:
    ///     - man `udev_monitor_get_fd(3)`
    var fileDescriptor: Int32? {
        let fd = udev_monitor_get_fd(handle)

        guard fd >= 0 else { return nil }

        return fd
    }

    var fileHandle: FileHandle? {
        if let fd = fileDescriptor {
            FileHandle(fileDescriptor: fd)
        } else {
            nil
        }
    }

    init(udev: OpaquePointer) {
        self.udevHandle = udev
        self.handle = udev_monitor_new_from_netlink(udev, "udev")
    }

    deinit {
        udev_monitor_unref(handle)
    }

    func enableReceiving() throws {
        guard udev_monitor_enable_receiving(handle) >= 0 else {
            throw DeviceError.udevError(details: "udev_monitor_enable_receiving() failed")
        }
    }

    func receive() -> Device? {
        guard let dev = udev_monitor_receive_device(handle) else {
            return nil
        }

        return Device(udev: handle, handle: dev)
    }

    func setReceiveBufferSize(_ size: Int32) throws {
        guard udev_monitor_set_receive_buffer_size(handle, size) >= 0 else {
            throw DeviceError.udevError(details: "udev_monitor_set_receive_buffer_size() failed")
        }
    }

    func match(tag: String) throws {
        guard udev_monitor_filter_add_match_tag(handle, tag) >= 0 else {
            throw DeviceError.udevError(details: "udev_monitor_filter_add_match_tag() failed")
        }
    }

    func match(subsystem: String, deviceType: String) throws {
        guard udev_monitor_filter_add_match_subsystem_devtype(handle, subsystem, deviceType) >= 0
        else {
            throw DeviceError.udevError(details: "udev_monitor_filter_add_match_tag() failed")
        }
    }

    func updateFilters() throws {
        guard udev_monitor_filter_update(handle) >= 0 else {
            throw DeviceError.udevError(details: "udev_monitor_filter_update() failed")
        }
    }

    func removeFilters() throws {
        guard udev_monitor_filter_remove(handle) >= 0 else {
            throw DeviceError.udevError(details: "udev_monitor_filter_remove() failed")
        }
    }
}
