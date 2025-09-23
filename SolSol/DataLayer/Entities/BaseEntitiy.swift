//
//  BaseEntitiy.swift
//  SolSol
//
//  Created by NUNU:D on 6/3/25.
//

import Foundation
import GRDB

public protocol BaseEntitiy: Codable, PersistableRecord, FetchableRecord, Sendable { }
