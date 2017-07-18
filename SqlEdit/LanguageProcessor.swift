//
//  LanguageProcessor.swift
//  SqlEdit
//
//  Created by Mark Hoggatt on 16/07/2017.
//  Copyright © 2017 Code Europa. All rights reserved.
//

import Foundation

public class LanguageProcessor
{
	private var _keyWords = Trie()

	public func ProcessReservedWords() -> Bool
	{
		guard let resvdPath = Bundle.main.path(forResource: "sqlReserved_9.6.3", ofType: "txt")
		else
		{
			return false
		}

		do
		{
			let fData = try String(contentsOfFile: resvdPath, encoding: .utf8)
			let wordLines : [String] = fData.components(separatedBy: .newlines)
			for wrd in wordLines
			{
				ExtractReservedWord(line: wrd)
			}
		}
		catch
		{
			NSLog("Failed to open \(resvdPath)")
			return false
		}

		return true
	}

	func ExtractReservedWord(line : String)
	{
		let wrdDefs : [String] = line.components(separatedBy: .whitespaces)
		_keyWords.insert(word: wrdDefs[0])
	}

	public func IsWordFound(refWord : String) -> Bool
	{
		return _keyWords.contains(word: refWord)
	}
}
