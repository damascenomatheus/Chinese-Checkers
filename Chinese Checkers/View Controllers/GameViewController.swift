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

enum PlayerType: String {
    case BLUE = "BLUE"
    case RED = "RED"
    case NONE = "NONE"
}

typealias Movement = (col: Int, row: Int)

class GameViewController: UIViewController {
    
    var currentGame: GameScene?
    
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var messageView: TextMessageField!
    @IBOutlet weak var winnerLabel: UILabel!
    @IBOutlet weak var turnLabel: UILabel!
    @IBOutlet weak var messagesNavigationBar: UINavigationBar!
    
    fileprivate let cellId = "CellId"
    
    var chatMessages = [ChatMessage]() {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.chatTableView.reloadData()
            }
        }
    }
    
    var requestFlag = false
    
    var player: PlayerType = Server.shared.player
    
    var playerTurn: PlayerType = .RED
    
    var previousMoves: [[Movement]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                currentGame = scene as? GameScene
                currentGame?.viewController = self
                currentGame?.player = player
                Server.shared.setProviderController(controller: self)
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
        
        setupViews()
    }
    
    private func setupViews() {
        winnerLabel.isHidden = true
        
        let chatMessageCellNib = UINib(nibName: "ChatMessageCell", bundle: nil)
        
        chatTableView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        chatTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        chatTableView.register(chatMessageCellNib, forCellReuseIdentifier: "ChatMessageCell")
        chatTableView.backgroundColor = .darkGray
        
        messagesNavigationBar.barTintColor = UIColor(displayP3Red: 50/255, green: 51/255, blue: 50/255, alpha: 0.7)
        messagesNavigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        messageView.delegate = self
        
        changeTurnLabel(isFirstMove: true)
    }
    
    @IBAction func restartButtonClicked(_ sender: UIButton) {
        let alert = Alert.showAlert(title: "Restart", message: "Are you sure of this?") { result in
            // Restart button clicked
            if result {
                Client.shared.requestToRestart()
            }
        }
        present(alert, animated: true)
    }
    
    @IBAction func redoButtonClicked(_ sender: UIButton) {
        guard previousMoves.count > 0, let lastMove = previousMoves.last else {
            return
        }
        
        let previousMove = (col: Int(lastMove[0].col), row: Int(lastMove[0].row))
        let currentMove = (col: Int(lastMove[1].col), row: Int(lastMove[1].row))
        let piece = currentGame?.getPieceAt(col: previousMove.col, row: previousMove.row)
        
        currentGame?.movePieceTo(piece: piece!, col: currentMove.col, row: currentMove.row)
        Client.shared.movePiece(previousMove: previousMove, currentMove: currentMove)
        
        changeTurnLabel(isFirstMove: false)
        Client.shared.changeTurn()
    }
    
    @IBAction func surrenderButtonClicked(_ sender: UIButton) {
        let alert = Alert.showAlert(title: "Surrender", message: "Are you sure of this?") { [weak self] result in
            if result {
                let winner = self?.player == .BLUE ? PlayerType.RED : PlayerType.BLUE
                self?.showWinnerLabel(winner: winner)
                Client.shared.surrender(winner: winner)
            } else {
                print("No, i can win!")
            }
        }
        present(alert, animated: true)
    }
    
    @IBAction func quitButtonClicked(_ sender: UIButton) {
        Server.shared.stop()
        Client.shared.stop()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "InitialViewController") as! InitialViewController
        present(vc, animated: true, completion: nil)
    }
    
    func showWinnerLabel(winner: PlayerType) {
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
    
    func showReceivedRestartMessage() {
        let alert = Alert.showAlert(title: "Restart", message: "Opponent has requested to restart the match") { [unowned self] result in
            if result == true {
                self.currentGame?.restartGame()
            }
            Client.shared.responseToRestart(value: result)
        }
        present(alert, animated: true)
    }
    
    func changeTurnLabel(isFirstMove: Bool) {
        if !isFirstMove {
            playerTurn = playerTurn == .RED ? .BLUE : .RED
        }
        if playerTurn == .RED {
            currentGame?.playerTurn = .RED
            turnLabel.text = currentGame?.player == playerTurn ? "Your turn" : "Red turn"
            turnLabel.textColor = UIColor(displayP3Red: 254/255, green: 2/255, blue: 0, alpha: 1)
        } else if playerTurn == .BLUE {
            currentGame?.playerTurn = .BLUE
            turnLabel.text = currentGame?.player == playerTurn ? "Your turn" : "Blue turn"
            turnLabel.textColor = UIColor(displayP3Red: 35/255, green: 139/255, blue:255, alpha: 1)
        }
    }
    
    func showWinnerBy(command: String) {
        let winner = command.components(separatedBy: "/")[1]
        if winner == "RED" {
            showWinnerLabel(winner: .RED)
        } else if winner == "BLUE" {
            showWinnerLabel(winner: .BLUE)
        }
    }
    
    func showDeclineAlert() {
        let alert = Alert.showAlert(title: "REQUEST DECLINED", message: "Opponent refused to restart the match")
        present(alert, animated: true)
    }
    
    func addReceivedMessage(message: String) {
        var isComing = true
        var playertype = player == .RED ? PlayerType.BLUE : .RED
        if message.contains("\(player):") {
            isComing = false
            playertype = player
        }
        
        let messageContent = message.components(separatedBy: ":")[1]
        let chatMessage = ChatMessage(content: messageContent, owner: playertype, isComing: isComing)
        chatMessages.append(chatMessage)
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
        cell.messageLabel.textColor = .white
        
        if chatMessage.owner == .RED {
            cell.bubbleBackgroundView.backgroundColor = UIColor(displayP3Red: 135/255, green: 35/255, blue: 29/255, alpha: 0.8)
        } else if chatMessage.owner == .BLUE {
            cell.bubbleBackgroundView.backgroundColor = UIColor(displayP3Red: 27/255, green: 51/255, blue: 181/255, alpha: 0.8)
        }
        
        return cell
    }
}

extension GameViewController: TextMessageFieldDelegate {
    func didClickSendButton(text: String) {
        let message = ChatMessage(content: text, owner: player, isComing: false)
        chatMessages.append(message)
        Client.shared.sendMessage(content: text, owner: player)
        messageView.textMessageView.text = ""
    }
}
