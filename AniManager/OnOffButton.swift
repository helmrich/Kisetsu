//
//  OnOffButton.swift
//  AniManager
//
//  Created by Tobias Helmrich on 28.11.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

class OnOffButton: UIButton {

    var isOn: Bool = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
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
    
    func toggle() {
        if isOn {
            backgroundColor = .white
            layer.borderColor = UIColor.aniManagerBlue.cgColor
            layer.borderWidth = 1
            setTitleColor(.aniManagerBlue, for: .normal)
            isOn = false
        } else {
            backgroundColor = .aniManagerBlue
            layer.borderWidth = 0
            setTitleColor(.white, for: .normal)
            isOn = true
        }
    }

}
