//
//  ProfessorViewController.swift
//  Game Theory App 2
//
//  Created by Richard Poutier on 2/19/17.
//  Copyright © 2017 Richard Poutier. All rights reserved.
//

import UIKit
import Firebase

class ProfessorViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
//    @IBOutlet weak var emailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //attempt to get user info
        if let user = FIRAuth.auth()?.currentUser {
            if let name = user.displayName {
                self.titleLabel.text = name
            }
            if let email = user.email {
                print("This is where it was going wrong \(email)")
                //self.emailLabel.text = email
            }
            
            let thisID = user.uid
            globalAuthID = thisID
            
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Log Out Current Professor
    @IBAction func logOutButtonTapped() {
        
        //log off user
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
        
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
