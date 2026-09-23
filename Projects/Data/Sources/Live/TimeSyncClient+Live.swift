import Clients
import Dependencies
import Foundation
@preconcurrency import Kronos

extension TimeSyncClient: DependencyKey {
    public static let liveValue = Self(
        sync: {
            await withCheckedContinuation { continuation in
                // `first:`는 오프라인 시 호출되지 않으므로 반드시 `completion:`에서 재개한다
                Kronos.Clock.sync(completion: { date, _ in
                    continuation.resume(returning: date)
                })
            }
        }
    )
}
