//
//  HorizontalKeyboardComponent.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2019-05-20.
//  Copyright © 2019 Daniel Saidi. All rights reserved.
//

import UIKit

/**
 This protocol represents a view component that can be added
 to a horizontally flowing part of the keyboard.
 */
public protocol HorizontalKeyboardComponent: UIView {
    
    var widthConstraint: NSLayoutConstraint? { get set }
}

public extension HorizontalKeyboardComponent {
    
    var width: CGFloat {
        get { return widthConstraint?.constant ?? intrinsicContentSize.width }
        set { setWidth(to: newValue) }
    }
}

private extension HorizontalKeyboardComponent {
    
    func setWidth(to width: CGFloat) {
        widthConstraint = widthConstraint ?? widthAnchor.constraint(equalToConstant: width)
        widthConstraint?.priority = .defaultLow
        widthConstraint?.constant = width
        widthConstraint?.isActive = true
    }
}
