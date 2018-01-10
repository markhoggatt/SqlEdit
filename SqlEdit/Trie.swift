//
//  Trie.swift
//  SqlEdit
//
//  Created by Mark Hoggatt on 18/07/2017.
//  Copyright © 2017 Code Europa. All rights reserved.
//

import Foundation


/// Word string implementation of a trie node structure.
class Trie
{
	private var wordCount : Int
	private let root : TrieNode<Character>

	private var isEmpty : Bool
	{
		get
		{
			return wordCount == 0;
		}
	}

	init()
	{
		wordCount = 0
		root = TrieNode<Character>()
	}


	/// Inserts a word into the trie. If the word already exists, there is no change.
	///
	/// - Parameter word: The word to add to the trie, if not already present.
	func insert(word : String)
	{
		guard word.isEmpty == false
		else
		{
			return
		}

		var currentNode : TrieNode<Character> = root
		for chr : Character in word.lowercased()
		{
			if let childNode = currentNode.children[chr]
			{
				currentNode = childNode
			}
			else
			{
				currentNode.addChild(value: chr)
				currentNode = currentNode.children[chr]!
			}
		}

		guard currentNode.isTerminating == false
		else
		{
			return
		}

		wordCount += 1
		currentNode.isTerminating = true
	}


	/// Checks if the supplied word exists in the trie structure.
	///
	/// - Parameter word: The word to verify.
	/// - Returns: true = The word is present, otherwise false.
	func contains(word : String) -> Bool
	{
		guard word.isEmpty == false
		else
		{
			return false
		}

		var currentNode : TrieNode<Character> = root
		for chr : Character in word.lowercased()
		{
			guard let childNode = currentNode.children[chr]
			else
			{
				return false
			}

			currentNode = childNode
		}

		return currentNode.isTerminating
	}


	/// Walks the nodes to find if the reference word exists, regardless of termination.
	///
	/// - Parameter word: The word to verify.
	/// - Returns: The last node to complete the word regardless of termination, otherwise nil.
	func findLastNodeOf(word : String) -> TrieNode<Character>?
	{
		var currentNode : TrieNode<Character> = root
		for chr : Character in word.lowercased()
		{
			guard let childNode : TrieNode<Character> = currentNode.children[chr]
			else
			{
				return nil
			}

			currentNode = childNode
		}

		return currentNode
	}


	/// Walks the nodes to find if the reference word exists and is terminating.
	///
	/// - Parameter word: The word to verify
	/// - Returns: The last node to complete the word if it is ternating, otherwise nil.
	func findTerminalNodeOf(word : String) -> TrieNode<Character>?
	{
		if let lastNode : TrieNode<Character>  = findLastNodeOf(word: word)
		{
			return lastNode.isTerminating ? lastNode : nil
		}

		return nil
	}


	/// Returns a list of words in the trie with the same prefix as the reference word.
	///
	/// - Parameter prefix: The reference word prefix.
	/// - Returns: The array of words with the matching prefix.
	func findWordsWithPrefix(prefix : String) -> [String]
	{
		var words = [String]()
		let prefixLower : String = prefix.lowercased()
		if let lastNode : TrieNode<Character> = findLastNodeOf(word: prefixLower)
		{
			if lastNode.isTerminating
			{
				words.append(prefixLower)
			}

			for childNode : TrieNode<Character> in lastNode.children.values
			{
				let childWords : [String] = wordsInSubtrie(rootNode: childNode, partialWord: prefixLower)
				words += childWords
			}
		}

		return words
	}


	/// Retrieves an array of words found ina subtrie of the whole structure.
	///
	/// - Parameters:
	///   - rootNode: The top node container.
	///   - partialWord: The remaining letters collected by traversing this node.
	/// - Returns: The words in the subtrie.
	private func wordsInSubtrie(rootNode : TrieNode<Character>, partialWord : String) -> [String]
	{
		var subTrieWords = [String]()
		var previousLetters : String = partialWord

		if let value : Character = rootNode.val
		{
			previousLetters.append(value)
		}

		if rootNode.isTerminating
		{
			subTrieWords.append(previousLetters)
		}

		for childNode : TrieNode<Character> in rootNode.children.values
		{
			let childWords : [String] = wordsInSubtrie(rootNode: childNode, partialWord: previousLetters)
			subTrieWords += childWords
		}

		return subTrieWords
	}
}
