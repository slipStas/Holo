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
    var isUserAuthorised = false
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var systemInformationLabel: UILabel!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.passwordTextField.delegate = self
        
        isUserAuthorised = defaults.bool(forKey: "isLogin")
        print(isUserAuthorised)
        
        loadUsers()
        
        if isUserAuthorised {
            goToNavigationController()
        }
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
                    
                    goToNavigationController()
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
    
    func goToNavigationController() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let navigationVC = storyBoard.instantiateViewController(withIdentifier: "navigationController") as! NavigationViewController
        navigationVC.modalPresentationStyle = .fullScreen
        
        DispatchQueue.main.async {
            self.present(navigationVC, animated: true, completion: nil)
        }
        defaults.set(true, forKey: "isLogin")
        print("go to NavigationViewController")
        print(isUserAuthorised)
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
