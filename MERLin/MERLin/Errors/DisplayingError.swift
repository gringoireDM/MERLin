//
//  DisplayingError.swift
//  Module
//
//  Created by Giuseppe Lanza on 27/07/18.
//  Copyright © 2018 Gilt. All rights reserved.
//

import Foundation

public protocol DisplayingError: class {
    func displayError(_ error: DisplayableError)
}
