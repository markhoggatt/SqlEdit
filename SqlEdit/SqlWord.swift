//
//  SqlWord.swift
//  SqlEdit
//
//  Created by Mark Hoggatt on 28/07/2017.
//  Copyright © 2017 Code Europa. All rights reserved.
//

import Foundation

/// Holds the content of a known SQL word found inside a SQL Statement
struct SqlWord
{
	/// The SQL word
	public let word : String

	/// The range of the word inside the text container that displays it.
	public let wordRange : Range<Int>

	/// Indicates whether or not this word is found in the SQL command or key word lists.
	public let foundInList : Bool
}
