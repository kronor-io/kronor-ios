import SwiftUI
import Apollo

class PollingManager: Cancellable {
    let pollingInterval: TimeInterval
    private var pollingTimer: Timer?
    private var pollingAction: (() -> Void)?

    init(pollingInterval: TimeInterval) {
        self.pollingInterval = pollingInterval
    }

    func startPolling(pollingAction: @escaping () -> Void) -> Cancellable {
        self.pollingAction = pollingAction
        DispatchQueue.main.async {
            self.pollingTimer = Timer.scheduledTimer(
                withTimeInterval: self.pollingInterval,
                repeats: true
            ) { _ in
                pollingAction()
            }
        }
        return self
    }

    func cancel() {
        pollingTimer?.invalidate()
        pollingTimer = nil
        pollingAction = nil
    }
}
