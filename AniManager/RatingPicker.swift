//
//  RatingPicker.swift
//  AniManager
//
//  Created by Tobias Helmrich on 16.12.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

class RatingPicker: UIView {
    
    // MARK: - Properties
    
    let pickerView = UIPickerView()
    let dismissToolbarButton = UIBarButtonItem(image: #imageLiteral(resourceName: "CancelCross"), style: .plain, target: nil, action: nil)
    let submitToolbarButton = UIBarButtonItem(title: "Submit", style: .done, target: nil, action: nil)

    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        let toolbar = UIToolbar()
        toolbar.barTintColor = .aniManagerBlue
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        
        // Set the toolbar's bar button items' color
        dismissToolbarButton.tintColor = .white
        submitToolbarButton.tintColor = .white
        
        // Set the toolbar's items and include a flexible space
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([dismissToolbarButton, flexibleSpace, submitToolbarButton], animated: false)
        
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add the toolbar and picker view as subviews to the RatingPicker view
        addSubview(toolbar)
        addSubview(pickerView)
        
        // Set the constraints
        addConstraints([
            NSLayoutConstraint(item: toolbar, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 44.0),
            NSLayoutConstraint(item: toolbar, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: toolbar, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: toolbar, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0.0),
            
            NSLayoutConstraint(item: pickerView, attribute: .top, relatedBy: .equal, toItem: toolbar, attribute: .bottom, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: pickerView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: pickerView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: pickerView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0.0),
            ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
