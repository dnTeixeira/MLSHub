import SwiftUI

struct TeamSelectionView: View {
    @Environment(AppContainer.self) private var container
    @State private var viewModel: TeamSelectionViewModel?
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 5)
    
    var body: some View {
        ZStack {
            Image(.teamSelectionViewBackground)
                .resizable()
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Image(.outlinedWhiteMLSLogo)
                    .resizable()
                    .frame(width: 68, height: 72)
                    .padding(.top, 30)
                
                if let viewModel = viewModel {
                    ConferenceTeamGrid(
                        title: "Eastern Conference",
                        teams: viewModel.easternTeams,
                        columns: columns
                    )
                    
                    ConferenceTeamGrid(
                        title: "Western Conference",
                        teams: viewModel.westernTeams,
                        columns: columns
                    )
                }
                
                Spacer()
            }
        }
        .background(Color.black)
        .navigationBarBackButtonHidden()
        .onAppear {
            if viewModel == nil {
                viewModel = TeamSelectionViewModel(dataRepository: container.dataRepository)
            }
        }
    }
}

private struct ConferenceTeamGrid: View {
    let title: String
    let teams: [TeamInfo]
    let columns: [GridItem]
    @Environment(AppContainer.self) private var container
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(title)
                .font(.custom("Montserrat-Bold", size: 16))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(teams) { team in
                    Button {
                        container.navigationCoordinator.navigateToTeamConfirmation(team: team)
                    } label: {
                        TeamLogoView(logo: team.logo)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

private struct TeamLogoView: View {
    let logo: String
    
    var body: some View {
        Image(logo)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 60, height: 60)
    }
}
