//
//  AniManagerTextField.swift
//  AniManager
//
//  Created by Tobias Helmrich on 18.11.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

class AniManagerTextField: UITextField {

    // Add a left padding to text inside of text fields
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.minX + 20, y: bounds.origin.y, width: bounds.width, height: bounds.height)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.minX + 20, y: bounds.origin.y, width: bounds.width, height: bounds.height)
    }
    
}
