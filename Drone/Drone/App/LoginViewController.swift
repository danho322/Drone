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
            return [.Headline("Login"),
                    .EmailTextField,
                    .PasswordTextField,
                    .SubmitButton("Login"),
                    .Separator,
                    .ToggleState("Sign up")]
        case Register:
            return [.EmailTextField,
                    .NameTextField,
                    .PasswordTextField,
                    .SubmitButton("Register"),
                    .Separator,
                    .ToggleState("Log in")]
        }
    }
}

enum AuthCellType {
    case Headline(String)
    case EmailTextField
    case NameTextField
    case PasswordTextField
    case SubmitButton(String)
    case ToggleState(String)
    case Separator
    
    func identifier() -> String {
        switch self {
        case .Headline:
            return "Headline"
        case .EmailTextField:
            return "EmailTextField"
        case .NameTextField:
            return "NameTextField"
        case .PasswordTextField:
            return "PasswordTextField"
        case .SubmitButton:
            return "SubmitButton"
        case .ToggleState:
            return "ToggleState"
        case .Separator:
            return "Separator"
        }
    }
}

extension AuthCellType: Equatable {
}

func ==(lhs: AuthCellType, rhs: AuthCellType) -> Bool {
    switch (lhs, rhs) {
    case (let .Headline(string1), let .Headline(string2)):
        return string1 == string2
    case (let .SubmitButton(string1), let .SubmitButton(string2)):
        return string1 == string2
    case (let .ToggleState(string1), let .ToggleState(string2)):
        return string1 == string2
    default:
        return lhs.identifier() == rhs.identifier()
    }
}


class HeadlineTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
}

class EmailTableViewCell: UITableViewCell {
    @IBOutlet weak var textField: UITextField!
}

class PasswordTableViewCell: UITableViewCell {
    @IBOutlet weak var textField: UITextField!
}

class NameTableViewCell: UITableViewCell {
    @IBOutlet weak var textField: UITextField!
}

class SubmitTableViewCell: UITableViewCell {
    @IBOutlet weak var submitButton: UIButton!
}

class ToggleTableViewCell: UITableViewCell {
    @IBOutlet weak var submitButton: UIButton!
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
    
    func onToggleTap() {
        var newState = AuthViewState.Register
        if (currentState == .Register) {
            newState = .Login
        }
        transitionToViewState(newState)
    }
    
    func onSubmitTap() {
        if (currentState == .Register) {
            viewModel.executeSignup()
        } else if (currentState == .Login) {
            viewModel.executeLogin()
        }
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
//        var newState = AuthViewState.Login
//        if (currentState == .Login) {
//            newState = .Register
//        }
//        transitionToViewState(newState)
    }
    
    
    // MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentState.cellArray().count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let currentCellEnum = currentState.cellArray()[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(currentCellEnum.identifier())
        switch currentCellEnum {
        case .Headline(let title):
            if let cell = cell as? HeadlineTableViewCell {
                cell.titleLabel.text = title
            }
        case .SubmitButton(let title):
            if let cell = cell as? SubmitTableViewCell {
                cell.submitButton.setTitle(title, forState: .Normal)
                cell.submitButton.addTarget(self, action: #selector(onSubmitTap), forControlEvents: .TouchUpInside)

            }
        case .ToggleState(let title):
            if let cell = cell as? ToggleTableViewCell {
                cell.submitButton.setTitle(title, forState: .Normal)
                cell.submitButton.addTarget(self, action: #selector(onToggleTap), forControlEvents: .TouchUpInside)
            }

        default:
            break
        }
        
        viewModel.bindCell(cell, type: currentCellEnum, state: currentState)
        
        return cell ?? UITableViewCell()
    }
}

