//
//  ViewController.swift
//  FireBaseApp
//
//  Created by Nikola Andriiev on 22.12.16.
//  Copyright © 2016 Andriiev.Mykola. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var infoLabel: UILabel!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!

    @IBOutlet var signIbButton: UIButton!
    @IBOutlet var forgotButton: UIButton!
    @IBOutlet var createAccButton: UIView!
    
    //MARK: Overrided functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.chechIfLoginned()
    }
    
    deinit {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    //MARK: Actions
    
    @IBAction func onSignInButton(_ sender: UIButton) {
        guard let email = self.emailTextField.text, let pass = self.passwordTextField.text else { return }
        FIRAuth.auth()?.signIn(withEmail: email, password: pass) { [weak self] (user, error) in
            if let error = error {
                self?.showAllerError(error, title: Constants.Messages.loginError)
                return
            }
            self?.emailTextField.text = ""
            self?.passwordTextField.text = ""
            user.map { self?.loginedWithUser(userData: $0) }
        }
    }
    
    @IBAction func onForgotButton(_ sender: UIButton) {
        self.infoLabel.text = ""
        self.restorePassword()
    }
    
    @IBAction func onCreateAccButton(_ onCreate: UIButton) {
        self.infoLabel.text = ""
    }
    
    //MARK: Private methods
    
    private func chechIfLoginned() {
        FIRAuth.auth()?.currentUser.map { self.loginedWithUser(userData: $0) }
    }
    
    private func loginedWithUser(userData: FIRUser) {
        let appState = AppState.instance
        appState.isLoginned = true
        appState.user = User(userData: userData)
        //transition to another controller
    }
    
    private func showAllerError(_ error: Error, title: String) {
        let allert = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        
        allert.addAction(action)
        self.present(allert, animated: true, completion: nil)
    }
    
    private func restorePassword() {
        let controller = UIAlertController(title: "Write your email", message: nil, preferredStyle: .alert)
        controller.addTextField { (textFild: UITextField) in
            textFild.placeholder = "User email"
        }
        
        let sendAction = UIAlertAction(title: "Send", style: .default) { (sendAction) in
            if let email = controller.textFields?[0].text {
                FIRAuth.auth()?.sendPasswordReset(withEmail: email) { (error) in
                    if let error = error {
                        self.infoLabel.text = error.localizedDescription
                        
                        return
                    } else {
                        self.infoLabel.text = Constants.Messages.passwordSended
                    }
                }
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (cancelAction) in
            self.dismiss(animated: true, completion: nil)
        }
        
        controller.addAction(cancelAction)
        controller.addAction(sendAction)
       
        self.present(controller, animated: true, completion: nil)
    }
}

extension LoginViewController: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
}

