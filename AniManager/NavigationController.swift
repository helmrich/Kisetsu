//
//  NavigationController.swift
//  AniManager
//
//  Created by Tobias Helmrich on 22.11.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.titleTextAttributes = [
            NSFontAttributeName: UIFont(name: Constant.FontName.logo, size: 24),
            NSForegroundColorAttributeName: UIColor.white
        ]
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
}
