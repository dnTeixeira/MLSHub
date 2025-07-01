import Foundation

@Observable
final class HomeViewModel {
    private(set) var teamStats: TeamStats?
    private(set) var isLoading = false
    private(set) var error: DataError?
    
    let team: TeamInfo
    private let dataRepository: DataRepositoryProtocol
    private var loadingTask: Task<Void, Never>?
    
    var lastMatch: Match? { teamStats?.lastMatches.first }
    var upcomingMatches: [Match] { teamStats?.nextMatches ?? [] }
    var standings: Standings? { teamStats?.standings }
    
    init(team: TeamInfo, dataRepository: DataRepositoryProtocol) {
        self.team = team
        self.dataRepository = dataRepository
    }
    
    deinit {
        loadingTask?.cancel()
    }
    
    @MainActor
    func loadTeamStats() async {
        loadingTask?.cancel()
        
        loadingTask = Task {
            isLoading = true
            error = nil
            
            do {
                _ = try await dataRepository.fetchRemoteStats()
                teamStats = dataRepository.stats(for: team)
                
                if teamStats == nil {
                    error = .noDataAvailable
                }
            } catch {
                self.error = DataError.from(error)
            }
            
            isLoading = false
        }
        
        await loadingTask?.value
    }
}

