//
//  ViewModel.swift
//  BabyMood
//
//  Created by Daniel on 9/23/16.
//  Copyright © 2016 Worthless Apps. All rights reserved.
//

import Foundation
import ReactiveCocoa

protocol ViewModelProtocol {
    var services: ViewModelServicesProtocol { get }
    var disposables: [Disposable] { get set }
}

class ViewModel: NSObject, ViewModelProtocol {
    
    let services: ViewModelServicesProtocol
    var disposables: [Disposable] = []
    
    init(services: ViewModelServicesProtocol) {
        self.services = services
        super.init()
    }
    
    func disposeAll() {
        for disposable in disposables {
            disposable.dispose()
        }
    }
    
    deinit {
        disposeAll()
    }
}
