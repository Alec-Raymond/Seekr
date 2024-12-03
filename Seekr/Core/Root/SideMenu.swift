import SwiftUI
import Combine

// Define a notification name
extension Notification.Name {
    static let hardModeToggled = Notification.Name("hardModeToggled")
}

struct SideMenu: View {
    @Binding var isVisible: Bool
    @EnvironmentObject var authViewModel: AuthViewModel
    @State public var isHardMode: Bool = false 

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Profile Button (leads to Profile View)
            NavigationLink(destination: ProfileView()) {
                HStack {
                    Image(systemName: "person.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                    Text("Profile")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .padding(.vertical, 10)
            }
            .simultaneousGesture(TapGesture().onEnded {
                // Collapse the menu when navigation occurs
                withAnimation {
                    isVisible = false
                }
            })

            // View Pins Button
            NavigationLink(destination: PinsView()) { // Make sure you have created PinsView
                HStack {
                    Image(systemName: "mappin.circle.fill") // Using a pin icon
                        .font(.title2)
                        .foregroundColor(.white)
                    Text("View Pins")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .padding(.vertical, 10)
            }
            .simultaneousGesture(TapGesture().onEnded {
                // Collapse the menu when navigation occurs
                withAnimation {
                    isVisible = false
                }
            })
            
            // Hard Mode Toggle
            Toggle(isOn: $isHardMode) {
                HStack {
                    Image(systemName: "trophy.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                    Text("Hard Mode")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .padding(.vertical, 10)
            }
            .toggleStyle(SwitchToggleStyle(tint: .red)) // Custom toggle style
            .onChange(of: isHardMode) { newValue in
                NotificationCenter.default.post(name: .hardModeToggled, object: nil, userInfo: ["isHardMode": isHardMode])
            }
            
            Spacer()
        }
        .padding(.top, 100)
        .padding(.horizontal, 20)
        .frame(minWidth: 200, maxWidth: 250, alignment: .leading)
        .background(Color("DarkBlue"))
        .cornerRadius(10, corners: [.topRight, .bottomRight])
        .shadow(radius: 5)
    }
}

// Preview for localized testing in Xcode
struct SideMenu_Previews: PreviewProvider {
    static var previews: some View {
        SideMenu(isVisible: .constant(true))
            .environmentObject(AuthViewModel())
    }
}
