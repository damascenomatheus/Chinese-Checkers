//
//  ChatMessageCell.swift
//  Chinese Checkers
//
//  Created by Thalys Viana on 12/08/19.
//  Copyright © 2019 Thalys Viana. All rights reserved.
//

import UIKit

class ChatMessageCell: UITableViewCell {

    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var bubbleBackgroundView: UIView!
    
    @IBOutlet var messageLabelTrailingConstraint: NSLayoutConstraint!
    @IBOutlet var messageLabelLeadingConstraint: NSLayoutConstraint!
    
    var chatMessage: ChatMessage! {
        didSet {
            bubbleBackgroundView.backgroundColor = chatMessage.isComing ? .white : .darkGray
            messageLabel.textColor = chatMessage.isComing ? .black : .white
            messageLabel.text = chatMessage.text
            
            if chatMessage.isComing {
                messageLabelLeadingConstraint.isActive = true
                messageLabelTrailingConstraint.isActive = false
            } else {
                messageLabelTrailingConstraint.isActive = true
                messageLabelLeadingConstraint.isActive = false
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backgroundColor = .clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
