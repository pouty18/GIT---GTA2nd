//
//  StudentResultsViewController.swift
//  Game Theory App 2
//
//  Created by Richard Poutier on 2/24/17.
//  Copyright © 2017 Richard Poutier. All rights reserved.
//

import UIKit
import Firebase

class StudentResultsViewController: UIViewController {

    var ref = FIRDatabase.database().reference()
    var resultsRef = FIRDatabase.database().reference(withPath: "results")
    
    
    var avearge  = ""
    var closestGuess = ""
    var winnerName = ""
    var result = ""
    var payoff = ""
    
    //variables to be set from prior view controller
    var gameType: String = ""
    var gameKey: String = ""
    var gameName = ""
    
    @IBOutlet weak var gameNameLabel: UILabel!
    
    @IBOutlet weak var averageLabel: UILabel!
    
    @IBOutlet weak var closestGuessLabel: UILabel!
    
    @IBOutlet weak var winnerNameLabel: UILabel!
    
    @IBOutlet weak var resultLabel: UILabel!
    
    @IBOutlet weak var payoffLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        getResults(ofGame: gameKey)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    @IBAction func goBackButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    /*
     getResults(ofGame id: String) retrieves the game Analysis data that 
     is sent to the results branch of Firebase once a professor analyzes a game
     */
    func getResults(ofGame id: String) {
        if gameType == "Guessing Game" {
            
            //we need to download the relevant results data
            resultsRef.observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
                if let resultsData = snapshot.value as? [String : AnyObject] {
                    
                    //loop through the results and find our game
                    
                    for game in resultsData {
                        
                        //if the current key and the gameKey are equal, we found our game
                        if game.key == self.gameKey {
                            
                            //create a dictionary from the game results details
                            if let details = game.value as? [String : String] {
                                
                                self.gameNameLabel.text! = self.gameName
                                self.winnerNameLabel.text = details["winning userName"]
                                self.resultLabel.text = details["result"]
                                self.closestGuessLabel.text = details["closest guess"]
                                self.averageLabel.text = details["average"]
                                self.payoffLabel.text = details["payoff"]
                            }
                        }
                    }
                    
                }
            })
        }
        
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
