//
//  ActionsTableViewCell.swift
//  AniManager
//
//  Created by Tobias Helmrich on 09.12.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

class ActionsTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    var seriesId: Int?
    
    
    // MARK: - Outlets and Actions
    
    // MARK: - Outlets
    
    // Top Buttons
    @IBOutlet weak var topButtonsStackView: UIStackView!
    @IBOutlet weak var userListStatusButton: AniManagerButton!
    @IBOutlet weak var rateButton: AniManagerButton!
    
    // Anime Progress Stack View
    @IBOutlet weak var animeProgressStackView: UIStackView!
    @IBOutlet weak var maximumNumberOfEpisodesLabel: UILabel!
    @IBOutlet weak var watchedEpisodesTextField: UITextField!
    @IBOutlet weak var watchedEpisodesDescriptionLabel: UILabel!
    
    
    // Manga Progress Stack View
    @IBOutlet weak var mangaProgressStackView: UIStackView!
    @IBOutlet weak var chaptersReadStackView: UIStackView!
    @IBOutlet weak var volumesReadStackView: UIStackView!
    @IBOutlet weak var maximumNumberOfChaptersLabel: UILabel!
    @IBOutlet weak var chaptersReadTextField: UITextField!
    @IBOutlet weak var maximumNumberOfVolumesLabel: UILabel!
    @IBOutlet weak var volumesReadTextField: UITextField!
    @IBOutlet weak var chaptersReadDescriptionLabel: UILabel!
    @IBOutlet weak var volumesReadDescriptionLabel: UILabel!
    
    
    @IBOutlet var slashes: [UILabel]!
    @IBOutlet var subtractButtons: [UIButton]!
    @IBOutlet var addButtons: [UIButton]!
    @IBOutlet var subtractButtonsSmall: [UIButton]!
    @IBOutlet var addButtonsSmall: [UIButton]!
    
    // MARK: - Actions

    // Anime Actions
    @IBAction func increaseWatchedEpisodes(_ sender: Any) {
        if let watchedEpisodesText = watchedEpisodesTextField.text,
            let watchedEpisodes = Int(watchedEpisodesText) {
            if (Int(maximumNumberOfEpisodesLabel.text!)! > 0 && watchedEpisodes < Int(maximumNumberOfEpisodesLabel.text!)!) || Int(maximumNumberOfEpisodesLabel.text!)! == 0 {
                watchedEpisodesTextField.text = "\(watchedEpisodes + 1)"
            }
        }
    }
    
    @IBAction func decreaseWatchedEpisodes(_ sender: Any) {
        if let watchedEpisodesText = watchedEpisodesTextField.text,
            let watchedEpisodes = Int(watchedEpisodesText),
            watchedEpisodes > 0 {
            watchedEpisodesTextField.text = "\(watchedEpisodes - 1)"
        }
    }
    
    // Manga Actions
    @IBAction func increaseReadChapters(_ sender: Any) {
        if let readChaptersText = chaptersReadTextField.text,
            let readChapters = Int(readChaptersText) {
            chaptersReadTextField.text = "\(readChapters + 1)"
        }
    }
    
    @IBAction func decreaseReadChapters(_ sender: Any) {
        if let readChaptersText = chaptersReadTextField.text,
            let readChapters = Int(readChaptersText),
            readChapters > 0 {
            chaptersReadTextField.text = "\(readChapters - 1)"
        }
    }
    
    @IBAction func increaseReadVolumes(_ sender: Any) {
        if let readVolumesText = volumesReadTextField.text,
            let readVolumes = Int(readVolumesText) {
            volumesReadTextField.text = "\(readVolumes + 1)"
        }
    }
    
    @IBAction func decreaseReadVolumes(_ sender: Any) {
        if let readVolumesText = volumesReadTextField.text,
            let readVolumes = Int(readVolumesText),
            readVolumes > 0 {
            volumesReadTextField.text = "\(readVolumes - 1)"
        }
    }
    
    
    // MARK: - Functions
    
    func setupCell(forGrantType grantType: GrantType, seriesType: SeriesType, isSeriesInList: Bool) {
        if grantType != .clientCredentials {
            toggleStatus(of: userListStatusButton, active: true)
        }
        
        if seriesType == .anime {
            DispatchQueue.main.async {
                self.mangaProgressStackView.alpha = 0.0
            }
        } else {
            DispatchQueue.main.async {
                self.animeProgressStackView.alpha = 0.0
                self.mangaProgressStackView.alpha = 0.4
            }
        }
        
        if isSeriesInList {
            toggleStatus(of: rateButton, active: true)
            if seriesType == .anime {
                self.toggleStatus(of: self.animeProgressStackView, active: true)
            } else {
                self.toggleStatus(of: self.mangaProgressStackView, active: true)
            }
        } else {
            DispatchQueue.main.async {
                self.watchedEpisodesTextField.text = "0"
                self.chaptersReadTextField.text = "0"
                self.volumesReadTextField.text = "0"
                self.userListStatusButton.setTitle("Add to List", for: .normal)
            }
        }
    }
    
    func toggleStatus(of view: UIView, active: Bool) {
        DispatchQueue.main.async {
            if active {
                view.alpha = 1.0
                view.isUserInteractionEnabled = true
            } else {
                view.alpha = 0.4
                view.isUserInteractionEnabled = false
            }
        }
    }
    
    /*
        This function is used to add a toolbar with a "done"-button to
        a progress text field as an input accessory view which will
        show on top of the keyboard when a progress text field becomes
        the first responder. 
     
        It takes the done button's target and action as a parameter as
        this should be specified when the actions table view cell is
        implemented
     */
    func addToolbarInputAccessoryViewToProgressTextFields(doneButtonTarget target: Any, doneButtonAction action: Selector) {
        // Create and configure the toolbar
        let progressTextFieldToolbar = UIToolbar()
        progressTextFieldToolbar.barTintColor = Style.Color.BarTint.toolbar
        progressTextFieldToolbar.sizeToFit()
        
        /*
            Create and configure the done bar button and a flexible
            space bar button item and add assign them to the toolbar's
            items property
         */
        let doneBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: target, action: action)
        doneBarButtonItem.tintColor = .white
        let flexibleSpaceBarButtonItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        progressTextFieldToolbar.items = [flexibleSpaceBarButtonItem, doneBarButtonItem]
        
        /*
            Assign the created toolbar to all of the progress-related
            text fields' inputAccessoryView property
         */
        watchedEpisodesTextField.inputAccessoryView = progressTextFieldToolbar
        chaptersReadTextField.inputAccessoryView = progressTextFieldToolbar
        volumesReadTextField.inputAccessoryView = progressTextFieldToolbar
    }
    
    /*
        This function is used in order to get an integer rating value from
        the action cell's rate button. It therefore removes the "Your Rating "
        string that's shown in the button when the user already rated the series.
        Afterwards an integer object is initialized with the resulting string and
        the value (or nil if it failed) is returned
     */
    func getUserScoreFromRateButton() -> Int? {
        guard let rateButtonText = rateButton.title(for: .normal) else {
            return nil
        }
        
        let userScoreString = rateButtonText.replacingOccurrences(of: "Your Rating: ", with: "")
        
        guard let userScore = Int(userScoreString) else {
            return nil
        }
        
        return userScore
        
    }
    
    override func layoutSubviews() {
        maximumNumberOfVolumesLabel.textColor = Style.Color.Text.progressLabel
        maximumNumberOfChaptersLabel.textColor = Style.Color.Text.progressLabel
        maximumNumberOfEpisodesLabel.textColor = Style.Color.Text.progressLabel
        volumesReadTextField.textColor = Style.Color.Text.textField
        chaptersReadTextField.textColor = Style.Color.Text.textField
        watchedEpisodesTextField.textColor = Style.Color.Text.textField
        volumesReadDescriptionLabel.textColor = Style.Color.Text.progressLabel
        chaptersReadDescriptionLabel.textColor = Style.Color.Text.progressLabel
        watchedEpisodesDescriptionLabel.textColor = Style.Color.Text.progressLabel
        
        slashes.forEach { $0.textColor = Style.Color.Text.progressLabel }
        addButtons.forEach { $0.setImage(Style.Image.progressPlusIcon, for: .normal) }
        subtractButtons.forEach { $0.setImage(Style.Image.progressMinusIcon, for: .normal) }
        addButtonsSmall.forEach { $0.setImage(Style.Image.progressPlusIconSmall, for: .normal) }
        subtractButtonsSmall.forEach { $0.setImage(Style.Image.progressMinusIconSmall, for: .normal) }
    }
}
