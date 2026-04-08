import UIKit
import Testing
import DesignSystem
@testable import HomePresentation

struct HomePresentationTests {
    @Test
    func chartSnapshot_buildsTotalBasedStackedBarFrames() async throws {
        let snapshot = HomeExpenseChartSnapshot(
            entries: [
                SDChartDataEntry(label: "Food", color: .systemRed, x: 2, y: 0),
                SDChartDataEntry(label: "Transport", color: .systemBlue, x: 3, y: 0),
                SDChartDataEntry(label: "Etc", color: .systemGreen, x: 5, y: 0),
            ]
        )

        let frames = snapshot.segmentFrames(in: CGRect(x: 0, y: 0, width: 100, height: 20))

        #expect(snapshot.totalValue == 10)
        #expect(frames.count == 3)
        #expect(abs(frames[0].width - 20) < 0.001)
        #expect(abs(frames[1].width - 30) < 0.001)
        #expect(abs(frames[2].width - 50) < 0.001)
        #expect(abs(frames[2].maxX - 100) < 0.001)
    }

    @Test
    func chartSnapshot_returnsNoFramesForEmptyEntries() async throws {
        let snapshot = HomeExpenseChartSnapshot(entries: [])

        let frames = snapshot.segmentFrames(in: CGRect(x: 0, y: 0, width: 120, height: 20))

        #expect(snapshot.totalValue == 0)
        #expect(frames.isEmpty)
    }
}
