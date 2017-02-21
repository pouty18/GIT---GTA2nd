//
//  CreateGameViewController.swift
//  Game Theory App 2
//
//  Created by Richard Poutier on 2/19/17.
//  Copyright © 2017 Richard Poutier. All rights reserved.
//


import UIKit
import Firebase
import FirebaseDatabase

class CreateGameViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate  {
    
    var ref = FIRDatabase.database().reference()
    
    @IBOutlet weak var gamePicker: UIPickerView!
    @IBOutlet weak var gameSelectionLabel: UILabel!
    @IBOutlet weak var gameNameTxt: UITextField! = nil
    
    let gameOptions = ["Guessing Game", "Simultaneous Game #1", "Simultaneous Game #2", "Player Coordinated","Market Game", "Incomplete Info", "Private Value Auction", "Simple Simultaneous Move","Common Value Auction", "Public Good Game", "Sequential Bargaining", "Coin Game","Coalition Game"]
    
    @IBAction func DismissViewButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gameNameTxt.delegate = self
        gameSelectionLabel.text = gameOptions[0]
     
    }
    
    //MARK: - Delegates and data sources
    //MARK: Data Sources
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return gameOptions.count
    }
    
    //MARK: Delegates
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return gameOptions[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        gameSelectionLabel.text = gameOptions[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleData = gameOptions[row]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Helvetica Neue", size: 15.0)!,NSForegroundColorAttributeName:UIColor.black])
        return myTitle
    }
    
    @IBAction func createNewGame() {
        gameNameTxt.resignFirstResponder()
        switch gameSelectionLabel.text! {
        case "Guessing Game":
            print("trying to create a new guessing game")
            if gameNameTxt.text! == "" {
                presentAlertView("Error",_message:  "Please enter game name.", someFunction: { print("error") })
            } else {
                submitGuessingGame()
            }
            //            performSegue(withIdentifier: "submitGuessingGame", sender: nil)
            break
        case "Simultaneous Game #1":
            print("Trying to create a Simultaneous Game #1 game")
            if gameNameTxt.text! == "" {
                presentAlertView("Error",_message:  "Please enter game name.", someFunction: { print("error") })
            } else {
                submitSimultaneousGame1()
            }
            //            performSegue(withIdentifier: "submitSimultaneousGame1", sender: nil)
            break
        case "Simultaneous Game #2":
            print("Trying to create a Simultaneous Game #2 game")
            if gameNameTxt.text! == "" {
                presentAlertView("Error",_message:  "Please enter game name.", someFunction: { print("error") })
            } else {
                submitSimultaneousGame2()
            }
            //            performSegue(withIdentifier: "submitSimultaneousGame2", sender: nil)
            break
        case "Player Coordinated":
            print("Trying to create a Player Coordinated game")
            if gameNameTxt.text! == "" {
                presentAlertView("Error",_message:  "Please enter game name.", someFunction: { print("error") })
            } else {
                submitPlayerCoordinatedGame()
            }
            break
        case "Market Game":
            print("Trying to create a Market Game game")
            if gameNameTxt.text! == "" {
                presentAlertView("Error",_message:  "Please enter game name.", someFunction: { print("error") })
            } else {
                submitMarketGame()
            }
            break
        case "Incomplete Info":
            print("Trying to create a Incomplete Info game")
            if gameNameTxt.text! == "" {
                presentAlertView("Error",_message:  "Please enter game name.", someFunction: { print("error") })
            } else {
                submitIncompleteInfoGame()
            }
            break
        case "Private Value Auction":
            print("Trying to create a Private Value Auction game")
            if gameNameTxt.text! == "" {
                presentAlertView("Error",_message:  "Please enter game name.", someFunction: { print("error") })
            } else {
                submitPrivateValueAuctionGame()
            }
            break
        case "Simple Simultaneous Move":
            print("Trying to create a Simple Simultaneous Move game")
            if gameNameTxt.text! == "" {
                presentAlertView("Error",_message:  "Please enter game name.", someFunction: { print("error") })
            } else {
                submitSimpleSimultaneousMoveGame()
            }
            break
        case "Common Value Auction":
            print("Trying to create a Common Value Auction game")
            if gameNameTxt.text! == "" {
                presentAlertView("Error",_message:  "Please enter game name.", someFunction: { print("error") })
            } else {
                submitCommonValueAuctionGame()
            }
            break
        case "Public Good Game":
            print("Trying to create a Public Good Game game")
            if gameNameTxt.text! == "" {
                presentAlertView("Error",_message:  "Please enter game name.", someFunction: { print("error") })
            } else {
                submitPublicGoodGame()
            }
            break
        case "Sequential Bargaining":
            print("Trying to create a Sequential Bargaining game")
            if gameNameTxt.text! == "" {
                presentAlertView("Error",_message:  "Please enter game name.", someFunction: { print("error") })
            } else {
                submitSequentialBargainingGame()
            }
            break
        case "Coin Game":
            print("Trying to create a Coin Game game")
            if gameNameTxt.text! == "" {
                presentAlertView("Error",_message:  "Please enter game name.", someFunction: { print("error") })
            } else {
                submitCoinGame()
            }
            break
        case"Coalition Game":
            print("Trying to create a Coalition Game  game")
            if gameNameTxt.text! == "" {
                presentAlertView("Error",_message:  "Please enter game name.", someFunction: { print("error") })
            } else {
                submitCoalitionGame()
            }
            break
        default:
            break
        }
    }
    
    func submitGuessingGame() {
        let childs = ref.child("games").childByAutoId()
        let key = childs.key
        let post = ["gameName": gameNameTxt.text!,"lowerRange": "0", "upperRange": "1000", "multiplier": "0.75", "reward": "10", "status": "pending","type" : "Guessing Game"]
        let childUpdates = ["/games/\(key)/" : post]
        ref.updateChildValues(childUpdates as [AnyHashable: Any])
        presentAlertView("Game Made!", _message: "Successfully made new Guessing Game", someFunction: { self.dismiss(animated: true, completion: nil)} )
        gameNameTxt.text! = ""
        
    }
    
    func submitSimultaneousGame1() {
        let childs = ref.child("games").childByAutoId()
        let key = childs.key
        let post = ["gameName": gameNameTxt.text!, "status" : "pending", "type" : "Simultaneous Game 1"]
        let childUpdates = ["/games/\(key)/" : post]
        ref.updateChildValues(childUpdates as [AnyHashable: Any])
        presentAlertView("Game Made!", _message: "Successfully made new Simultaneous #1 Game", someFunction: { self.dismiss(animated: true, completion: nil)} )
        gameNameTxt.text! = ""
        
    }
    
    func submitSimultaneousGame2() {
        let childs = ref.child("games").childByAutoId()
        let key = childs.key
        let post = ["gameName": gameNameTxt.text!, "status" : "pending", "type" : "Simultaneous Game 2"]
        let childUpdates = ["/games/\(key)/" : post]
        ref.updateChildValues(childUpdates as [AnyHashable: Any])
        presentAlertView("Game Made!", _message: "Successfully made new Simultaneous #2 Game", someFunction: { self.dismiss(animated: true, completion: nil)} )
        gameNameTxt.text! = ""
    }
    
    func submitPlayerCoordinatedGame() {
        let childs = ref.child("games").childByAutoId()
        let key = childs.key
        let post = ["gameName": gameNameTxt.text!, "status" : "pending", "type" : "Player Coordinated"]
        let childUpdates = ["/games/\(key)/" : post]
        ref.updateChildValues(childUpdates as [AnyHashable: Any])
        presentAlertView("Game Made!", _message: "Successfully made new Player Coordinated Game", someFunction: { self.dismiss(animated: true, completion: nil)} )
        gameNameTxt.text! = ""
    }
    
    func submitMarketGame() {
        let childs = ref.child("games").childByAutoId()
        let key = childs.key
        let post = ["gameName": gameNameTxt.text!, "status" : "pending", "type" : "Market Game"]
        let childUpdates = ["/games/\(key)/" : post]
        ref.updateChildValues(childUpdates as [AnyHashable: Any])
        presentAlertView("Game Made!", _message: "Successfully made new Market Game Game", someFunction: { self.dismiss(animated: true, completion: nil)} )
        gameNameTxt.text! = ""
    }
    
    func submitIncompleteInfoGame() {
        let childs = ref.child("games").childByAutoId()
        let key = childs.key
        let post = ["gameName": gameNameTxt.text!, "status" : "pending", "type" : "Incomplete Info"]
        let childUpdates = ["/games/\(key)/" : post]
        ref.updateChildValues(childUpdates as [AnyHashable: Any])
        presentAlertView("Game Made!", _message: "Successfully made new Incomplete Info Game", someFunction: { self.dismiss(animated: true, completion: nil)} )
        gameNameTxt.text! = ""
    }
    
    func submitPrivateValueAuctionGame() {
        let childs = ref.child("games").childByAutoId()
        let key = childs.key
        let post = ["gameName": gameNameTxt.text!, "status" : "pending", "type" : "Private Value Auction"]
        let childUpdates = ["/games/\(key)/" : post]
        ref.updateChildValues(childUpdates as [AnyHashable: Any])
        presentAlertView("Game Made!", _message: "Successfully made new Private Value Auction Game", someFunction: { self.dismiss(animated: true, completion: nil)} )
        gameNameTxt.text! = ""
    }
    
    func submitSimpleSimultaneousMoveGame() {
        let childs = ref.child("games").childByAutoId()
        let key = childs.key
        let post = ["gameName": gameNameTxt.text!, "status" : "pending", "type" : "Simple Simultaneous Move"]
        let childUpdates = ["/games/\(key)/" : post]
        ref.updateChildValues(childUpdates as [AnyHashable: Any])
        presentAlertView("Game Made!", _message: "Successfully made new Simple Simultaneous Move Game", someFunction: { self.dismiss(animated: true, completion: nil)} )
        gameNameTxt.text! = ""
    }
    
    func submitCommonValueAuctionGame() {
        let childs = ref.child("games").childByAutoId()
        let key = childs.key
        let post = ["gameName": gameNameTxt.text!, "status" : "pending", "type" : "Common Value Auction"]
        let childUpdates = ["/games/\(key)/" : post]
        ref.updateChildValues(childUpdates as [AnyHashable: Any])
        presentAlertView("Game Made!", _message: "Successfully made new Common Value Auction Game", someFunction: { self.dismiss(animated: true, completion: nil)} )
        gameNameTxt.text! = ""
    }
    
    func submitPublicGoodGame() {
        let childs = ref.child("games").childByAutoId()
        let key = childs.key
        let post = ["gameName": gameNameTxt.text!, "status" : "pending", "type" : "Public Good"]
        let childUpdates = ["/games/\(key)/" : post]
        ref.updateChildValues(childUpdates as [AnyHashable: Any])
        presentAlertView("Game Made!", _message: "Successfully made new Public Good Game", someFunction: { self.dismiss(animated: true, completion: nil)} )
        gameNameTxt.text! = ""
    }
    
    func submitSequentialBargainingGame() {
        let childs = ref.child("games").childByAutoId()
        let key = childs.key
        let post = ["gameName": gameNameTxt.text!, "status" : "pending", "type" : "Sequential Bargaining"]
        let childUpdates = ["/games/\(key)/" : post]
        ref.updateChildValues(childUpdates as [AnyHashable: Any])
        presentAlertView("Game Made!", _message: "Successfully made new Sequential Bargaining Game", someFunction: { self.dismiss(animated: true, completion: nil)} )
        gameNameTxt.text! = ""
    }
    
    func submitCoinGame() {
        let childs = ref.child("games").childByAutoId()
        let key = childs.key
        let post = ["gameName": gameNameTxt.text!, "status" : "pending", "type" : "Coin"]
        let childUpdates = ["/games/\(key)/" : post]
        ref.updateChildValues(childUpdates as [AnyHashable: Any])
        presentAlertView("Game Made!", _message: "Successfully made new Coin Game", someFunction: { self.dismiss(animated: true, completion: nil)} )
        gameNameTxt.text! = ""
    }
    
    func submitCoalitionGame() {
        let childs = ref.child("games").childByAutoId()
        let key = childs.key
        let post = ["gameName": gameNameTxt.text!, "status" : "pending", "type" : "Coalition"]
        let childUpdates = ["/games/\(key)/" : post]
        ref.updateChildValues(childUpdates as [AnyHashable: Any])
        presentAlertView("Game Made!", _message: "Successfully made new Coalition Game", someFunction: { self.dismiss(animated: true, completion: nil)} )
        gameNameTxt.text! = ""
    }
    
    func presentAlertView(_ str: String, _message: String, someFunction: @escaping () -> Void) {
        
        let alert = UIAlertController(title: str, message: _message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: { action in someFunction() } ) )
        
        self.present(alert, animated: true, completion: nil)
    }
    
    //handles keyboard operations
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
