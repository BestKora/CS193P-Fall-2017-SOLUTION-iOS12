//
//  SetCardDeck.swift
//  Set
//
//  Created by Tatiana Kornilova on 12/31/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import Foundation
struct SetCardDeck {
    private(set) var cards = [SetCard]()
    
    init() {
        for number in SetCard.Variant.allCases {
            for color in SetCard.Variant.allCases {
                for shape in SetCard.Variant.allCases {
                    for fill in SetCard.Variant.allCases {
                        cards.append(SetCard(number: number,
                                              color: color,
                                              shape: shape,
                                               fill: fill))
                    }
                }
            }
        }
    }
    
    mutating func draw() -> SetCard? {
        if cards.count > 0 {
            
            // For Swift 4.2 better use native  Int.random(in: ...)
            // return cards.remove(at: cards.count.arc4random)
             return cards.remove(at: Int.random(in: 0..<cards.count))
        } else {
            return nil
        }
    }
}
