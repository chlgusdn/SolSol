//
//  UserRepositoryImpl.swift
//  SolSol
//
//  Created by NUNU:D on 6/6/25.
//

import Foundation
import Combine

public final class UserRepositoryImpl: UserRepositoryProtocol {
    
    let localDataSource: UserLocalDataSourceRepository
    
    init(localDataSource: UserLocalDataSourceRepository) {
        self.localDataSource = localDataSource
    }
    
    public func getUser() -> AnyPublisher<UserModel, any Error> {
        return Future { promise in
            Task {
                if let result = await self.localDataSource.getUser() {
                    let userDomainModel = UserMapper.toDomain(to: result)
                    promise(.success(userDomainModel))
                }
                else {
                    promise(.failure(NSError(domain: "", code: -1)))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    public func getUsers() -> AnyPublisher<[UserModel], any Error> {
        return Future { promise in
            Task {
                let result = await self.localDataSource.getUsers()
                let models = result.map { UserMapper.toDomain(to: $0) }
                promise(.success(models))
            }
        }
        .eraseToAnyPublisher()
    }
    
    public func saveUser(user: UserModel) -> AnyPublisher<Bool, any Error> {
        return Future { promise in
            Task {
                let isSuccess = await self.localDataSource.saveUser(user)
                promise(.success(isSuccess))
            }
        }
        .eraseToAnyPublisher()
    }
    
    public func saveUsers(users: [UserModel]) -> AnyPublisher<Bool, any Error> {
        return Future { promise in
            Task {
                let isSuccess = await self.localDataSource.saveUsers(users: users)
                promise(.success(isSuccess))
            }
        }
        .eraseToAnyPublisher()
    }
    
    public func updateUser(user: UserModel) -> AnyPublisher<Bool, any Error> {
        return Future { promise in
            Task {
                let isSuccess = await self.localDataSource.updateUser(user)
                promise(.success(isSuccess))
            }
        }
        .eraseToAnyPublisher()
    }
    
    public func deleteUser(user: UserModel) -> AnyPublisher<Bool, any Error> {
        return Future { promise in
            Task {
                let isSuccess = await self.localDataSource.deleteUser(user)
                promise(.success(isSuccess))
            }
        }
        .eraseToAnyPublisher()
    }
    
    
}
