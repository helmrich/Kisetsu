//
//  ListPageViewController.swift
//  AniManager
//
//  Created by Tobias Helmrich on 18.05.17.
//  Copyright © 2017 Tobias Helmrich. All rights reserved.
//

import UIKit

class ListPageViewController: UIPageViewController {

    // MARK: - Properties
    var animeListSelectionViewController: AnimeListSelectionViewController!
    var mangaListSelectionViewController: MangaListSelectionViewController!
    
    
    // MARK: - Outlets and Actions
    
    // MARK: - Actions
    
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        setViewController(forSelectedIndex: sender.selectedSegmentIndex)
    }
    
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        animeListSelectionViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "animeListSelectionViewController") as! AnimeListSelectionViewController
        mangaListSelectionViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mangaListSelectionViewController") as! MangaListSelectionViewController
        
        setupInterfaceForCurrentTheme()
        
        NotificationCenter.default.addObserver(self, selector: #selector(setupInterfaceForCurrentTheme), name: .themeSettingChanged, object: nil)
        
        navigationController?.navigationBar.barStyle = .black
        
        setViewController(forSelectedIndex: 0)
    }
    
    
    // MARK: - Functions
    
    func setupInterfaceForCurrentTheme() {
        navigationController?.navigationBar.barTintColor = Style.Color.BarTint.navigationBar
    }
    
    func setViewController(forSelectedIndex selectedIndex: Int) {
        setViewControllers([selectedIndex == 0 ? animeListSelectionViewController : mangaListSelectionViewController], direction: .forward, animated: false, completion: nil)
    }
}

extension ListPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if viewController == animeListSelectionViewController { return mangaListSelectionViewController }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if viewController == mangaListSelectionViewController { return animeListSelectionViewController }
        return nil
    }
}
