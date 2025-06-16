//
//  BaseEntitiy.swift
//  SolSol
//
//  Created by NUNU:D on 6/3/25.
//

import Foundation
import GRDB

public protocol BaseEntitiy: Codable, PersistableRecord, FetchableRecord {
    /// 기본키가 될 id값
    var id: Int64? { get set }
}
