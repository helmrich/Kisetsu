//
//  SeriesDetailViewControllerTableViewDelegate.swift
//  AniManager
//
//  Created by Tobias Helmrich on 14.12.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

extension SeriesDetailViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let bannerView = seriesDataTableView.tableHeaderView as! BannerView
        bannerView.scrollViewDidScroll(scrollView: scrollView)
    }
}
