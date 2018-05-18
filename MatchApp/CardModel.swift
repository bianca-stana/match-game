//
//  CardModel.swift
//  MatchApp
//
//  Created by Alex on 01/01/2001.
//  Copyright © 2001 Bianca Bucur. All rights reserved.
//

import Foundation

class CardModel {
    
    func getCards() -> [Card] {
        
        // Declare an array to store numbers we've already generated
        var generatedNumbers = [Int]()
        
        // Declare an array to store the generated cards
        var generatedCards = [Card]()
        
        // Randomly generate 8 pairs of cards
        while generatedNumbers.count < 8 {
            // Get a random number
            let randNumber = arc4random_uniform(13) + 1
            
            // Ensure that the random number isn't one we already have
            if generatedNumbers.contains(Int(randNumber)) == false {
                // Store the number into the generatedNumbers
                generatedNumbers.append(Int(randNumber))
                
                // Create the first card object (and add it to the array)
                let cardOne = Card()
                cardOne.imageName = "card\(randNumber)"
                generatedCards.append(cardOne)
                
                // Create the second card object (and add it to the array)
                let cardTwo = Card()
                cardTwo.imageName = "card\(randNumber)"
                generatedCards.append(cardTwo)
            }
        }
        
        // Randomize the array
        for i in 0...generatedCards.count - 1 {
            // Find a random index to swap with
            let randNumber = Int(arc4random_uniform(UInt32(generatedCards.count)))
            
            // Swap the two cards
            let temp = generatedCards[i]
            generatedCards[i] = generatedCards[randNumber]
            generatedCards[randNumber] = temp
        }
        
        // Return the array
        return generatedCards
    }
    
}
