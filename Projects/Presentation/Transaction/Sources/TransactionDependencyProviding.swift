//
//  TransactionDependencyProviding.swift
//  TransactionPresentation
//
//  Created by Codex on 6/20/26.
//

public protocol TransactionDependencyProviding: AnyObject {
    func makeTransactionInputViewModel(initialType: TransactionInputType) -> TransactionInputViewModel
}
