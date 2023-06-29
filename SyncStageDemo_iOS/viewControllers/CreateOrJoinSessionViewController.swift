//
//  CreateJoinSessionViewController.swift
//  SyncStageDemo_iOS
//
//  Created by bilal mahfouz on 08/11/2022.
//

import UIKit
import SyncStageSDK

class CreateOrJoinSessionViewController: UIViewController {
    
    @IBOutlet var label: UILabel!
    @IBOutlet var codeTextField: UITextField!
    @IBOutlet var joinButton: UIButton!
    @IBOutlet var createSessionButton: UIButton!
    
    var server: ServerInstance?
    var displayName = ""
    var code = ""
    var isSyncStageReady = false
    var userId = ""
    let userIdKey = "userIdKey"
    
    private let startNewSessionSegueIdentifier = "startNewSession"
    private let joinSessionSegueIdentifier = "JoinSessionByCode"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let fontSize = CGFloat(14)
        label.attributedText = NSMutableAttributedString().systemFontWith(text: "Sessions", size: 24, weight: .semibold)
            .systemFontWith(text: "\nEnter a code to join an existing session or create a new one.", size: fontSize, weight: .regular)
        
        if let value = UserDefaults.standard.string(forKey: userIdKey) {
            userId = value
        } else {
            userId = UUID().uuidString
            UserDefaults.standard.set(userId, forKey: userIdKey)
        }
    }

    @IBAction func joinSession() {
        if codeTextField.text?.isEmpty == true {
            self.showAlert(with: "Warning", message: "Please enter session code to join.")
        } else if let text = codeTextField.text {
            code = text
            self.performSegue(withIdentifier: joinSessionSegueIdentifier, sender: self)
        }
    }

    @IBAction func createSession() {
        guard let server = server else {
            self.showAlert(with: "Warning", message: "No studio server selected.")
            return
        }

        let hud = HUDView.show(view: view)
        SyncStageHelper.instance.createSession(zoneId: server.zoneId, studioServerId: server.studioServerId, userId: userId, completion: { [weak self] result in
            hud.hide()
            switch result {
            case .success(let sessionIdentifier):
                self?.code = sessionIdentifier.sessionCode
                self?.performSegue(withIdentifier: self?.joinSessionSegueIdentifier ?? "", sender: self)
            case .failure(let error):
                self?.showAlert(with: "Warning", message: error.localizedDescription)
            }
        })
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == startNewSessionSegueIdentifier, let destVC = segue.destination as? SessionLocationViewController {
            destVC.displayName = displayName
            destVC.userId = userId
        } else if segue.identifier == joinSessionSegueIdentifier, let destVC = segue.destination as? CurrentSessionViewController {
            destVC.displayName = displayName
            destVC.userId = userId
            destVC.code = code
            destVC.server = server
        }
    }
}

extension CreateOrJoinSessionViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.performSegue(withIdentifier: joinSessionSegueIdentifier, sender: self)
        return true
    }
}
