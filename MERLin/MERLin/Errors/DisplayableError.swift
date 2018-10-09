//
//  DisplayableError.swift
//  TheBay
//
//  Created by Giuseppe Lanza on 26/07/18.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import Foundation

public protocol DisplayableError: Error {
    var title: String? { get }
    var errorMessage: String? { get }
}
