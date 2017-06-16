//
//  CharacterDetailViewController.swift
//  AniManager
//
//  Created by Tobias Helmrich on 07.12.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

class CharacterDetailViewController: UIViewController {

    // MARK: - Properties
    
    let errorMessageView = ErrorMessageView()
    var character: Character!
    
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
        
        AniListClient.shared.favorite(characterWithId: character.id) { (errorMessage) in
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
        }
        
        /*
            Switch over the character's first and last name
            and set the character name label's text depending
            on which values are available
        */
        switch (character.firstName, character.lastName) {
        case (.some, .none):
            characterNameLabel.text = character.firstName!
        case (.none, .some):
            characterNameLabel.text = character.lastName!
        case (.none, .none):
            characterNameLabel.text = ""
        default:
            characterNameLabel.text = "\(character.firstName!) \(character.lastName!)"
        }
        
        characterImageView.layer.cornerRadius = 2.0
        
        infoTextView.textContainerInset = UIEdgeInsets(top: 20.0, left: 15.0, bottom: 20.0, right: 15.0)
        infoTextView.layer.cornerRadius = 2.0
        
        NetworkActivityManager.shared.increaseNumberOfActiveConnections()
        
        AniListClient.shared.getPageModelCharacter(forCharacterId: character.id) { (pageModelCharacter, errorMessage) in
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
            
            if let japaneseName = pageModelCharacter.japaneseName {
                DispatchQueue.main.async {
                    self.characterJapaneseNameLabel.text = japaneseName
                }
            }
            
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.25) {
                    self.nameStackView.alpha = 1.0
                }
            }
            
            if let info = pageModelCharacter.info {
                DispatchQueue.main.async {
                    /*
                        Check if the character info has content or not, if it has
                        create an attributed string with the "Biography" heading and
                        the character info. If not, display a message that indicates
                        this
                     */
                    if info.characters.count > 0 {
                        let attributedString = NSMutableAttributedString(string: "Biography\n\n\(info)")
                        attributedString.addAttributes([
                            NSFontAttributeName: UIFont(name: Constant.FontName.mainBlack, size: 24.0)!,
                            NSForegroundColorAttributeName: Style.Color.Text.textView
                            ], range: NSRange(location: 0, length: 9))
                        attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: Constant.FontName.mainRegular, size: 16.0)!, range: NSRange(location: 9, length: attributedString.string.characters.count - 9))
                        self.infoTextView.attributedText = attributedString
                        self.infoTextView.textColor = Style.Color.Text.textView
                        self.infoTextView.textAlignment = .justified
                    } else {
                        self.infoTextView.text = "There is no biography available for this character at the moment. >_<"
//                        self.infoTextView.textColor = Style.Color.Text.textView
                    }
                    UIView.animate(withDuration: 0.25) {
                        self.infoTextView.alpha = 1.0
                    }
                }
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
        
        if let imageLargeURLString = character.imageLargeURLString,
            let imageLargeURL = URL(string: imageLargeURLString) {
            characterImageView.kf.setImage(with: imageLargeURL, placeholder: UIImage.with(color: .aniManagerGray, andSize: characterImageView.bounds.size), options: [.transition(.fade(0.25))], progressBlock: nil) { (_, _, _, _) in
                NetworkActivityManager.shared.decreaseNumberOfActiveConnections()
            }
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
}
