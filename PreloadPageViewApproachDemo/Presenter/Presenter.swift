//
//  Presenter.swift
//  PreloadPageViewApproachDemo
//
//  Created by Joshua Chang on 2020/9/14.
//  Copyright © 2020 Joshua Chang. All rights reserved.
//

import Foundation

final class Presenter {
    
    var selectedIndex: Int = 0
    
    var myViewController: ViewController?
    
    init(_ viewController: ViewController) {
        self.myViewController = viewController
    }
    
    func detachView() {
        self.myViewController = nil
    }
    
    /// preload previous or next page
    func notifyPageViewPreload() {
        self.myViewController?.preloadPendingPage(self.selectedIndex)
    }
}
