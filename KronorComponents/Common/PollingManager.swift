import SwiftUI

class PollingManager {
    let pollingInterval: UInt64
    private var task: Task<Void, Never>?

    init(pollingInterval: UInt64) {
        self.pollingInterval = pollingInterval
    }

    func startPolling(pollingAction: @escaping () async -> Void) -> Task<Void, Never> {
        let task = Task {
           while !Task.isCancelled {
               try? await Task.sleep(nanoseconds: self.pollingInterval * NSEC_PER_SEC)
               if Task.isCancelled {
                   break
               }
               await pollingAction()
           }
        }
        self.task = task
        return task
    }

    func cancel() {
        task?.cancel()
        task = nil
    }
}
