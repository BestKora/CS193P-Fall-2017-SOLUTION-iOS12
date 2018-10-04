//
//  Concentration.swift
//
//  Created by CS193p Instructor  on 09/25/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import Foundation

class Concentration {
	
	private(set) var cards = [Card]()
   
    private(set) var flipCount = 0
    private(set) var score = 0
    private var seenCards: Set<Int> = []
    
    private struct Points {
        static let matchBonus = 2
        static let missMatchPenalty = 1
    }
    
	private var indexOfOneAndOnlyFaceUpCard: Int? {
		get {
			var foundIndex: Int?
			for index in cards.indices {
				if cards[index].isFaceUp  {
					guard foundIndex == nil else { return nil }
					foundIndex = index
				}
			}
			return foundIndex
		}
		set {
			for index in cards.indices {
				cards[index].isFaceUp = (index == newValue)
			}
		}
				
	}
	
	func chooseCard(at index: Int) {
		assert(cards.indices.contains(index), "Concentration.chooseCard(at: \(index)) : Choosen index out of range")
		if !cards[index].isMatched {
            flipCount += 1
			if let matchIndex = indexOfOneAndOnlyFaceUpCard, matchIndex != index {

				if cards[matchIndex].identifier == cards[index].identifier {
    //cards match
					cards[matchIndex].isMatched = true
					cards[index].isMatched = true
                    
                    // Increase the score
                    score += Points.matchBonus
                } else {
    //cards didn't match - Penalize
                    if seenCards.contains(index) {
                        score -= Points.missMatchPenalty
                    }
                    if seenCards.contains(matchIndex) {
                        score -= Points.missMatchPenalty
                    }
                    seenCards.insert(index)
                    seenCards.insert(matchIndex)
                }
				cards[index].isFaceUp = true
                
			} else {
				indexOfOneAndOnlyFaceUpCard = index
			}
		}
	}
	
    func resetGame (){
        flipCount = 0
        score = 0
        seenCards = []
        for index in cards.indices  {
            cards[index].isFaceUp = false
            cards[index].isMatched = false
        }
        cards.shuffle()
    }
    
	init(numberOfPairsOfCards: Int) {
		assert(numberOfPairsOfCards > 0,
               "Concentration.init(\(numberOfPairsOfCards)) : You must have at least one pair of cards")
		for _ in 1...numberOfPairsOfCards {
			let card = Card()
			cards += [card, card]
		}
	// Shuffle the cards
    // For Swift 4.2 better use native shuffle() for sequences
        cards.shuffle()
	}
}

/* extension Array {
    /// тасование элементов  `self` "по месту".
    mutating func shuffle() {
        // пустая коллекция и с одним элементом не тасуются
        if count < 2 { return }
        
        for i in indices.dropLast() {
            let diff = distance(from: i, to: endIndex)
            let j = index(i, offsetBy: diff.arc4random)
            swapAt(i, j)
        }
    }
}
 */

