import Foundation

@Observable
final class TeamSelectionViewModel {
    private(set) var easternTeams: [TeamInfo] = []
    private(set) var westernTeams: [TeamInfo] = []
    private(set) var isLoading = false
    private(set) var error: DataError?
    
    private let dataRepository: DataRepositoryProtocol
    
    init(dataRepository: DataRepositoryProtocol) {
        self.dataRepository = dataRepository
        organizeTeams()
    }
    
    private func organizeTeams() {
        let allTeams = dataRepository.allTeams
        easternTeams = allTeams.filter { $0.conference == "Eastern" }
        westernTeams = allTeams.filter { $0.conference == "Western" }
    }
}
