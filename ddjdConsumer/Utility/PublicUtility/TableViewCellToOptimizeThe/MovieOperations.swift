import Foundation

//队列管理类，追踪每个操作的状态
class MovieOperations {
    static let shared=MovieOperations()
    private init(){}
    //追踪进行中的和等待中的下载操作
    lazy var downloadsInProgress = [IndexPath:Operation]()
    //图片下载队列
    lazy var downloadQueue:OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Download queue"
        queue.maxConcurrentOperationCount = 1
        return queue
        }()
}
