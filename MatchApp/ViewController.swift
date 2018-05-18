//
//  ViewController.swift
//  MatchApp
//
//  Created by Alex on 01/01/2001.
//  Copyright © 2001 Bianca Bucur. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var timerSwitch: UISwitch!
    
    @IBOutlet weak var soundsSwitch: UISwitch!
    
    @IBOutlet weak var resetButton: UIButton!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var model = CardModel()
    var cardArray = [Card]()
    
    var firstFlippedCardIndex:IndexPath?
    
    var firstCardSelected = false
    
    var timer:Timer?
    var miliseconds:Float = 30 * 1000 // 30 seconds
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resetButton.layer.cornerRadius = 5.0
        
        // Call the getCards method of the card model
        cardArray = model.getCards()
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if soundsSwitch.isOn {
            SoundManager.playSound(.shuffle)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - IBAction Methods
    
    @IBAction func timerSwitchAction(_ sender: Any) {
        
        resetTimer()
    }
    
    @IBAction func resetButtonAction(_ sender: Any) {
        
        restartGame()
    }
    
    // MARK: - Timer Methods
    
    @objc func timerElapsed() {
        
        miliseconds -= 1
        
        // Convert to seconds
        let seconds = String(format: "%.2f", miliseconds / 1000)
        
        // Set label
        timerLabel.text = "Time remaining: \(seconds)"
        
        // When the timer has reached 0...
        if miliseconds <= 0 {
            // Stop the timer
            timer?.invalidate()
            timerLabel.textColor = UIColor.red
            
            // Check if there are any cards unmatched
            checkGameEnded()
        }
    }
    
    func resetTimer() {
        
        timer?.invalidate()
        
        if timerSwitch.isOn {
            miliseconds = 30 * 1000
            
            timerLabel.text = "Time remaining: 30"
            timerLabel.textColor = UIColor.black
            
        } else {
            timerLabel.text = "Time remaining: ∞"
            timerLabel.textColor = UIColor.lightGray
        }
        
        firstCardSelected = false
    }

    // MARK: - UICollectionView Protocol Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return cardArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // Get a CardCollectionViewCell object
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath) as! CardCollectionViewCell
        
        // Get the card that the collection view is trying to display
        let card = cardArray[indexPath.row]
        
        // Set that card for the cell
        cell.setCard(card)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if firstCardSelected == false {
            firstCardSelected = true
            
            // Create the timer if the timer switch is on
            if timerSwitch.isOn {
                timer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(timerElapsed), userInfo: nil, repeats: true)
                
                RunLoop.main.add(timer!, forMode: .commonModes)
            }
        }
        
        // Check if there's any time left
        if miliseconds <= 0 {
            return
        }
        
        // Get the cell that the user selected
        let cell = collectionView.cellForItem(at: indexPath) as! CardCollectionViewCell
        
        // Get the card that the user selected
        let card = cardArray[indexPath.row]
        
        if !card.isFlipped && !card.isMatched {
            // Flip the card
            cell.flip()
            
            // Play the flip sound
            if soundsSwitch.isOn {
                SoundManager.playSound(.flip)
            }
            
            // Set the status of the card
            card.isFlipped = true
            
            // Determine if it's the first card or the second card that's flipped over
            if firstFlippedCardIndex == nil {
                // This is the first card being flipped
                firstFlippedCardIndex = indexPath
                
            } else {
                // This is the second card being flipped
                
                // Perform the matching logic
                checkForMatches(indexPath)
            }
        }
    }
    
    // MARK: - Game Logic Methods
    
    func checkForMatches(_ secondFlippedCardIndex:IndexPath) {
        
        // Get the cells for the two cards that were revealed
        let cardOneCell = collectionView.cellForItem(at: firstFlippedCardIndex!) as? CardCollectionViewCell
        let cardTwoCell = collectionView.cellForItem(at: secondFlippedCardIndex) as? CardCollectionViewCell
        
        // Get the cards for the two cards that were revealed
        let cardOne = cardArray[firstFlippedCardIndex!.row]
        let cardTwo = cardArray[secondFlippedCardIndex.row]
        
        // Compare the two cards
        if cardOne.imageName == cardTwo.imageName {
            // It's a match
            
            // Play sound
            if soundsSwitch.isOn {
                SoundManager.playSound(.match)
            }
            
            // Set the statuses of the cards
            cardOne.isMatched = true
            cardTwo.isMatched = true
            
            // Remove the cards from the grid
            cardOneCell?.remove()
            cardTwoCell?.remove()
            
            // Check if there are any cards left unmatched
            checkGameEnded()
            
        } else {
            // It's not a match
            
            // Play sound
            if soundsSwitch.isOn {
                SoundManager.playSound(.nomatch)
            }
            
            // Set the statuses of the cards
            cardOne.isFlipped = false
            cardTwo.isFlipped = false
            
            // Flip both cards back
            cardOneCell?.flipBack()
            cardTwoCell?.flipBack()
        }
        
        // Tell the collectionView to reload the cell of the first card if it is nil
        if cardOneCell == nil {
            collectionView.reloadItems(at: [firstFlippedCardIndex!])
        }
        
        // Reset the property that tracks the first card flipped
        firstFlippedCardIndex = nil
    }
    
    func checkGameEnded() {
        
        // Determine if there are any cards unmatched
        var isWon = true
        
        for card in cardArray {
            if card.isMatched == false {
                isWon = false
                break
            }
        }
        
        // Messaging variables
        var title = ""
        var message = ""
        
        // If not, then user has won, stop the timer
        if isWon == true {
            if miliseconds > 0 {
                timer?.invalidate()
            }
            
            title = "Congratulations!"
            message = "You've won"
            
        } else {
            // If there are unmatched cards, check if there's any time left
            if miliseconds > 0 {
                return
            }
            
            title = "Game Over"
            message = "You've lost"
        }
        
        // Show won/lost messaging
        showAlert(title, message)
    }
    
    func showAlert(_ title:String, _ message:String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(alertAction)
        
        present(alert, animated: true, completion: restartGame)
    }
    
    func restartGame() {
        
        firstFlippedCardIndex = nil
        
        cardArray = model.getCards()
        collectionView.reloadData()
        
        if soundsSwitch.isOn {
            SoundManager.playSound(.shuffle)
        }
        
        resetTimer()
    }
    
}

