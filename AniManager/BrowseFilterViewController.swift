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
    
    var seriesType: SeriesType!
    var wasSubmitted = false
    
    var presentingBrowseViewController: BrowseViewController?
    
    override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }
    
    
    // MARK: - Outlets and Actions
    
    // MARK: - Outlets
    
    @IBOutlet weak var seriesTypeButtonAnime: OnOffButton!
    @IBOutlet weak var seriesTypeButtonManga: OnOffButton!
    @IBOutlet weak var filterTableView: UITableView!
    
    // MARK: - Actions
    
    @IBAction func applyFilters() {
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
        // Turn on the anime series type button by default
        seriesTypeButtonAnime.toggle()
        
        // Set the table view's separator color
        filterTableView.separatorColor = .aniManagerGray
        
        /*
            Set the series type buttons depending on the
            view controller's series type
         */
        if seriesType == .manga {
            seriesTypeButtonManga.isOn = true
            seriesTypeButtonAnime.isOn = false
        } else {
            seriesTypeButtonAnime.isOn = true
            seriesTypeButtonManga.isOn = false
        }
        
        /*
            Iterate over all filter name-value dictionaries in the shared data
            source's selectedBrowseFilters dictionary and then iterate
            over all filter value dictionaries and select the rows at indices
            that are a key in a filter value dictionary
         */
        for (_, filterValues) in DataSource.shared.selectedBrowseFilters {
            for (filterIndexPath, _) in filterValues! {
                filterTableView.selectRow(at: filterIndexPath, animated: true, scrollPosition: .top)
            }
        }
    }
    

}

extension BrowseFilterViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return DataSource.shared.browseFilters.count
    }
    
    /*
        The number of rows in a section should be equal to the number of filter
        values in the dictionary at the index that is equal to the current section
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfFilterValues = 0
        for (_, filterValues) in DataSource.shared.browseFilters[section] {
            numberOfFilterValues = filterValues.count
        }
        return numberOfFilterValues
    }
    
    /*
        - Dequeue a cell
        - Get the filter values from the dictionary at the index that is equal
          to the current index path's section property
        - Assign the filter value at the index that is equal to the index path's
          row property to the filterValueString variable by interpolating it
        - Assign the filterValueString to the cell's filterNameLabel's text property
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "filterNameCell") as! FilterNameTableViewCell
        var filterValueString = ""
        for (_, filterValues) in DataSource.shared.browseFilters[indexPath.section] {
            filterValueString = "\(filterValues[indexPath.row])"
        }
        cell.filterNameLabel.text = filterValueString
        return cell
    }
}

extension BrowseFilterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        /*
            The title for each section should be the key in the filter dictionary
            at the index of the current section
         */
        let sectionHeaderLabel = BrowseFilterHeaderLabel()
        var headerTitle = ""
        for (filterKey, _) in DataSource.shared.browseFilters[section] {
            headerTitle = filterKey
        }
        sectionHeaderLabel.text = headerTitle
        
        // Configure the header title's appearance
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
        for (filterName, filterValues) in DataSource.shared.browseFilters[indexPath.section] {
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
    
    /*
        When a row will be deselected, iterate over all filter dictionaries
        and check the filter name. If it's "Genres", its dictionary's
        value ([IndexPath:String]) should be removed for the current index path.
        As "Genres" is currently the only filter that can have multiple values
        all other filter's dictionaries can be set to an empty [IndexPath:String]
        dictionary
     */
    func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        for (filterName, _) in DataSource.shared.browseFilters[indexPath.section] {
            if filterName == "Genres" {
                let _ = DataSource.shared.selectedBrowseFilters[filterName]??.removeValue(forKey: indexPath)
            } else {
                DataSource.shared.selectedBrowseFilters[filterName] = [IndexPath:String]()
            }
        }
        return indexPath
    }
}
