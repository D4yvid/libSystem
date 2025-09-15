import CUDevices
import Foundation

/// A Swift wrapper for udev device functionality
///
/// This class provides a Swift interface to interact with udev devices,
/// allowing access to device properties, attributes, and metadata.
///
/// - SeeAlso:
///     - man `udev(7)`
///     - man `libudev(3)`
public class Device {
    let udevHandle: OpaquePointer
    let handle: OpaquePointer

    /// Get the parent device
    ///
    /// - SeeAlso:
    ///     - man `udev_device_get_parent(3)`
    var parent: Device? {
        guard let device = udev_device_get_parent(handle) else {
            return nil
        }

        return Device(udevHandle: udevHandle, handle: device)
    }

    /// If the device is initialized
    /// - SeeAlso:
    /// - man `udev_device_get_parent(3)`
    ///
    var initialized: Bool {
        udev_device_get_is_initialized(handle) != 0
    }

    /// Get the time when this device was initialized
    /// - SeeAlso:
    /// - man `udev_device_get_usec_since_initialized`
    ///
    var initializationDate: Date {
        .now.addingTimeInterval(
            -Double(udev_device_get_usec_since_initialized(handle)) / 1_000_000.0)
    }

    /// Get the sequence number of the device
    /// - SeeAlso:
    /// - man `udev_device_get_seqnum(3)`
    ///
    var sequenceNumber: UInt64 {
        udev_device_get_seqnum(handle)
    }

    /// Get the path of the device in the kernel device tree
    /// - SeeAlso:
    /// - man `udev_device_get_devpath(3)`
    ///
    var devicePath: String? {
        guard let cStr = udev_device_get_devpath(handle) else {
            return nil
        }

        return String(cString: cStr)
    }

    /// Get the device node of the device
    /// - SeeAlso:
    /// - man `udev_device_get_devnode(3)`
    ///
    var deviceNode: String? {
        guard let cStr = udev_device_get_devnode(handle) else {
            return nil
        }

        return String(cString: cStr)
    }

    /// Get the device number of the device
    /// - SeeAlso:
    /// - man `udev_device_get_devnum(3)`
    ///
    var deviceNumber: UInt {
        udev_device_get_devnum(handle)
    }

    /// Get the device type of the device
    /// - SeeAlso:
    /// - man `udev_device_get_devtype(3)`
    ///
    var deviceType: String? {
        guard let cStr = udev_device_get_devtype(handle) else {
            return nil
        }

        return String(cString: cStr)
    }

    /// Get the driver name of the device
    /// - SeeAlso:
    /// - man `udev_device_get_driver(3)`
    ///
    var driver: String? {
        guard let cStr = udev_device_get_driver(handle) else {
            return nil
        }

        return String(cString: cStr)
    }

    /// Get the subsystem of the device
    /// - SeeAlso:
    /// - man `udev_device_get_subsystem(3)`
    ///
    var subsystem: String? {
        guard let cStr = udev_device_get_subsystem(handle) else {
            return nil
        }

        return String(cString: cStr)
    }

    /// Get the system path of the device
    /// - SeeAlso:
    /// - man `udev_device_get_syspath(3)`
    ///
    var systemPath: String? {
        guard let cStr = udev_device_get_syspath(handle) else {
            return nil
        }

        return String(cString: cStr)
    }

    /// Get the system name of the device
    /// - SeeAlso:
    /// - man `udev_device_get_sysname(3)`
    ///
    var systemName: String? {
        guard let cStr = udev_device_get_sysname(handle) else {
            return nil
        }

        return String(cString: cStr)
    }

    /// Get the system number of the device
    /// - SeeAlso:
    /// - man `udev_device_get_sysnum(3)`
    ///
    var systemNumber: String? {
        guard let cStr = udev_device_get_sysnum(handle) else {
            return nil
        }

        return String(cString: cStr)
    }

    /// Get the action of the device
    /// - SeeAlso:
    /// - man `udev_device_get_action(3)`
    ///
    var action: String? {
        guard let cStr = udev_device_get_action(handle) else {
            return nil
        }

        return String(cString: cStr)
    }

