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
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        NetworkActivityManager.shared.increaseNumberOfActiveConnections()
        
        AniListClient.shared.favorite(characterWithId: character.id) { (errorMessage) in
            guard errorMessage == nil else {
                self.errorMessageView.showAndHide(withMessage: errorMessage!)
                NetworkActivityManager.shared.decreaseNumberOfActiveConnections()
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = NetworkActivityManager.shared.numberOfActiveConnections > 0
                }
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
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = NetworkActivityManager.shared.numberOfActiveConnections > 0
            }
            
        }
    }
    
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        
        nameStackView.alpha = 0.0
        infoTextView.alpha = 0.0
        characterImageView.alpha = 0.0
        
        // Banner Configuration
        favoriteButton.alpha = 0
        bannerView.backgroundColor = .aniManagerBlack
        bannerView.alpha = 0.85
        bannerImageView.contentMode = .scaleAspectFill
        if let bannerImageURL = bannerImageURL {
            NetworkActivityManager.shared.increaseNumberOfActiveConnections()
            UIApplication.shared.isNetworkActivityIndicatorVisible = NetworkActivityManager.shared.numberOfActiveConnections > 0
            bannerImageView.kf.setImage(with: bannerImageURL, placeholder: UIImage.with(color: .aniManagerGray, andSize: bannerView.bounds.size), options: [.transition(.fade(0.25))], progressBlock: nil) { (_, _, _, _) in
                NetworkActivityManager.shared.decreaseNumberOfActiveConnections()
                UIApplication.shared.isNetworkActivityIndicatorVisible = NetworkActivityManager.shared.numberOfActiveConnections > 0
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
        
        infoTextView.textContainerInset = UIEdgeInsets(top: 20.0, left: 20.0, bottom: 0.0, right: 20.0)
        infoTextView.layer.cornerRadius = 2.0
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        NetworkActivityManager.shared.increaseNumberOfActiveConnections()
        
        AniListClient.shared.getPageModelCharacter(forCharacterId: character.id) { (pageModelCharacter, errorMessage) in
            guard errorMessage == nil else {
                self.errorMessageView.showAndHide(withMessage: errorMessage!)
                NetworkActivityManager.shared.decreaseNumberOfActiveConnections()
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = NetworkActivityManager.shared.numberOfActiveConnections > 0
                }
                return
            }
            
            guard let pageModelCharacter = pageModelCharacter else {
                self.errorMessageView.showAndHide(withMessage: "Couldn't get character page model")
                NetworkActivityManager.shared.decreaseNumberOfActiveConnections()
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = NetworkActivityManager.shared.numberOfActiveConnections > 0
                }
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
                            NSForegroundColorAttributeName: UIColor.aniManagerBlack
                            ], range: NSRange(location: 0, length: 9))
                        self.infoTextView.attributedText = attributedString
                    } else {
                        self.infoTextView.text = "There is no biography available for this character at the moment. >_<"
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
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = NetworkActivityManager.shared.numberOfActiveConnections > 0
            }
            
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        NetworkActivityManager.shared.increaseNumberOfActiveConnections()
        
        if let imageLargeUrlString = character.imageLargeUrlString,
            let imageLargeUrl = URL(string: imageLargeUrlString) {
            characterImageView.kf.setImage(with: imageLargeUrl, placeholder: nil, options: [.transition(.fade(0.25))], progressBlock: nil) { (_, _, _, _) in
                UIView.animate(withDuration: 0.25) {
                    self.characterImageView.alpha = 1.0
                }
                NetworkActivityManager.shared.decreaseNumberOfActiveConnections()
                UIApplication.shared.isNetworkActivityIndicatorVisible = NetworkActivityManager.shared.numberOfActiveConnections > 0
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NetworkActivityManager.shared.numberOfActiveConnections = 0
    }
}
