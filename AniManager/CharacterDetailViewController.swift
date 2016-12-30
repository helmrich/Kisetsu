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
    
    
    // MARK: - Outlets and Actions
    
    // MARK: - Outlets
    
    @IBOutlet weak fileprivate var characterImageView: UIImageView!
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
                self.errorMessageView.showError(withMessage: errorMessage!)
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
        
        favoriteButton.alpha = 0
        
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
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        NetworkActivityManager.shared.increaseNumberOfActiveConnections()
        
        AniListClient.shared.getPageModelCharacter(forCharacterId: character.id) { (pageModelCharacter, errorMessage) in
            guard errorMessage == nil else {
                self.errorMessageView.showError(withMessage: errorMessage!)
                NetworkActivityManager.shared.decreaseNumberOfActiveConnections()
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = NetworkActivityManager.shared.numberOfActiveConnections > 0
                }
                return
            }
            
            guard let pageModelCharacter = pageModelCharacter else {
                self.errorMessageView.showError(withMessage: "Couldn't get character page model")
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
            
            if let info = pageModelCharacter.info {
                DispatchQueue.main.async {
                    self.infoTextView.text = info
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
        
        if let imageLargeUrlString = character.imageLargeUrlString {
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            NetworkActivityManager.shared.increaseNumberOfActiveConnections()
            
            AniListClient.shared.getImageData(fromUrlString: imageLargeUrlString) { (imageData, errorMessage) in
                guard errorMessage == nil else {
                    NetworkActivityManager.shared.decreaseNumberOfActiveConnections()
                    DispatchQueue.main.async {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = NetworkActivityManager.shared.numberOfActiveConnections > 0
                    }
                    return
                }
                
                guard let imageData = imageData else {
                    NetworkActivityManager.shared.decreaseNumberOfActiveConnections()
                    DispatchQueue.main.async {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = NetworkActivityManager.shared.numberOfActiveConnections > 0
                    }
                    return
                }
                
                if let image = UIImage(data: imageData) {
                    DispatchQueue.main.async {
                        self.characterImageView.image = image
                        UIView.animate(withDuration: 0.25) {
                            self.characterImageView.alpha = 1.0
                        }
                    }
                }
                
                NetworkActivityManager.shared.decreaseNumberOfActiveConnections()
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = NetworkActivityManager.shared.numberOfActiveConnections > 0
                }
            }
        }
    }
}
