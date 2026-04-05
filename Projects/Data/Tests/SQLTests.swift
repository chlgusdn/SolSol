//
//  SQLTests.swift
//  SolSolTests
//
//  Created by NUNU:D on 6/6/25.
//

import Testing
import Foundation
import Combine
@testable import SolSol

@Suite("SQLTest")
struct SQLTests {
    
    let accessor : SQLAccessor
    let repository : UserRepositoryProtocol
    
    init() async throws {
        self.accessor = await SQLAccessor()
        self.repository = UserRepositoryImpl(
            localDataSource: try UserLocalDataSourceRepositoryImpl(
                accessor: accessor
            )
        )
    }
    
    @Test("Insert 단건 테스트")
    func insertUser() async throws {
        let user = UserModel(createdAt: Date())
        var cancellable: AnyCancellable?
        let isSuccess = await withCheckedContinuation { countinuation in
            
            cancellable = repository.saveUser(user: user)
                .replaceError(with: false)
                .sink { isSuccess in
                    countinuation.resume(returning: isSuccess)
                    cancellable = nil
                }
            _ = cancellable
        }
        
        #expect(isSuccess, "insert에 성공해야합니다")
    }
    
    @Test("100개 insert 스트레스 테스트", .timeLimit(.minutes(1)))
    func test_insert_stress_for_100() async throws {
        var userList: [UserModel] = []
        for _ in 1...100 {
            userList.append(
                UserModel(createdAt: Date())
            )
        }
        var cancellable: AnyCancellable?
        let isSuccess = await withCheckedContinuation { countinuation in
            
            cancellable = repository.saveUsers(users: userList)
                .replaceError(with: false)
                .sink { isSuccess in
                    countinuation.resume(returning: isSuccess)
                    cancellable = nil
                }
            _ = cancellable
        }
        
        #expect(isSuccess, "insert에 성공해야합니다")
    }
    
    @Test("Fetch User 단건 테스트")
    func test_user_fetch_one() async throws {
        let currentDate = Date()
        let user = UserModel(createdAt: currentDate)
        var cancellable: AnyCancellable?
        let fetchModel = await withCheckedContinuation { countinuation in
            cancellable =  repository.saveUser(user: user)
                .replaceError(with: false)
                .flatMap { _ in self.repository.getUser() }
                .sink { completion in} receiveValue: { model in
                    countinuation.resume(returning: model)
                    cancellable = nil
                }
            _ = cancellable
        }
        
        #expect(fetchModel.createdAt.millisecond == user.createdAt.millisecond, "fetchModel의 데이터와 같아야합니다")
    }

}
