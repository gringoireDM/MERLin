//
//  OSLog.swift
//  MERLin
//
//  Created by Giuseppe Lanza on 09/11/2019.
//  Copyright © 2019 Giuseppe Lanza. All rights reserved.
//

import os.log

extension OSLog {
    private static var subsystem = "com.merlintech.merlin"
    
    static let moduleManager = OSLog(subsystem: subsystem, category: "ModuleManager")
    static let router = OSLog(subsystem: subsystem, category: "Router")
    static let listener = OSLog(subsystem: subsystem, category: "EventsListener")
    static let producer = OSLog(subsystem: subsystem, category: "Producer")
}
