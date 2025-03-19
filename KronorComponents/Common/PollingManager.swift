import SwiftUI
import Apollo

class PollingManager: Cancellable {
    let pollingInterval: UInt64
    private var task: Task<(), Never>?
    private var pollingAction: (() -> Void)?

    init(pollingInterval: UInt64) {
        self.pollingInterval = pollingInterval
    }

    func startPolling(pollingAction: @escaping () -> Void) -> Cancellable {
        self.pollingAction = pollingAction
        self.task = Task {
           while(true) {
               try? await Task.sleep(nanoseconds: self.pollingInterval * NSEC_PER_SEC)
               if Task.isCancelled {
                   break
               }
               pollingAction()
           }
        }
       return self
    }

    func cancel() {
        self.task?.cancel()
        pollingAction = nil
    }
}
