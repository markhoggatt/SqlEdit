//
//  SqlViewController.swift
//  SqlEdit
//
//  Created by Mark Hoggatt on 28/05/2017.
//  Copyright © 2017 Code Europa. All rights reserved.
//

import Cocoa

class SqlViewController: NSViewController, NSTextStorageDelegate
{
	@IBOutlet var sqlTextView: NSTextView!

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
			NSLog("Failed to load SQL word dictionary.")
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
		updateSqlStatements(processedText: textStorage.string, editedRange: editedRange, lastDelta: delta)
	}

	public func updateSqlStatements(processedText : String, editedRange : NSRange, lastDelta : Int)
	{
		if lastDelta < 0
		{
			let removedOk : Bool = currentStatement.removeCharacterFromStatement(droppingLast: lastDelta)
			if removedOk
			{
				NSLog("Failed to remove characters from statement.")
			}
		}
		else
		{
			let newCharsStartIdx : String.Index = processedText.index(processedText.startIndex, offsetBy: editedRange.location)
			let newCharsEndIdx : String.Index = processedText.index(newCharsStartIdx, offsetBy: lastDelta)
			let newChars : String = String(processedText[newCharsStartIdx..<newCharsEndIdx])

			currentStatement.addCharactersToStatement(nextChars: newChars, withRange: editedRange)

			if currentStatement.isNewWord
			{
				if currentStatement.lastWord.foundInList
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
