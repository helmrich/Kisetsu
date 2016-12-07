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
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    // MARK: - Outlets and Actions
    
    // MARK: - Outlets
    
    @IBOutlet weak fileprivate var characterImageView: UIImageView!
    @IBOutlet weak fileprivate var characterNameLabel: UILabel!
    @IBOutlet weak fileprivate var characterJapaneseNameLabel: UILabel!
    @IBOutlet weak fileprivate var infoTextView: UITextView!
    
    
    
    // MARK: - Actions
    
    @IBAction func dismiss(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func favorite(_ sender: Any) {
    }
    
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        
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
        
        if let japaneseName = character.japaneseName {
            characterJapaneseNameLabel.text = japaneseName
        }
        
        if let info = character.info {
            infoTextView.text = info
        }
        
        if let imageLargeUrlString = character.imageLargeUrlString {
            AniListClient.shared.getImageData(fromUrlString: imageLargeUrlString) { (imageData, errorMessage) in
                guard errorMessage == nil else {
                    return
                }
                
                guard let imageData = imageData else {
                    return
                }
                
                if let image = UIImage(data: imageData) {
                    DispatchQueue.main.async {
                        self.characterImageView.image = image
                    }
                }
            }
        }
    }
    

}
