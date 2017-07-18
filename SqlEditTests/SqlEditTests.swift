//
//  SqlEditTests.swift
//  SqlEditTests
//
//  Created by Mark Hoggatt on 28/05/2017.
//  Copyright © 2017 Code Europa. All rights reserved.
//

import XCTest
@testable import SqlEdit

class SqlEditTests: XCTestCase
{
    override func setUp()
	{
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown()
	{
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCanProcessReservedWords()
	{
		let lp = LanguageProcessor()
		let processedOk : Bool = lp.ProcessReservedWords()
		assert(processedOk == true, "Failed to process reserved words.")
	}

	func testCanFindWordsInTrie()
	{
		let lp = LanguageProcessor()
		let processedOk : Bool = lp.ProcessReservedWords()
		assert(processedOk == true, "Failed to process reserved words prior to search.")

		let searchTerms = [String](arrayLiteral: "select", "from", "where", "drop", "insert", "update", "delete")
		for term : String in searchTerms
		{
			let foundOk = lp.IsWordFound(refWord: term)
			assert(foundOk == true)
		}

		let wrongTerms = [String](arrayLiteral: "solect", "fron", "whire", "drip", "insest", "ipdate", "delate")
		for term : String in wrongTerms
		{
			let foundOk = lp.IsWordFound(refWord: term)
			assert(foundOk == false)
		}
	}
    
    func testPerformanceExample()
	{
        // This is an example of a performance test case.
        self.measure
		{
            // Put the code you want to measure the time of here.
        }
    }
    
}
