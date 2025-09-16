import CUDevices
import Foundation

public class DeviceEnumerator {
    private let udevHandle: OpaquePointer
    private let handle: OpaquePointer!

    /**
     Initializes a new device enumerator with the given udev handle.
    
     - Parameters:
       - udev: The udev handle to use for enumeration
    
     - SeeAlso:
       - man `udev_enumerate_new(3)`
     */
    init(handle udev: OpaquePointer!) {
        self.udevHandle = udev
        self.handle = udev_enumerate_new(udev)

        udev_ref(udev)
    }

    deinit {
        udev_unref(self.udevHandle)
        udev_enumerate_unref(self.handle)
    }

    /**
     Adds a filter to match devices by subsystem.
    
     - Parameters:
       - subsystem: The subsystem name to match (e.g., "usb", "block", "net")
    
     - Returns: Self for method chaining
    
     - SeeAlso:
       - man `udev_enumerate_add_match_subsystem(3)`
     */
    public func match(subsystem: String) -> Self {
        udev_enumerate_add_match_subsystem(self.handle, subsystem)

        return self
    }

    /**
     Adds a filter to match devices by tag.
    
     - Parameters:
       - tag: The tag to match
    
     - Returns: Self for method chaining
    
     - SeeAlso:
       - man `udev_enumerate_add_match_tag(3)`
     */
    public func match(tag: String) -> Self {
        udev_enumerate_add_match_tag(self.handle, tag)

        return self
    }

    /**
     Adds a filter to match devices that are children of the specified parent device.
    
     - Parameters:
       - parent: The parent device to match children of
    
     - Returns: Self for method chaining
    
     - SeeAlso:
       - man `udev_enumerate_add_match_parent(3)`
     */
    public func match(parent: Device) -> Self {
        udev_enumerate_add_match_parent(self.handle, parent.handle)

        return self
    }

    /**
    Match devices with the sysname provided
    
    - Parameters:
      - systemName: sysname of the device
    
    - SeeAlso:
      - man `udev_enumerate_add_match_sysname(3)`
    */
    public func match(systemName: String) -> Self {
        udev_enumerate_add_match_sysname(self.handle, systemName)

        return self
    }

    /**
     Adds a filter to match devices by a specific system attribute and its value.
    
     - Parameters:
       - attributeName: The name of the system attribute to match
       - value: The value of the system attribute to match
    
     - Returns: Self for method chaining
    
     - SeeAlso:
       - man `udev_enumerate_add_match_sysattr(3)`
     */
    public func match(attributeName: String, withValue value: String) -> Self {
        udev_enumerate_add_match_sysattr(self.handle, attributeName, value)

        return self
    }

    /**
     Adds a filter to match devices by a specific property and its value.
    
     - Parameters:
       - propertyName: The name of the property to match
       - value: The value of the property to match
    
     - Returns: Self for method chaining
    
     - SeeAlso:
       - man `udev_enumerate_add_match_property(3)`
     */
    public func match(propertyName: String, withValue value: String) -> Self {
        udev_enumerate_add_match_property(self.handle, propertyName, value)

        return self
    }

    /**
     Adds a filter to match only initialized or uninitialized devices.
    
     - Parameters:
       - initialized: If true, matches only initialized devices; if false, does not apply this filter
    
     - Returns: Self for method chaining
    
     - SeeAlso:
       - man `udev_enumerate_add_match_is_initialized(3)`
     */
    public func match(initialized: Bool) -> Self {
        if initialized {
            udev_enumerate_add_match_is_initialized(self.handle)
        }

        return self
    }

    /**
    Scan all devices using the enumerator, with the filters applied.
    
    - Returns: The device list
    - SeeAlso:
        - man `udev_enumerate_get_list_entry(3)`, `udev_enumerate_scan_devices(3)`
    */
    public func scanDevices() -> [Device] {
        udev_enumerate_scan_devices(self.handle)
        var entry = udev_enumerate_get_list_entry(self.handle)
        var devices: [Device] = []

        while entry != nil {
            guard let name = udev_list_entry_get_name(entry) else {
                entry = udev_list_entry_get_next(entry)

                continue
            }

            devices.append(
                Device(
                    udev: self.udevHandle,
                    fromSystemPath: String(cString: name)
                )
            )

            entry = udev_list_entry_get_next(entry)
        }

        return devices
    }

}
