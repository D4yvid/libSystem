import Foundation
import Testing

@testable import SystemDevices

struct DeviceTreeHelper {
    static func filterValidDevices(from devices: [Device]) -> [Device] {
        return devices.filter { device in
            device.initialized &&
            device.devicePath?.hasPrefix("/") == true
        }
    }
    
    static func findRootDevices(from validDevices: [Device]) -> [Device] {
        return validDevices.filter { device in
            !validDevices.contains { otherDevice in
                guard let otherPath = otherDevice.devicePath,
                      let devicePath = device.devicePath,
                      devicePath != otherPath else {
                    return false
                }
                return devicePath.hasPrefix(otherPath + "/")
            }
        }
    }
    
    static func printDeviceTree(
        _ device: Device,
        validDevices: [Device],
        prefix: String = "",
        isLast: Bool = true,
        showSubsystem: Bool = false
    ) {
        let connector = isLast ? "└── " : "├── "
        let deviceName = device.systemName ?? "Unknown Device"
        
        var deviceInfo = deviceName
        if showSubsystem, let subsystem = device.subsystem {
            deviceInfo += " [\(subsystem)]"
        }
        if let deviceType = device.deviceType {
            deviceInfo += " (\(deviceType))"
        }
        if let driver = device.driver {
            deviceInfo += " [Driver: \(driver)]"
        }
        
        print("\(prefix)\(connector)\(deviceInfo)")
        
        // Print detailed information with proper indentation
        let detailPrefix = prefix + (isLast ? "    " : "│   ")
        
        var details: [(String, String)] = []
        
        if let devicePath = device.devicePath {
            details.append(("Path", devicePath))
        }
        if let deviceNode = device.deviceNode {
            details.append(("Node", deviceNode))
        }
        if let systemPath = device.systemPath {
            details.append(("SysPath", systemPath))
        }
        if let systemNumber = device.systemNumber {
            details.append(("SysNum", systemNumber))
        }
        details.append(("DevNum", "\(device.deviceNumber)"))
        details.append(("SeqNum", "\(device.sequenceNumber)"))
        details.append(("Init", "\(device.initialized) @ \(device.initializationDate)"))
        
        if !device.deviceLinks.isEmpty {
            details.append(("Links", device.deviceLinks.joined(separator: ", ")))
        }
        
        if !device.tags.isEmpty {
            details.append(("Tags", device.tags.joined(separator: ", ")))
        }
        
        // Print all details with proper tree structure
        for (index, (key, value)) in details.enumerated() {
            let isLastDetail = index == details.count - 1 && 
                              device.deviceProperties.isEmpty && 
                              device.systemAttributes.isEmpty
            print("\(detailPrefix)│ → \(key): \(value)")
        }
        
        let properties = device.deviceProperties
        if !properties.isEmpty {
            print("\(detailPrefix)│ → Properties:")
            let sortedProps = properties.sorted(by: { $0.key < $1.key })
            for (key, value) in sortedProps {
                let propPrefix = "\(detailPrefix)│   "
                print("\(propPrefix)  \(key): \(String(describing: value))")
            }
        }
        
        let attributes = device.systemAttributes
        if !attributes.isEmpty {
            print("\(detailPrefix)│ → Attributes:")
            let sortedAttrs = attributes.sorted(by: { $0.key < $1.key })
            for (key, value) in sortedAttrs {
                let attrPrefix = "\(detailPrefix)│   "
                print("\(attrPrefix)  \(key): \(String(describing: value))")
            }
        }
        
        let children = validDevices.filter { child in
            guard let childPath = child.devicePath,
                  let currentPath = device.devicePath,
                  childPath != currentPath else {
                return false
            }
            
            let relativePath = String(childPath.dropFirst(currentPath.count))
            return childPath.hasPrefix(currentPath + "/") && !relativePath.dropFirst().contains("/")
        }
        
        let newPrefix = prefix + (isLast ? "    " : "│   ")
        
        for (index, child) in children.enumerated() {
            let isLastChild = index == children.count - 1
            printDeviceTree(child, validDevices: validDevices, prefix: newPrefix, isLast: isLastChild, showSubsystem: showSubsystem)
        }
    }
}

