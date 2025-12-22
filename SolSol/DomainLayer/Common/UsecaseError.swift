//
//  UsecaseError.swift
//  SolSol
//
//  Created by NUNU:D on 12/22/25.
//

import Foundation

public enum UsecaseError: Error {
    /// 값이 null 인경우
    case notFound
    // 메시지형식 에러
    case message(message: String)
    // 그 외 에러
    case unknown(error: Error)
}
