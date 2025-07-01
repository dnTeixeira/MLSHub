import Foundation

@Observable
final class DataRepository: DataRepositoryProtocol {
    private(set) var allTeams: [TeamInfo] = []
    private(set) var allTeamsStats: [String: TeamStats] = [:]
    private(set) var isLoading = false
    
    private let localDataService: LocalDataServiceProtocol
    private let networkService: NetworkServiceProtocol
    
    init(localDataService: LocalDataServiceProtocol, networkService: NetworkServiceProtocol) {
        self.localDataService = localDataService
        self.networkService = networkService
    }
    
    func loadLocalTeams() async throws {
        allTeams = try await localDataService.loadTeams()
    }
    
    func fetchRemoteStats() async throws -> [String: TeamStats] {
        guard !isLoading else { return allTeamsStats }
        
        isLoading = true
        defer { isLoading = false }
        
        let stats: [String: TeamStats] = try await networkService.fetch(MLSStatsEndpoint.teamStats())
        allTeamsStats = stats
        return stats
    }
    
    func stats(for team: TeamInfo) -> TeamStats? {
        allTeamsStats[String(team.id)]
    }
    
    func logo(forTeamName teamName: String) -> String? {
        allTeams.first { team in
            team.name.localizedCaseInsensitiveCompare(teamName) == .orderedSame
        }?.logo
    }
}
