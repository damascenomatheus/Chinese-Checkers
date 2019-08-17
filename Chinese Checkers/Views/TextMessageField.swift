//
//  TextMessageField.swift
//  Chinese Checkers
//
//  Created by Thalys Viana on 12/08/19.
//  Copyright © 2019 Thalys Viana. All rights reserved.
//

import UIKit

protocol TextMessageFieldDelegate: class {
    func didClickSendButton(text: String)
}

class TextMessageField: UIView {
    
    let nibName = "TextMessageField"
    
    @IBOutlet weak var textMessageView: UITextView!
    weak var delegate: TextMessageFieldDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = UIColor(white: 0.90, alpha: 1)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let xibView = Bundle.main.loadNibNamed(nibName, owner: self, options: nil)!.first as! UIView
        xibView.frame = self.bounds
        xibView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(xibView)
    }
    
    @IBAction func sendButtonClicked(_ sender: UIButton) {
        self.delegate?.didClickSendButton(text: textMessageView.text ?? "No message")
    }
    
}
