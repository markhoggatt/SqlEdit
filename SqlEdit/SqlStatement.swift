//
//  SqlStatement.swift
//  SqlEdit
//
//  Created by Mark Hoggatt on 29/05/2017.
//  Copyright © 2017 Code Europa. All rights reserved.
//

import Foundation

/// Holds and maintains a single SQL statement.
/// Any sequence of characters terminated by a semi-colon qualifies as a statement,
///		even though it may be syntactically incorrect.
class SqlStatement
{
	fileprivate let spaceSymbol : Character = " "
	fileprivate let terminatorSymbol : Character = ";"

	/// The raw text of the statement.
	var statementText : String

	/// The range of the statement describing how the statement is placed in the container that displays it.
	var statementRange : Range<Int>

	/// true = The statement ends in a semi-colon, otherwise false.
	var isComplete : Bool

	/// true = The statement is an empty string, otherwise false.
	var isEmpty : Bool
	{
		return statementText.count <= 0
	}

	/// The numbers of SQL words that the statement contains.
	var wordCount : Int
	{
		return wordList.count
	}

	var lastWord  : SqlWord?
	{
		return wordList.last
	}
	var isNewWord : Bool = false

	fileprivate var wordList = [SqlWord]()

	fileprivate var delimitingSet : CharacterSet = CharacterSet.whitespacesAndNewlines

	fileprivate var unwordedStartIdx : String.Index

	fileprivate var lastWordUpperBound : Int

	/// Initialises the statement with whatever text is available that constitutes a statement.
	///
	/// - Parameter statement: The starting statement.
	init(statement : String)
	{
		statementText = ""
		statementRange = 0..<0
		isComplete = false
		delimitingSet.insert(charactersIn: String(terminatorSymbol))
		unwordedStartIdx = statementText.startIndex
		lastWordUpperBound = 0

		appendChrsToStatement(nextChars: statement, withRange: 0..<statement.count)
	}

