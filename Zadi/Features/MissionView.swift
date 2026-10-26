
import SwiftUI

struct MissionView: View {
    @Environment(\.dismiss) private var dismiss
    // MARK: - Selected Character
    let character: String
    
    private var isGirl: Bool {
        character == "girl"
    }
    
    private var characterImage: String {
        isGirl ? "MissionGirl" : "MissionBoy"
    }
    
    private var missionText: String {
        isGirl
        ? "جاهزة نجهّز وجبتنا؟\nاختاري أكلة تفضّلينها"
        : "جاهز نجهّز وجبتنا؟\nاختر أكلة تفضّلها"
    }
    
    var body: some View {
        GeometryReader { geometry in
            
            let width = geometry.size.width
            let height = geometry.size.height
            
            ZStack {
                
                // MARK: - Kitchen Background
                Image("MissionKitchen")
                    .resizable()
                    .scaledToFill()
                    .frame(width: width, height: height)
                    .ignoresSafeArea()
                    .clipped()
                // MARK: - Character
                Image(characterImage)
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: width * 0.35,
                        height: height * 0.72
                    )
                    .position(
                        x: width * 0.25,
                        y: height * 0.65
                    )
                
                // MARK: - Speech Bubble Tail
                Circle()
                    .fill(.white)
                    .frame(width: width * 0.025)
                    .position(
                        x: width * 0.48,
                        y: height * 0.48
                    )
                
                Circle()
                    .fill(.white)
                    .frame(width: width * 0.038)
                    .position(
                        x: width * 0.51,
                        y: height * 0.43
                    )
                
                // MARK: - Speech Bubble
                ZStack {
                    Ellipse()
                        .fill(.white)
                        .overlay {
                            Ellipse()
                                .stroke(
                                    Color.brown.opacity(0.45),
                                    lineWidth: 2
                                )
                        }
                        .shadow(
                            color: .black.opacity(0.12),
                            radius: 6,
                            y: 3
                        )
                    
                    Text(missionText)
                        .font(.system(
                            size: height * 0.043,
                            weight: .bold
                        ))
                        .foregroundStyle(
                            Color(red: 0.65, green: 0.39, blue: 0.11)
                        )
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.8)
                        .padding(24)
                }
                .frame(
                    width: width * 0.44,
                    height: height * 0.30
                )
                .position(
                    x: width * 0.70,
                    y: height * 0.28
                )
                
                // MARK: - Start Mission Button
                NavigationLink {
                    FoodSelectionPage(character: character)
                } label: {
                    HStack(spacing: 10) {
                        
                        Image(systemName: "hand.tap.fill")
                            .font(.system(size: height * 0.032))
                            .foregroundStyle(
                                Color(red: 0.32, green: 0.39, blue: 0.70)
                            )
                        
                        Text("لنبدأ")
                            .font(.system(
                                size: height * 0.045,
                                weight: .bold
                            ))
                            .foregroundStyle(
                                Color(red: 0.32, green: 0.39, blue: 0.70)
                            )
                        
                        Image(systemName: "chevron.left")
                            .font(.system(size: height * 0.03, weight: .bold))
                            .foregroundStyle(
                                Color(red: 0.32, green: 0.39, blue: 0.70)
                            )
                            .opacity(0.75)
                    }
                    .frame(
                        width: width * 0.28,
                        height: height * 0.12
                    )
                    .background(
                        Color(red: 1.0, green: 0.77, blue: 0.86),
                        in: Capsule()
                    )
                    .overlay {
                        Capsule()
                            .stroke(
                                Color.brown.opacity(0.35),
                                lineWidth: 2
                            )
                    }
                    .shadow(
                        color: .black.opacity(0.15),
                        radius: 8,
                        y: 5
                    )
                }
                .position(
                    x: width * 0.73,
                    y: height * 0.83
                )
                
                
                // MARK: - Back Button
               Button {
                   dismiss()
               } label: {
                   Image(systemName: "chevron.left")
                       .font(.system(size: 22, weight: .bold))
                       .foregroundStyle(
                           Color(red: 0.30, green: 0.40, blue: 0.55)
                       )
                       .frame(width: 52, height: 52)
                       .background(
                           .white.opacity(0.85),
                           in: Circle()
                       )
                       .shadow(
                           color: .black.opacity(0.12),
                           radius: 5,
                           y: 3
                       )
               }
               .buttonStyle(.plain)
               .position(
                   x: width * 0.055,
                   y: height * 0.09
               )
               .zIndex(100)
               .accessibilityLabel("الرجوع لاختيار الشخصية")

           
            } // End ZStack
            .frame(width: width, height: height)
            .clipped()

        } // End GeometryReader
        .ignoresSafeArea()
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)

        } // End body

    } // End MissionView

    #Preview(traits: .landscapeLeft) {
        NavigationStack {
            MissionView(character: "girl")
        }
    }
