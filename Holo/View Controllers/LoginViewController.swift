//
//  LoginViewController.swift
//  Holo
//
//  Created by Stanislav Slipchenko on 01.10.2020.
//

import UIKit
import CoreData

class LoginViewController: UIViewController {
    
    var user: User?
    var usersArray: [User] = []
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var systemInformationLabel: UILabel!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUsers()
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
        if self.usersArray.count > 0 {
            usersArray.forEach { (user) in
                if user.login == self.loginTextField.text && user.password == self.passwordTextField.text {
                    UserDefaults.standard.set(true, forKey: "isLogin")
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let navigationVC = storyBoard.instantiateViewController(withIdentifier: "navigationController") as! NavigationViewController
                    navigationVC.modalPresentationStyle = .fullScreen
                    self.present(navigationVC, animated: true, completion: nil)
                    print("go to NavigationViewController")
                } else {
                    print("Incorrect login or password")
                    self.systemInformationLabel.text = "Incorrect login or password"
                }
            }
        } else {
            print("You should be Sign up")
            self.systemInformationLabel.text = "You should be Sign up"
        }
        
    }
    
    @IBAction func signUp(_ sender: Any) {
        
        var isUserExist = false
        
        usersArray.forEach { (user) in
            if user.login == self.loginTextField.text {
                isUserExist = true
            }
        }
        
        switch isUserExist {
        case true:
            print("user is exist")
            usersArray.forEach { (user) in
                if user.login == self.loginTextField.text {
                    user.setValue(self.passwordTextField.text, forKey: "password")
                }
            }
        case false:
            user = User(context: self.context)
            print("user is not exist")
            user?.login = self.loginTextField.text
            user?.password = self.passwordTextField.text
        }
        
        do {
            try context.save()
        } catch let error {
            print(error.localizedDescription)
        }
        
        self.usersArray.removeAll()
        self.loadUsers()
    }
    
    func loadUsers() {
        do {
            self.usersArray = try context.fetch(User.fetchRequest())
            print(self.usersArray.count)
        } catch let error {
            print(error.localizedDescription)
        }
    }

}
