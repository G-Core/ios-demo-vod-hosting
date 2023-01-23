//
//  VideoDataManager.swift
//  GCoreVodDemo
//
//  Created by Evgenij Polubin on 04.10.2022.
//

import AsyncDisplayKit

protocol VideoTableManagerDelegate: AnyObject {
    func loadVideos(page: Int, isNextPage: Bool) 
    func onNextDataAdded()
}

final class VideoTableManager: NSObject {
    // MARK: - Public properies
    private enum DataType {
        case prevData, currentData, nextData
    }

    weak var delegate: VideoTableManagerDelegate?

    weak var tableView: ASTableNode? {
        didSet {
            tableView?.delegate = self
            tableView?.dataSource = self
        }
    }

    var prevData: [VOD] = []
    var currentData: [VOD] = []
    var nextData: [VOD] = []

    var currentPage = 1

    // MARK: - Private properties
    private let maxItemsOnPage = 25

    private lazy var maxIndexOnData = maxItemsOnPage - 1

    private var lastCell: VODSmoothCell?

    private var dataTotalCount: Int {
        prevData.count + currentData.count + nextData.count
    }

    private var indexForUpdateData: Int {
        dataTotalCount - 3
    }

    private var itemCountInPrevData: Int {
        max(prevData.count - 1, 0)
    }

    private var itemCountInCurrentData: Int {
        max(currentData.count - 1, 0)
    }

    // MARK: - Public methods
    func add(loadedData: [VOD], isNextPage: Bool) {
        if isNextPage {
            add(nextLoadedData: loadedData)
        } else {
            add(prevLoadedData: loadedData)
        }
    }

    // MARK: - Private methods
    private func add(nextLoadedData: [VOD]) {
        let allData = prevData + currentData + nextData

        let newVideos: [VOD] = nextLoadedData.filter { loadedVideo in
            return !allData.contains { $0.id == loadedVideo.id }
        }

        var count = 0

        if currentData.count != maxItemsOnPage {
          currentData += newVideos
          count = prevData.count
        } else {
          nextData = newVideos
          count = prevData.count + currentData.count
        }
        
        var indexPaths: [IndexPath] = []
        
        newVideos.indices.forEach {
            let path = IndexPath(row: $0 + count, section: 0)
            indexPaths += [path]
        }

        tableView?.insertRows(at: indexPaths, with: .none)

        if !newVideos.isEmpty {
            delegate?.onNextDataAdded()
        }
    }

    private func add(prevLoadedData: [VOD]) {
        prevData = prevLoadedData
    }

    private func getVideoDataType(from index: Int) -> DataType {
        if !prevData.isEmpty && (0...maxIndexOnData).contains(index) {
            return .prevData
        }

        guard !nextData.isEmpty else { return .currentData }

        if prevData.isEmpty {
            return (0...maxIndexOnData).contains(index) ? .currentData : .nextData
        }

        return (0...maxIndexOnData*2).contains(index) ? .currentData : .nextData
    }
}

// MARK: - ASTableDataSource
extension VideoTableManager: ASTableDataSource {
    func tableNode(_: ASTableNode, numberOfRowsInSection _: Int) -> Int {
        prevData.count + currentData.count + nextData.count
    }

    func tableNode(_: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        let video: VOD
        
        let videoDataType = getVideoDataType(from: indexPath.row)

        switch videoDataType {
        case .currentData:
            let index = indexPath.row - prevData.count
            video = currentData[index]
        case .nextData:
            let index = indexPath.row - prevData.count - currentData.count
            video = nextData[index]
        case .prevData:
            video = prevData[indexPath.row]
        }

        let cell = VODSmoothCell(data: video)

        if lastCell == nil {
            lastCell = cell
            cell.isShouldPlay = true
        }

        return {
            return cell
        }
    }
}

// MARK: ASTableDelegate
extension VideoTableManager: ASTableDelegate {
    func tableNode(_: ASTableNode, constrainedSizeForRowAt _: IndexPath) -> ASSizeRange {
        ASSizeRangeMake(tableView?.bounds.size ?? .zero)
    }

    func shouldBatchFetch(for _: ASTableNode) -> Bool {
        return false
    }

    // We track the user's scrolling in order to start the current video before the cell is centralized
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let scrollViewHeight = scrollView.frame.size.height
        let scollViewOffSetY = scrollView.contentOffset.y

        var currentVideoIndex = Int(scollViewOffSetY / scrollViewHeight)

        var isScrollDown = velocity.y > 0
        var isScrollUp = velocity.y < 0
        
        let nextVideoOffsetY = CGFloat(currentVideoIndex) * (scrollViewHeight * 1.5)
        let isNextVideoWillSelected = nextVideoOffsetY < scollViewOffSetY

        func loadPreviousVodIfNeeded() {
            let isMinVodNumberForLoad = currentVideoIndex <= 3
            let isAllowedPage = currentPage - 1 > 0
            guard prevData.isEmpty, isMinVodNumberForLoad, isAllowedPage else { return }
            delegate?.loadVideos(page: currentPage - 1, isNextPage: false)
        }

        if isScrollDown && currentVideoIndex + 1 < dataTotalCount {
            currentVideoIndex += 1
        } else if isScrollUp {
            loadPreviousVodIfNeeded()
        } else if isNextVideoWillSelected && currentVideoIndex + 1 < dataTotalCount {
            isScrollDown = true
            currentVideoIndex += 1
        } else {
            isScrollUp = true
            loadPreviousVodIfNeeded()
        }

        let indexPath = IndexPath(item: currentVideoIndex, section: 0)

        guard let currentCell = tableView?.nodeForRow(at: indexPath) as? VODSmoothCell, currentCell != lastCell else { return }

        // and to download the next array of videos
        if currentVideoIndex >= indexForUpdateData && nextData.isEmpty {
            let page: Int = currentData.count == maxItemsOnPage ? (currentPage + 1) : currentPage
            delegate?.loadVideos(page: page, isNextPage: true)
        }

        lastCell?.isShouldPlay = false
        currentCell.isShouldPlay = true
        lastCell = currentCell
    }

    // we also track the direction of scrolling to load the player on the screen
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.panGestureRecognizer.velocity(in: scrollView).y < 0 {
            let nextVideoIndex = Int(scrollView.contentOffset.y / scrollView.frame.size.height) + 1
        
            if nextVideoIndex < dataTotalCount {
                let indexForNextData = nextVideoIndex - itemCountInPrevData - itemCountInCurrentData
                if nextData.indices.contains(indexForNextData) {
                    prevData = currentData
                    currentData = nextData
                    nextData = []
                    currentPage += 1
                }
            }

        } else if scrollView.panGestureRecognizer.velocity(in: scrollView).y > 0 {
            let nextVideo = Int(scrollView.contentOffset.y / scrollView.frame.size.height) - 1
            guard prevData.indices.contains(nextVideo) && nextVideo < maxIndexOnData else { return }
            nextData = currentData
            currentData = prevData
            prevData = []
            currentPage -= 1
        }
    }
}
