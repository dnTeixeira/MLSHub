import Foundation
import SwiftUI

@Observable
final class TeamConfirmationViewModel {
    private(set) var isLoading = false
    private(set) var error: DataError?
    
    private let userSettingsService: UserSettingsServiceProtocol
    private let dataRepository: DataRepositoryProtocol
    private let navigationCoordinator: NavigationCoordinator
    
    init(
        userSettingsService: UserSettingsServiceProtocol,
        dataRepository: DataRepositoryProtocol,
        navigationCoordinator: NavigationCoordinator
    ) {
        self.userSettingsService = userSettingsService
        self.dataRepository = dataRepository
        self.navigationCoordinator = navigationCoordinator
    }
    
    @MainActor
    func selectTeam(_ team: TeamInfo) async {
        isLoading = true
        error = nil
        
        userSettingsService.selectTeam(team)
        
        do {
            _ = try await dataRepository.fetchRemoteStats()
            
            try await Task.sleep(nanoseconds: 500_000_000)
            
            navigationCoordinator.navigateToHome()
        } catch {
            self.error = DataError.from(error)
        }
        
        isLoading = false
    }
}