	/// Adds the given characters to the statement and adjusts the word content accordingly.
	///
	/// - Parameters:
	///   - nextChars: The characters to add.
	///   - withRange: The range co-ordinates indicating where the characters are to be placed.
	public func addCharactersToStatement(nextChars : String, withRange : Range<Int>)
	{
		var chRange : Range<Int> = withRange.lowerBound..<withRange.lowerBound
		var chRangeUpper : Int = chRange.upperBound
		let statCount = statementText.count
		for ch : Character in nextChars
		{
			if chRangeUpper < statCount
			{
				statementText.insert(ch, at: statementText.index(statementText.startIndex, offsetBy: chRangeUpper))
			}
			else
			{
				statementText.append(ch)
			}
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


	/// Handles the standard case of appending text to the current statement. It compiles word objects
	///		and checks them against known words.
	///
	/// - Parameters:
	///   - nextChars: The text segment to append.
	///   - withRange: The range of the segment in the context of the the whole document.
	public func appendChrsToStatement(nextChars : String, withRange : Range<Int>)
	{
		let appendSize : Int = nextChars.count
		guard withRange.isEmpty == false,
			withRange.lowerBound >= statementText.count,
			withRange.count == appendSize,
			isComplete == false
		else
		{
			return
		}

		if statementText.isEmpty
		{
			unwordedStartIdx = statementText.startIndex
			lastWordUpperBound = withRange.lowerBound
		}

		statementText.append(nextChars)
		if nextChars.contains(spaceSymbol)
		{
			if nextChars.count == 1
			{
				if statementText.count == 1
				{
					return
				}

				completeWord(byAppendingText: nextChars, startingIdx: withRange.lowerBound, expectedSymbol: spaceSymbol)
				return
			}

			let wordSet : [String.SubSequence] = nextChars.split(separator: spaceSymbol)
			if wordSet.count > 1
			{
				var targetSymbol : Character = spaceSymbol
				wordSet.forEach
				{ (word : Substring) in
					if statementText[statementText.index(after: unwordedStartIdx)...].contains(where:
					{ (chr : Character) -> Bool in
						switch (chr)
						{
						case spaceSymbol:
							return true

						case terminatorSymbol:
							targetSymbol = terminatorSymbol
							return true

						default:
							return false
						}
					})
					{
						completeWord(byAppendingText: String(word), startingIdx: lastWordUpperBound, expectedSymbol: targetSymbol)
					}
				}
			}
			else
			{
				completeWord(byAppendingText: String(wordSet[0]), startingIdx: withRange.lowerBound, expectedSymbol: spaceSymbol)
			}
		}

		isComplete = statementText.hasSuffix(";")
	}

	/// Removes characters from the end of the statement.
	///
	/// - Parameter droppingLast: The number of characters to drop from the end of the statement
	/// - Returns: Indicates whether or not the operation was successful. true = successful, otherwise false.
	public func removeCharacterFromStatement(droppingLast: Int) -> Bool
	{
		// Pre-conditions
		let startCount = statementText.count
		guard startCount > 0,
			(droppingLast + startCount) >= 0
		else
		{
			return false
		}

		let charToDrop : Int = -1
		var currentlyNewWord : Bool = false
		for _ in droppingLast..<0
		{
			currentlyNewWord = isNewWord
			isNewWord = statementText.last == " "

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

	public func updateCharactersInStatement(nextChars : String, withRange : NSRange)
	{
		
	}

	fileprivate func completeWord(byAppendingText : String, startingIdx : Int,  expectedSymbol : Character)
	{
		guard let wordEnd : String.Index = statementText.suffix(from: statementText.index(after: unwordedStartIdx)).index(of: expectedSymbol)
		else
		{
			return
		}

		let wordText : Substring = statementText.suffix(from: unwordedStartIdx)[...statementText.index(before: wordEnd)]
		guard wordText.count > 0
		else
		{
			return
		}

		let reformedWord = String(wordText)
		let foundWord = LanguageProcessor.Instance().IsWordFound(refWord: reformedWord)

		let rangeEnd : Int = lastWordUpperBound + wordText.count
		let newWord = SqlWord(word: reformedWord, wordRange: lastWordUpperBound..<rangeEnd, foundInList: foundWord)
		wordList.append(newWord)

		lastWordUpperBound = newWord.wordRange.upperBound + 1
		unwordedStartIdx = statementText.index(after: wordEnd)
	}

	fileprivate func createNewWord(fromRange : Range<Int>) -> SqlWord
	{
		let wordStartPos : Int = fromRange.lowerBound
		// Reduce by the delimiter
		var wordLength : Int = fromRange.count - 1
		var wordRange : Range<Int> = wordStartPos..<(wordStartPos + wordLength)
		let wordTextStartIdx : String.Index = statementText.index(statementText.startIndex, offsetBy: wordStartPos)
		let wordText : String = statementText[wordTextStartIdx..<statementText.endIndex].trimmingCharacters(in: delimitingSet)

		wordLength = wordText.count
		wordRange = wordStartPos..<(wordStartPos + wordLength)

		let langProc : LanguageProcessor = LanguageProcessor.Instance()
		let isInList : Bool = langProc.IsWordFound(refWord: wordText)

		let nextWord = SqlWord(word : wordText, wordRange : wordRange, foundInList : isInList)

		return nextWord
	}

	fileprivate func completeWord(_ chRange: Range<Int>) -> Range<Int>
	{
		let currentWord = createNewWord(fromRange: chRange)
		wordList.append(currentWord)
		isNewWord = true
		return pinNextRange(sourceRange: chRange)
	}

	fileprivate func pinNextRange(sourceRange : Range<Int>) -> Range<Int>
	{
		let newLocation : Int = sourceRange.lowerBound + sourceRange.count

		return newLocation..<newLocation
	}
}

// MARK: - Hashable protocol conformance. Includes Equatable.
extension SqlStatement : Hashable
{
	var hashValue: Int
	{
		return statementText.hashValue
	}

	public static func ==(lhs : SqlStatement, rhs : SqlStatement) -> Bool
	{
		return lhs.statementText == rhs.statementText
	}
}
