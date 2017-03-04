//
//  ProfessorResultsViewController.swift
//  Game Theory App 2
//
//  Created by Richard Poutier on 2/24/17.
//  Copyright © 2017 Richard Poutier. All rights reserved.
//

import UIKit

class ProfessorResultsViewController: UIViewController {
    
    var gameName = ""
    var avearge  = ""
    var closestGuess = ""
    var winnerName = ""
    var result = ""

    @IBOutlet weak var gameNameLabel: UILabel!
    
    @IBOutlet weak var averageLabel: UILabel!
    
    @IBOutlet weak var closestGuessLabel: UILabel!
    
    @IBOutlet weak var winnerNameLabel: UILabel!
    
    @IBOutlet weak var resultLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        gameNameLabel.text = gameName
        averageLabel.text = avearge
        closestGuessLabel.text = closestGuess
        winnerNameLabel.text = winnerName
        resultLabel.text = result
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func goBackButtonTapped() {
        self.dismiss(animated: true, completion: nil)
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
