//
//  InitialViewController.swift
//  Chinese Checkers
//
//  Created by Thalys Viana on 17/08/19.
//  Copyright © 2019 Thalys Viana. All rights reserved.
//

import UIKit
import SwiftGRPC

class InitialViewController: UIViewController {

    
    @IBOutlet weak var hostPortTextField: UITextField!
    @IBOutlet weak var clientAddressTextField: UITextField!
    @IBOutlet weak var clientPortTextField: UITextField!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var activePlayersLabel: UILabel!
    
    var playerType: [PlayerType] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        statusView.layer.cornerRadius = statusView.frame.width / 2
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @IBAction func connectButtonClicked(_ sender: UIButton) {
        Server.shared
            .setPort(hostPortTextField.text!)
            .start()
        startButton.isEnabled = true
    }
    
    @IBAction func startButtonClicked(_ sender: UIButton) {
        Client.shared.connect(address: clientAddressTextField.text ?? "127.0.0.1", port: clientPortTextField.text!)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toGameVC" {
            if let destination = segue.destination as? GameViewController {
                destination.player = .RED
            }
        }
    }

}
