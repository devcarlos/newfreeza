//
//  PersistenceTests.swift
//  freezaTests
//
//  Created by Carlos Alcala on 1/11/21.
//  Copyright © 2021 Zerously. All rights reserved.
//


import XCTest
import RealmSwift
@testable import freeza

class PersistenceTests: XCTestCase {
    // MARK: - Properties
    var persistence: Persistence!

    // MARK: - Overrider Methods
    override func setUp() {
        super.setUp()

        // Open the Realm with the configuration
        let realm = try! Realm()
        persistence = Persistence(realm: realm)

        //start with clean DB
        persistence.deleteAll()

        //check DB file
        print(Realm.Configuration.defaultConfiguration.fileURL!)
    }

    override func tearDown() {
        persistence.deleteAll()
        persistence = nil

        super.tearDown()
    }

    // MARK: - Enabled Tests
    func testEntryModelCreation() {
        let favorite = Favorite(entry: EntryModel.entry1)

        persistence.createOrUpdate(object: favorite)

        persistence.verifyCreationOrUpdating(object: favorite)
    }

    func testEntryModelDeletion() {
        let favorite = Favorite(entry: EntryModel.entry2)

        persistence.createOrUpdate(object: favorite)

        let results = persistence.fetch(with: nil, sortDescriptors: [])

        guard let favoriteInDB = results.first else {
            XCTFail("unable to get favoriteInDB")
            return
        }

        persistence.delete(object: favoriteInDB)

        persistence.verifyEntryModelDeletion()
    }
}

//// MARK: - Verify
extension Persistence {
    func verifyCreationOrUpdating(object: Favorite, file: StaticString = #file, line: UInt = #line) {
        let results = fetch(with: nil, sortDescriptors: [])
        XCTAssertEqual(results.count, 1, "results count", file: file, line: line)

        let favoriteInDB = results.first!
        XCTAssertEqual(favoriteInDB.title, object.title, "title", file: file, line: line)
        XCTAssertEqual(favoriteInDB.author, object.author, "author", file: file, line: line)
        XCTAssertEqual(favoriteInDB.commentsCount, object.commentsCount, "commentsCount", file: file, line: line)
    }

    func verifyEntryModelDeletion(file: StaticString = #file, line: UInt = #line) {
        let results = fetch(with: nil, sortDescriptors: [])
        XCTAssertEqual(results.count, 0, "results count", file: file, line: line)
    }
}
