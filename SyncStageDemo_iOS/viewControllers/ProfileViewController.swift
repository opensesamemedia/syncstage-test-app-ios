//
//  UserViewController.swift
//  SyncStageDemo_iOS
//
//  Created by bilal mahfouz on 08/11/2022.
//

import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet var userNameTextField: UITextField!
    
    private let nextSegueIdentifier = "Discovery"
    private let userNameKey = "userNameKey"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if let userName = UserDefaults.standard.string(forKey: userNameKey) {
            userNameTextField.text = userName
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        userNameTextField.becomeFirstResponder()
    }

    @IBAction func next(sender: UIButton) {
        if userNameTextField.text?.isEmpty == true {
            self.showAlert(with: "Warning", message: "Please enter your user name.")
        } else {
            updateUserName()
            self.performSegue(withIdentifier: nextSegueIdentifier, sender: self)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == nextSegueIdentifier, let destVC = segue.destination as? DiscoveryViewController {
            destVC.displayName = userNameTextField.text ?? ""
        }
    }
    
    func updateUserName() {
        if let userName = userNameTextField.text {
            UserDefaults.standard.set(userName, forKey: userNameKey)
        }
    }
}

extension ProfileViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        updateUserName()
        self.performSegue(withIdentifier: nextSegueIdentifier, sender: self)
        return true
    }
}
