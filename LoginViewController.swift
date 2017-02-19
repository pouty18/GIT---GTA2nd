//
//  LoginViewController.swift
//  Game Theory App 2
//
//  Created by Richard Poutier on 2/19/17.
//  Copyright © 2017 Richard Poutier. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    //IBOutlets for textfields
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func loginButtonTapped() {
        
        if emailTxt.text != "" || passwordTxt.text != "" {
            logInUser()
        } else {
            //textfields not filled out
            emailTxt.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSForegroundColorAttributeName: UIColor.red])
            passwordTxt.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName: UIColor.red])
        }
        
    }
    
    @IBAction func registerButtonTapped() {
        self.performSegue(withIdentifier: "showRegisterViewController", sender: nil)
    }
    
    func logInUser() {
        let email   =
            emailTxt.text!
        let pass1   = passwordTxt.text!
        
        FIRAuth.auth()?.signIn( withEmail: email, password: pass1) { (user, error) in
            // ...
            if error == nil {
                print("You have successfully logged in")
                //if the professor is signing in, push professor homepage
                if user?.uid == adminID {
                    self.performSegue(withIdentifier: "showProfessorHomePage", sender: nil)
                } else {
                    //else push student homepage
                    self.performSegue(withIdentifier: "showStudentHomePage", sender: nil)
                }
                
            }else{
                print ("Sign-in Failed... Please Try Again")
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
