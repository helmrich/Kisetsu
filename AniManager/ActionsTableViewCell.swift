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
    
    // Manga Progress Stack View
    @IBOutlet weak var mangaProgressStackView: UIStackView!
    @IBOutlet weak var chaptersReadStackView: UIStackView!
    @IBOutlet weak var volumesReadStackView: UIStackView!
    @IBOutlet weak var maximumNumberOfChaptersLabel: UILabel!
    @IBOutlet weak var chaptersReadTextField: UITextField!
    @IBOutlet weak var maximumNumberOfVolumesLabel: UILabel!
    @IBOutlet weak var volumesReadTextField: UITextField!
    
    
    
    
    
    
    // MARK: - Actions

    // Anime Actions
    @IBAction func increaseWatchedEpisodes(_ sender: Any) {
        if let watchedEpisodesText = watchedEpisodesTextField.text,
            let watchedEpisodes = Int(watchedEpisodesText),
            watchedEpisodes < Int(maximumNumberOfEpisodesLabel.text!)! {
                watchedEpisodesTextField.text = "\(watchedEpisodes + 1)"
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
    
    func setupCell(forSeriesType seriesType: SeriesType) {
        if seriesType == .anime {
            mangaProgressStackView.isHidden = true
            animeProgressStackView.isHidden = false
        } else if seriesType == .manga {
            animeProgressStackView.isHidden = true
            mangaProgressStackView.isHidden = false
        }
    }
    
    func setupCellForStatus(isSeriesInList: Bool) {
        if isSeriesInList {
            rateButton.isEnabled = true
            animeProgressStackView.isUserInteractionEnabled = true
            mangaProgressStackView.isUserInteractionEnabled = true
            UIView.animate(withDuration: 0.25) {
                self.rateButton.alpha = 1.0
                self.animeProgressStackView.alpha = 1.0
                self.mangaProgressStackView.alpha = 1.0
            }
        } else {
            watchedEpisodesTextField.text = "0"
            chaptersReadTextField.text = "0"
            volumesReadTextField.text = "0"
            userListStatusButton.setTitle("Add to List", for: .normal)
            rateButton.isEnabled = false
            animeProgressStackView.isUserInteractionEnabled = false
            mangaProgressStackView.isUserInteractionEnabled = false
            UIView.animate(withDuration: 0.25) {
                self.rateButton.alpha = 0.4
                self.animeProgressStackView.alpha = 0.4
                self.mangaProgressStackView.alpha = 0.4
            }
        }
    }
    
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
    
    
}
