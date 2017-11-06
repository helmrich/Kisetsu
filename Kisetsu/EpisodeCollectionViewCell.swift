//
//  EpisodeCollectionViewCell.swift
//  Kisetsu
//
//  Created by Tobias Helmrich on 25.06.17.
//  Copyright © 2017 Tobias Helmrich. All rights reserved.
//

import UIKit

class EpisodeCollectionViewCell: UICollectionViewCell {
    let episodeTitleLabel = CellTitleLabel()
    let episodeDescriptionLabel = AniManagerLabel()
    let previewImageView = UIImageView()
    let crunchyrollButton = AniManagerButton()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        crunchyrollButton.setTitle("Watch on Crunchyroll", for: .normal)
        
        layer.cornerRadius = 5.0
        layer.masksToBounds = false
        layer.shadowColor = Style.Color.Shadow.episodeCell.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowRadius = 0.0
        layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        
        backgroundColor = Style.Color.Background.episodeCollectionViewCell
        previewImageView.backgroundColor = Style.Color.Background.episodeCollectionViewCellPreviewImage
        episodeTitleLabel.textColor = Style.Color.Text.episodeCollectionViewCell
        episodeDescriptionLabel.textColor = Style.Color.Text.episodeCollectionViewCell
        
        previewImageView.contentMode = .scaleAspectFill
        previewImageView.clipsToBounds = true
        previewImageView.round(corners: [.topLeft, .topRight], withRadius: 5.0)
        
        episodeTitleLabel.numberOfLines = 3
        episodeTitleLabel.font = UIFont(name: Constant.FontName.mainBlack, size: 14.0)
        
        episodeDescriptionLabel.numberOfLines = 0
        episodeDescriptionLabel.textAlignment = .justified
        episodeDescriptionLabel.font = UIFont(name: Constant.FontName.mainLight, size: 10.0)
        
        crunchyrollButton.titleLabel?.font = UIFont(name: Constant.FontName.mainRegular, size: 14.0)
        
        episodeTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        episodeDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        previewImageView.translatesAutoresizingMaskIntoConstraints = false
        crunchyrollButton.translatesAutoresizingMaskIntoConstraints = false
        
        
        addSubview(previewImageView)
        addSubview(episodeTitleLabel)
        addSubview(episodeDescriptionLabel)
        addSubview(crunchyrollButton)
        
        // Activate constraints
        NSLayoutConstraint.activate([
                // Preview Image View
                previewImageView.heightAnchor.constraint(equalToConstant: 112.0),
                previewImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
                previewImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
                previewImageView.topAnchor.constraint(equalTo: topAnchor),
                // Episode Title Label
                episodeTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10.0),
                episodeTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10.0),
                episodeTitleLabel.topAnchor.constraint(equalTo: previewImageView.bottomAnchor, constant: 5.0),
                // Episode Description Label
                episodeDescriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10.0),
                episodeDescriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10.0),
                episodeDescriptionLabel.topAnchor.constraint(equalTo: episodeTitleLabel.bottomAnchor, constant: 3.0),
                episodeDescriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: crunchyrollButton.topAnchor, constant: -10.0),
                // Crunchyroll Button
                crunchyrollButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10.0),
                crunchyrollButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10.0),
                crunchyrollButton.heightAnchor.constraint(equalToConstant: 35.0),
                crunchyrollButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10.0)
            ])
    }
    
    override func prepareForReuse() {
        previewImageView.image = nil
    }
}
