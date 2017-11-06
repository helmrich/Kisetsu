//
//  Style.swift
//  AniManager
//
//  Created by Tobias Helmrich on 04.06.17.
//  Copyright © 2017 Tobias Helmrich. All rights reserved.
//

import Foundation
import UIKit

struct Style {
    static var activeTheme: Theme {
        if let themeUserDefaultsString = UserDefaults.standard.string(forKey: UserDefaultsKey.theme.rawValue),
            let theme = Theme(rawValue: themeUserDefaultsString) {
            return theme
        } else {
            return .light
        }
    }
    
    struct Color {
        struct Background {
            static var mainView: UIColor {
                if activeTheme == .light { return .white } else { return  .aniManagerBlack }
            }
            static var collectionView: UIColor {
                if activeTheme == .light { return .white } else { return .aniManagerBlack }
            }
            static var imagesCollectionView: UIColor {
                if activeTheme == .light { return .aniManagerGray } else { return .aniManagerBlackAlternative }
            }
            static var episodesCollectionView: UIColor {
                if activeTheme == .light { return .aniManagerGray } else { return .aniManagerBlack }
            }
            static var collectionViewCell: UIColor {
                if activeTheme == .light { return .aniManagerBlack } else { return .aniManagerBlackAlternative }
            }
            static var tableView: UIColor {
                if activeTheme == .light { return .white } else { return .aniManagerBlack }
            }
            static var settingsTableView: UIColor {
                if activeTheme == .light { return .aniManagerGray } else { return .aniManagerBlackAlternative }
            }
            static var tableViewCell: UIColor {
                if activeTheme == .light { return .white } else { return  .aniManagerBlack }
            }
            static var tableViewCellSelected: UIColor {
                if activeTheme == .light { return .aniManagerBlueAlternative } else { return .aniManagerBlackAlternative }
            }
            static var searchBar: UIColor {
                if activeTheme == .light { return .aniManagerBlueAlternative } else { return .aniManagerBlackAlternative }
            }
            static var imagesTableViewCell: UIColor {
                if activeTheme == .light { return .white } else { return .aniManagerBlack }
            }
            static var imagesCollectionViewCell: UIColor {
                if activeTheme == .light { return .aniManagerGray } else { return .aniManagerBlack }
            }
            static var imagesTableViewCellTitleLabel: UIColor {
                if activeTheme == .light { return .aniManagerBlack } else { return .white }
            }
            static var episodeCollectionViewCell: UIColor {
                if activeTheme == .light { return .white } else { return .aniManagerBlackAlternative }
            }
            static var episodeCollectionViewCellPreviewImage: UIColor {
                if activeTheme == .light { return .aniManagerBlack } else { return .aniManagerBlackAlternative }
            }
            static var browseFilterTableViewSectionHeader: UIColor {
                if activeTheme == .light { return .aniManagerBlue } else { return .aniManagerBlackAlternative }
            }
            static var onOffButtonActive: UIColor {
                if activeTheme == .light { return .aniManagerBlue } else { return .white }
            }
            static var onOffButtonInactive: UIColor {
                if activeTheme == .light { return .white } else { return .aniManagerBlack }
            }
            static var aniManagerButton: UIColor {
                if activeTheme == .light { return .aniManagerBlue } else { return .white }
            }
            static var genreLabel: UIColor {
                if activeTheme == .light { return .aniManagerBlack } else { return .white }
            }
            static var ratingPicker: UIColor {
                if activeTheme == .light { return .white } else { return .aniManagerBlack }
            }
            static var featuredSlider: UIColor {
                if activeTheme == .light { return .aniManagerBlack } else { return .aniManagerBlackAlternative }
            }
            static var textView: UIColor {
                if activeTheme == .light { return .white } else { return .aniManagerBlack }
            }
            static var textField: UIColor {
                if activeTheme == .light { return .white } else { return .aniManagerBlack }
            }
            static var videoWebView: UIColor {
                if activeTheme == .light { return .aniManagerGray } else { return .aniManagerBlackAlternative }
            }
            static var requiredLogin: UIColor {
                if activeTheme == .light { return .aniManagerBlue } else { return .aniManagerBlack }
            }
            static var imagePlaceholder: UIColor {
                if activeTheme == .light { return .aniManagerGray } else { return .aniManagerBlackAlternative }
            }
            static var seriesCollectionImageView: UIColor {
                if activeTheme == .light { return .aniManagerGray } else { return .aniManagerGray }
            }
        }
        
