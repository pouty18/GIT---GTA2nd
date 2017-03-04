//
//  GameResultsTableViewController.swift
//  Game Theory App 2
//
//  Created by Richard Poutier on 2/24/17.
//  Copyright © 2017 Richard Poutier. All rights reserved.
//

import UIKit
import Firebase

class GameResultsTableViewController: UITableViewController {
    
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
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return games.count
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if globalAuthID == adminID {
            //professor tapped cell
            
            //PM Masterlist ref GG.2
            //mark selected game as completed in Firebase
            //so long as setUpResults page doesn't return an error
            gamesRef.child(games[indexPath.row].key).updateChildValues(["status" : "done"])
            
            setUpResultsPage(withGame: games[indexPath.row])
            
        } else {
            //student tapped cell
            
            //send the prepare for segue an array of the gamekey, gametype, and gameName
            let gameInfo = [games[indexPath.row].key, games[indexPath.row].gameType, games[indexPath.row].gameName]
            
            self.performSegue(withIdentifier: "showStudentResults", sender: gameInfo)
        }
    }
    
    @IBAction func doneWithTable(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> CustomTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! CustomTableViewCell
        
        let game = games[indexPath.row] as Game
        cell.cellGameNameLabel.text! = game.gameName!
        cell.cellGameDetailLabel.text! = game.gameType!
        
        let gameKey = games[indexPath.row].key
        var waitingCount = 0
        var userIsWaiting = false
        var userIsDone = false
        
        ref.observe(FIRDataEventType.value, with: { (snapshot) in
            waitingCount = 0
            
            //parse submission data to see who is done with what game
            let subChildSnapshot = snapshot.childSnapshot(forPath: "submissions")
            
            if let postData = subChildSnapshot.value as? [String : AnyObject] {
                for game in postData {
                    if let users = game.value as? [String : AnyObject] {
                        
                        if game.key == gameKey {
                            for user in users{
                                waitingCount += 1
                                if user.key == globalAuthID {
                                    userIsDone = true
                                }
                            }
                        }
                    }
                }
            }
            
            
            //  If the user is a professor, show who's waiting or what's active
            
            if globalAuthID == adminID && game.gameStatus == "pending" {
                cell.cellNumberLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
                cell.cellNumberLabel.numberOfLines = 0
                cell.cellStatusLabel.font = cell.cellStatusLabel.font.withSize(14)
                cell.cellStatusLabel.text! = "Waiting"
                cell.cellNumberLabel.font = cell.cellNumberLabel.font.withSize(20)
                cell.cellNumberLabel.text! = "\(waitingCount)"
                
            } else
                if globalAuthID == adminID && game.gameStatus == "active" {
                    cell.cellNumberLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
                    cell.cellNumberLabel.numberOfLines = 0
                    cell.cellStatusLabel.font = cell.cellStatusLabel.font.withSize(14)
                    cell.cellStatusLabel.text! = "Finished:"
                    cell.cellNumberLabel.font = cell.cellNumberLabel.font.withSize(20)
                    cell.cellNumberLabel.textColor = UIColor.blue
                    cell.cellNumberLabel.text! = "\(waitingCount)"
                } else
                    //  PM Master List Reference GG.S.3
                    //check and see if the student has already played this game
                    if userIsDone {
                        SubmitData[gameKey] = "done"
                        cell.cellNumberLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
                        cell.cellNumberLabel.numberOfLines = 0
                        cell.cellStatusLabel.text! = "Status"
                        cell.cellNumberLabel.font = cell.cellNumberLabel.font.withSize(12)
                        cell.cellNumberLabel.textColor = UIColor.black
                        cell.cellNumberLabel.text! = "Finished"
                    } else
                        //  If the user is a student, tell them to join, what's waiting, and what's ready
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
            userIsDone = false
            userIsWaiting = false
            
            
        })
        
        return cell
        
    }
    
    //loads game data for table view
    func loadPendingGames() {
        gamesRef.observe(FIRDataEventType.value, with: { (snapshot) in
            self.games.removeAll()
            if let postData = snapshot.value as? [String : AnyObject] {
                for child in postData {
                    let tempKey = child.0
                    if let tempType = child.1["type"] as? String {
                        if let tempName = child.1["gameName"] as? String {
                            if let tempStatus = child.1["status"] as? String {
                                
                                //  PM Master List Reference GG.5, GG.S.5
                                //  if current user is a professor, and the game is active or done
                                if globalAuthID == adminID && tempStatus != "pending" {
                                    //  we want to show user all games that can be analyzed or already have been
                                    //  this means it won't show any pending games
                                    self.games.append(Game(_name: tempName, _type: tempType, _status: tempStatus, _key: tempKey))
                                    
                                }
                                    //  else if the user is a student
                                else  {
                                    //  we only want to show them games that have already been analyzed
                                    if tempStatus == "done" {
                                        
                                        //so only add games with status "done" to the table
                                        self.games.append(Game(_name: tempName, _type: tempType, _status: tempStatus, _key: tempKey))
                                    }
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
    
    func setUpResultsPage(withGame thisGame: Game) {
        let gameRef = FIRDatabase.database().reference(withPath: "submissions/\(thisGame.key)/")
        
        if thisGame.gameType == "Guessing Game" {
            gameRef.observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
                var runningTotal:Double = 0
                var amountOfGuesses = 0
                if let users = snapshot.value as? [String : AnyObject] {
                    for user in users {
                        amountOfGuesses += 1
                        if let data = user.value as? [String : AnyObject] {
                            print(data.debugDescription)
                            if let result = data["value"] as? String {
                                runningTotal += Double(result)!
                            }
//                            let userGuess = data["value"] as! Double
//                            runningTotal += userGuess
                            
                        }
                    }
                }
                let average = runningTotal/Double(amountOfGuesses)
                print("average = \(average)")
                
                let MULTIPLIER = 0.75
                
                //result is the final amount
                //the user with a guess closest to multiplier is written to the results
                let result = average * MULTIPLIER
                print("result = \(result)")
                
                
                var closestDifference = 1000000.0
                var winningGuess = ""
                var winningUser = ""
                if let users = snapshot.value as? [String : AnyObject] {
                    for user in users {
                        
                        if let data = user.value as? [String : AnyObject] {
                            print(data.debugDescription)
                            if let amount = data["value"] as? String {
                                let userGuess = Double(amount)!
                                runningTotal += userGuess
                                
                                let difference = abs(result - userGuess)
                                if difference < closestDifference {
                                    winningGuess = String(userGuess)
                                    closestDifference = difference
                                    winningUser = user.key
                                }
                            }
                        }
                    }
                }
                
                let userRef = FIRDatabase.database().reference(withPath: "users")
                userRef.observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
                    
                    if let users = snapshot.value as? [String : AnyObject] {
                        for user in users {
                            //details["winning user"] is the id of the user who win
                            //here we try and find that user, and get his/her name
                            if user.key == winningUser {
                                if let winnerDetails = user.value as? [String : String] {
                                    
                                    
                                    let winningUserName = winnerDetails["name"]!
                                    
                                    let post = ["result" : String(result), "closest guess" : winningGuess, "winning userName" : winningUserName, "winnin user key" : winningUser, "average" : String(average)]
                                    
                                    let childUpdates = ["/results/\(thisGame.key)/" : post]
                                    self.ref.updateChildValues(childUpdates as [AnyHashable: Any])
                                    let details = [post, thisGame] as [Any]
                                    
                                    //if user is professor, push professor view
                                    //else push student view
                                    if globalAuthID == adminID {
                                        self.performSegue(withIdentifier: "showProfessorResults", sender: details)
                                    } else {
                                        self.performSegue(withIdentifier: "showStudentResults", sender: details)
                                    }
                                }
                            }
                        }
                    }
                })
            })
        } else
            if thisGame.gameType == "Simultaneous Game 2" {
                
        } else
                if thisGame.gameType == "Public Good" {
                    
        }
        
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showProfessorResults" {
            
            if let post = sender as? [Any] {
                    
                    if let details = post.first as? [String : String] {
                        
                        if let thisGame = post.last as? Game {
                            
                            let vc = (segue.destination as! ProfessorResultsViewController)

                            //set next view controller's properies to match current values being sent
                            vc.gameName = thisGame.gameName!
                            vc.result = details["result"]!
                            vc.avearge = details["average"]!
                            vc.closestGuess = details["closest guess"]!
                            vc.winnerName = details["winning userName"]!
                            // set a variable in the second view controller with the String to pass
                        }
                    }
                }
        }
        else
            if segue.identifier == "showStudentResults" {
                if let post = sender as? [String?] {
                    
                    if let vc = segue.destination as? StudentResultsViewController {
                        vc.gameKey = post[0]!
                        vc.gameType = post[1]!
                        vc.gameName = post[2]! 
                    }
                    
                }

        }
    }
    

}
