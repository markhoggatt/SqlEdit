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

	init(statement : String)
	{
		statementText = statement
	}

	var hashValue: Int
	{
		return statementText.hashValue
	}

	public static func ==(lhs : SqlStatement, rhs : SqlStatement) -> Bool
	{
		return lhs.statementText == rhs.statementText
	}
}
