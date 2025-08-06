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
                
                MainContentView(
                    viewModel: viewModel,
                    isLoadingDetail: $isLoadingDetail,
                    selectedUser: $selectedUser,
                    showingDetail: $showingDetail
                )
            }
            .navigationBarTitleDisplayMode(.automatic)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    AddUserButton(
                        showingAddUser: $showingAddUser,
                        isDisabled: isLoadingDetail || viewModel.isLoading
                    )
                }
            }
        }
        .sheet(isPresented: $showingDetail) {
            if let user = selectedUser {
                UserDetailView(userId: user.id)
            }
        }
        .sheet(isPresented: $showingAddUser) {
            AddUserView { newUser in
                viewModel.addUser(newUser)
            }
        }
        .onAppear {
            if viewModel.users.isEmpty && !viewModel.isLoading {
                loadRealData()
            }
        }
        .onChange(of: viewModel.hasError) { hasError in
            print("🎯 Error state changed: \(hasError)")
            if !hasError {
                print("✅ Error cleared successfully!")
            }
        }
    }
    
    private func loadRealData() {
        print("🚀 Loading users from real backend API with pagination (5 per page)...")
        viewModel.loadUsers()
    }
}

// MARK: - Main Content View
struct MainContentView: View {
    @ObservedObject var viewModel: UserListViewModel
    @Binding var isLoadingDetail: Bool
    @Binding var selectedUser: User?
    @Binding var showingDetail: Bool
    
    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.users.isEmpty {
                LoadingView()
            } else if viewModel.hasError && viewModel.users.isEmpty {
                ErrorView(viewModel: viewModel)
            } else {
                UserListContentView(
                    viewModel: viewModel,
                    isLoadingDetail: $isLoadingDetail,
                    selectedUser: $selectedUser,
                    showingDetail: $showingDetail
                )
            }
        }
    }
}

// MARK: - Loading View
struct LoadingView: View {
    var body: some View {
        VStack(spacing: Spacing.lg) {
            AppProgressView.primary

            
            Text(Strings.Loading.users)
                .captionStyle()
                .foregroundColor(.primaryBlue)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.backgroundPrimary.opacity(0.95))
        .screenPadding()
    }
}

// MARK: - Error View
struct ErrorView: View {
    @ObservedObject var viewModel: UserListViewModel
    
    var body: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "exclamationmark.triangle")
                .iconSize(Layout.iconXLarge)
                .foregroundColor(.errorRed)
            
            Text(viewModel.errorMessage)
                .cardTitleStyle()
                .multilineTextAlignment(.center)
            
            RetryButton {
                print("🔴 RETRY BUTTON PRESSED")
                viewModel.retryLoadUsers()
            }
            .disabled(viewModel.isLoading)
        }
        .screenPadding()
    }
}

// MARK: - User List Content View
struct UserListContentView: View {
    @ObservedObject var viewModel: UserListViewModel
    @Binding var isLoadingDetail: Bool
    @Binding var selectedUser: User?
    @Binding var showingDetail: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                RefreshableScrollView(
                    isRefreshing: $viewModel.isRefreshing,
                    onRefresh: {
                        viewModel.refreshUsers()
                    }
                ) {
                    LazyVStack(spacing: Spacing.md) {
                        UserItemsList(
                            users: viewModel.filteredUsers,
                            onUserTap: { user in
                                handleUserTap(user: user)
                            },
                            onLoadNextPage: {
                                viewModel.loadNextPage()
                            }
                        )
                        
                        PaginationFooter(viewModel: viewModel)
                    }
                    .screenPadding()
                }
            }
        }
    }
    
    private func handleUserTap(user: User) {
        isLoadingDetail = true
        selectedUser = user
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isLoadingDetail = false
            showingDetail = true
        }
    }
}

// MARK: - User Items List
struct UserItemsList: View {
    let users: [User]
    let onUserTap: (User) -> Void
    let onLoadNextPage: () -> Void
    
    var body: some View {
        ForEach(users) { user in
            UserListItemView(user: user) {
                onUserTap(user)
            }
            .onAppear {
                if user.id == users.last?.id {
                    onLoadNextPage()
                }
            }
        }
    }
}

// MARK: - Pagination Footer
struct PaginationFooter: View {
    @ObservedObject var viewModel: UserListViewModel
    
    var body: some View {
        Group {
            if viewModel.isLoadingPage {
                LoadingPageIndicator()
            }
            
            if !viewModel.hasMorePages && !viewModel.users.isEmpty {
                AllUsersLoadedIndicator()
            }
        }
    }
}

// MARK: - Loading Page Indicator
struct LoadingPageIndicator: View {
    var body: some View {
        HStack {
            AppProgressView.custom(scale: 0.8, tint: .primary)

            Text(Strings.Loading.page)
                .captionStyle()
        }
        .padding(.vertical, Spacing.md)
    }
}

// MARK: - All Users Loaded Indicator
struct AllUsersLoadedIndicator: View {
    var body: some View {
        Text(Strings.Loading.allUsersLoaded)
            .captionStyle()
            .padding(.vertical, Spacing.md)
    }
}

// MARK: - Add User Button
struct AddUserButton: View {
    @Binding var showingAddUser: Bool
    let isDisabled: Bool
    
    var body: some View {
        Button(action: {
            showingAddUser = true
        }) {
            Image(systemName: "plus")
                .foregroundColor(.primaryBlue)
        }
        .disabled(isDisabled)
    }
}

// MARK: - Retry Button
struct RetryButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "arrow.clockwise")
                Text(Strings.Actions.tryAgain)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.primaryBlue)
            .foregroundColor(.white)
            .cornerRadius(Layout.buttonCornerRadius)
        }
    }
}

// MARK: - Refreshable Scroll View
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
