//
//  Date+Extension.swift
//  SolSol
//
//  Created by NUNU:D on 6/6/25.
//

import Foundation

public extension Date {
    
    var millisecond: TimeInterval {
        return floor(self.timeIntervalSince1970 * 1000)
    }
    
    var second: TimeInterval {
        return floor(self.timeIntervalSince1970)
    }
    
    var minute: TimeInterval {
        return floor(self.timeIntervalSince1970 / 60)
    }
    
    var hour: TimeInterval {
        return floor(self.timeIntervalSince1970 / (60 * 60))
    }
    
}
