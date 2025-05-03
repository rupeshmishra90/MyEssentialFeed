//
//  XCTTestCase+MemoryLeakTracking.swift
//  MyEssentialFeed
//
//  Created by Rupesh Kumar on 11/01/25.
//

import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock {[weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated", file: file, line: line)
        }
    }
}
