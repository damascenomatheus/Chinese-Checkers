//
//  InitialViewController.swift
//  Chinese Checkers
//
//  Created by Thalys Viana on 17/08/19.
//  Copyright © 2019 Thalys Viana. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController {

    @IBOutlet weak var hostTextField: UITextField!
    @IBOutlet weak var portTextField: UITextField!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var activePlayersLabel: UILabel!
    
    var playerType: [Player] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NetworkManager.shared.delegate = self
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        statusView.layer.cornerRadius = statusView.frame.width / 2
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @IBAction func connectButtonClicked(_ sender: UIButton) {
        NetworkManager.shared.setupNetworkCommunication(host: hostTextField.text ?? "192.168.0.6", port: portTextField.text ?? "1338")
        NetworkManager.shared.joinChat()
    }
    
    @IBAction func startButtonClicked(_ sender: UIButton) {
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toGameVC" {
            if let destination = segue.destination as? GameViewController {
                destination.player = playerType[0]
            }
        }
    }

}

extension InitialViewController: NetworkManagerDelegate {
    func didReceiveMessage(message: String) {
        if message.contains("JOIN") {
            self.statusView.backgroundColor = UIColor(displayP3Red: 28/255, green: 254/255, blue: 186/255, alpha: 1)
            self.statusLabel.text = "Connected"
        }
        
        if message.contains("SELECT") {
            if message.contains("RED") {
                playerType.append(.RED)
            } else if message.contains("BLUE") {
                playerType.append(.BLUE)
            }
            self.connectButton.isEnabled = false
        }
        
        if message.contains("START") {
            self.activePlayersLabel.text = "Opponent found"
            startButton.isEnabled = true
        }
    }
    
    func didStopSession() {
        print("Session did stop")
    }
}
