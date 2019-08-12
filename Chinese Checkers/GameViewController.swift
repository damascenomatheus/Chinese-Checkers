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
    
    fileprivate let cellId = "CellId"
    
    let chatMessages = [
        [
            ChatMessage(text: "Lorem ipsum dolor sit amet", isComing: true, date: Date()),
            ChatMessage(text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit", isComing: true, date: Date.dateFromCustomString(customString: "01/04/2019")),
        ],
        [
            ChatMessage(text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce at laoreet ex, et malesuada enim. Vestibulum porttitor magna lacus", isComing: true, date: Date.dateFromCustomString(customString: "15/05/2019")),
            ChatMessage(text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce at laoreet ex, et malesuada enim. Vestibulum porttitor magna lacus. Quisque et ultrices arcu.", isComing: false, date: Date.dateFromCustomString(customString: "02/06/2019"))
        ],
        [
            ChatMessage(text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce at laoreet ex, et malesuada enim. Vestibulum porttitor magna lacus. Quisque et ultrices arcu. Maecenas eget ipsum aliquet, imperdiet nibh at, porttitor sapien.", isComing: true, date: Date.dateFromCustomString(customString: "12/07/2019"))
        ]
    ]
    
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return chatMessages.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatMessages[section].count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let dateHeaderView = Bundle.main.loadNibNamed("DateHeaderView", owner: self, options: nil)?.first as! DateHeaderView
        dateHeaderView.dateLabel.text = Date.customStringFromDate(date: chatMessages[section].first?.date ?? Date())
        return dateHeaderView
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let firstMessageInSection = chatMessages[section].first {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            let dateString = dateFormatter.string(from: firstMessageInSection.date)
            return dateString
        }
        return "\(Date())"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChatMessageCell", for: indexPath) as? ChatMessageCell else {
            return ChatMessageCell()
        }
        
        let chatMessage = chatMessages[indexPath.section][indexPath.row]
        cell.chatMessage = chatMessage
        
        return cell
    }
    
    
}
