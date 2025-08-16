//
//  Container+DomainLayer.swift
//  SolSol
//
//  Created by NUNU:D on 8/16/25.
//

import Foundation
import Factory

public extension Container {
    
    /// 유저 도메인 레포지토리
    var userRepository: Factory<UserRepositoryProtocol> {
        self {
            return UserRepositoryImpl(
                localDataSource: self.userDataSource()
            )
        }
    }
    
    /// 예산 관련 도메인 레포지토리
    var budgetRepository: Factory<BudgetRepositoryProtocol> {
        self {
            return BudgetRepositoryImpl(
                localDataSource: self.budgetDataSource()
            )
        }
    }
    
    /// 거래 내용 관련 도메인 레포지토리
    var transactionRepository: Factory<TransactionRepositroyProtocol> {
        self {
            return TransactionRepositroyImpl(
                localDataSource: self.transactionDataSource()
            )
        }
    }
    
    /// 알림 관련 도메인 레포지토리
    var notificationRepository: Factory<NotificationRepositoryProtocol> {
        self {
            return NotificationRepositoryImpl(
                localDataSource: self.notificationDataSource()
            )
        }
    }
}
