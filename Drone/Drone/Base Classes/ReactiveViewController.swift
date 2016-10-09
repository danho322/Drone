//
//  ReactiveViewController.swift
//  BabyMood
//
//  Created by Daniel on 9/23/16.
//  Copyright © 2016 Worthless Apps. All rights reserved.
//

import UIKit

protocol ReactiveViewControllerProtocol {
    func updateWithViewModel(viewModel: ViewModelProtocol)
}

class ReactiveViewController<T: ViewModelProtocol>: UIViewController {
    
    // MARK: Properties
    
    var viewModel: T!
    
    // MARK: API
    
    func updateWithViewModel(viewModel: T) {
        self.viewModel = viewModel
    }
    
    
}
