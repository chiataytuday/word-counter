//
//  WordCounterTextField.swift
//  WordCounter
//
//  Created by Yifei He on 9/9/20.
//  Copyright © 2020 Arefly. All rights reserved.
//

import Foundation
import UIKit

// https://stackoverflow.com/a/63805005/2603230
class CustomInputAccessoryWithToolbarView: UIView {
    public var toolbar: UIToolbar!
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        // https://stackoverflow.com/a/58524360/2603230
        toolbar = UIToolbar(frame: frame)

        // Below is adopted from https://stackoverflow.com/a/46510833/2603230
        self.addSubview(toolbar)

        self.autoresizingMask = .flexibleHeight

        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.leadingAnchor.constraint(
            equalTo: self.leadingAnchor,
            constant: 0
        ).isActive = true
        toolbar.trailingAnchor.constraint(
            equalTo: self.trailingAnchor,
            constant: 0
        ).isActive = true
        toolbar.topAnchor.constraint(
            equalTo: self.topAnchor,
            constant: 0
        ).isActive = true
        // This is the important part:
        if #available(iOS 11.0, *) {
            toolbar.bottomAnchor.constraint(
                equalTo: self.safeAreaLayoutGuide.bottomAnchor,
                constant: 0
            ).isActive = true
        } else {
            toolbar.bottomAnchor.constraint(
                equalTo: self.layoutMarginsGuide.bottomAnchor,
                constant: 0
            ).isActive = true
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // https://stackoverflow.com/a/46510833/2603230
    // This is needed so that the inputAccesoryView is properly sized from the auto layout constraints.
    // Actual value is not important.
    override var intrinsicContentSize: CGSize {
        return CGSize.zero
    }
}
