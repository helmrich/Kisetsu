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
                backgroundColor = Style.Color.Background.onOffButtonActive
                layer.borderWidth = 0
                setTitleColor(Style.Color.Text.onOffButtonTitleActive, for: .normal)
            } else {
                backgroundColor = Style.Color.Background.onOffButtonInactive
                layer.borderColor = Style.Color.Background.onOffButtonActive.cgColor
                layer.borderWidth = 1
                setTitleColor(Style.Color.Text.onOffButtonTitleInactive, for: .normal)
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
