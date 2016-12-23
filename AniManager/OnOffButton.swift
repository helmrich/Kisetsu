//
//  OnOffButton.swift
//  AniManager
//
//  Created by Tobias Helmrich on 28.11.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

class OnOffButton: UIButton {

    /*
        Inside the didSet property observer the button's
        appearance is changed depending on the isOn property's
        value
     */
    var isOn: Bool = false {
        didSet {
            if isOn {
                backgroundColor = .aniManagerBlue
                layer.borderWidth = 0
                setTitleColor(.white, for: .normal)
            } else {
                backgroundColor = .white
                layer.borderColor = UIColor.aniManagerBlue.cgColor
                layer.borderWidth = 1
                setTitleColor(.aniManagerBlue, for: .normal)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    /*
        This method toggles an on-off button's boolean isOn
        property's value
     */
    func toggle() {
        if isOn {
            isOn = false
        } else {
            isOn = true
        }
    }

}
