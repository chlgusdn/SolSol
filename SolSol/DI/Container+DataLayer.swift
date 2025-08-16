//
//  DataSourceDIContainers.swift
//  SolSol
//
//  Created by NUNU:D on 8/16/25.
//

import Foundation
import Factory

// MARK: - Access
public extension Container {
    var sqlAccessor: Factory<SQLAccessor> {
        self {
            fatalError("""
                [ERROR] "SQLAccessor is not implemented:
                > [SQLAccessorable은 앱 시작 시 미리 초기화 되어야합니다]
                """)
        }
        .singleton
    }
}

// MARK: - DataSource
public extension Container {
    
    /// 유저 정보 관련 데이터소스 DI
    var userDataSource: Factory<UserLocalDataSourceRepository> {
        self {
            do {
                return try UserLocalDataSourceRepositoryImpl(
                    accessor: self.sqlAccessor()
                )
            }
            catch {
                fatalError("UserLocalDataSourceRepository 초기화 실패 \(error)")
            }
        }
    }
    
    /// 예산 관련 데이터소스 DI
    var budgetDataSource: Factory<BudgetLocalDataSourceRepository> {
        self {
            do {
                return try BudgetDataSourceRepositoryImpl(
                    accessor: self.sqlAccessor()
                )
            }
            catch {
                fatalError("BudgetLocalDataSourceRepository 초기화 실패 \(error)")
            }
        }
    }
    
    /// 거래 내용 관련 데이터 소스 DI
    var transactionDataSource: Factory<TransactionLocalDataSourceRepository> {
        self {
            do {
                return try TransactionDataSourceRepositoryImpl(
                    accessor: self.sqlAccessor()
                )
            }
            catch {
                fatalError("TransactionLocalDataSourceRepository 초기화 실패 \(error)")
            }
        }
    }
    
    /// 알림 관련 데이터 소스 DI
    var notificationDataSource: Factory<NotificationLocalDataSourceRepository> {
        self {
            do {
                return try NotificationDataSourceRepositroyImpl(
                    accessor: self.sqlAccessor()
                )
            }
            catch {
                fatalError("NotificationLocalDataSourceRepository 초기화 실패 \(error)")
            }
        }
    }
}
