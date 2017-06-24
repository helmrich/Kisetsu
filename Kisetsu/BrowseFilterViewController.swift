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
    @IBOutlet weak var toolbar: UIToolbar!
    
    
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
        
        setupInterfaceForCurrentTheme()
        
        NotificationCenter.default.addObserver(self, selector: #selector(setupInterfaceForCurrentTheme), name: .themeSettingChanged, object: nil)
        
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        /*
             Iterate over all filter name-value dictionaries in the shared data
             source's selectedBrowseFilters dictionary and then iterate
             over all filter value dictionaries and select the rows at indices
             that are a key in a filter value dictionary
         */
        for (_, filterValues) in DataSource.shared.selectedBrowseFilters {
            for (filterIndexPath, _) in filterValues! {
                filterTableView.selectRow(at: filterIndexPath, animated: true, scrollPosition: .none)
            }
        }
    }
    
    // MARK: - Functions
    
    func setupInterfaceForCurrentTheme() {
        toolbar.barTintColor = Style.Color.BarTint.browseFilterToolbar
        view.backgroundColor = Style.Color.Background.mainView
        filterTableView.backgroundColor = Style.Color.Background.tableView
        filterTableView.reloadData()
    }
    

}

extension BrowseFilterViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return DataSource.shared.filterSections.count
    }
    
    /*
        The number of rows in a section should be equal to the number of filter
        values in the dictionary at the index that is equal to the current section
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataSource.shared.filterSections[section].items.count
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "filterValueCell") as! FilterValueTableViewCell
        if DataSource.shared.filterSections[indexPath.section].name == "Type" {
            cell.filterValueLabel.text = "\(DataSource.shared.filterSections[indexPath.section].items[indexPath.row])"
        } else {
            cell.filterValueLabel.text = "\(DataSource.shared.filterSections[indexPath.section].items[indexPath.row])".capitalized
        }
        let selectedIndexPathsForSection = DataSource.shared.selectedBrowseFilters[DataSource.shared.filterSections[indexPath.section].name]
        if (selectedIndexPathsForSection!?.keys.contains { $0 == indexPath })! {
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        }
        return cell
    }
}

extension BrowseFilterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? CollapsibleTableViewHeader ?? CollapsibleTableViewHeader(reuseIdentifier: "header")
        
        /*
            The title for each section should be the key in the filter dictionary
            at the index of the current section
         */
        header.titleLabel.text = DataSource.shared.filterSections[section].name
        header.arrowLabel.text = ">"
        header.arrowLabel.textColor = .white
        header.set(collapsed: DataSource.shared.filterSections[section].collapsed)
        header.section = section
        header.delegate = self
        
        // Configure the header title's appearance
        header.titleLabel.font = UIFont(name: Constant.FontName.mainBold, size: 20.0)
        header.titleLabel.textColor = .white
        header.titleLabel.backgroundColor = Style.Color.Background.browseFilterTableViewSectionHeader
        header.titleLabel.textAlignment = .left
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if DataSource.shared.filterSections[indexPath.section].collapsed {
            return 0.0
        } else {
            return 44.0
        }
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        print(DataSource.shared.filterSections[indexPath.section].items[indexPath.row])
        /*
            Check if the current section's name is "Genres" which is
            the only filter that can have multiple selected values and
            if it is, add a dictionary item with the current index path
            as a key and the selected item as a value to the selectedFilters
            dictionary with the current section name as a key
         */
        let filterSection = DataSource.shared.filterSections[indexPath.section]
        
        if filterSection.name == "Genres" {
            DataSource.shared.selectedBrowseFilters[filterSection.name]??[indexPath] = "\(filterSection.items[indexPath.row])"
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
            if let selectedFilter = DataSource.shared.selectedBrowseFilters[filterSection.name] {
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
            DataSource.shared.selectedBrowseFilters[filterSection.name] = [indexPath: "\(filterSection.items[indexPath.row])"]
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
        let filterSection = DataSource.shared.filterSections[indexPath.section]
        if filterSection.name == "Genres" {
            DataSource.shared.selectedBrowseFilters[filterSection.name]??.removeValue(forKey: indexPath)
        } else {
            DataSource.shared.selectedBrowseFilters[filterSection.name] = [IndexPath:String]()
        }
        return indexPath
    }
}

extension BrowseFilterViewController: CollapsibleTableViewHeaderDelegate {
    func toggleSection(_ header: CollapsibleTableViewHeader, section: Int) {
        let newCollapsed = !DataSource.shared.filterSections[section].collapsed
        DataSource.shared.filterSections[section].collapsed = newCollapsed
        header.set(collapsed: newCollapsed)
        filterTableView.beginUpdates()
        for i in 0..<DataSource.shared.filterSections[section].items.count {
            filterTableView.reloadRows(at: [IndexPath(row: i, section: section)], with: .automatic)
        }
        filterTableView.endUpdates()
    }
}
