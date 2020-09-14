//
//  ViewController.swift
//  PreloadPageViewApproachDemo
//
//  Created by Joshua Chang on 2020/9/11.
//  Copyright © 2020 Joshua Chang. All rights reserved.
//

import UIKit

protocol ViewPresentProtocol {
    func preloadPendingPage(_ index: Int)
}

class ViewController: UIViewController {
    
    lazy var frameView: FrameView = {
        let view = FrameView(self.presenter)
        view.pageViewControl.dataSource = self
        view.pageViewControl.delegate = self
        return view
    }()
    
    lazy var presenter: Presenter = {
        let presenter = Presenter(self)
        return presenter
    }()
    
    override func loadView() {
        super.loadView()
        self.view = self.frameView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutContraints()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.presenter.detachView()
    }

    // MARK: - Private Method
    private func layoutContraints() {
        // addChildView
        addChild(frameView.pageViewControl)
        frameView.pageViewControl.didMove(toParent: self)
    }

}

extension ViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard
            let index = self.frameView.viewControllerList.firstIndex(of: viewController),
            index > 0
            else { return nil }
        return self.frameView.viewControllerList[index - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard
            let index = self.frameView.viewControllerList.firstIndex(of: viewController),
            index < self.frameView.viewControllerList.count - 1
            else { return nil }
        return self.frameView.viewControllerList[index + 1]
    }
    
}

extension ViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        guard
            let viewcontroller = pendingViewControllers.first,
            let index = self.frameView.viewControllerList.firstIndex(of: viewcontroller)
            else { return }
        self.presenter.selectedIndex = index
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            self.frameView.segmentedControl.selectedSegmentIndex = self.presenter.selectedIndex
            self.presenter.notifyPageViewPreload()
        }
    }
    
}

extension ViewController: ViewPresentProtocol {
    
    func preloadPendingPage(_ index: Int) {
        if index > 0 {
            self.frameView.viewControllerList[index - 1].loadViewIfNeeded()
        }
        
        if index < self.frameView.viewControllerList.count - 1 {
            self.frameView.viewControllerList[index + 1].loadViewIfNeeded()
        }
    }
    
}
