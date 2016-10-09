//
//  LoginViewController.swift
//  Drone
//
//  Created by Daniel on 10/9/16.
//  Copyright © 2016 Worthless Apps. All rights reserved.
//

import UIKit
import SwiftLCS

enum AuthViewState {
    case Login, Register
    
    func cellArray() -> [AuthCellType] {
        switch self {
        case Login:
            return [.Headline,
                    .Separator,
                    .EmailTextField,
                    .PasswordTextField,
                    .LoginButton]
        case Register:
            return [.EmailTextField,
                    .NameTextField,
                    .PasswordTextField,
                    .LoginButton]
        }
    }
}

enum AuthCellType: String {
    case Headline = "Headline"
    case EmailTextField = "EmailTextField"
    case NameTextField = "NameTextField"
    case PasswordTextField = "PasswordTextField"
    case LoginButton = "LoginButton"
    case Separator = "Separator"
}

class LoginViewController: ReactiveViewController<LoginViewModel>, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var currentState: AuthViewState = .Login
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentState = .Login

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - State changes
    
    func transitionToViewState(newState: AuthViewState) {
        let diff = currentState.cellArray().diff(newState.cellArray())
        currentState = newState
        
        let addedIndexes = diff.addedIndexes.map({ NSIndexPath(forRow: $0, inSection: 0) })
        let removedIndexes = diff.removedIndexes.map({ NSIndexPath(forRow: $0, inSection: 0) })
        
        tableView?.beginUpdates()
        tableView?.insertRowsAtIndexPaths(addedIndexes,
                                          withRowAnimation: .Fade)
        tableView?.deleteRowsAtIndexPaths(removedIndexes,
                                          withRowAnimation: .Fade)
        tableView?.endUpdates()
    }

    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var newState = AuthViewState.Login
        if (currentState == .Login) {
            newState = .Register
        }
        transitionToViewState(newState)
    }
    
    
    // MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("\(currentState)")
        return currentState.cellArray().count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let currentCellEnum = currentState.cellArray()[indexPath.row]
        return tableView.dequeueReusableCellWithIdentifier(currentCellEnum.rawValue) ?? UITableViewCell()
    }
}

