//
//  PresentWebViewControllerExtension.swift
//  AniManager
//
//  Created by Tobias Helmrich on 01.06.17.
//  Copyright © 2017 Tobias Helmrich. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func presentWebViewController(with url: URL) {
        DispatchQueue.main.async {
            let webViewController = self.storyboard?.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
            webViewController.url = url
            self.present(webViewController, animated: true, completion: nil)
        }
    }
}