        struct BarTint {
            static var navigationBar: UIColor {
                if activeTheme == .light { return .aniManagerBlue } else { return .aniManagerBlack }
            }
            static var searchBar: UIColor {
                if activeTheme == .light { return .aniManagerBlue } else { return .aniManagerBlack }
            }
            static var toolbar: UIColor {
                if activeTheme == .light { return .aniManagerBlue } else { return .aniManagerBlack }
            }
            static var browseFilterToolbar: UIColor {
                if activeTheme == .light { return .aniManagerBlue } else { return .aniManagerBlackAlternative }
            }
        }
        
        struct Text {
            static var aniManagerLabel: UIColor {
                if activeTheme == .light { return .aniManagerBlack } else { return .white }
            }
            static var aniManagerButton: UIColor {
                if activeTheme == .light { return .white } else { return .aniManagerBlack }
            }
            static var requiredLoginButton: UIColor {
                if activeTheme == .light { return .aniManagerBlue } else { return .aniManagerBlack }
            }
            static var tableViewSectionHeaderTitle: UIColor {
                if activeTheme == .light { return .aniManagerBlack } else { return .white }
            }
            static var cellTitle: UIColor {
                if activeTheme == .light { return .aniManagerBlack } else { return .white }
            }
            static var tableViewCell: UIColor {
                if activeTheme == .light { return .aniManagerBlack } else { return .white }
            }
            static var tableViewCellSelected: UIColor {
                if activeTheme == .light { return .white } else { return .white }
            }
            static var episodeCollectionViewCell: UIColor {
                if activeTheme == .light { return .aniManagerBlack } else { return .white }
            }
            static var pickerView: UIColor {
                if activeTheme == .light { return .aniManagerBlack } else { return .white }
            }
            static var genreLabel: UIColor {
                if activeTheme == .light { return .white } else { return .aniManagerBlack }
            }
            static var informationsLabel: UIColor {
                if activeTheme == .light { return .aniManagerBlack } else { return .white }
            }
            static var progressLabel: UIColor {
                if activeTheme == .light { return .aniManagerBlack } else { return .white }
            }
            static var textView: UIColor {
                if activeTheme == .light { return .aniManagerBlack } else { return .white }
            }
            static var textField: UIColor {
                if activeTheme == .light { return .aniManagerBlack } else { return .white }
            }
            static var onOffButtonTitleActive: UIColor {
                if activeTheme == .light { return .white } else { return .aniManagerBlack }
            }
            static var onOffButtonTitleInactive: UIColor {
                if activeTheme == .light { return .aniManagerBlue } else { return .white }
            }
        }
        
        struct Shadow {
            static var episodeCell: UIColor {
                if activeTheme == .light { return .aniManagerBlack } else { return .white }
            }
        }
    }
    
    struct Image {
        static var progressPlusIcon: UIImage {
            if activeTheme == .light { return #imageLiteral(resourceName: "PlusIcon") } else { return #imageLiteral(resourceName: "PlusIconWhite") }
        }
        static var progressPlusIconSmall: UIImage {
            if activeTheme == .light { return #imageLiteral(resourceName: "PlusIconSmall") } else { return #imageLiteral(resourceName: "PlusIconSmallWhite") }
        }
        static var progressMinusIcon: UIImage {
            if activeTheme == .light { return #imageLiteral(resourceName: "MinusIcon") } else { return #imageLiteral(resourceName: "MinusIconWhite") }
        }
        static var progressMinusIconSmall: UIImage {
            if activeTheme == .light { return #imageLiteral(resourceName: "MinusIconSmall") } else { return #imageLiteral(resourceName: "MinusIconSmallWhite") }
        }
    }
    
    struct ActivityIndicatorView {
        static var lightDark: UIActivityIndicatorViewStyle {
            if activeTheme == .light { return .gray } else { return .white }
        }
    }
    
    enum Theme: String {
        case light, dark
    }
}
