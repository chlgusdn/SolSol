//
//  Combine+Async.swift
//  SolSol
//
//  Created by NUNU:D on 6/21/25.
//

import Foundation
import Combine

extension Publishers {
    /// async 함수를 Publisher로 변환하는 Publisher
    struct Async<Output>: Publisher {
        typealias Failure = Error

        private let asyncOperation: () async throws -> Output

        init(_ asyncOperation: @escaping () async throws -> Output) {
            self.asyncOperation = asyncOperation
        }

        func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
            let subscription = AsyncSubscription(
                asyncOperation: asyncOperation,
                subscriber: subscriber
            )
            subscriber.receive(subscription: subscription)
        }
    }

    /// async 함수를 Publisher로 변환 (기본)
    static func async<T>(_ asyncOperation: @escaping () async throws -> T) -> Publishers.Async<T> {
        return Publishers.Async(asyncOperation)
    }

    /// async 함수를 Publisher로 변환 (detached Task 사용)
    static func asyncDetached<T>(_ asyncOperation: @escaping () async throws -> T) -> AnyPublisher<T, Error> {
        return Deferred {
            Future { promise in
                Task.detached {
                    do {
                        let result = try await asyncOperation()
                        promise(.success(result))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }

    /// async 함수를 Publisher로 변환 (우선순위 지정 가능)
    static func async<T>(priority: TaskPriority? = nil, _ asyncOperation: @escaping () async throws -> T) -> AnyPublisher<T, Error> {
        return Deferred {
            Future { promise in
                Task(priority: priority) {
                    do {
                        let result = try await asyncOperation()
                        promise(.success(result))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }

    /// async 함수를 Publisher로 변환 (MainActor에서 실행)
    @MainActor
    static func asyncMain<T>(_ asyncOperation: @escaping () async throws -> T) -> AnyPublisher<T, Error> {
        return Deferred {
            Future { promise in
                Task { @MainActor in
                    do {
                        let result = try await asyncOperation()
                        promise(.success(result))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - AsyncSubscription 구현
private class AsyncSubscription<Output, S: Subscriber>: Subscription where S.Input == Output, S.Failure == Error {

    private let asyncOperation: () async throws -> Output
    private var subscriber: S?
    private var task: Task<Void, Never>?

    init(asyncOperation: @escaping () async throws -> Output, subscriber: S) {
        self.asyncOperation = asyncOperation
        self.subscriber = subscriber
    }

    func request(_ demand: Subscribers.Demand) {
        guard demand > 0, task == nil else { return }

        task = Task {
            do {
                let result = try await asyncOperation()

                // 취소 확인
                guard !Task.isCancelled else { return }

                _ = subscriber?.receive(result)
                subscriber?.receive(completion: .finished)
            } catch {
                subscriber?.receive(completion: .failure(error))
            }
        }
    }

    func cancel() {
        task?.cancel()
        task = nil
        subscriber = nil
    }
}
