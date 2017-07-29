//
//  SqlStatement.swift
//  SqlEdit
//
//  Created by Mark Hoggatt on 29/05/2017.
//  Copyright © 2017 Code Europa. All rights reserved.
//

import Foundation

class SqlStatement : Hashable
{
	var statementText : String
	var statementRange : NSRange
	var lastWordRange : NSRange = NSMakeRange(0, 0)
	var isComplete : Bool
	var isEmpty : Bool
	{
		return statementText.characters.count <= 0
	}

	var lastWordIdx : String.Index = "".startIndex
	var lastWord  = SqlWord(word : "", wordRange : NSMakeRange(0, 0), foundInList : false)
	var isNewWord : Bool = false

	var wordList = [SqlWord]()

	init(statement : String)
	{
		statementText = statement
		statementRange = NSMakeRange(0, 0)
		isComplete = false
	}

	var hashValue: Int
	{
		return statementText.hashValue
	}

	public static func ==(lhs : SqlStatement, rhs : SqlStatement) -> Bool
	{
		return lhs.statementText == rhs.statementText
	}

	public func removeCharacterFromStatement(droppingLast: Int) -> Bool
	{
		let startCount = statementText.characters.count
		guard startCount > 0
		else
		{
			return false
		}

		guard (droppingLast + startCount) >= 0
		else
		{
			return false
		}

		let startIdx : String.Index = statementText.index(statementText.endIndex, offsetBy: droppingLast)
		let truncateRange : Range<String.Index> = startIdx..<statementText.endIndex
		statementText.removeSubrange(truncateRange)

		if isComplete
		{
			isComplete = false
		}

		statementRange = NSMakeRange(statementRange.location, statementRange.length + droppingLast)

		return true
	}

	public func addCharactersToStatement(nextChars : String, withRange : NSRange)
	{
		statementText.append(nextChars)
		switch nextChars
		{
			case ";":
				isComplete = true
				isNewWord = true

			case " ":
				lastWord = createNewWord(fromRange: withRange)
				isNewWord = true

			default:
				isNewWord = false
		}

		statementRange = NSUnionRange(statementRange, withRange)
	}

	private func createNewWord(fromRange : NSRange) -> SqlWord
	{
		return lastWord
	}
}
