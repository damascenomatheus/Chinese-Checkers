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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NetworkManager.shared.delegate = self
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @IBAction func blueColorSelected(_ sender: UIButton) {
        
    }
    
    @IBAction func redColorSelected(_ sender: UIButton) {
        
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
            
            }
        }
    }

}

extension InitialViewController: NetworkManagerDelegate {
    func didReceiveMessage(message: String) {
        if message.contains(">JOIN") {
            statusView.backgroundColor = .green
            statusLabel.text = "Connected"
            connectButton.isEnabled = false
            startButton.isEnabled = true
        }
    }
    
    func didStopSession() {
        print("Session did stop")
    }
}
