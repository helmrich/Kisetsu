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
    
    var wasSubmitted = false
    
    var presentingBrowseViewController: BrowseViewController?
    
    override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }
    
    // TEMPORARY TABLE VIEW DATA SOURCE FOR TESTING
    
    
    let browseFilters: [[String:[Any]]] = [
        ["Sort By": ["Score", "Popularity"]],
        ["Season": Season.allSeasonStrings],
        ["Status": AnimeAiringStatus.allStatusStrings],
        ["Type": MediaType.allMediaTypeStrings],
        ["Genres": Genre.allGenreStrings],
        ["Year": [Int](1951...2016).reversed()]
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
        wasSubmitted = true
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
        filterTableView.showsVerticalScrollIndicator = false
        filterTableView.allowsMultipleSelection = true
        
        for (_, filterValues) in DataSource.shared.selectedBrowseFilters {
            for (filterIndexPath, _) in filterValues! {
                filterTableView.selectRow(at: filterIndexPath, animated: true, scrollPosition: .top)
            }
        }
    }
    

}

extension BrowseFilterViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return browseFilters.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var headerTitle = ""
        for (filterKey, _) in browseFilters[section] {
            headerTitle = filterKey
        }
        return headerTitle
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfFilterValues = 0
        for (_, filterValues) in browseFilters[section] {
            numberOfFilterValues = filterValues.count
        }
        return numberOfFilterValues
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "filterNameCell") as! FilterNameTableViewCell
        var filterValueString = ""
        for (_, filterValues) in browseFilters[indexPath.section] {
            filterValueString = "\(filterValues[indexPath.row])"
        }
        cell.filterNameLabel.text = filterValueString
        return cell
    }
}

extension BrowseFilterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeaderLabel = BrowseFilterHeaderLabel()
        var headerTitle = ""
        for (filterKey, _) in browseFilters[section] {
            headerTitle = filterKey
        }
        sectionHeaderLabel.text = headerTitle
        sectionHeaderLabel.font = UIFont(name: Constant.FontName.mainBold, size: 20.0)
        sectionHeaderLabel.textColor = .aniManagerBlack
        sectionHeaderLabel.textColor = .white
        sectionHeaderLabel.backgroundColor = .aniManagerBlue
        sectionHeaderLabel.textAlignment = .left
        return sectionHeaderLabel
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        /*
            When a row will be selected, get the associated
            filter key and value from the filters array's
            dictionary at the position of the indexPath's
            section property.
         */
        for (filterName, filterValues) in browseFilters[indexPath.section] {
            /*
                Check if the current section's associated filter name
                is "Genres" which is the only filter that can have
                multiple selected values and if it is, add a dictionary
                item with the current index path as a key and the selected
                filter value as a value to the selectedFilters dictionary
                with the current filter name as a key
             */
            if filterName == "Genres" {
                DataSource.shared.selectedBrowseFilters[filterName]??[indexPath] = "\(filterValues[indexPath.row])"
            } else {
                /*
                    If the current section's associated filter name is NOT
                    "Genres" it should only be possible to select one value.
                    Thus before selecting a new row the row that was eventually
                    selected before should be deselected. To achieve this the
                    index path should be extracted from the dictionary - that's
                    the value of the selectedFilter dictionary - to deselect 
                    the row at this index path.
                 */
                if let selectedFilter = DataSource.shared.selectedBrowseFilters[filterName] {
                    for (indexPath, _) in selectedFilter! {
                        tableView.deselectRow(at: indexPath, animated: false)
                    }
                }
                
                /*
                    Afterwards the value at the selectedFilters' dictionary
                    with the current filter name should be set to a new dictionary
                    with the current index path as a key and the filter value
                    at the index of the index path's row property
                 */
                DataSource.shared.selectedBrowseFilters[filterName] = [indexPath: "\(filterValues[indexPath.row])"]
            }
        }
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        for (filterName, _) in browseFilters[indexPath.section] {
            if filterName == "Genres" {
                let _ = DataSource.shared.selectedBrowseFilters[filterName]??.removeValue(forKey: indexPath)
            } else {
                DataSource.shared.selectedBrowseFilters[filterName] = [IndexPath:String]()
            }
        }
        return indexPath
    }
}
