import SwiftUI

struct WelcomeView: View {
    @Environment(AppContainer.self) private var container
    
    var body: some View {
        ZStack {
            Image(.welcomeViewBackground)
                .resizable()
                .ignoresSafeArea()
            
            VStack {
                Image(.outlinedBlackMLSLogo)
                    .resizable()
                    .frame(width: 100, height: 100)
                    .padding(.bottom, 20)
                
                Text("Welcome to MLS Hub.")
                    .font(.custom("Montserrat-Bold", size: 28))
                
                Text("The league at your fingertips.")
                    .font(.custom("Montserrat-Light", size: 20))
                    .padding(.top, 5)
                
                Spacer()
                
                Button {
                    container.navigationCoordinator.navigateToTeamSelection()
                } label: {
                    Text("Continue")
                        .font(.custom("Montserrat-Medium", size: 18))
                        .foregroundStyle(.white)
                        .frame(width: 280, height: 55)
                        .background(Color.black.opacity(0.6))
                        .clipShape(.buttonBorder)
                }
            }
            .padding(.vertical, 120)
        }
        .ignoresSafeArea()
    }
}
