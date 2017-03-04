//
//  LoginViewController.swift
//  Game Theory App 2
//
//  Created by Richard Poutier on 2/19/17.
//  Copyright © 2017 Richard Poutier. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate {

    //IBOutlets for textfields
    @IBOutlet weak var emailTxt: UITextField! = nil
    @IBOutlet weak var passwordTxt: UITextField! = nil
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTxt.delegate = self
        passwordTxt.delegate = self

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func loginButtonTapped() {
        emailTxt.resignFirstResponder()
        passwordTxt.resignFirstResponder()
        login()
    }
    
    @IBAction func registerButtonTapped() {
        self.performSegue(withIdentifier: "showRegisterViewController", sender: nil)
    }
    

    //logging in from seperate function allows us to avoid recursion when calling loging from keyboard 'Go' button
    func login() {
        
        let alert = UIAlertController(title: nil, message: "Signing In...", preferredStyle: .alert)
        
        alert.view.tintColor = UIColor.black
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50)) as UIActivityIndicatorView
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        
        
        if emailTxt.text != "" || passwordTxt.text != "" {
            //start animation the loading indicator
            loadingIndicator.startAnimating()
            alert.view.addSubview(loadingIndicator)
            present(alert, animated: true, completion: nil)
            
            //log in user
            let email   =
                emailTxt.text!
            let pass1   = passwordTxt.text!
            
            FIRAuth.auth()?.signIn( withEmail: email, password: pass1) { (user, error) in
                // ...
                if error == nil {
                    print("You have successfully logged in")
                    //if the professor is signing in, push professor homepage
                    if user?.uid == adminID {
                        alert.dismiss(animated: true, completion: nil)
                        self.clearTextFields()
                        
                        self.performSegue(withIdentifier: "showProfessorHomePage", sender: nil)
                    } else {
                        //else push student homepage
                        alert.dismiss(animated: true, completion: nil)
                        self.clearTextFields()
                        self.performSegue(withIdentifier: "showStudentHomePage", sender: nil)
                    }
                    
                }else{
                    print ("Sign-in Failed... Please Try Again")
                    alert.dismiss(animated: true, completion: { action in self.presentAlertView("Sign-In Failed", _message: "The email/password you entered are invalid.")})
//                    self.presentAlertView("Sign-In Failed", _message: "The email/password you entered are invalid.")
                }
                
            }
            
        } else {
            //textfields not filled out
            emailTxt.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSForegroundColorAttributeName: UIColor.red])
            passwordTxt.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName: UIColor.red])
        }
    }
    
    
    func clearTextFields() {
        emailTxt.text! = ""
        passwordTxt.text! = ""
    }

    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */

    func presentAlertView(_ str: String, _message: String) {
        let alertMessage = UIAlertController(title: str, message: _message, preferredStyle: UIAlertControllerStyle.alert)
        alertMessage.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertMessage, animated: true, completion: nil)
    }
    
    
    //handles keyboard operations
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == self.emailTxt {
            self.passwordTxt.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            login()
            return true
        }
        return false
    }
}