    /// Get a list of device links
    /// - SeeAlso:
    /// - man `udev_device_get_devlinks_list_entry(3)`
    ///
    var deviceLinks: [String] {
        var links: [String] = []
        var entry = udev_device_get_devlinks_list_entry(handle)

        while entry != nil {
            links.append(String(cString: udev_list_entry_get_name(entry)!))

            entry = udev_list_entry_get_next(entry)
        }

        return links
    }

    /// Get all device properties as a dictionary
    /// - SeeAlso:
    /// - man `udev_device_get_properties_list_entry(3)`
    ///
    var deviceProperties: [String: String?] {
        var properties: [String: String?] = [:]
        var entry = udev_device_get_properties_list_entry(handle)

        while entry != nil {
            let name = String(cString: udev_list_entry_get_name(entry)!)

            var value: String? = nil

            if let str = udev_device_get_property_value(handle, name) {
                value = String(cString: str)
            }

            properties[name] = value

            entry = udev_list_entry_get_next(entry)
        }

        return properties
    }

    /// Get all device tags
    /// - SeeAlso:
    /// - man `udev_device_get_tags_list_entry(3)`
    ///
    var tags: [String] {
        var tags: [String] = []
        var entry = udev_device_get_tags_list_entry(handle)

        while entry != nil {
            tags.append(String(cString: udev_list_entry_get_name(entry)!))

            entry = udev_list_entry_get_next(entry)
        }

        return tags
    }

    /// Get all system attributes as a dictionary
    /// - SeeAlso:
    /// - man `udev_device_get_sysattr_list_entry(3)`
    ///
    var systemAttributes: [String: String?] {
        var attributes: [String: String?] = [:]
        var entry = udev_device_get_sysattr_list_entry(handle)

        while entry != nil {
            let name = String(cString: udev_list_entry_get_name(entry))
            var value: String? = nil

            if let str = udev_device_get_sysattr_value(handle, name) {
                value = String(cString: str)
            }

            attributes[name] = value ?? ""

            entry = udev_list_entry_get_next(entry)
        }

        return attributes
    }

    /// Initialize a device from a system path
    /// - Parameter udev: The udev context
    /// - Parameter path: The system path to the device
    /// - SeeAlso:
    /// - man `udev_device_new_from_syspath(3)`
    ///
    init(udev: OpaquePointer, fromSystemPath path: String) {
        // This should not fail, and if it does, it's probably because of low memory
        // TODO: handle this better?
        let device = udev_device_new_from_syspath(udev, path)!

        self.handle = device
        self.udevHandle = udev

        udev_ref(self.udevHandle)
    }

    private init(udevHandle: OpaquePointer, handle: OpaquePointer) {
        self.handle = handle
        self.udevHandle = udevHandle

        udev_ref(udevHandle)
    }

    deinit {
        udev_unref(self.udevHandle)
        udev_device_unref(self.handle)
    }

    /// Get the parent with subsystem `subSystem` and devType `devType`.
    /// - SeeAlso:
    /// - man `udev_device_get_parent_with_subsystem_devtype(3)`
    ///
    func parentWith(subSystem: String, devType: String) -> Device? {
        guard
            let device = udev_device_get_parent_with_subsystem_devtype(
                self.handle, subSystem, devType)
        else {
            return nil
        }

        return Device(udevHandle: udevHandle, handle: device)
    }

    /// Get the value of a specific device property
    /// - Parameter property: The name of the property to retrieve
    /// - Returns: The property value, or nil if not found
    /// - SeeAlso:
    /// - man `udev_device_get_property_value(3)`
    ///
    func propertyValue(of property: String) -> String? {
        guard let value = udev_device_get_property_value(handle, property) else {
            return nil
        }

        return String(cString: value)
    }

    /// Get the value of a specific system attribute
    /// - Parameter attribute: The name of the attribute to retrieve
    /// - Returns: The attribute value, or nil if not found
    /// - SeeAlso:
    /// - man `udev_device_get_sysattr_value(3)`
    ///
    func systemAttributeValue(of attribute: String) -> String? {
        guard let value = udev_device_get_sysattr_value(handle, attribute) else {
            return nil
        }

        return String(cString: value)
    }
}
