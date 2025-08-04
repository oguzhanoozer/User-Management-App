//
//  SplashView.swift
//  User Management App
//
//  Created by oguzhan on 4.08.2025.
//

import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opacity = 0.5
    
    var body: some View {
        if isActive {
            UserListView()
        } else {
            ZStack {
                Color.backgroundPrimary
                    .ignoresSafeArea()
                
                VStack(spacing: Spacing.lg) {
                    // App Icon/Logo placeholder
                    Circle()
                        .fill(Color.primaryBlue)
                        .frame(width: 120, height: 120)
                        .overlay(
                            Image(systemName: "person.3.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.textOnPrimary)
                        )
                        .scaleEffect(size)
                        .opacity(opacity)
                    
                    // App Title
                    VStack(spacing: Spacing.sm) {
                        Text(Strings.App.title)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.textPrimary)
                        
                        Text(Strings.App.subtitle)
                            .font(.title)
                            .fontWeight(.medium)
                            .foregroundColor(.primaryBlue)
                    }
                    .scaleEffect(size)
                    .opacity(opacity)
                }
            }
            .onAppear {
                withAnimation(.easeIn(duration: 1.2)) {
                    self.size = 0.9
                    self.opacity = 1.0
                }
                
                // Navigate to main app after animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        self.isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    SplashView()
        .applyTheme()
}