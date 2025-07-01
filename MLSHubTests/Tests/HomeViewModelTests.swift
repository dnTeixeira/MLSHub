import XCTest
@testable import MLSHub

@MainActor
final class HomeViewModelTests: XCTestCase {

    var mockDataRepository: MockDataRepository!
    var sut: HomeViewModel!

    override func setUp() {
        super.setUp()
        mockDataRepository = MockDataRepository()
        sut = HomeViewModel(team: SampleData.miami, dataRepository: mockDataRepository)
    }

    override func tearDown() {
        mockDataRepository = nil
        sut = nil
        super.tearDown()
    }

    func test_initialState_isCorrect() {
        XCTAssertNil(sut.teamStats)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.error)
        XCTAssertEqual(sut.team.id, SampleData.miami.id)
    }

    func test_loadTeamStats_success_updatesTeamStatsAndComputedProperties() async {
        let stats = ["1": SampleData.miamiStats]
        mockDataRepository.statsToReturn = stats
        
        await sut.loadTeamStats()
        
        XCTAssertFalse(sut.isLoading, "isLoading should be false after loading completes")
        XCTAssertNil(sut.error, "Error should be nil on success")
        XCTAssertNotNil(sut.teamStats, "teamStats should be populated")
        XCTAssertEqual(sut.teamStats?.standings.rank, 1)
        XCTAssertEqual(sut.lastMatch?.opponent, "Orlando City")
        XCTAssertEqual(mockDataRepository.fetchRemoteStatsCallCount, 1, "fetchRemoteStats should be called once")
    }
    
    func test_loadTeamStats_failure_setsError() async {
        mockDataRepository.errorToThrow = SampleData.networkError
        
        await sut.loadTeamStats()
        
        XCTAssertFalse(sut.isLoading, "isLoading should be false after loading fails")
        XCTAssertNil(sut.teamStats, "teamStats should remain nil on failure")
        XCTAssertNotNil(sut.error, "error should be populated on failure")
        
        guard case .networkError = sut.error else {
            XCTFail("Expected a network error, but got \(String(describing: sut.error))")
            return
        }
    }
}
