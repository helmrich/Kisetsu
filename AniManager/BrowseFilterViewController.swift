//
//  BrowseFilterViewController.swift
//  AniManager
//
//  Created by Tobias Helmrich on 28.11.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

class BrowseFilterViewController: UIViewController {

    // MARK: - Properties
    
    var presentingBrowseViewController: BrowseViewController?
    
    override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }
    
    // TEMPORARY TABLE VIEW DATA SOURCE FOR TESTING
    
    
    let filters: [[String:[Any]]] = [
        ["Sort By": ["Score", "Popularity"]],
        ["Year": [2016, 2015, 2014, 2013, 2012, 2011, 2010, 2009, 2008, 2007, 2006, 2005]],
        ["Season": Season.allSeasonStrings],
        ["Status": AnimeAiringStatus.allStatusStrings],
        ["Type": MediaType.allMediaTypeStrings],
        ["Genre": Genre.allGenreStrings]
    ]
    
    var filterData = [
        "Sort By",
        "Year",
        "Season",
        "Status",
        "Type",
        "Genre"
    ]
    
    
    // TEMPORARY TABLE VIEW DATA SOURCE FOR TESTING
    
    
    // MARK: - Outlets and Actions
    
    // MARK: - Outlets
    
    @IBOutlet weak var seriesTypeButtonAnime: OnOffButton!
    @IBOutlet weak var seriesTypeButtonManga: OnOffButton!
    @IBOutlet weak var filterTableView: UITableView!
    
    // MARK: - Actions
    
    @IBAction func applyFilters() {
        // TODO: Save selected filters as parameters in BrowseViewController
        // and request a new list of series.
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func toggleSelectedSeriesType(_ sender: OnOffButton) {
        seriesTypeButtonAnime.toggle()
        seriesTypeButtonManga.toggle()
    }
    
    
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        /*
            This gesture recognizer is added in order to prevent the filter modal
            from being dismissed because of the FilterModalPresentationController's
            tap gesture recognizer. This way it's only dismissed when there is a tap
            outside of the BrowseFilterViewController.
         */
        
        seriesTypeButtonAnime.toggle()
        
        filterTableView.separatorColor = .aniManagerGray
    }
    

}

extension BrowseFilterViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "filterNameCell") as! FilterNameTableViewCell
        let currentFilter = filters[indexPath.row]
        for (filterName, _) in currentFilter {
            cell.filterNameLabel.text = filterName
        }
        return cell
    }
}

extension BrowseFilterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: Implement
    }
}
