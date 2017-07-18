//
//  SqlViewController.swift
//  SqlEdit
//
//  Created by Mark Hoggatt on 28/05/2017.
//  Copyright © 2017 Code Europa. All rights reserved.
//

import Cocoa

class SqlViewController: NSViewController, NSTextViewDelegate
{
	@IBOutlet var sqlTextView: NSTextView!

	var statements : Set<SqlStatement> = Set<SqlStatement>()

    override func viewDidLoad()
	{
        super.viewDidLoad()
        // Do view setup here.
		sqlTextView.isContinuousSpellCheckingEnabled = false
		sqlTextView.isGrammarCheckingEnabled = false
		sqlTextView.isRulerVisible = false

    }

	override var representedObject: Any?
	{
		didSet
		{
			// Update the view, if already loaded.
		}
	}
}
