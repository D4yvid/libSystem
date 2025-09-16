import ArgumentParser
import System
import Foundation

@main
struct DiskUtil: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "diskutil",
        abstract: "Disk utility for listing and managing block devices",
        subcommands: [ListCommand.self]
    )
}