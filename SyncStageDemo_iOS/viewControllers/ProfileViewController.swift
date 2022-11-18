//
//  UserViewController.swift
//  SyncStageDemo_iOS
//
//  Created by bilal mahfouz on 08/11/2022.
//

import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet var userNameTextField: UITextField!
    
    private let nextSegueIdentifier = "JoinOrCreateSession"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        userNameTextField.becomeFirstResponder()
    }

    @IBAction func next(sender: UIButton) {
        if userNameTextField.text?.isEmpty == true {
            self.showAlert(with: "Warning", message: "Please enter your user name.")
        } else {
            self.performSegue(withIdentifier: nextSegueIdentifier, sender: self)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == nextSegueIdentifier, let destVC = segue.destination as? CreateOrJoinSessionViewController {
            destVC.displayName = userNameTextField.text ?? ""
        }
    }
}

extension ProfileViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.performSegue(withIdentifier: nextSegueIdentifier, sender: self)
        return true
    }
}
