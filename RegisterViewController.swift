//
//  RegisterViewController.swift
//  Game Theory App 2
//
//  Created by Richard Poutier on 2/19/17.
//  Copyright © 2017 Richard Poutier. All rights reserved.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {

    @IBOutlet weak var firstNameTxt: UITextField!
    @IBOutlet weak var lastNameTxt: UITextField!
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
    
    @IBAction func registerButtonTapped() {
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
                            clearFields()
                            alert.dismiss(animated: true, completion: nil)
                            
                            self.performSegue(withIdentifier: "showStudentHomePage", sender: nil)
                            
                        }
                        else {
                            print("Error updating the name")
                        }
                        
                    })
                    
                }else{
                    //failure in registration process
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
    
    @IBAction func goBackButtonTapped() {
        self.dismiss(animated: true, completion: nil)
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

}
