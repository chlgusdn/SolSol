import SQLiteData

/// 칸별 수입·지출 합계 (칸 번호로 GROUP BY)
@Selection
struct BucketTotal: Sendable {
    let index: Int
    let income: Int
    let expense: Int
}
