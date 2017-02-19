//
//  Game.swift
//  Game Theory App 2
//
//  Created by Richard Poutier on 2/19/17.
//  Copyright © 2017 Richard Poutier. All rights reserved.
//

import Foundation
import Firebase

class Game {
    var key: String
    
    var gameName: String?
    
    var gameType: String?
    
    var gameStatus: String?
    
    var ref: FIRDatabaseReference?
    
    init( _name: String?, _type: String?, _status: String?, _key: String = "") {
        self.key = _key
        self.gameName = _name
        self.gameType = _type
        self.gameStatus = _status
        self.ref = nil
    }
    
    init(snapshot: FIRDataSnapshot) {
        key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        gameName = snapshotValue["gameName"] as? String
        gameType = snapshotValue["type"] as? String
        gameStatus = snapshotValue["status"] as? String
        ref = snapshot.ref
    }
    
}
