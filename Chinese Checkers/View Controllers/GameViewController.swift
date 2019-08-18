//
//  GameViewController.swift
//  Chinese Checkers
//
//  Created by Thalys Viana on 10/08/19.
//  Copyright © 2019 Thalys Viana. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

enum Player: String {
    case BLUE = "BLUE"
    case RED = "RED"
    case NONE = "NONE"
}

class GameViewController: UIViewController {

    var currentGame: GameScene?
    
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var messageView: TextMessageField!
    @IBOutlet weak var winnerLabel: UILabel!
    
    fileprivate let cellId = "CellId"
    
    var chatMessages = [ChatMessage]()
    
    var requestFlag = false
    
    var player: Player!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
                
                currentGame = scene as? GameScene
                currentGame?.viewController = self
                currentGame?.player = player
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
        
        winnerLabel.isHidden = true
        
        let chatMessageCellNib = UINib(nibName: "ChatMessageCell", bundle: nil)
        
        chatTableView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        chatTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        chatTableView.register(chatMessageCellNib, forCellReuseIdentifier: "ChatMessageCell")
        
        messageView.delegate = self
        NetworkManager.shared.delegate = self
    }
    
    @IBAction func restartButtonClicked(_ sender: UIButton) {
        let alert = Alert.showAlert(title: "Restart", message: "Are you sure of this?") { result in
            if result {
                let data = "iam:\(self.player!),msg:>RESTART".data(using: .utf8)!
                NetworkManager.shared.send(data: data)
                self.requestFlag = true
                print("Yup, i want to restart the match!")
            } else {
                print("No, i don't want to restart the match!")
            }
        }
        present(alert, animated: true)
    }
    
    @IBAction func surrenderButtonClicked(_ sender: UIButton) {
        let alert = Alert.showAlert(title: "Surrender", message: "Are you sure of this?") { result in
            if result {
                let data = "iam:\(self.player!),msg:>SURRENDER".data(using: .utf8)!
                NetworkManager.shared.send(data: data)
                self.requestFlag = true
                print("Yup, i give up!")
            } else {
                print("No, i can win!")
            }
        }
        present(alert, animated: true)
    }
    
    func showWinnerLabel(winner: Player) {
        let playerStr: String
        switch winner {
        case .BLUE:
            playerStr = "Blue"
            winnerLabel.textColor = UIColor(displayP3Red: 35/255, green: 139/255, blue:255, alpha: 1)
            print("Blue wins!")
        case .RED:
            playerStr = "Red"
            winnerLabel.textColor = UIColor(displayP3Red: 254/255, green: 2/255, blue: 0, alpha: 1)
            print("Red wins!")
        case .NONE:
            playerStr = ""
            print("No winner")
        }
        winnerLabel.isHidden = false
        winnerLabel.text = "\(playerStr) wins!"
    }
    
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension GameViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChatMessageCell", for: indexPath) as? ChatMessageCell else {
            return ChatMessageCell()
        }
        
        let chatMessage = chatMessages[indexPath.row]
        cell.chatMessage = chatMessage
        
        return cell
    }
}

extension GameViewController: TextMessageFieldDelegate {
    func didClickSendButton(text: String) {
        let data = "iam:\(player!),msg:\(text)".data(using: .utf8)!
        
        if text == "QUIT" {
            NetworkManager.shared.stopChatSession()
        }
        NetworkManager.shared.send(data: data)
        messageView.textMessageView.text = ""
    }
}

extension GameViewController: NetworkManagerDelegate {
    func didReceiveMessage(message: String) {
        print(message)
        
        // Split the message into two fragmenoits
        // The first one says who the player is and the second one contains the message content
        // After this, check if message content is command by checking whether it contains '>' at beginning
        let isCommand = message.components(separatedBy: ":").last?.first == ">"
        
        if isCommand {
            guard let command = message.components(separatedBy: ">").last else {
                print("INVALID COMMAND")
                return
            }
            
            if command.contains("MOVE") {
                guard let positions = command
                    .components(separatedBy: " ").last?
                    .components(separatedBy: ";")
                    else {
                        return
                }
                
                let startPos = positions[0].components(separatedBy: "-")
                let endPos = positions[1].components(separatedBy: "-")
                
                let piece = currentGame?.getPieceAt(col: Int(startPos[0])!, row: Int(startPos[1])!)
                currentGame?.movePieceTo(piece: piece!, col: Int(endPos[0])!, row: Int(endPos[1])!)
            } else if command.contains("SURRENDER") {
                print("YOU WON!")
                if player == .BLUE {
                    showWinnerLabel(winner: .RED)
                } else {
                    showWinnerLabel(winner: .BLUE)
                }
            } else if command.contains("RESTART") {
                if !requestFlag {
                    let alert = Alert.showAlert(title: "Restart", message: "Opponent has requested to restart the match") { [unowned self] result in
                        if result {
                            let data = "iam:\(self.player!),msg:>ACCEPT".data(using: .utf8)!
                            NetworkManager.shared.send(data: data)
                            self.currentGame?.restartGame()
                            print("Yup, i want to restart the match!")
                        } else {
                            let data = "iam:\(self.player!),msg:>DECLINE".data(using: .utf8)!
                            NetworkManager.shared.send(data: data)
                            print("No, i don't want to restart the match!")
                        }
                    }
                    present(alert, animated: true)
                }
            } else if command.contains("ACCEPT") {
                if requestFlag {
                    currentGame?.restartGame()
                    requestFlag = false
                }
            } else if command.contains("DECLINE") {
                if requestFlag {
                    let alert = Alert.showAlert(title: "REQUEST DECLINED", message: "Opponent refused to restart the match")
                    present(alert, animated: true)
                    requestFlag = false
                }
            } else if command.contains("WINNER") {
                let winner = command.components(separatedBy: "/")[1]
                if winner == "RED" {
                    showWinnerLabel(winner: .RED)
                } else if winner == "BLUE" {
                    showWinnerLabel(winner: .BLUE)
                }
            }
        } else {
            let chatMessage = ChatMessage(text: message, isComing: true)
            chatMessages.append(chatMessage)
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.chatTableView.reloadData()
        }
    }
    
    func didStopSession() {
        print("Session has stopped")
    }
}