@Test func enumerateUSBDevices() {
    let devices = try! SystemDevices()
    let enumerator = devices.makeEnumerator()

    _ = enumerator.match(subsystem: "usb")

    let usbDevices = enumerator.scanDevices()

    print("Found \(usbDevices.count) USB devices:")
    print(String(repeating: "=", count: 80))

    for (index, device) in usbDevices.enumerated() {
        print("\nDevice \(index + 1):")
        print(String(repeating: "-", count: 40))

        if let systemName = device.systemName {
            print("System Name: \(systemName)")
        }

        if let devicePath = device.devicePath {
            print("Device Path: \(devicePath)")
        }

        if let deviceNode = device.deviceNode {
            print("Device Node: \(deviceNode)")
        }

        if let subsystem = device.subsystem {
            print("Subsystem: \(subsystem)")
        }

        if let deviceType = device.deviceType {
            print("Device Type: \(deviceType)")
        }

        if let driver = device.driver {
            print("Driver: \(driver)")
        }

        if let systemPath = device.systemPath {
            print("System Path: \(systemPath)")
        }

        if let systemNumber = device.systemNumber {
            print("System Number: \(systemNumber)")
        }

        print("Device Number: \(device.deviceNumber)")
        print("Sequence Number: \(device.sequenceNumber)")
        print("Initialized: \(device.initialized) (at: \(device.initializationDate))")

        if !device.deviceLinks.isEmpty {
            print("Device Links: \(device.deviceLinks.joined(separator: ", "))")
        }

        if !device.tags.isEmpty {
            print("Tags: \(device.tags.joined(separator: ", "))")
        }

        let properties = device.deviceProperties
        if !properties.isEmpty {
            print("Properties:")
            for (key, value) in properties.sorted(by: { $0.key < $1.key }) {
                print("  \(key): \(String(describing: value))")
            }
        }

        let attributes = device.systemAttributes
        if !attributes.isEmpty {
            print("System Attributes:")
            for (key, value) in attributes.sorted(by: { $0.key < $1.key }) {
                print("  \(key): \(String(describing: value))")
            }
        }
    }
}

@Test func printUSBDeviceTree() {
    let devices = try! SystemDevices()
    let enumerator = devices.makeEnumerator()

    _ = enumerator.match(subsystem: "usb")

    let usbDevices = enumerator.scanDevices()

    print("USB Device Tree:")
    print(String(repeating: "=", count: 50))

    let validDevices = DeviceTreeHelper.filterValidDevices(from: usbDevices)

    if validDevices.isEmpty {
        print("No valid USB devices found")
        return
    }

    let rootDevices = DeviceTreeHelper.findRootDevices(from: validDevices)

    if rootDevices.isEmpty {
        print("No root USB devices found")
    } else {
        for (index, rootDevice) in rootDevices.enumerated() {
            let isLast = index == rootDevices.count - 1
            DeviceTreeHelper.printDeviceTree(rootDevice, validDevices: validDevices, isLast: isLast, showSubsystem: false)
        }
    }
}

@Test func printAllDevicesTree() {
    let devices = try! SystemDevices()
    let enumerator = devices.makeEnumerator()

    let allDevices = enumerator.scanDevices()

    print("All System Device Tree:")
    print(String(repeating: "=", count: 50))

    let validDevices = DeviceTreeHelper.filterValidDevices(from: allDevices)

    if validDevices.isEmpty {
        print("No valid devices found")
        return
    }

    let rootDevices = DeviceTreeHelper.findRootDevices(from: validDevices)

    if rootDevices.isEmpty {
        print("No root devices found")
    } else {
        for (index, rootDevice) in rootDevices.enumerated() {
            let isLast = index == rootDevices.count - 1
            DeviceTreeHelper.printDeviceTree(rootDevice, validDevices: validDevices, isLast: isLast, showSubsystem: true)
        }
    }
}
