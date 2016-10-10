//
//  Extensions.swift
//  BabyMood
//
//  Created by Daniel on 9/24/16.
//  Copyright © 2016 Worthless Apps. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Result

// Treat an array as a stack.
extension Array {
    
    mutating func push(newElement: Element) {
        self.append(newElement)
    }
    
    mutating func append(newElements: [Element]?) {
        for e in newElements ?? [] {
            self.append(e)
        }
    }
    
    mutating func pop() -> Element? {
        return self.removeLast()
    }
    
    func peekAtStack() -> Element? {
        return self.last
    }
}

extension UITextField {
    var rex_text: SignalProducer<String, NoError> {
        return self.rac_textSignal().toSignalProducer()
            .map { $0 as? String ?? "" }
            .flatMapError { _ in SignalProducer<String, NoError>.empty }
    }
}
