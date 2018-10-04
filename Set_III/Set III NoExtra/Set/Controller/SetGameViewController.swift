//
//  ViewController.swift
//  Set
//
//  Created by Tatiana Kornilova on 12/31/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import UIKit

class SetGameViewController: UIViewController {
    
    private var game = SetGame()
    
    @IBOutlet weak var boardView: BoardView!{
        didSet {
            let swipe = UISwipeGestureRecognizer(target: self,
                                                 action: #selector(deal3))
            swipe.direction = .down
            boardView.addGestureRecognizer(swipe)
            
            let rotate = UIRotationGestureRecognizer(target: self,
                                                     action: #selector(reshuffle))
            boardView.addGestureRecognizer(rotate)
        }
    }
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var deckCountLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    
    @IBOutlet weak var dealButton: BorderButton!
    @IBOutlet weak var newButton: BorderButton!
    @IBOutlet weak var hintButton: BorderButton!
    
   @IBOutlet weak var stackMessage: UIStackView!
    
    private func updateViewFromModel() {
        updateCardViewsFromModel()
        // update Buttons and Labels
        updateHintButton()
        deckCountLabel.text = "Deck: \(game.deckCount )"
        scoreLabel.text = "Score: \(game.score) / \(game.numberSets)"
        if let itIsSet = game.isSet {
            messageLabel.text = itIsSet ? "СОВПАДЕНИЕ" :"НЕСОВПАДЕНИЕ"
        } else {
             messageLabel.text = ""
        }
        
        dealButton.isHidden =  game.deckCount == 0
        hintButton.disable = game.hints.count == 0
    }
    
    private func updateHintButton() {
        hintButton.setTitle("\(game.hints.count ) sets", for: .normal)
        _lastHint = 0
    }
    
    private func updateCardViewsFromModel() {
        // remove cards from boardView
        if boardView.cardViews.count - game.cardsOnTable.count > 0 {
            let cardViews = boardView.cardViews [..<game.cardsOnTable.count ]
            boardView.cardViews = Array(cardViews)
        }
        let numberCardViews =  boardView.cardViews.count
        
        for index in game.cardsOnTable.indices {
            let card = game.cardsOnTable[index]
            if  index > (numberCardViews - 1) { // new cards
                
                let cardView = SetCardView()
                updateCardView(cardView,for: card)
                addTapGestureRecognizer(for: cardView) // gesture tap
                boardView.cardViews.append(cardView)
           
            } else {                                // old cards
                let cardView = boardView.cardViews [index]
                updateCardView(cardView,for: card)
            }
        }
    }
        
    private func addTapGestureRecognizer(for cardView: SetCardView) {
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(tapCard(recognizedBy: )))
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        cardView.addGestureRecognizer(tap)
    }
    
    @objc
    private func tapCard(recognizedBy recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            if  let cardView = recognizer.view! as? SetCardView {
                game.chooseCard(at: boardView.cardViews.index(of: cardView)!)
            }
        default:
            break
        }
        updateViewFromModel()
    }
    
    private func updateCardView(_ cardView: SetCardView, for card: SetCard){
        cardView.symbolInt =  card.shape.rawValue
        cardView.fillInt = card.fill.rawValue
        cardView.colorInt = card.color.rawValue
        cardView.count =  card.number.rawValue
        cardView.isSelected =  game.cardsSelected.contains(card)
        if let itIsSet = game.isSet {
            if game.cardsTryMatched.contains(card) {
               cardView.isMatched = itIsSet
            }
        } else {
            cardView.isMatched = nil
        }
    }
    
    @IBAction func deal3() {
            game.deal3()
            updateViewFromModel()
    }
    
    private weak var timer: Timer?
    private var _lastHint = 0
    private let flashTime = 1.5
    
    @IBAction func hint() {
        timer?.invalidate()
        if  game.hints.count > 0 {
            game.hints[_lastHint].forEach { (idx) in
                boardView.cardViews[idx].hint()
            }
            messageLabel.text = "Set \(_lastHint + 1) Wait..."
            timer = Timer.scheduledTimer(withTimeInterval: flashTime,
                                         repeats: false) { [weak self] time in
            self?._lastHint =
                (self?._lastHint)!.incrementCicle(in:(self?.game.hints.count)!)
            self?.messageLabel.text = ""
            self?.updateCardViewsFromModel()
            }
        }
    }
    
    @IBAction func new() {
        game = SetGame()
        boardView.cardViews.removeAll()
        updateViewFromModel()
    }
    
    @objc
    func reshuffle(_ sender: UITapGestureRecognizer) {
        switch sender.state {
        case .ended:
            game.shuffle()
            updateViewFromModel()
        default:
            break
        }
    }
    
    //     MARK:    ViewController lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad ()
        updateViewFromModel()
    }
}

extension Int {
    func incrementCicle (in number: Int)-> Int {
        return (number - 1) > self ? self + 1: 0
    }
}
/*
 
 */
