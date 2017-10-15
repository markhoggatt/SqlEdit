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
	var statementRange : Range<Int>
	var isComplete : Bool
	var isEmpty : Bool
	{
		return statementText.characters.count <= 0
	}

	var wordCount : Int
	{
		return wordList.count
	}

	var lastWord  = SqlWord(word : "", wordRange : Range<Int>(NSMakeRange(0, 0))!, foundInList : false)
	var isNewWord : Bool = false

	var wordList = [SqlWord]()

	var delimitingSet : CharacterSet = CharacterSet.whitespacesAndNewlines

	init(statement : String)
	{
		statementText = statement
		statementRange = Range<Int>(NSMakeRange(0, 0))!
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
			statementRange = statementRange.lowerBound..<(statementRange.upperBound + charToDrop)

			if currentlyNewWord && isNewWord == false
			{
				wordList.removeLast()
			}
		}

		return true
	}

	public func addCharactersToStatement(nextChars : String, withRange : Range<Int>)
	{
		var chRange : Range<Int> = withRange.lowerBound..<withRange.lowerBound
		var chRangeUpper : Int = chRange.upperBound
		for ch : Character in nextChars.characters
		{
			statementText.append(ch)
			chRangeUpper += 1
			chRange = chRange.lowerBound..<chRangeUpper
			switch ch
			{
			case ";":
				isComplete = true
				chRange = completeWord(chRange)

			case " ":
				chRange = completeWord(chRange)

			default:
				isNewWord = false
			}
		}

		statementRange = statementRange.lowerBound..<(withRange.lowerBound + withRange.count)
	}

	public func updateCharactersInStatement(nextChars : String, withRange : NSRange)
	{
		
	}

	fileprivate func createNewWord(fromRange : Range<Int>) -> SqlWord
	{
		let wordStartPos : Int = fromRange.lowerBound
		// Reduce by the delimiter
		var wordLength : Int = fromRange.count - 1
		var wordRange : Range<Int> = wordStartPos..<(wordStartPos + wordLength)
		let wordTextStartIdx : String.Index = statementText.index(statementText.startIndex, offsetBy: wordStartPos)
		let wordText : String = statementText[wordTextStartIdx..<statementText.endIndex].trimmingCharacters(in: delimitingSet)

		wordLength = wordText.characters.count
		wordRange = wordStartPos..<(wordStartPos + wordLength)

		let langProc : LanguageProcessor = LanguageProcessor.Instance()
		let isInList : Bool = langProc.IsWordFound(refWord: wordText)

		let nextWord = SqlWord(word : wordText, wordRange : wordRange, foundInList : isInList)

		return nextWord
	}

	fileprivate func completeWord(_ chRange: Range<Int>) -> Range<Int>
	{
		lastWord = createNewWord(fromRange: chRange)
		wordList.append(lastWord)
		isNewWord = true
		return pinNextRange(sourceRange: chRange)
	}

	fileprivate func pinNextRange(sourceRange : Range<Int>) -> Range<Int>
	{
		let newLocation : Int = sourceRange.lowerBound + sourceRange.count

		return newLocation..<newLocation
	}
}
