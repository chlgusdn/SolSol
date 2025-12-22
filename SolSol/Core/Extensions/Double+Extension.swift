//
//  Double+Extension.swift
//  SolSol
//
//  Created by NUNU:D on 11/25/25.
//

import Foundation

public extension Double {
    
    var decimalValue: Decimal {
        return Decimal(floatLiteral: self)
    }
    
    var intValue: Int {
        return Int(self)
    }
}
