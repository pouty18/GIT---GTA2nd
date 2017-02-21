//
//  CurrentGamesTableViewController.swift
//  Game Theory App 2
//
//  Created by Richard Poutier on 2/20/17.
//  Copyright © 2017 Richard Poutier. All rights reserved.
//

import UIKit
import Firebase

class CurrentGamesTableViewController: UITableViewController {
    
    var waitingRef = FIRDatabase.database().reference(withPath: "waiting")
    var gamesRef = FIRDatabase.database().reference(withPath: "games")

    var games:[Game] = [Game(_name: "", _type: "", _status: "")]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        loadPendingGames()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return games.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! CustomTableViewCell
        
        let game = games[indexPath.row] as Game
        cell.cellGameNameLabel.text! = game.gameName!
        cell.cellGameDetailLabel.text! = game.gameType!
        
        let gameKey = games[indexPath.row].key
        var waitingCount = 0
        var userIsWaiting = false
        var userIsPlaying = false
        var userIsDone = false
        
        waitingRef.observe(FIRDataEventType.value, with: { (snapshot) in
            waitingCount = 0
            
                if let postData = snapshot.value as? [String : AnyObject] {
                    for user in postData {
                        if let games = user.value as? [String : AnyObject] {
                            for game in games{
                                if game.key == gameKey {
                                    waitingCount += 1
                                }
                                if user.key == globalAuthID {
                                    if game.key == gameKey {
                                        userIsWaiting = true
                                    }
                                }
                            }
                        }
                    }
                }
                
//      If the user is a professor, show who's waiting or what's active
            if globalAuthID == adminID && game.gameStatus == "pending" {
                cell.cellNumberLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
                cell.cellNumberLabel.numberOfLines = 0
                cell.cellNumberLabel.font = cell.cellNumberLabel.font.withSize(12)
                cell.cellNumberLabel.text! = "Waiting on \(waitingCount)"
            } else
                if globalAuthID == adminID && game.gameStatus == "active" {
                    cell.cellNumberLabel.text! = "Active"
                    cell.cellNumberLabel.font = cell.cellNumberLabel.font.withSize(12)
                    cell.cellNumberLabel.textColor = UIColor.blue
            } else
//        If the user is a student, tell them to join, what's waiting, and what's ready
            if userIsWaiting == true && game.gameStatus == "pending"  {
                cell.cellNumberLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
                cell.cellNumberLabel.numberOfLines = 0
                cell.cellNumberLabel.text! = "Waiting"
                cell.cellNumberLabel.font = cell.cellNumberLabel.font.withSize(12)
                cell.cellNumberLabel.textColor = UIColor.red
            } else
                if userIsWaiting != true && game.gameStatus == "pending" {
                    cell.cellNumberLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
                    cell.cellNumberLabel.numberOfLines = 0
                    cell.cellNumberLabel.text! = "Tap to Join"
                    cell.cellNumberLabel.font = cell.cellNumberLabel.font.withSize(12)
                    cell.cellNumberLabel.textColor = UIColor.black
            } else
                if game.gameStatus == "active" {
                    cell.cellNumberLabel.text! = "Ready"
                    cell.cellNumberLabel.font = cell.cellNumberLabel.font.withSize(12)
                    cell.cellNumberLabel.textColor = UIColor.blue
                }
        })
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if globalAuthID == adminID {
            
            //update this game so that it's now active
            gamesRef.child(games[indexPath.row].key).updateChildValues(["status": "active"])
            presentAlertView("Success", _message: "You have successfully activated \(games[indexPath.row].gameName!)")
            loadPendingGames()
        } else {
            if games[indexPath.row].gameStatus == "pending" {
                
                //add this player to the waiting room so Professor knows how many people are ready
                let post = ["user" : "waiting"]
                let childUpdates = ["/\(globalAuthID)/\(games[indexPath.row].key)/" : post]
                waitingRef.updateChildValues(childUpdates as [AnyHashable: Any])
                self.tableView.reloadData()
                presentAlertView("Get Ready!", _message: "Please wait for your professor to start the game")
            } else
                if games[indexPath.row].gameStatus == "active" {
                    //push gameBoard
                    self.performSegue(withIdentifier: "showGenericGameBoard", sender: nil)
            }
        }
    }
    
    // MARK: - IBACTIONS
    
    @IBAction func doneWithTable(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func refreshTableView() {
        loadPendingGames()
    }
    
    
    // MARK: - Data retrival
    
    func loadPendingGames() {
        
        
        
        
        gamesRef.observe(FIRDataEventType.value, with: { (snapshot) in
            self.games.removeAll()
            if let postData = snapshot.value as? [String : AnyObject] {
                for child in postData {
                    let tempKey = child.0
                    if let tempType = child.1["type"] as? String {
                        if let tempName = child.1["gameName"] as? String {
                            if let tempStatus = child.1["status"] as? String {
                                //we only want to be able to view active games so check and see if the current game is active
                                //                                if tempStatus == "pending" {
                                self.games.append(Game(_name: tempName, _type: tempType, _status: tempStatus, _key: tempKey))
                                //                                }
                                //game isn't active so don't add it to active games table view controller
                                //                            } else {
                                //                                print("Error in retrieving game status")
                                //                            }
                            } else {
                                print("Couldn't retrieve game Name")
                            }
                        } else {
                            print("Couldn't retrieve game type")
                        }
                    }
                }
                self.tableView.reloadData()
            }
        })
    }
    
    func presentAlertView(_ _title: String, _message: String) {
        
        let alert = UIAlertController(title: _title, message: _message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
