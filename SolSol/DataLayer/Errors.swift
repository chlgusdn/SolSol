//
//  Errors.swift
//  SolSol
//
//  Created by NUNU:D on 8/14/25.
//

import Foundation

//MARK: - User Error
/// 유저 에러
public enum UserError: Error {
    /// 유저를 찾을 수 없습니다.
    case notFound
    /// 알 수 없는 에러
    case unknown
}

// MARK: - Budget Error
/// 예산 에러
public enum BudgetError: Error {
    /// 예산을 찾을 수 없습니다.
    case notFound
    /// 알 수 없는 에러
    case unknown
}

//MARK: - Transaction Error
public enum TransactionError: Error {
    /// 거래 내용을 찾을 수 없습니다
    case notFound
    /// 알 수 없는 에러
    case unknown
}
