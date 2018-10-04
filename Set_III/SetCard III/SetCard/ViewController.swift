//
//  ViewController.swift
//  PlayingCard
//
//  Created by CS193p Instructor on 10/9/17.
//  Copyright © 2017 CS193p Instructor. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var deck = SetCardDeck()
    
    @IBOutlet weak var playingCardView: SetCardView! {
        didSet {
            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(nextCard))
            swipe.direction = [.left,.right]
            playingCardView.addGestureRecognizer(swipe)
        }
    }
    
    @objc func nextCard() {
        if let card = deck.draw() {
            playingCardView.symbolInt =  card.shape.rawValue
            playingCardView.fillInt = card.fill.rawValue
            playingCardView.colorInt = card.color.rawValue
            playingCardView.count =  card.number.rawValue
            
        }
    }
    
    // this is wired up directly to a UITapGestureRecognizer in the storyboard
    @IBAction func flipCard(_ sender: UITapGestureRecognizer) {
        switch sender.state {
        case .ended:
            playingCardView.isFaceUp = !playingCardView.isFaceUp
        default: break
        }
    }
}
