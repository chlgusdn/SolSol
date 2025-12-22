//
//  Int+Extension.swift
//  SolSol
//
//  Created by NUNU:D on 12/22/25.
//

import Foundation

public extension Int {
    
    var decimalValue: Decimal {
        return NSDecimalNumber(value: self).decimalValue
    }
}
