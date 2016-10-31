//
//  ViewModelServices.swift
//  BabyMood
//
//  Created by Daniel on 9/23/16.
//  Copyright © 2016 Worthless Apps. All rights reserved.
//

import Foundation

protocol ViewModelServicesDelegate: class {
    func services(services: ViewModelServicesProtocol, navigate: NavigationEvent)
}

protocol ViewModelServicesProtocol {
    func push(viewModel: ViewModelProtocol)
    func pop(viewModel: ViewModelProtocol)
    var user: User? { get }
}

struct User {
    
    let uid: String
    let email: String
    
    init(authData: FIRUser) {
        uid = authData.uid
        email = authData.email!
    }
    
    init(uid: String, email: String) {
        self.uid = uid
        self.email = email
    }
    
}

class ViewModelServices: NSObject, ViewModelServicesProtocol {
    // MARK: Properties
    
//    let todo: TodoServiceProtocol
//    let date: DateServiceProtocol
    
    var user: User?
    private weak var delegate: ViewModelServicesDelegate?
    
    // MARK: API
    
    init(delegate: ViewModelServicesDelegate?) {
        self.delegate = delegate
//        self.todo = TodoService()
//        self.date = DateService()
        super.init()
        
        FIRAuth.auth()?.addAuthStateDidChangeListener() { [unowned self] auth, user in
            if let user = user {
                self.user = User(authData: user)
            }
        }
    }
    
    func push(viewModel: ViewModelProtocol) {
        delegate?.services(self, navigate: NavigationEvent(viewModel))
    }
    
    func pop(viewModel: ViewModelProtocol) {
        delegate?.services(self, navigate: .Pop)
    }
}
