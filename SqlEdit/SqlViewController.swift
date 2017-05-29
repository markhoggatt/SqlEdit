//
//  SqlViewController.swift
//  SqlEdit
//
//  Created by Mark Hoggatt on 28/05/2017.
//  Copyright © 2017 Code Europa. All rights reserved.
//

import Cocoa

class SqlViewController: NSViewController
{
	@IBOutlet var sqlTextView: NSTextView!

	var statements : Set<SqlStatement> = Set<SqlStatement>()

    override func viewDidLoad()
	{
        super.viewDidLoad()
        // Do view setup here.
    }

	override var representedObject: Any?
	{
		didSet
		{
			// Update the view, if already loaded.
		}
	}
}
