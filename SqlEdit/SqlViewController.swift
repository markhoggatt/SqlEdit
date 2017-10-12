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
				if currentStatement.isEmpty == false
				{
					return
				}
			}

			let statementCount : Int = statements.count
			switch statementCount
			{
			case 0:
				statements.append(currentStatement)

			case 1:
				break

			default:
				currentStatement = statements[statementCount - 2]
				statements.remove(at: statementCount - 1)
			}

			return
		}

		let newChars : String = String(processedText.characters.suffix(lastDelta))
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

	private func applyAttributeToKeyWord()
	{

	}

	private func setWordAttributeInView(range : NSRange, colour : NSColor)
	{
		let textStore = sqlTextView.textStorage!

		textStore.setAttributes([NSAttributedStringKey.foregroundColor : colour], range: range)
	}
}
