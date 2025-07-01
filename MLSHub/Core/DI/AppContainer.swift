import Foundation
import SwiftUI

@Observable
final class AppContainer {
    private(set) var userSettingsService: UserSettingsServiceProtocol!
    private(set) var dataRepository: DataRepositoryProtocol!
    var navigationCoordinator: NavigationCoordinator!
    
    init() {
        setupDependencies()
    }
    
    private func setupDependencies() {
        let localDataService = LocalDataService()
        let networkService = NetworkService()
        
        dataRepository = DataRepository(
            localDataService: localDataService,
            networkService: networkService
        )
        
        userSettingsService = UserSettingsService()
        navigationCoordinator = NavigationCoordinator()
    }
    
    func initialize() async {
        do {
            try await dataRepository.loadLocalTeams()
        } catch {
            print("Failed to initialize app: \(error)")
        }
    }
}
