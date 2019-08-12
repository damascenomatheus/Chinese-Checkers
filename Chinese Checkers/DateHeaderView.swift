//
//  DateHeaderView.swift
//  Chinese Checkers
//
//  Created by Thalys Viana on 12/08/19.
//  Copyright © 2019 Thalys Viana. All rights reserved.
//

import UIKit

class DateHeaderView: UIView {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dateBackgroundView: UIView!
    
    override var intrinsicContentSize: CGSize {
        let originalContentSize = super.intrinsicContentSize
        let height = originalContentSize.height + 12
        return CGSize(width: originalContentSize.width + 16, height: height)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor(white: 0.95, alpha: 1)
        dateLabel.font = UIFont.boldSystemFont(ofSize: 16)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        dateBackgroundView.layer.cornerRadius = dateBackgroundView.frame.height / 2
    }
}
