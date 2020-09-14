//
//  FrameView.swift
//  PreloadPageViewApproachDemo
//
//  Created by Joshua Chang on 2020/9/11.
//  Copyright © 2020 Joshua Chang. All rights reserved.
//

import UIKit
import SnapKit

class FrameView: UIView {
    
    // MARK: - Internal Property
    var viewControllerList: [UIViewController] = [UIViewController]()
    
    lazy var titleView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var segmentedControl: UISegmentedControl = {
        let items = ["First", "Second", "Third", "Fourth", "Fifth"]
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.backgroundColor = .lightGray
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.addTarget(self, action: #selector(segmentedChange), for: .valueChanged)
        return segmentedControl
    }()
    
    lazy var pageViewControl: UIPageViewController = {
        let pageViewControl = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewControl.isEditing = true
        return pageViewControl
    }()
    
    // MARK: - ViewController in Page
    let firstPage = FirstPageViewController()
    let secondPage = SecondPageViewController()
    let thirdPage = ThirdPageViewController()
    let fourthPage = FourthPageViewController()
    let fifthPage = FifthPageViewController()
    
    // MARK: - Private Property
    private var presenter: Presenter
    
    // MARK: - Initialize
    init(_ presenter: Presenter) {
        self.presenter = presenter
        super.init(frame: .zero)
        self.layoutContraints()
        self.setupPageViewMemberObject()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Method
    private func layoutContraints() {
        
        // addSubView
        addSubview(titleView)
        addSubview(segmentedControl)
        addSubview(pageViewControl.view)
        
        // constraint
        titleView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(safeAreaLayoutGuide)
            $0.height.equalTo(125)
        }
        
        segmentedControl.snp.makeConstraints {
            $0.top.equalTo(titleView.snp.bottom)
            $0.leading.trailing.equalTo(safeAreaLayoutGuide)
            $0.height.equalTo(40)
        }
        
        pageViewControl.view.snp.makeConstraints {
            $0.top.equalTo(segmentedControl.snp.bottom)
            $0.leading.trailing.bottom.equalTo(safeAreaLayoutGuide)
        }
        
    }
    
    private func setupPageViewMemberObject() {
        viewControllerList.append(firstPage)
        viewControllerList.append(secondPage)
        viewControllerList.append(thirdPage)
        viewControllerList.append(fourthPage)
        viewControllerList.append(fifthPage)
        guard let viewControllerFirstObject = self.viewControllerList.first else { return }
        DispatchQueue.main.async {
            self.pageViewControl.setViewControllers([viewControllerFirstObject], direction: .forward, animated: false) { [weak self] (_) in
                guard let weakSelf = self else { return }
                // preload next page when setup page view control
                weakSelf.presenter.notifyPageViewPreload()
            }
        }
    }
    
    // MARK: - Add Target
    @objc func segmentedChange(sender: UISegmentedControl) {
        DispatchQueue.main.async {
            self.pageViewControl.setViewControllers([self.viewControllerList[sender.selectedSegmentIndex]], direction: sender.selectedSegmentIndex > self.presenter.selectedIndex ? .forward : .reverse, animated: true) { [weak self] (complete) in
                if complete {
                    guard let weakSelf = self else { return }
                    weakSelf.presenter.selectedIndex = sender.selectedSegmentIndex
                    // preload previous or next page when segmented change
                    weakSelf.presenter.notifyPageViewPreload()
                }
            }
        }
    }
    
}
