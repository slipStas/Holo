//
//  LoginViewController.swift
//  Holo
//
//  Created by Stanislav Slipchenko on 01.10.2020.
//

import UIKit

class LoginViewController: UIViewController {
    
    
    @IBOutlet weak var loginTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
   
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func signIn(_ sender: Any) {
        guard let loginText = loginTextField else {return}
        guard let passwordText = passwordTextField else {return}
        
        if loginText.text!.isEmpty {
            print("The login field is empty")
        } else {
            print("login - " + loginText.text!)
        }
        
        if passwordText.text!.isEmpty {
            print("The password field login is empty")
        } else {
            print("password - " + passwordText.text!)
        }
    }
    
    @IBAction func signUp(_ sender: Any) {
        
    }
    

}
