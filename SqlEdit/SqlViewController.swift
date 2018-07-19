//
//  SqlViewController.swift
//  SqlEdit
//
//  Created by Mark Hoggatt on 28/05/2017.
//  Copyright © 2017 Code Europa. All rights reserved.
//

import Cocoa
import os.log

class SqlViewController: NSViewController, NSTextStorageDelegate
{
	@IBOutlet var sqlTextView: NSTextView!

	let logHandle : OSLog = OSLog(subsystem: "eu.hoggatt.SqlEdit", category: "SqlViewController")
	var statements : [SqlStatement] = [SqlStatement]()
	var currentStatement : SqlStatement = SqlStatement(statement: "")

    override func viewDidLoad()
	{
        super.viewDidLoad()
        // Do view setup here.
		sqlTextView.isContinuousSpellCheckingEnabled = false
		sqlTextView.isGrammarCheckingEnabled = false
		sqlTextView.isRulerVisible = false
		sqlTextView.textStorage?.delegate = self
		
		currentStatement.statementText = sqlTextView.string
		if statements.count == 0
		{
			statements.append(currentStatement)
		}

		let langProc = LanguageProcessor.Instance()
		if langProc.ProcessReservedWords() == false
		{
			os_log("Failed to load SQL word dictionary.")
		}
    }

	override var representedObject: Any?
	{
		didSet
		{
			// Update the view, if already loaded.
		}
	}

	func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int)
	{
		updateSqlStatements(processedText: textStorage.string, editedRange: Range<Int>(editedRange)!, lastDelta: delta)
	}

	public func updateSqlStatements(processedText : String, editedRange : Range<Int>, lastDelta : Int)
	{
		if lastDelta < 0
		{
			let removedOk : Bool = currentStatement.removeCharacterFromStatement(droppingLast: lastDelta)
			if removedOk == false
			{
				os_log("Failed to remove characters from statement.")
			}
		}
		else
		{
			let newCharsStartIdx : String.Index = processedText.index(processedText.startIndex, offsetBy: editedRange.lowerBound)
			let newCharsEndIdx : String.Index = processedText.index(newCharsStartIdx, offsetBy: lastDelta)
			let newChars : String = String(processedText[newCharsStartIdx..<newCharsEndIdx])

			currentStatement.appendChrsToStatement(nextChars: newChars, withRange: editedRange)

			if currentStatement.isNewWord
			{
				guard let currentWord : SqlWord = currentStatement.lastWord
				else
				{
					return
				}

				if currentWord.foundInList
				{
					// TODO: Change the text colour here
				}
			}

			if currentStatement.isComplete
			{
				statements.append(currentStatement)
			}
		}
	}

	private func applyAttributeToKeyWord()
	{

	}

	private func setWordAttributeInView(range : NSRange, colour : NSColor)
	{
		let textStore = sqlTextView.textStorage!

		textStore.setAttributes([NSAttributedStringKey.foregroundColor : colour], range: range)
	}
}
