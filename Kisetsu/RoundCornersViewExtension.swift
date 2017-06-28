//
//  RoundCornersViewExtension.swift
//  Kisetsu
//
//  Created by Tobias Helmrich on 26.06.17.
//  Copyright © 2017 Tobias Helmrich. All rights reserved.
//

import UIKit

extension UIView {
    func round(corners: UIRectCorner, withRadius radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        layer.mask = maskLayer
    }
}
