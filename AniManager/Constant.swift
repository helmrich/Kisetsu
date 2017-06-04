//
//  Constant.swift
//  AniManager
//
//  Created by Tobias Helmrich on 19.11.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import Foundation

struct Constant {
    struct URL {
        static let aniListSignUpString = "https://anilist.co/register"
        static let aniListForgotPasswordURLString = "https://anilist.co/forgot"
        static let aniListForumRecentURLString = "https://anilist.co/forum/recent"
    }
    
    struct FontName {
        static let mainLight = "Lato-Light"
        static let mainRegular = "Lato-Regular"
        static let mainBold = "Lato-Bold"
        static let mainBlack = "Lato-Black"
        
        static let logo = "CarterOne"
    }
    
    struct NotificationKey {
        static let settingValueChanged = "settingValueChanged"
    }
}
