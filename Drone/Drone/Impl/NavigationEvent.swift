//
//  NavigationEvent.swift
//  BabyMood
//
//  Created by Daniel on 9/23/16.
//  Copyright © 2016 Worthless Apps. All rights reserved.
//

import UIKit

protocol StoryboardInstantiable: class {
    static var storyboardIdentifier: String {get}
    static func instantiateFromStoryboard(storyboard: UIStoryboard) -> Self
}

extension UIViewController: StoryboardInstantiable {
    
    static var storyboardIdentifier: String {
        // Get the name of current class
        let classString = NSStringFromClass(self)
        let components = classString.componentsSeparatedByString(".")
        assert(components.count > 0, "Failed extract class name from \(classString)")
        return components.last!
    }
    
    class func instantiateFromStoryboard(storyboard: UIStoryboard) -> Self {
        return instantiateFromStoryboard(storyboard, type: self)
    }
}

extension UIViewController {
    
    // Thanks to generics, return automatically the right type
    private class func instantiateFromStoryboard<T: UIViewController>(storyboard: UIStoryboard, type: T.Type) -> T {
        return storyboard.instantiateViewControllerWithIdentifier(self.storyboardIdentifier) as! T
    }
}

enum NavigationEvent {
    
    enum PushStyle {
        case Push, Modal
    }
    
    case Push(UIViewController, PushStyle)
    case Pop
    
    init(_ viewModel: ViewModelProtocol) {
        
        if let vm = viewModel as? LoginViewModel {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let loginVC = LoginViewController.instantiateFromStoryboard(storyBoard)
            loginVC.updateWithViewModel(vm)
            self = .Push(loginVC, .Push)
        }/* else if let vm = viewModel as? CreateTodoViewModel {
            self = .Push(CreateTodoViewController(viewModel: vm), .Modal)
        }*/ else {
            self = .Push(UIViewController(), .Push)
        }
    }
    
}
