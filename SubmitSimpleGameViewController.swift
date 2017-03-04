//
//  SubmitSimpleGameViewController.swift
//  Game Theory App 2
//
//  Created by Richard Poutier on 2/20/17.
//  Copyright © 2017 Richard Poutier. All rights reserved.
//

import UIKit
import Firebase

class SubmitSimpleGameViewController: UIViewController {

    var subRef = FIRDatabase.database().reference(withPath: "submissions")
    var ref = FIRDatabase.database().reference()
    
    @IBOutlet weak var inputTxt: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func submit() {
        
        if inputTxt.text! != "" {
            let post = ["value": inputTxt.text!]
            let childUpdates = ["/\(globalGameID)/\(globalAuthID)/" : post]
            subRef.updateChildValues(childUpdates as [AnyHashable: Any])
            
            //delete playing data from DB
            deleteData(fromGame: globalGameID, user: globalAuthID)
            
            
            globalGameID = ""
            
            //dismiss view
            self.dismiss(animated: true, completion: nil)
        } else {
            //tell user to input a valid number
        }
    }
    
    func deleteData(fromGame game: String, user: String) {
        ref.child("/playing/\(user)/\(game)").removeValue { (error, ref) in
            if error != nil {
                print("error \(error)")
            }
            else {
                print("Delete successful")
            }
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
