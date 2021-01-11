import XCTest
@testable import freeza

class NSFWEntriesViewModelTests: XCTestCase {

    func testCompletion() {
        
        let client = RedditClient()
        let nsfwEntriesViewModel = NSFWEntriesViewModel(withClient: client)
        
        let waitExpectation = expectation(description: "Wait for loadEntries to complete.")
        
        nsfwEntriesViewModel.loadEntries {
            
            XCTAssertEqual(nsfwEntriesViewModel.entries.count, 51)
            XCTAssertFalse(nsfwEntriesViewModel.hasError)
            
            nsfwEntriesViewModel.entries.forEach { entryViewModel in
                
                XCTAssertFalse(entryViewModel.hasError)
            }
            
            waitExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 60, handler: nil)
    }
    
    func testError() {
        
        let client = TestErrorClient()
        let topEntriesViewModel = NSFWEntriesViewModel(withClient: client)
        
        let waitExpectation = expectation(description: "Wait for loadEntries to complete.")
        
        topEntriesViewModel.loadEntries {
            
            XCTAssertTrue(topEntriesViewModel.hasError)
            XCTAssertEqual(topEntriesViewModel.errorMessage, TestErrorClient.testErrorMessage)
            waitExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 60, handler: nil)
    }
}
