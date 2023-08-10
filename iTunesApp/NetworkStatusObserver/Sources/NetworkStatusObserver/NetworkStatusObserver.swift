import Foundation
import Network

public class WeakRef  {
    weak var ref: NetworkStatusObserverDelegate?
    public init(_ ref: NetworkStatusObserverDelegate) {
        self.ref = ref
    }
}

public protocol NetworkStatusObserverDelegate: AnyObject {
    func onConnectionChanged(_ isConnected: Bool)
}

public protocol NetworkStatusObserverProtocol {
    var delegates: [WeakRef] { get set }
    var isConnected: Bool { get }
    
    func startObserving()
    func stopObserving()
}

public final class NetworkStatusObserver {
    
    public static let shared: NetworkStatusObserverProtocol = NetworkStatusObserver()
    
    public var delegates = [WeakRef]()
    
    private let networkQueue = DispatchQueue.global()
    private let networkMonitor = NWPathMonitor()
    
    public private(set) var isConnected: Bool = false
    
    private var isLoadedOnce: Bool = false
    
    private init() {}
    
    private func notifyDelegates(_ isConnected: Bool) {
        for delegate in delegates {
            delegate.ref?.onConnectionChanged(isConnected)
        }
    }
}

extension NetworkStatusObserver: NetworkStatusObserverProtocol {
    public func startObserving() {
        networkMonitor.start(queue: networkQueue)
        networkMonitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            
            switch path.status {
            case .satisfied:
                isConnected = !isLoadedOnce
            case .unsatisfied:
                isConnected = isLoadedOnce
            case .requiresConnection:
                isConnected = false
            default:
                isConnected = false
            }
            
            isLoadedOnce = true
            notifyDelegates(isConnected)
        }
    }
    
    public func stopObserving() {
        networkMonitor.cancel()
    }
}
