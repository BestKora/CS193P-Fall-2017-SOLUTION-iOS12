//
//  ViewController.swift
//  Set
//
//  Created by Tatiana Kornilova on 12/31/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    enum Player:Int {
        case me = 1
        case iPhone
    }
    
    private var currentPLayer = Player.me {
        didSet {
            game.playerIndex = currentPLayer.rawValue - 1
        }
    }
    
    private var game = SetGame()
    
    var colors = [#colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1), #colorLiteral(red: 0.5808190107, green: 0.0884276256, blue: 0.3186392188, alpha: 1), #colorLiteral(red: 1, green: 0.2527923882, blue: 1, alpha: 1)]
    var strokeWidths:[CGFloat] = [ -10, 10, -10]
    var alphas:[CGFloat] = [1.0, 0.60, 0.15]
    
    @IBOutlet weak var deckCountLabel: UILabel!
    /// ------ ME --------
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    /// ------ IPHONE  --------
    @IBOutlet weak var iPhoneLabel: UILabel!
    @IBOutlet weak var messageIPhoneLabel: UILabel!
    @IBOutlet weak var scoreiPhoneLabel: UILabel!
    
    @IBOutlet var cardButtons: [SetCardButton]! {
        didSet {
            for button in cardButtons{
                button.strokeWidths = strokeWidths
                button.colors = colors
                button.alphas = alphas
        }
    }
    }
    
    @IBOutlet weak var dealButton: BorderButton!
    @IBOutlet weak var newButton: BorderButton!
    @IBOutlet weak var hintButton: BorderButton!
    
    @IBAction func touchCard(_ sender: SetCardButton) {
        timer1?.invalidate()
        currentPLayer = .me
        if let cardNumber = cardButtons.index(of: sender) {
            game.chooseCard(at: cardNumber)
            updateViewFromModel()
            if let itIsSet = game.isSet, itIsSet {
                TryiPhone()
            }
        } else {
            print("choosen card was not in cardButtons")
        }
    }
    
    private func updateViewFromModel() {
        updateButtonsFromModel()
        updateHintButton()
        deckCountLabel.text = "Deck: \(game.deckCount )"
        
        scoreLabel.text = "Score: \(game.score[0]) / \(game.numberSets[0])"
        scoreiPhoneLabel.text = "Score: \(game.score[1]) / \(game.numberSets[1])"
        if currentPLayer != .iPhone {
           iPhoneLabel.text = "  🤔  "
           iPhoneLabel.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        }
        
        dealButton.disable = (game.cardsOnTable.count) >= cardButtons.count
                           || game.deckCount == 0
        hintButton.disable = game.hints.count == 0
    }
    
    private func updateHintButton() {
        hintButton.setTitle("\(game.hints.count ) sets", for: .normal)
        _lastHint = 0
    }
    
    private func updateButtonsFromModel() {
        messageLabel.text = ""
        messageIPhoneLabel.text = ""
        
        for index in cardButtons.indices {
            let button = cardButtons[index]
            if index < game.cardsOnTable.count {
                //--------------------------------
                let card = game.cardsOnTable[index] 
                button.setCard = card
                //-----------Selected----------------------
                button.setBorderColor(color:
                    game.cardsSelected.contains(card) ? Colors.selected : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0))
                //-----------TryMatched----------------------
                if let itIsSet = game.isSet {
                    if game.cardsTryMatched.contains(card) {
                        button.setBorderColor(color:
                            itIsSet ? Colors.matched: Colors.misMatched)
                    }
                    switch currentPLayer {
                    case .me:
                            messageLabel.text = itIsSet ? "СОВПАДЕНИЕ" :"НЕСОВПАДЕНИЕ"
                    case .iPhone:
                        messageIPhoneLabel.text = itIsSet ? "OK!!!" :"NO..."
                    }
                }
                //--------------------------------
            } else {
                button.setCard = nil
            }
        }
    }
   
    @IBAction func deal3() {
        if (game.cardsOnTable.count + 3) <= cardButtons.count {
            currentPLayer = .me
            game.deal3()
            updateViewFromModel()
            timer1?.invalidate()
        }
    }
    
    private weak var timer: Timer?
    private weak var timer1: Timer?
    private var _lastHint = 0
    
    @IBAction func hint() {
        timer?.invalidate()
        if  game.hints.count > 0 {
            game.hints[_lastHint].forEach { (idx) in
                let button = self.cardButtons[idx]
                button.setBorderColor(color: Colors.hint)
            }
            messageLabel.text = "Set \(_lastHint + 1) Wait..."
            timer = Timer.scheduledTimer(withTimeInterval: Constants.flashTime,
                                          repeats: false) { [weak self] time in
                self?.game.hints[(self?._lastHint)!].forEach { (idx) in
                    let button = self?.cardButtons[idx]
                    button!.setBorderColor(color: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0))
                }
                self?._lastHint =
                    (self?._lastHint)!.incrementCicle(in:(self?.game.hints.count)!)
                self?.messageLabel.text = ""
                self?.updateButtonsFromModel()
            }
        }
    }
    
    @IBAction func new() {
        timer?.invalidate()
        timer1?.invalidate()
        game = SetGame()
        currentPLayer = Player.me
        cardButtons.forEach { $0.setCard = nil }
        updateViewFromModel()
    }
    
    //     MARK:    ViewController lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad ()
        updateViewFromModel()
    }
    
   //     MARK:   Actions for iPhone
    
    private func neutralizationSet (){
        //--- neutralize Set from .me
        var cardsOnTable = game.cardsOnTable
        cardsOnTable.remove(elements: game.cardsTryMatched)
            let randomCard = cardsOnTable [Int.random(in: 0..<cardsOnTable.count)]
            if let randomIndex  = game.cardsOnTable.index(of: randomCard) {
                game.chooseCard(at: randomIndex )
            }
    }
    private func removeSelectedCards (){
         // remove selected cards
       game.cardsSelected.forEach { card in
            if let idx = game.cardsOnTable.index(of: card){
                game.chooseCard(at: idx)
            }
        }
    }
    
    private func selectHintSet (){
        // success hint Set
        if game.hints.count > 0 {
            game.hints[0].forEach { idx in
                game.chooseCard(at: idx)
            }
        }
    }
    
    private func selectRandomSet(){
        var cardsOnTable = game.cardsOnTable
        // For Swift 4.2 better use native shuffle() for sequences
        cardsOnTable.shuffle()
            for index in 0..<3 {
                if let idx = game.cardsOnTable.index(of: cardsOnTable[index]){
                    game.chooseCard(at: idx)
                }
            }
    }
    
    private func TryiPhone(){
        //-----------TryiPhone----------------------
        timer1 = Timer.scheduledTimer(withTimeInterval:
            Constants.iPhoneWaitTime, repeats: false) {[weak self] time in
                                        
                self?.currentPLayer = .iPhone
                self?.iPhoneLabel.text = "  😄  "
                self?.iPhoneLabel.backgroundColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
                
        //--- neutralize Set from .me
                self?.neutralizationSet ()
                
        // remove selected cards
                self?.removeSelectedCards ()
                
        // flip a coin with probability 2/3
                if  Int.randomNumber(probabilities: [1, 2]) == 1 {
        // success hint Set
                    self?.selectHintSet ()
                } else {
        // fail random Set
                    self?.selectRandomSet()
                }
                self?.updateViewFromModel()
                if let itIsSet = self?.game.isSet {
                    self?.iPhoneLabel.text = itIsSet ? "  😂!!!" : "  😥..."
                } else {
                    self?.iPhoneLabel.text = "🤢 No Sets at all."
                }
        }
    }
}

extension ViewController {
    //------------------ Constants -------------
    private struct Colors {
        static let hint = #colorLiteral(red: 1, green: 0.5212053061, blue: 1, alpha: 1)
        static let selected = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
        static let matched = #colorLiteral(red: 0, green: 0.9914394021, blue: 1, alpha: 1)
        static var misMatched = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    }
    
    private struct Constants {
        static let flashTime = 1.5
        static let iPhoneWaitTime = 2.0
    }
}

extension Int {
    func incrementCicle (in number: Int)-> Int {
        return (number - 1) > self ? self + 1: 0
    }
    
   static func randomNumber(probabilities: [Int]) -> Int {
        
        // Sum of all probabilities (so that we don't have to require that the sum is 1.0):
        let sum = probabilities.reduce(0, +)
        // Random number in the range 0.0 <= rnd < sum :
        let rnd = Int.random(in: 0..<sum)
        // Find the first interval of accumulated probabilities into which `rnd` falls:
        var accum = 0
        for (i, p) in probabilities.enumerated() {
            accum += p
            if rnd < accum {
               return i
            }
        }
       return (probabilities.count - 1)
    }
}


