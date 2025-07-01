import XCTest
@testable import MLSHub

final class UserSettingsServiceTests: XCTestCase {
    
    var userDefaults: UserDefaults!
    var sut: UserSettingsService!
    private let testSuiteName = "TestUserDefaults"
    private let storageKey = "selectedTeam"

    override func setUp() {
        super.setUp()
        userDefaults = UserDefaults(suiteName: testSuiteName)
        userDefaults.removePersistentDomain(forName: testSuiteName)
        
        sut = UserSettingsService(userDefaults: userDefaults)
    }

    override func tearDown() {
        userDefaults.removePersistentDomain(forName: testSuiteName)
        userDefaults = nil
        sut = nil
        super.tearDown()
    }

    func test_selectTeam_savesTeamToUserDefaults() throws {
        let teamToSave = SampleData.atlanta
        
        sut.selectTeam(teamToSave)
        
        let data = userDefaults.data(forKey: storageKey)
        XCTAssertNotNil(data, "Data should be saved to UserDefaults")
        
        let decoder = JSONDecoder()
        let retrievedTeam = try XCTUnwrap(try? decoder.decode(TeamInfo.self, from: data!))
        
        XCTAssertEqual(retrievedTeam, teamToSave)
    }
    
    func test_clearSelectedTeam_removesTeamFromUserDefaults() {
        sut.selectTeam(SampleData.miami)
        XCTAssertNotNil(userDefaults.data(forKey: storageKey))
        
        sut.clearSelectedTeam()
        
        XCTAssertNil(sut.selectedTeam, "The selected team property should be nil")
        XCTAssertNil(userDefaults.data(forKey: storageKey), "The data in UserDefaults should be removed")
    }
    
    func test_init_loadsExistingTeamFromUserDefaults() throws {
        let teamToLoad = SampleData.miami
        let data = try XCTUnwrap(try? JSONEncoder().encode(teamToLoad))
        userDefaults.set(data, forKey: storageKey)
        
        let newSUT = UserSettingsService(userDefaults: userDefaults)
        
        XCTAssertNotNil(newSUT.selectedTeam, "The service should load the team on init")
        XCTAssertEqual(newSUT.selectedTeam, teamToLoad)
    }
}
