//
//  LoginViewModel.swift
//  Drone
//
//  Created by Daniel on 10/9/16.
//  Copyright © 2016 Worthless Apps. All rights reserved.
//

import UIKit
import ReactiveCocoa
import Result

class LoginViewModel: ViewModel {
    
    // Input
    let nameInput: MutableProperty<String> = MutableProperty("")
    let emailInput: MutableProperty<String> = MutableProperty("")
    let passwordInput: MutableProperty<String> = MutableProperty("")
    
    // Actions
//    let switchRegisterAction: Action<(), Void, NoError>
//    let switchRegisterCocoaAction: CocoaAction
    
    internal var didPushMap: Bool = false

    override init(services: ViewModelServicesProtocol) {
//        switchRegisterAction = Action() { () -> SignalProducer<Void, NoError> in
//            return SignalProducer(value: ())
//        }
//        switchRegisterCocoaAction = CocoaAction(switchRegisterAction, input: ())
        
        super.init(services: services)
        FIRAuth.auth()?.addAuthStateDidChangeListener() { [unowned self] auth, user in
            if let user = user {
                print("user: \(user): \(auth)")
                self.navigateToMap()
            }
        }
    }
    
    func bindCell(cell: UITableViewCell?, type: AuthCellType, state: AuthViewState) {
        switch type {
        case .NameTextField:
            if let cell = cell as? NameTableViewCell {
                disposables.append(nameInput <~ cell.textField.rex_text)
            }
            break
        case .EmailTextField:
            if let cell = cell as? EmailTableViewCell {
                disposables.append(emailInput <~ cell.textField.rex_text)
            }
            break
        case .PasswordTextField:
            if let cell = cell as? PasswordTableViewCell {
                disposables.append(passwordInput <~ cell.textField.rex_text)
            }
            break
        default:
            break
        }
    }
    
    func executeLogin() {
        FIRAuth.auth()?.signInWithEmail(emailInput.value, password: passwordInput.value) { [unowned self] user, error in
            if let user = user {
                print("logged into user \(user)")
                self.navigateToMap()
            }
        }
    }
    
    func executeSignup() {
        FIRAuth.auth()?.createUserWithEmail(emailInput.value, password: passwordInput.value) { user, error in
            if error == nil {
                self.executeLogin()
            }
        }
    }
    
    func navigateToMap() {
        if (didPushMap) {
            return
        }
        didPushMap = true
        
        let vm = MapSetupViewModel(services: services)
        services.push(vm)
    }
}
