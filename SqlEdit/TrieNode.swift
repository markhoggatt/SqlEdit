//
//  TrieNode.swift
//  SqlEdit
//
//  Created by Mark Hoggatt on 17/07/2017.
//  Copyright © 2017 Code Europa. All rights reserved.
//

import Foundation


/// Maintains a single object node
class TrieNode<T : Hashable>
{
	let val : T?
	weak var parentNode : TrieNode?
	var children : [T : TrieNode] = [:]
	var isTerminating : Bool = false
	var isLeaf : Bool
	{
		return children.count == 0
	}

	// Initialiser - normally used by the root at start.
	init()
	{
		val = nil
	}


	/// A new object node to be joined to its parent.
	///
	/// - Parameters:
	///   - value: The object held by this node.
	///   - parentNd: The parent node to which it must now relate.
	init(value : T, parentNd : TrieNode?)
	{
		val = value
		self.parentNode = parentNd
	}


	/// Add a new object for which this node must become the parent.
	///
	/// - Parameter value: The object value to be held by the new node.
	func addChild(value : T)
	{
		guard children[value] == nil
		else
		{
			return
		}

		children[value] = TrieNode(value: value, parentNd: self)
	}
}
