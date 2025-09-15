import Foundation
import Testing

@testable import System

@Test func getMountpoints() throws {
    let mountpoints = try ProcessInfo.processInfo.mountpoints()

    assert(mountpoints.count > 0, "Wait, how you don't have any mountpoints? Where's /dev?")
}
