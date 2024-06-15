//
//  XCTestCase+TrackForMemoryLeaks.swift
//  ImagesApp
//
//  Created by Lynneker Souza on 15/06/24.
//

import XCTest

extension XCTestCase {
    /// Tracks for memory leak after test finishes. Should release instance memory.
    func trackForMemoryLeaks(_ instance: AnyObject,
                             file: StaticString = #filePath,
                             line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", 
                         file: file,
                         line: line)
        }
    }
}
