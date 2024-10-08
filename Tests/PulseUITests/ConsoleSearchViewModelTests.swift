// The MIT License (MIT)
//
// Copyright (c) 2020–2023 Alexander Grebenyuk (github.com/kean).

#if os(iOS) || os(macOS)

import XCTest
import Combine
@testable import Pulse
@testable import PulseUI

@available(iOS 16, *)
final class ConsoleSearchViewModelTests: XCTestCase {
    let directory = TemporaryDirectory()
    var store: LoggerStore!
    var searchBarViewModel: ConsoleSearchBarViewModel!
    var sut: ConsoleSearchViewModel!
    var cancellables: [AnyCancellable] = []

    override func setUp() {
        super.setUp()

        let storeURL = directory.url.appending(filename: "\(UUID().uuidString).pulse")
        store = try! LoggerStore(storeURL: storeURL, options: [.create, .synchronous])
        store.populate()

        setUp(store: store)
    }

    override func tearDown() {
        super.tearDown()

        try? store.destroy()
        directory.remove()
    }

    func setUp(store: LoggerStore, context: ConsoleContext = ConsoleContext()) {
        self.store = store
        self.searchBarViewModel = ConsoleSearchBarViewModel()
    }
}

#endif
