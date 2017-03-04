//
//  RegisterViewController.swift
//  Game Theory App 2
//
//  Created by Richard Poutier on 2/19/17.
//  Copyright © 2017 Richard Poutier. All rights reserved.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var firstNameTxt: UITextField! = nil
    @IBOutlet weak var lastNameTxt: UITextField! = nil
    @IBOutlet weak var emailTxt: UITextField! = nil
    @IBOutlet weak var passwordTxt: UITextField! = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        firstNameTxt.delegate = self
        lastNameTxt.delegate = self
        emailTxt.delegate = self
        passwordTxt.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func registerButtonTapped() {
        passwordTxt.resignFirstResponder()
        registerUser()
    }
    
    @IBAction func goBackButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //registers a new user, presents loading indicator while it waits for confirmation from server
    func registerUser() {
        
        //setUP Loading Overlay
        
        let alert = UIAlertController(title: nil, message: "Registering New User...", preferredStyle: .alert)
        
        alert.view.tintColor = UIColor.black
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50)) as UIActivityIndicatorView
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        
        //start animation the loading indicator
        loadingIndicator.startAnimating()
        
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
        
        let firstName = firstNameTxt.text!
        let lastName = lastNameTxt.text!
        let email = emailTxt.text!
        let password = passwordTxt.text!
        
        //** Need to error check these and make sure appropiate values are being entered
        
        //right here we're just checking to see if the values are empty
        if firstName != "" || lastName != "" || email != "" || password != "" {
            
            FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user: FIRUser?, error) in
                if error == nil {
                    print  ("You are successfully registered")
                    let changeRequest = FIRAuth.auth()?.currentUser?.profileChangeRequest()
                    changeRequest?.displayName = firstName+" "+lastName
                    changeRequest?.commitChanges(completion: { (error) in
                        // if user displayName is successfully updated, then handle the appropiate user
                        if error == nil {
                            print("Name updated")
                            
                            //**HANDLE SEGUE TO APPROPIATE VIEW - PROFESSOR VS. STUDENT
                            self.clearFields()
                            alert.dismiss(animated: true, completion: {action in
                            
                            self.performSegue(withIdentifier: "showStudentHomePage", sender: nil)
                            })
                        }
                        else {
                            print("Error updating the name")
                        }
                        
                    })
                    
                }else{
                    //failure in registration process
                    self.presentAlertView("Registration Failed", _message: "There was an error in registering your information. Please double check everything and try again.")
                }
            })
            
            
            
        } //else the info was not currently inputted
        else {
            
            //display which text fields need to be updated
            firstNameTxt.attributedPlaceholder = NSAttributedString(string: "First Name", attributes: [NSForegroundColorAttributeName: UIColor.red])
            lastNameTxt.attributedPlaceholder = NSAttributedString(string: "Last Name", attributes: [NSForegroundColorAttributeName: UIColor.red])
            emailTxt.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSForegroundColorAttributeName: UIColor.red])
            passwordTxt.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName: UIColor.red])
            alert.dismiss(animated: true, completion: nil)
            
        }

    }
    
    func clearFields() {
        firstNameTxt.text! = ""
        lastNameTxt.text! = ""
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
        
        let alert = UIAlertController(title: str, message: _message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //handles keyboard operations
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == self.firstNameTxt {
            self.lastNameTxt.becomeFirstResponder()
        } else if textField == self.lastNameTxt {
            emailTxt.becomeFirstResponder()
        } else if textField == self.emailTxt {
            passwordTxt.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            registerUser()
            return true
        }
        return false
    }

}
