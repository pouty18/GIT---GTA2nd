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
    
    var ref = FIRDatabase.database().reference()
    var waitingRef = FIRDatabase.database().reference(withPath: "waiting")
    var gamesRef = FIRDatabase.database().reference(withPath: "games")
    var subRef = FIRDatabase.database().reference(withPath: "submissions")
    var playRef = FIRDatabase.database().reference(withPath: "playing")

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
        
        ref.observe(FIRDataEventType.value, with: { (snapshot) in
            waitingCount = 0
            let waitChildSnapshot = snapshot.childSnapshot(forPath: "waiting")
            //parse submission data to see who is done with what game
            let subChildSnapshot = snapshot.childSnapshot(forPath: "submissions")
            
            if let postData = waitChildSnapshot.value as? [String : AnyObject] {
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
            
            if let postData = subChildSnapshot.value as? [String : AnyObject] {
                for game in postData {
                    if let users = game.value as? [String : AnyObject] {
                        
                        if game.key == gameKey {
                            for user in users{
                                if user.key == globalAuthID {
                                    userIsDone = true
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
                cell.cellStatusLabel.font = cell.cellStatusLabel.font.withSize(14)
                cell.cellStatusLabel.text! = "Waiting"
                cell.cellNumberLabel.font = cell.cellNumberLabel.font.withSize(20)
                cell.cellNumberLabel.text! = "\(waitingCount)"
            } else
                if globalAuthID == adminID && game.gameStatus == "active" {
                    cell.cellStatusLabel.font = cell.cellStatusLabel.font.withSize(14)
                    cell.cellStatusLabel.text! = "Finished:"
                    cell.cellNumberLabel.font = cell.cellNumberLabel.font.withSize(20)
                    cell.cellNumberLabel.textColor = UIColor.blue
                    cell.cellNumberLabel.text! = "\(waitingCount)"
            } else
                    if userIsDone {
                        SubmitData[gameKey] = "done"
                        cell.cellStatusLabel.font = cell.cellStatusLabel.font.withSize(14)
                        cell.cellStatusLabel.text! = "Status:"
                        cell.cellNumberLabel.text! = "Done"
                        cell.cellNumberLabel.font = cell.cellNumberLabel.font.withSize(14)
                        cell.cellNumberLabel.textColor = UIColor.black
            } else
//        If the user is a student, tell them to join, what's waiting, and what's ready
            if userIsWaiting == true && game.gameStatus == "pending"  {
                cell.cellStatusLabel.text! = "Status:"
                cell.cellStatusLabel.font = cell.cellStatusLabel.font.withSize(14)
                cell.cellNumberLabel.text! = "Waiting"
                cell.cellNumberLabel.font = cell.cellNumberLabel.font.withSize(14)
                cell.cellNumberLabel.textColor = UIColor.red
            } else
                if userIsWaiting != true && game.gameStatus == "pending" {
                    cell.cellNumberLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
                    cell.cellNumberLabel.numberOfLines = 0
                    cell.cellStatusLabel.text! = "Tap to"
                    cell.cellStatusLabel.font = cell.cellStatusLabel.font.withSize(14)
                    cell.cellNumberLabel.text! = "Join"
                    cell.cellNumberLabel.font = cell.cellNumberLabel.font.withSize(20)
                    cell.cellNumberLabel.textColor = UIColor.black
            } else
                if game.gameStatus == "active" {
                    cell.cellStatusLabel.text! = ""
                    cell.cellStatusLabel.font = cell.cellStatusLabel.font.withSize(15)
                    cell.cellNumberLabel.text! = "Play!"
                    cell.cellNumberLabel.font = cell.cellNumberLabel.font.withSize(16)
                    cell.cellNumberLabel.textColor = UIColor.blue
                }
            userIsDone = false
            userIsWaiting = false
        })
        
        return cell
    }
    
    /*
     This function does the following:
     If user is a Professor:
        -marks game status as active
 */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! CustomTableViewCell
        
        if globalAuthID == adminID {
            
            //update this game so that it's now active
            gamesRef.child(games[indexPath.row].key).updateChildValues(["status": "active"])
            presentAlertView("Success", _message: "You have successfully activated \(games[indexPath.row].gameName!)")
            loadPendingGames()
        }
        else {
            if games[indexPath.row].gameStatus == "pending" {
                
                //add this player to the waiting room so Professor knows how many people are ready
                let post = ["user" : "waiting"]
                let childUpdates = ["/\(globalAuthID)/\(games[indexPath.row].key)/" : post]
                waitingRef.updateChildValues(childUpdates as [AnyHashable: Any])
                self.tableView.reloadData()
                presentAlertView("Get Ready!", _message: "Please wait for your professor to start the game")
            }
            else
                //we can finally play a game, so remove gameID from waiting list
                if games[indexPath.row].gameStatus == "active" {
                    
                    
                    //  PM Master List Reference GG.S.1. - GG.S.8 - also got rid of submitData 
                    //listen and see if user has submitted any data for this game
                    subRef.observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
                        
                        var userHasAlreadySubmittedData = false
                        
                        if let games = snapshot.value as? [String : AnyObject] {
                            //for each game that has submission data
                            for game in games {
                                //if this game is the one we just selected, i.e. we found submission data for our game
                                if game.key == self.games[indexPath.row].key {
                                    //if we can create a dictionary of users from our submission info
                                    if let users = game.value as? [String : AnyObject] {
                                        
                                        for user in users {
                                            //try and see if I have already submitted something for this game
                                            if user.key == globalAuthID {
                                                
                                                //if yes, we don't want current user to be able to submit again for same game
                                                userHasAlreadySubmittedData = true
                                            }
                                        }
                                        
                                    }
                                    
                                }
                            }
                        }
                        if !userHasAlreadySubmittedData {
                            
                            //remove waiting list data from DB
                            self.deleteData(fromGame: self.games[indexPath.row].key, user: globalAuthID)
                            
                            let post = ["user" : "playing"]
                            let childUpdates = ["/\(globalAuthID)/\(self.games[indexPath.row].key)/" : post]
                            self.playRef.updateChildValues(childUpdates as [AnyHashable: Any])
                            
                            //push gameBoard
                            globalGameID = self.games[indexPath.row].key
                            self.performSegue(withIdentifier: "showGenericGameBoard", sender: nil)
                        }
                    })
                    
                } else {
                    //user has already played that game
                    let deselectedCell = tableView.cellForRow(at: indexPath)!
                    deselectedCell.setHighlighted(false, animated: false)
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
    
    // MARK: - Data Deletion
    
    func deleteData(fromGame game: String, user: String) {
        ref.child("/waiting/\(globalAuthID)/\(game)").removeValue { (error, ref) in
            if error != nil {
                print("error \(error)")
            }
            else {
                print("Delete successful")
            }
        }
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
                                
                                // *PM Master List Reference GG.S.2
                                //  we want to make sure we're only loading games that can be played.
                                //  if a game's status is "done", it has already been analyzed
                                if tempStatus != "done" {
                                    self.games.append(Game(_name: tempName, _type: tempType, _status: tempStatus, _key: tempKey))
                                }
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
