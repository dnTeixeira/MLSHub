import SwiftUI

struct TeamConfirmationView: View {
    let team: TeamInfo
    @Environment(AppContainer.self) private var container
    @State private var viewModel: TeamConfirmationViewModel?
    
    @State private var playerOffset: CGFloat = UIScreen.main.bounds.width
    @State private var logoScale: CGFloat = 0.8
    @State private var logoRotation: Double = -15
    @State private var logoOpacity: Double = 0.0
    
    var body: some View {
        ZStack {
            Image(.teamConfirmationViewBackground)
                .resizable()
                .ignoresSafeArea()
            
            backgroundLogo
            playerImage
            gradientOverlay
            
            VStack {
                headerView
                Spacer()
                continueButton
            }
            
            if viewModel?.isLoading == true {
                LoadingOverlay(team: team)
            }
        }
        .navigationBarBackButtonHidden()
        .onAppear {
            setupViewModel()
            animateElements()
        }
    }
    
    private var backgroundLogo: some View {
        Image(team.logo)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 320, height: 320)
            .opacity(logoOpacity)
            .scaleEffect(logoScale)
            .rotationEffect(.degrees(logoRotation))
    }
    
    private var playerImage: some View {
        VStack {
            HStack(alignment: .center) {
                Image(team.playerImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 550)
                    .mask(
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: .white, location: 0.5),
                                .init(color: .white.opacity(0.6), location: 0.8),
                                .init(color: .clear, location: 1.0)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .offset(x: playerOffset)
                    .padding(.leading)
            }
        }
        .ignoresSafeArea()
    }
    
    private var gradientOverlay: some View {
        RadialGradient(
            gradient: Gradient(colors: [Color(hex: team.colors.primary).opacity(0.65), .clear]),
            center: .leading,
            startRadius: 20,
            endRadius: 400
        )
        .ignoresSafeArea()
    }
    
    private var headerView: some View {
        HStack {
            Button {
                container.navigationCoordinator.goBack()
            } label: {
                Image(systemName: "chevron.left")
                    .foregroundColor(.white)
                    .font(.system(size: 20, weight: .semibold))
            }
            
            Spacer()
            
            Text(team.name)
                .font(.montserratBold(size: 20))
                .foregroundColor(.white)
            
            Spacer()
        }
        .padding(.horizontal)
    }
    
    private var continueButton: some View {
        Button {
            Task {
                await viewModel?.selectTeam(team)
            }
        } label: {
            HStack {
                if viewModel?.isLoading == true {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                    
                    Text("Loading...")
                        .font(.montserratMedium(size: 18))
                        .foregroundStyle(.white)
                } else {
                    Text("Continue")
                        .font(.montserratMedium(size: 18))
                        .foregroundStyle(.white)
                }
            }
            .frame(width: 280, height: 55)
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(hex: team.colors.primary), lineWidth: 2)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(viewModel?.isLoading ?? false)
    }
        
    private func setupViewModel() {
        guard viewModel == nil else { return }
        
        viewModel = TeamConfirmationViewModel(
            userSettingsService: container.userSettingsService,
            dataRepository: container.dataRepository,
            navigationCoordinator: container.navigationCoordinator
        )
    }
    
    private func animateElements() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.3)) {
            logoScale = 1.0
            logoRotation = 0
            logoOpacity = 0.5
        }
        
        withAnimation(.spring(response: 0.9, dampingFraction: 0.8, blendDuration: 0.5)) {
            playerOffset = 0
        }
    }
}

private struct LoadingOverlay: View {
    let team: TeamInfo
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(team.logo)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .opacity(0.8)
                    .scaleEffect(1.0)
                    .animation(
                        .easeInOut(duration: 1.0)
                        .repeatForever(autoreverses: true),
                        value: UUID()
                    )
                
                VStack(spacing: 8) {
                    Text("Loading \(team.name)")
                        .font(.montserratBold(size: 18))
                        .foregroundColor(.white)
                    
                    Text("Preparing team data...")
                        .font(.montserratMedium(size: 14))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                HStack(spacing: 4) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(Color(hex: team.colors.primary))
                            .frame(width: 8, height: 8)
                            .scaleEffect(1.0)
                            .animation(
                                .easeInOut(duration: 0.6)
                                .repeatForever()
                                .delay(Double(index) * 0.2),
                                value: UUID()
                            )
                    }
                }
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: team.colors.primary).opacity(0.3),
                                Color(hex: team.colors.secondary).opacity(0.2),
                                Color.black.opacity(0.5)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
        }
        .transition(.opacity.combined(with: .scale(scale: 0.9)))
    }
}
