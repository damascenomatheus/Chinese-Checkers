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

class GameViewController: UIViewController {

    var currentGame: GameScene?
    
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var messageView: TextMessageField!
    
    fileprivate let cellId = "CellId"
    
    var chatMessages = [ChatMessage]()
    
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
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
        
        chatTableView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        
        chatTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        let chatMessageCellNib = UINib(nibName: "ChatMessageCell", bundle: nil)
        chatTableView.register(chatMessageCellNib, forCellReuseIdentifier: "ChatMessageCell")
        
        messageView.delegate = self
        NetworkManager.shared.delegate = self
        
        // Join Chat
        
        NetworkManager.shared.joinChat()
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
        let data = "iam:RED,msg:\(text)".data(using: .utf8)!
        NetworkManager.shared.send(data: data)
        messageView.textMessageView.text = ""
    }
}

extension GameViewController: NetworkManagerDelegate {
    func didReceiveMessage(message: String) {
        print(message)
        let chatMessage = ChatMessage(text: message, isComing: true)
        chatMessages.append(chatMessage)
        
        // Split the message into two fragments
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
            }
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.chatTableView.reloadData()
        }
    }
    
    func didStopSession() {
        print("Session has stopped")
    }
}
