//
//  SqlStatement.swift
//  SqlEdit
//
//  Created by Mark Hoggatt on 29/05/2017.
//  Copyright © 2017 Code Europa. All rights reserved.
//

import Foundation
import os.log

/// Holds and maintains a single SQL statement.
/// Any sequence of characters terminated by a semi-colon qualifies as a statement,
///		even though it may be syntactically incorrect.
class SqlStatement
{
	fileprivate let spaceSymbol : Character = " "
	fileprivate let terminatorSymbol : Character = ";"

	let logHandle = OSLog(subsystem: "eu.hoggatt.SqlEdit", category: "SqlStatement")

	/// The raw text of the statement.
	var statementText : String

	/// The range of the statement describing how the statement is placed in the container that displays it.
	var statementRange : Range<Int>

	/// true = The statement ends in a semi-colon, otherwise false.
	var isComplete : Bool
	{
		return statementText.hasSuffix(String(terminatorSymbol))
	}

	/// true = The statement is an empty string, otherwise false.
	var isEmpty : Bool
	{
		return statementText.isEmpty
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
		delimitingSet.insert(charactersIn: String(terminatorSymbol))
		unwordedStartIdx = statementText.startIndex
		lastWordUpperBound = 0

		appendChrsToStatement(nextChars: statement, withRange: 0..<statement.count)
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

		let statementLowerBound : Int
		if statementText.isEmpty
		{
			unwordedStartIdx = statementText.startIndex
			lastWordUpperBound = withRange.lowerBound
			statementLowerBound = withRange.lowerBound
		}
		else
		{
			statementLowerBound = statementRange.lowerBound
		}

		statementText.append(nextChars)
		let statementUpperBound : Int = statementLowerBound + statementText.count
		statementRange = statementLowerBound..<statementUpperBound

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

	public func deleteCharactersFromStatement(editedRange : Range<Int>, lastDelta : Int)
	{
		guard lastDelta < 0
		else
		{
			return
		}

		let dropCount = lastDelta * -1
		statementText = String(statementText.dropLast(dropCount))
		lastWordUpperBound -= dropCount
		unwordedStartIdx = statementText.endIndex

		let belongsIdx : Int = wordList.partition
		{ (sampleWord : SqlWord) -> Bool in
			return sampleWord.wordRange.lowerBound > lastWordUpperBound
		}

		let removeCount = wordList.count - belongsIdx
		if removeCount > 0
		{
			wordList.removeFirst(removeCount)
		}

		if statementText.hasSuffix(String(spaceSymbol))
		{
			return
		}

		guard let endWord : SqlWord = wordList.last
		else
		{
			os_log("End word not found in word list.", log: logHandle, type: .error)
			return
		}

		unwordedStartIdx = endWord.statementStartIdx
		wordList.removeLast()
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
		let newWord = SqlWord(word: reformedWord, wordRange: lastWordUpperBound..<rangeEnd, foundInList: foundWord, statementStartIdx: unwordedStartIdx, statementEndIdx: wordEnd)
		wordList.append(newWord)

		lastWordUpperBound = newWord.wordRange.upperBound + 1
		unwordedStartIdx = statementText.index(after: wordEnd)
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
