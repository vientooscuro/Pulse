// The MIT License (MIT)
//
// Copyright (c) 2020-2022 Alexander Grebenyuk (github.com/kean).

import CoreData
import XCTest
@testable import Pulse

final class PerformanceTests: XCTestCase {
    var tempDirectoryURL: URL!
    var storeURL: URL!

    var store: LoggerStore!

    override func setUp() {
        super.setUp()

        tempDirectoryURL = FileManager().temporaryDirectory.appending(directory: UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDirectoryURL, withIntermediateDirectories: true, attributes: [:])
        storeURL = tempDirectoryURL.appending(filename: "performance-tests.pulse")

        store = try! LoggerStore(storeURL: storeURL, options: [.create, .synchronous])

        populateStore()
    }

    override func tearDown() {
        super.tearDown()

        try! store.destroy()
        try? FileManager.default.removeItem(at: tempDirectoryURL)
    }

    func _testInsert() {
        measure {
            for _ in 0...5 {
                populate(store: store)
            }
            store.backgroundContext.performAndWait {}
        }
    }

    func xtestQueryByLevel() {
        let request = NSFetchRequest<LoggerMessageEntity>(entityName: "LoggerMessageEntity")
        request.predicate = NSPredicate(format: "level == %i", LoggerStore.Level.info.rawValue)

        let moc = store.viewContext

        measure {
            let messages = (try? moc.fetch(request)) ?? []
            XCTAssertEqual(messages.count, 20000)
        }
    }

    func populateStore() {
        /// Create 60000 messages
        for _ in 0..<10000 {
            store.storeMessage(label: "application", level: .info, message:  "UIApplication.didFinishLaunching")
            store.storeMessage(label: "application", level: .info, message:  "UIApplication.willEnterForeground")
            store.storeMessage(label: "auth", level: .debug, message: "🌐 Will authorize user with name \"kean@github.com\"", metadata: [
                "system": .string("auth")
            ])
            store.storeMessage(label: "auth", level: .warning, message: "🌐 Authorization request failed with error 500")
            store.storeMessage(label: "auth", level: .debug, message: """
                Replace this implementation with code to handle the error appropriately. fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                2015-12-08 15:04:03.888 Conversion[76776:4410388] call stack:
                (
                0   Conversion                          0x000694b5 -[ViewController viewDidLoad] + 128
                1   UIKit                               0x27259f55 <redacted> + 1028
                ...
                9   UIKit                               0x274f67a7 <redacted> + 134
                10  FrontBoardServices                  0x2b358ca5 <redacted> + 232
                11  FrontBoardServices                  0x2b358f91 <redacted> + 44
                12  CoreFoundation                      0x230e87c7 <redacted> + 14
                ...
                16  CoreFoundation                      0x23038ecd CFRunLoopRunInMode + 108
                17  UIKit                               0x272c7607 <redacted> + 526
                18  UIKit                               0x272c22dd UIApplicationMain + 144
                19  Conversion                          0x000767b5 main + 108
                20  libdyld.dylib                       0x34f34873 <redacted> + 2
                )
            """)
            store.storeMessage(label: "default", level: .critical, message: "💥 0xDEADBEEF")
        }
    }
}
