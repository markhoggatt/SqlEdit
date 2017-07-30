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
	var isComplete : Bool
	var isEmpty : Bool
	{
		return statementText.characters.count <= 0
	}

	var wordCount : Int
	{
		return wordList.count
	}

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
		var chRange : NSRange = NSMakeRange(withRange.location, 0)
		for ch : Character in nextChars.characters
		{
			statementText.append(ch)
			chRange.length += 1
			switch ch
			{
			case ";":
				isComplete = true
				isNewWord = true

			case " ":
				lastWord = createNewWord(fromRange: chRange)
				wordList.append(lastWord)
				isNewWord = true

			default:
				isNewWord = false
			}
		}

		statementRange = NSUnionRange(statementRange, withRange)
	}

	private func createNewWord(fromRange : NSRange) -> SqlWord
	{
		let wordStartPos : Int = NSMaxRange(lastWord.wordRange)
		var wordLength : Int = fromRange.location - wordStartPos
		var wordRange : NSRange = NSMakeRange(wordStartPos, wordLength)
		let wordTextStartIdx : String.Index = statementText.index(statementText.startIndex, offsetBy: wordStartPos)
		let wordTextRange : Range<String.Index> = wordTextStartIdx..<statementText.endIndex
		let wordText : String = statementText.substring(with: wordTextRange).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

		wordLength = wordText.characters.count
		wordRange.length = wordLength

		let langProc : LanguageProcessor = LanguageProcessor.Instance()
		let isInList : Bool = langProc.IsWordFound(refWord: wordText)

		let nextWord = SqlWord(word : wordText, wordRange : wordRange, foundInList : isInList)

		return nextWord
	}
}
