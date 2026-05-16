//
//  Kronos+Extension.swift
//  SolSolCore
//
//  Created by NUNU:D on 5/16/26.
//  Copyright © 2026 SolSol. All rights reserved.
//

import Foundation
import Kronos

public extension Clock {

    @discardableResult
    static func synchronize() async -> Date {
        return await withCheckedContinuation { continuation in
            Clock.sync(first: { date, seconds in
                Log.i("시간 동기화 : NTP Date: \(date), seconds: \(seconds)")
                continuation.resume(returning: date)
            })
        }

    }
}
