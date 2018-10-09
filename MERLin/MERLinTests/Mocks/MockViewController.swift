//
//  MockViewController.swift
//  MERLinTests
//
//  Created by Giuseppe Lanza on 10/09/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import UIKit
import MERLin

class MockViewController: UIViewController, Themed {
    var applyTimes: Int = 0
    func applyTheme() {
        applyTimes += 1
    }
}


