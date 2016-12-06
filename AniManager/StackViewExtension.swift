//
//  StackViewExtension.swift
//  AniManager
//
//  Created by Tobias Helmrich on 05.12.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

extension UIStackView {
    static func createStackView(fromArrangedSubviews arrangedSubviews: [UIView], withAxis axis: UILayoutConstraintAxis, andSpacing spacing: CGFloat) -> UIStackView {
        let statusStackView = UIStackView(arrangedSubviews: arrangedSubviews)
        statusStackView.axis = axis
        statusStackView.spacing = spacing
        return statusStackView
    }
}
