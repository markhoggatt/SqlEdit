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
	var lastWord : String = ""
	var isNewWord : Bool = false

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

	public func removeCharacterFromStatement() -> Bool
	{
		var startCount = statementText.characters.count
		guard startCount > 0
		else
		{
			return false
		}

		statementText.characters.remove(at: statementText.index(before: statementText.endIndex))
		startCount -= 1

		if isComplete
		{
			isComplete = false
		}

		return true
	}

	public func addCharacterToStatement(nextChar : Character, withRange : NSRange)
	{
		statementText.characters.append(nextChar)
		switch nextChar
		{
			case ";":
				isComplete = true
				isNewWord = true

			case " ":
				lastWord = statementText.substring(from: lastWordIdx)
				lastWordIdx = statementText.endIndex
				isNewWord = true

			default:
				isNewWord = false
		}

		statementRange = NSUnionRange(statementRange, withRange)
	}
}
