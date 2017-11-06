//
//  EpisodesCollectionViewController.swift
//  Kisetsu
//
//  Created by Tobias Helmrich on 25.06.17.
//  Copyright © 2017 Tobias Helmrich. All rights reserved.
//

import UIKit

class EpisodesCollectionViewController: UIViewController {
    
    // MARK: - Properties
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    // MARK: - Outlets and Actions
    
    // MARK: - Outlets
    
    @IBOutlet weak var episodesCollectionView: UICollectionView!
    @IBOutlet weak var episodesCollectionViewFlowLayout: UICollectionViewFlowLayout!
    
    // MARK: - Actions
    
    @IBAction func dismiss(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barTintColor = Style.Color.BarTint.navigationBar
        episodesCollectionView.backgroundColor = Style.Color.Background.episodesCollectionView

        episodesCollectionViewFlowLayout.itemSize = CGSize(width: view.frame.width * 0.85, height: 275.0)
        episodesCollectionViewFlowLayout.minimumLineSpacing = 15.0
        episodesCollectionView.contentInset = UIEdgeInsets(top: 10.0, left: episodesCollectionView.contentInset.left, bottom: 10.0, right: episodesCollectionView.contentInset.right)
    }
}


// MARK: - Collection View Data Source
extension EpisodesCollectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let selectedAnimeSeries = DataSource.shared.selectedSeries as? AnimeSeries,
        let episodes = selectedAnimeSeries.episodes else {
            return 0
        }
        return episodes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "episodeCell", for: indexPath) as! EpisodeCollectionViewCell
        cell.layoutSubviews()
        
        guard let selectedAnimeSeries = DataSource.shared.selectedSeries as? AnimeSeries,
            let episodes = selectedAnimeSeries.episodes,
        episodes.count > indexPath.row else {
            return cell
        }
        
        let episodeForCell = episodes[indexPath.row]
        
        cell.episodeTitleLabel.text = episodeForCell.title
        cell.episodeDescriptionLabel.text = episodeForCell.description
        
        cell.crunchyrollButton.addTarget(self, action: #selector(openEpisode), for: .touchUpInside)
        
        let imageURLBasedOnHighQualitySetting = UserDefaults.standard.bool(forKey: UserDefaultsKey.downloadHighQualityImages.rawValue) ? episodeForCell.imageFullURL : episodeForCell.imageLargeURL
        if let previewImageURL = imageURLBasedOnHighQualitySetting,
            cell.previewImageView.image == nil {
            cell.previewImageView.kf.setImage(with: previewImageURL, placeholder: nil, options: [.transition(.fade(0.25))], progressBlock: nil, completionHandler: { (image, _, _, _) in
                collectionView.reloadItems(at: [indexPath])
            })
        }
        
        return cell
    }
    
    func openEpisode(_ sender: UIButton) {
        guard let buttonSuperview = sender.superview,
        let episodeCell = buttonSuperview as? EpisodeCollectionViewCell,
        let episodeCellIndexPath = episodesCollectionView.indexPath(for: episodeCell) else {
            return
        }
        
        guard let selectedAnimeSeries = DataSource.shared.selectedSeries as? AnimeSeries,
        let episodes = selectedAnimeSeries.episodes,
        episodes.count > episodeCellIndexPath.row else {
            return
        }
        
        let selectedEpisode = episodes[episodeCellIndexPath.row]
        
        guard let crunchyrollEpisodeURL = selectedEpisode.crunchyrollURL else { return }
        
        if UIApplication.shared.canOpenURL(URL(string: "crunchyroll://")!),
        let mediaId = selectedEpisode.mediaId {
            // If the Crunchyroll app is installed, the episode should be opened
            // in the application by using the crunchyroll scheme and the episode's
            // media ID
            UIApplication.shared.open(URL(string: "crunchyroll://playmedia/\(mediaId)")!, options: [:], completionHandler: nil)
        } else {
            // If the Crunchyroll app is not installed, the episode should be opened
            // in Safari
            UIApplication.shared.open(crunchyrollEpisodeURL, options: [:], completionHandler: nil)
        }
    }
}


// MARK: - Collection View Delegate
extension EpisodesCollectionViewController: UICollectionViewDelegate {
}
