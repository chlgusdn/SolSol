//
//  Decimal+Extension.swift
//  SolSol
//
//  Created by NUNU:D on 12/22/25.
//

import Foundation

public extension Decimal {
    
    var doubleValue: Double {
        return NSDecimalNumber(decimal: self).doubleValue
    }
    
}
