import Foundation
@testable import MLSHub

final class MockDataRepository: DataRepositoryProtocol {
    var teamsToReturn: [TeamInfo] = []
    var statsToReturn: [String: TeamStats]?
    var errorToThrow: Error?
    
    private(set) var fetchRemoteStatsCallCount = 0
    private(set) var loadLocalTeamsCallCount = 0
    
    var allTeams: [TeamInfo] {
        teamsToReturn
    }
    
    var isLoading: Bool = false
    
    func loadLocalTeams() async throws {
        loadLocalTeamsCallCount += 1
        if let error = errorToThrow {
            throw error
        }
    }
    
    func fetchRemoteStats() async throws -> [String : TeamStats] {
        fetchRemoteStatsCallCount += 1
        if let error = errorToThrow {
            throw error
        }
        return statsToReturn ?? [:]
    }
    
    func stats(for team: TeamInfo) -> TeamStats? {
        statsToReturn?[String(team.id)]
    }
    
    func logo(forTeamName teamName: String) -> String? {
        teamsToReturn.first { $0.name == teamName }?.logo
    }
}
