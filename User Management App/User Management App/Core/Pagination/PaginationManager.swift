//
//  PaginationManager.swift
//  User Management App
//
//  Created by oguzhan on 4.08.2025.
//

import Foundation
import Combine

class PaginationManager<T>: ObservableObject {
    @Published var currentPage = 1
    @Published var pageSize = 5
    @Published var totalItems = 0
    @Published var isLoadingMore = false
    
    private var allItems: [T] = []
    
    var totalPages: Int {
        guard totalItems > 0 else { return 1 }
        return (totalItems + pageSize - 1) / pageSize
    }
    
    var hasNextPage: Bool {
        return currentPage < totalPages
    }
    
    var hasPreviousPage: Bool {
        return currentPage > 1
    }
    
    var currentPageItems: [T] {
        let startIndex = (currentPage - 1) * pageSize
        let endIndex = min(startIndex + pageSize, allItems.count)
        guard startIndex < allItems.count else { return [] }
        return Array(allItems[startIndex..<endIndex])
    }
    
    var pageInfo: String {
        let startItem = ((currentPage - 1) * pageSize) + 1
        let endItem = min(currentPage * pageSize, totalItems)
        return "\(startItem)-\(endItem) of \(totalItems)"
    }
    
    init(pageSize: Int = 5) {
        self.pageSize = pageSize
    }
    
    func updateItems(_ items: [T]) {
        allItems = items
        totalItems = items.count
        
        if currentPage > totalPages && totalPages > 0 {
            currentPage = totalPages
        }
    }
    
    func nextPage() {
        guard hasNextPage else { return }
        currentPage += 1
    }
    
    func previousPage() {
        guard hasPreviousPage else { return }
        currentPage -= 1
    }
    
    func goToPage(_ page: Int) {
        let validPage = max(1, min(page, totalPages))
        currentPage = validPage
    }
    
    func goToFirstPage() {
        currentPage = 1
    }
    
    func goToLastPage() {
        currentPage = totalPages
    }
    
    func refresh() {
        currentPage = 1
    }
}

struct PaginatedResult<T> {
    let items: [T]
    let currentPage: Int
    let totalPages: Int
    let totalItems: Int
    let hasNextPage: Bool
    let hasPreviousPage: Bool
    let pageInfo: String
}

extension PaginationManager {
    func getPaginatedResult() -> PaginatedResult<T> {
        return PaginatedResult(
            items: currentPageItems,
            currentPage: currentPage,
            totalPages: totalPages,
            totalItems: totalItems,
            hasNextPage: hasNextPage,
            hasPreviousPage: hasPreviousPage,
            pageInfo: pageInfo
        )
    }
}

class InfiniteScrollManager<T>: ObservableObject {
    @Published var displayedItems: [T] = []
    @Published var isLoadingMore = false
    @Published var hasMoreData = true
    
    private var allItems: [T] = []
    private let pageSize: Int
    private var loadedCount = 0
    
    init(pageSize: Int = 10) {
        self.pageSize = pageSize
    }
    
    func updateAllItems(_ items: [T]) {
        allItems = items
        loadedCount = 0
        displayedItems = []
        hasMoreData = !items.isEmpty
        loadNextBatch()
    }
    
    func loadNextBatch() {
        guard !isLoadingMore && hasMoreData else { return }
        
        isLoadingMore = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let nextBatch = Array(self.allItems[self.loadedCount..<min(self.loadedCount + self.pageSize, self.allItems.count)])
            
            self.displayedItems.append(contentsOf: nextBatch)
            self.loadedCount += nextBatch.count
            self.hasMoreData = self.loadedCount < self.allItems.count
            self.isLoadingMore = false
        }
    }
    
    func refresh() {
        loadedCount = 0
        displayedItems = []
        hasMoreData = !allItems.isEmpty
        loadNextBatch()
    }
    
    func shouldLoadMore(currentItem: T) -> Bool where T: Identifiable {
        guard let currentIndex = displayedItems.firstIndex(where: { $0.id == currentItem.id }) else {
            return false
        }
        
        let threshold = max(1, displayedItems.count - 3)
        return currentIndex >= threshold && hasMoreData && !isLoadingMore
    }
}