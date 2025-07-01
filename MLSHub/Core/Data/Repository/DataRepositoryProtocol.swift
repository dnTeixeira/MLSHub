import Foundation

protocol DataRepositoryProtocol {
    var allTeams: [TeamInfo] { get }
    var isLoading: Bool { get }
    
    func loadLocalTeams() async throws
    func fetchRemoteStats() async throws -> [String: TeamStats]
    func stats(for team: TeamInfo) -> TeamStats?
    func logo(forTeamName teamName: String) -> String?
}
