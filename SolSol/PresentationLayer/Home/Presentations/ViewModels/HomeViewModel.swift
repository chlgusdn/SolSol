//
//  HomeViewModel.swift
//  SolSol
//
//  Created by NUNU:D on 12/27/25.
//

import Foundation

@Observable
final class HomeViewModel: ObservableObject {
    
    @Published private(set) var increasePercent: Int = 0
    
    init() {
        
    }
}
