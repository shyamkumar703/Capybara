//
//  ParallelWorkerPool.swift
//
//
//  Created by Shyam Kumar on 6/23/24.
//

import Foundation

class ParallelWorkerPool<ResultType> {
    private var workers = [DispatchWorkItem]()
    private let queue = DispatchQueue(label: "com.example.concurrent", qos: .userInitiated, attributes: .concurrent)

    public init(
        numberOfWorkers: Int,
        work: @escaping () -> ResultType,
        completion: @escaping (ResultType) -> Void
    ) {
        for _ in 0..<numberOfWorkers {
            let worker = DispatchWorkItem {
                let workResult = work()
                completion(workResult)
                self.workers.forEach { $0.cancel() }
            }
            self.workers.append(worker)
        }
    }
    
    public func run() {
        for worker in workers {
            queue.async(execute: worker)
        }
    }
}
