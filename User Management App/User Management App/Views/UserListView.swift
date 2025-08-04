//
//  UserListView.swift
//  User Management App
//
//  Created by oguzhan on 4.08.2025.
//

import SwiftUI

struct UserListView: View {
    @StateObject private var viewModel = UserListViewModel()
    @State private var selectedUser: User?
    @State private var showingDetail = false
    @State private var showingAddUser = false
    @State private var isLoadingDetail = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundPrimary
                    .ignoresSafeArea()
                
                if viewModel.isLoading && viewModel.users.isEmpty {
                    // Loading State
                    VStack(spacing: Spacing.lg) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .progressViewStyle(CircularProgressViewStyle(tint: .primaryBlue))
                        
                        Text(Strings.Loading.users)
                            .captionStyle()
                            .foregroundColor(.primaryBlue)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.backgroundPrimary.opacity(0.95))
                    .screenPadding()
                } else if viewModel.hasError && viewModel.users.isEmpty {
                    // Error State
                    VStack(spacing: Spacing.md) {
                        Image(systemName: "exclamationmark.triangle")
                            .iconSize(Layout.iconXLarge)
                            .foregroundColor(.errorRed)
                        
                        Text(Strings.Errors.general)
                            .cardTitleStyle()
                        
                        Text(viewModel.errorMessage)
                            .cardSubtitleStyle()
                            .multilineTextAlignment(.center)
                        
                        LayoutComponents.primaryButton {
                            Text(Strings.Actions.tryAgain)
                        }
                        .onTapGesture {
                            viewModel.retryLoadUsers()
                        }
                    }
                    .screenPadding()
                } else {
                                            // Content
                        VStack(spacing: 0) {
                            // User List
                            ScrollView {
                            RefreshableScrollView(
                                isRefreshing: $viewModel.isRefreshing,
                                onRefresh: {
                                    viewModel.refreshUsers()
                                }
                            ) {
                                LazyVStack(spacing: Spacing.md) {
                                    ForEach(viewModel.filteredUsers) { user in
                                        UserListItemView(user: user) {
                                            isLoadingDetail = true
                                            selectedUser = user
                                            
                                            // Simulate detail loading delay
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                isLoadingDetail = false
                                                showingDetail = true
                                            }
                                        }
                                        .onAppear {
                                            // Load next page when user reaches near end
                                            if user.id == viewModel.filteredUsers.last?.id {
                                                viewModel.loadNextPage()
                                            }
                                        }
                                    }
                                    
                                    // Loading more indicator
                                    if viewModel.isLoadingPage {
                                        HStack {
                                            ProgressView()
                                                .scaleEffect(0.8)
                                            Text(Strings.Loading.page)
                                                .captionStyle()
                                        }
                                        .padding(.vertical, Spacing.md)
                                    }
                                    
                                    // End of data indicator
                                    if !viewModel.hasMorePages && !viewModel.users.isEmpty {
                                        Text(Strings.Loading.allUsersLoaded)
                                            .captionStyle()
                                            .padding(.vertical, Spacing.md)
                                    }
                                }
                                .screenPadding()
                            }
                        }
                    }
                            }
            
            // Detail Loading Overlay
            if isLoadingDetail {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    VStack(spacing: Spacing.md) {
                        ProgressView()
                            .scaleEffect(1.2)
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        
                                                    Text(Strings.Loading.detail)
                            .captionStyle()
                            .foregroundColor(.white)
                    }
                    .padding(Spacing.xl)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(Layout.cornerRadiusMedium)
                }
            }
        }
        .navigationTitle(Strings.Navigation.users)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingAddUser = true
                }) {
                    Image(systemName: "plus")
                        .foregroundColor(.primaryBlue)
                }
                .disabled(isLoadingDetail || viewModel.isLoading)
            }
        }

        }
        .sheet(isPresented: $showingDetail) {
            if let user = selectedUser {
                UserDetailView(user: user)
            }
        }
        .sheet(isPresented: $showingAddUser) {
            AddUserView { newUser in
                viewModel.addUser(newUser)
            }
        }
        .onAppear {
            loadRealData()
        }
    }
    
    private func loadRealData() {
        // Load users from real backend API with pagination
        print("🚀 Loading users from real backend API with pagination (5 per page)...")
        viewModel.loadUsers()
    }
    

}



struct RefreshableScrollView<Content: View>: View {
    @Binding var isRefreshing: Bool
    let onRefresh: () -> Void
    let content: Content
    
    init(isRefreshing: Binding<Bool>, onRefresh: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self._isRefreshing = isRefreshing
        self.onRefresh = onRefresh
        self.content = content()
    }
    
    var body: some View {
        content
            .refreshable {
                onRefresh()
            }
    }
}



#Preview {
    UserListView()
        .applyTheme()
}
