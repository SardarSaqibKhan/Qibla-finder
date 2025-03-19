//
//  QiblaView.swift
//  Qibla Finder
//
//  Created by sardar saqib on 04/03/2025.
//

import SwiftUI

struct QiblaView: View {
    
    @ObservedObject var locationService = LocationService()
    @State private var lastValidHeading: Double? = nil
   
    var body: some View {
        titleView()
        ZStack {
            SwiftUI.Color(locationService.isHeadingToTarget ? "AccentColor" : "whiteColor", bundle: .main)
                .ignoresSafeArea()
            
            Group {
                
                Media.Image.directionCompass
                    .resizable()
                    .frame(width: 300, height: 300)
                    .clipShape(Circle())
                    .padding(0)
                    .overlay(
                        Circle().stroke(locationService.isHeadingToTarget ? Color.white : Color.accentColor, lineWidth: 10)
                    )
                
                
                Media.Image.compassNeedle
                    .resizable()
                    .offset(y: -25)
                    .frame(width: 50, height: 150)
                    .rotationEffect(.degrees(locationService.qiblaAngle))
            }
            .padding(.horizontal)
            .scaledToFit()
            .frame(maxWidth: 200, maxHeight: 200)
            .rotationEffect(Angle(degrees: -locationService.headingDegrees))
        }
        .onAppear {
            locationService.requestAuthorization()
        }
        headingAngleView()
            .sensoryFeedback(trigger: locationService.headingDegrees) { oldValue, newValue in
                if locationService.isHeadingToTarget {
                    return .impact(flexibility: .solid, intensity: 1.0)
                }
                return .impact(flexibility: .solid, intensity: 0.5)
                
            }
    }
    
    private func giveHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
          generator.prepare()
          generator.impactOccurred(intensity: 1.0)
    }
    
    private func titleView() -> some View {
        Text("Qibla Direction")
            .font(.system(size: 20, weight: .bold))
    }
    private func headingAngleView() -> some View {
        VStack(spacing: 0) {
            Text(String(format: "🕋 | %.0f°", locationService.qiblaAngle))
                .font(.system(size: 16, weight: .regular))
            Text(String(format: "%.0f°", abs(locationService.headingDegrees)))
                .font(.system(size: 14, weight: .bold))
        }
        .foregroundColor(.black)
    }
}

#Preview {
    QiblaView()
}
