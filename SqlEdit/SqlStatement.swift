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

	var delimitingSet : CharacterSet = CharacterSet.whitespacesAndNewlines

	init(statement : String)
	{
		statementText = statement
		statementRange = NSMakeRange(0, 0)
		isComplete = false
		delimitingSet.insert(charactersIn: ";")
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

		let charToDrop : Int = -1
		var currentlyNewWord : Bool = false
		for _ in droppingLast..<0
		{
			currentlyNewWord = isNewWord
			isNewWord = statementText.characters.last == " "

			let startIdx : String.Index = statementText.index(statementText.endIndex, offsetBy: charToDrop)
			let truncateRange : Range<String.Index> = startIdx..<statementText.endIndex
			statementText.removeSubrange(truncateRange)
			statementRange = NSMakeRange(statementRange.location, statementRange.length + charToDrop)

			if currentlyNewWord && isNewWord == false
			{
				wordList.removeLast()
			}
		}

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
				lastWord = createNewWord(fromRange: chRange)
				wordList.append(lastWord)
				isNewWord = true
				chRange = pinNextRange(sourceRange: chRange)

			case " ":
				lastWord = createNewWord(fromRange: chRange)
				wordList.append(lastWord)
				isNewWord = true
				chRange = pinNextRange(sourceRange: chRange)

			default:
				isNewWord = false
			}
		}

		statementRange = NSUnionRange(statementRange, withRange)
	}

	private func createNewWord(fromRange : NSRange) -> SqlWord
	{
		let wordStartPos : Int = fromRange.location
		// Reduce by the delimiter
		var wordLength : Int = fromRange.length - 1
		var wordRange : NSRange = NSMakeRange(wordStartPos, wordLength)
		let wordTextStartIdx : String.Index = statementText.index(statementText.startIndex, offsetBy: wordStartPos)
		let wordText : String = statementText[wordTextStartIdx..<statementText.endIndex].trimmingCharacters(in: delimitingSet)

		wordLength = wordText.characters.count
		wordRange.length = wordLength

		let langProc : LanguageProcessor = LanguageProcessor.Instance()
		let isInList : Bool = langProc.IsWordFound(refWord: wordText)

		let nextWord = SqlWord(word : wordText, wordRange : wordRange, foundInList : isInList)

		return nextWord
	}

	private func pinNextRange(sourceRange : NSRange) -> NSRange
	{
		let newLocation : Int = sourceRange.location + sourceRange.length

		return NSMakeRange(newLocation, 0)
	}
}
