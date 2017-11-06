//
//  PersonDetailViewController.swift
//  AniManager
//
//  Created by Tobias Helmrich on 07.12.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

class PersonDetailViewController: UIViewController {

    // MARK: - Properties
    
    let errorMessageView = ErrorMessageView()
    var character: Character?
    var staff: Staff?
    
    var bannerImageURL: URL?
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    // MARK: - Outlets and Actions
    
    // MARK: - Outlets
    
    @IBOutlet weak var characterImageView: UIImageView!
    @IBOutlet weak var bannerView: UIView!
    @IBOutlet weak var bannerImageView: UIImageView!
    @IBOutlet weak var nameStackView: UIStackView!
    @IBOutlet weak fileprivate var characterNameLabel: UILabel!
    @IBOutlet weak fileprivate var characterJapaneseNameLabel: UILabel!
    @IBOutlet weak fileprivate var infoTextView: UITextView!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    
    
    // MARK: - Actions
    
    @IBAction func dismiss(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func favorite(_ sender: Any) {
        
        NetworkActivityManager.shared.increaseNumberOfActiveConnections()
        
        let id: Int
        let personType: PersonType
        
        if let character = character {
            id = character.id
            personType = .character
        } else if let staff = staff {
            id = staff.id
            personType = .staff
        } else {
            NetworkActivityManager.shared.decreaseNumberOfActiveConnections()
            return
        }
        
        AniListClient.shared.favorite(personType: personType, withID: id) { (errorMessage) in
            guard errorMessage == nil else {
                self.errorMessageView.showAndHide(withMessage: errorMessage!)
                NetworkActivityManager.shared.decreaseNumberOfActiveConnections()
                return
            }
            
            DispatchQueue.main.async {
                if self.favoriteButton.image(for: .normal) == #imageLiteral(resourceName: "HeartIconActive") {
                    self.favoriteButton.setImage(#imageLiteral(resourceName: "HeartIcon"), for: .normal)
                } else {
                    self.favoriteButton.setImage(#imageLiteral(resourceName: "HeartIconActive"), for: .normal)
                }
            }
            NetworkActivityManager.shared.decreaseNumberOfActiveConnections()
        }
    }
    
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        
        errorMessageView.addToBottom(of: view)
        
        setupInterfaceForCurrentTheme()
        
        nameStackView.alpha = 0.0
        infoTextView.alpha = 0.0
        
        // Banner Configuration
        favoriteButton.alpha = 0
        bannerView.backgroundColor = .aniManagerBlack
        bannerView.alpha = 0.85
        bannerImageView.contentMode = .scaleAspectFill
        if let bannerImageURL = bannerImageURL {
            NetworkActivityManager.shared.increaseNumberOfActiveConnections()
            bannerImageView.kf.setImage(with: bannerImageURL, placeholder: UIImage.with(color: .aniManagerGray, andSize: bannerView.bounds.size), options: [.transition(.fade(0.25))], progressBlock: nil) { (_, _, _, _) in
                NetworkActivityManager.shared.decreaseNumberOfActiveConnections()
            }
        } else {
            bannerView.backgroundColor = .aniManagerBlackAlternative
            bannerView.alpha = 1.0
        }
        
        characterImageView.layer.cornerRadius = 2.0
        
        infoTextView.textContainerInset = UIEdgeInsets(top: 20.0, left: 15.0, bottom: 20.0, right: 15.0)
        infoTextView.layer.cornerRadius = 2.0
        
        NetworkActivityManager.shared.increaseNumberOfActiveConnections()
        
        if let character = character {
            
            characterNameLabel.text = character.fullName
            
            AniListClient.shared.getCharacterPageModel(forCharacterID: character.id) { (pageModelCharacter, errorMessage) in
                guard errorMessage == nil else {
                    self.errorMessageView.showAndHide(withMessage: errorMessage!)
                    NetworkActivityManager.shared.decreaseNumberOfActiveConnections()
                    return
                }
                
                guard let pageModelCharacter = pageModelCharacter else {
                    self.errorMessageView.showAndHide(withMessage: "Couldn't get character page model")
                    NetworkActivityManager.shared.decreaseNumberOfActiveConnections()
                    return
                }
                
                self.setupJapaneseNameLabel(forJapaneseName: pageModelCharacter.japaneseName)
                
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.25) {
                        self.nameStackView.alpha = 1.0
                    }
                }
                
                if UserDefaults.standard.bool(forKey: UserDefaultsKey.showBioWithSpoilers.rawValue) == true {
                    self.setupInfoTextView(withInfoText: pageModelCharacter.info?.replacingOccurrences(of: "~!", with: "").replacingOccurrences(of: "!~", with: ""))
                } else {
                    self.setupInfoTextView(withInfoText: pageModelCharacter.spoilerFreeInfo)
                }
                
                if let isFavorite = pageModelCharacter.isFavorite {
                    DispatchQueue.main.async {
                        if isFavorite {
                            self.favoriteButton.setImage(#imageLiteral(resourceName: "HeartIconActive"), for: .normal)
                        } else {
                            self.favoriteButton.setImage(#imageLiteral(resourceName: "HeartIcon"), for: .normal)
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.25) {
                        self.favoriteButton.alpha = 1.0
                    }
                }
                
                NetworkActivityManager.shared.decreaseNumberOfActiveConnections()
                
            }
            
            NetworkActivityManager.shared.increaseNumberOfActiveConnections()
            
            setupImageView(forImageWithURLString: character.imageLargeURLString)
        } else if let staff = staff {
            characterNameLabel.text = staff.fullName
            
            AniListClient.shared.getStaffPageModel(forStaffWithID: staff.id) { (pageModelStaff, errorMessage) in
                guard errorMessage == nil else {
                    self.errorMessageView.showAndHide(withMessage: errorMessage!)
                    NetworkActivityManager.shared.decreaseNumberOfActiveConnections()
                    return
                }
                
                guard let pageModelStaff = pageModelStaff else {
                    self.errorMessageView.showAndHide(withMessage: "Couldn't get actor page model")
                    NetworkActivityManager.shared.decreaseNumberOfActiveConnections()
                    return
                }
                
                self.setupJapaneseNameLabel(forJapaneseName: pageModelStaff.fullNameJapanese)
                
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.25) {
                        self.nameStackView.alpha = 1.0
                    }
                }
                
                self.setupInfoTextView(withInfoText: pageModelStaff.info)
                
                if let isFavorite = pageModelStaff.isFavorite {
                    DispatchQueue.main.async {
                        if isFavorite {
                            self.favoriteButton.setImage(#imageLiteral(resourceName: "HeartIconActive"), for: .normal)
                        } else {
                            self.favoriteButton.setImage(#imageLiteral(resourceName: "HeartIcon"), for: .normal)
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.25) {
                        self.favoriteButton.alpha = 1.0
                    }
                }
                
                NetworkActivityManager.shared.decreaseNumberOfActiveConnections()
            }
            
            NetworkActivityManager.shared.increaseNumberOfActiveConnections()
            self.setupImageView(forImageWithURLString: staff.imageLargeURLString)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NetworkActivityManager.shared.numberOfActiveConnections = 0
    }
    
    
    // MARK: - Functions
    
    func setupInterfaceForCurrentTheme() {
        view.backgroundColor = Style.Color.Background.mainView
        infoTextView.backgroundColor = Style.Color.Background.textView
        infoTextView.textColor = Style.Color.Text.textView
    }
    
    func setupInfoTextView(withInfoText info: String?) {
        if let info = info {
            DispatchQueue.main.async {
                /*
                     Check if the info text parameter has content or not, if it has
                     create an attributed string with the "Biography" heading and
                     the info text. If not, display a message that indicates this
                 */
                if info.characters.count > 0 {
                    let headingAttributedString = NSMutableAttributedString(
                        string: "Biography\n\n",
                        attributes: [
                            NSFontAttributeName: UIFont(name: Constant.FontName.mainBlack, size: 24.0)!,
                            NSForegroundColorAttributeName: Style.Color.Text.textView
                        ])
                    
                    let infoAttributedString = NSMutableAttributedString(
                        string: info,
                        attributes: [
                            NSFontAttributeName: UIFont(name: Constant.FontName.mainRegular, size: 16.0)!,
                            NSForegroundColorAttributeName: Style.Color.Text.textView
                        ])
                    
                    // Make text between two pairs of underscores bold
                    let underscoreMarkdownRegularExpression = try! NSRegularExpression(pattern: "(__|<b>).*?(__|</b>)", options: [])
                    let matches = underscoreMarkdownRegularExpression.matches(in: info, options: [], range: NSRange(location: 0, length: info.characters.count))
                    matches.forEach {
                        let matchRange = $0.range
                        infoAttributedString.addAttribute(
                            NSFontAttributeName,
                            value: UIFont(name: Constant.FontName.mainBlack, size: 16.0)!,
                            range: matchRange
                        )
                    }
                    
                    // Remove pairs of underscores
                    infoAttributedString.mutableString.replaceOccurrences(of: "__", with: "", options: [], range: NSRange(location: 0, length: infoAttributedString.length))
                    
                    infoAttributedString.mutableString.replaceOccurrences(of: "<b>", with: "", options: [.caseInsensitive], range: NSRange(location: 0, length: infoAttributedString.length))
                    
                    infoAttributedString.mutableString.replaceOccurrences(of: "</b>", with: "", options: [.caseInsensitive], range: NSRange(location: 0, length: infoAttributedString.length))
                    
                    // Replace <br> tags with line breaks
                    infoAttributedString.mutableString.replaceOccurrences(of: "<br>", with: "\n", options: [.caseInsensitive], range: NSRange(location: 0, length: infoAttributedString.length))
                    
                    // Replace &amp; with ampersand
                    infoAttributedString.mutableString.replaceOccurrences(of: "&amp;", with: "&", options: [.caseInsensitive], range: NSRange(location: 0, length: infoAttributedString.length))
                    
                    let combinedAttributedString = NSMutableAttributedString()
                    combinedAttributedString.append(headingAttributedString)
                    combinedAttributedString.append(infoAttributedString)
                    self.infoTextView.attributedText = combinedAttributedString
                    self.infoTextView.textAlignment = .justified
                } else {
                    self.infoTextView.text = "There is no biography available at the moment. >_<"
                }
                UIView.animate(withDuration: 0.25) {
                    self.infoTextView.alpha = 1.0
                }
            }
        }
    }
    
    func setupImageView(forImageWithURLString imageURLString: String?) {
        if let imageURLString = imageURLString,
            let imageURL = URL(string: imageURLString) {
            characterImageView.kf.setImage(with: imageURL, placeholder: UIImage.with(color: .aniManagerGray, andSize: characterImageView.bounds.size), options: [.transition(.fade(0.25))], progressBlock: nil) { (_, _, _, _) in
                NetworkActivityManager.shared.decreaseNumberOfActiveConnections()
            }
        }
    }
    
    func setupJapaneseNameLabel(forJapaneseName japaneseName: String?) {
        if let japaneseName = japaneseName {
            DispatchQueue.main.async {
                self.characterJapaneseNameLabel.text = japaneseName
            }
        }
    }
}
