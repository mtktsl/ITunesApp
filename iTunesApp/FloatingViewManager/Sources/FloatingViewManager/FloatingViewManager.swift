import UIKit

extension FloatingViewManager {
    fileprivate enum Sizes {
        //static let defaultPipSize = CGSize(width: 180, height: 101.25)
        static let edgeGap: CGFloat = 10
    }
}

public final class FloatingViewManager: NSObject {
    
    public static let shared = FloatingViewManager()
    
    public private(set) weak var view: UIView?
    private var recognizer: UIPanGestureRecognizer?
    
    @objc dynamic private weak var rootWindow: UIWindow? {
        didSet {
            windowFrameKVO = nil
            if rootWindow != nil {
                windowFrameKVO = observe(\.rootWindow!.frame) { [weak self] _, _ in
                    guard let self else { return }
                    layoutView()
                }
            }
        }
    }
    private var windowFrameKVO: NSKeyValueObservation?
    
    public private(set) var viewCurrentSize: FloatingViewManager.SizeModel?
    public private(set) var floatingLocation: FloatingLocation = .bottomLeft
    
    public var isPanGestureEnabled = true
    public var doesStickToEdgesAfterPanGesture = true
    public var resizeAnimationDuration = 0.35
    public var moveAnimationDuration = 0.35
    
    private var pipFrame: CGRect {
        
        guard let viewCurrentSize else { return .zero }
        switch viewCurrentSize {
        case .custom(let size):
            let window = view?.superview
            let safeFrame = window?.frame.inset(by: window?.safeAreaInsets ?? .zero) ?? .zero
            let calculatedY = safeFrame.origin.y + safeFrame.height - size.height
            
            return CGRect(
                x: safeFrame.origin.x + Sizes.edgeGap,
                y: calculatedY - Sizes.edgeGap,
                width: size.width,
                height: size.height
            )
        default:
            return .zero
        }
    }
    
    private override init() {
        super.init()
    }
    
    var initialCenter = CGPoint()
    @objc private func onViewPan(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard isPanGestureEnabled,
              let view = gestureRecognizer.view
        else { return }
        
        if viewCurrentSize == .fullScreen { return }
        
        let translation = gestureRecognizer.translation(in: view.superview)
        
        if gestureRecognizer.state == .began {
            self.initialCenter = view.center
        } else if gestureRecognizer.state == .changed {
            view.center = CGPoint(
                x: initialCenter.x + translation.x,
                y: initialCenter.y + translation.y
            )
        } else {
            guard doesStickToEdgesAfterPanGesture,
                  let root = view.superview
            else {
                initialCenter = view.center
                return
            }
            setFloatingInfo(
                isLeft: view.center.x < root.center.x,
                isBottom: view.center.y >= root.center.y
            )
            move(view: view, toLocation: floatingLocation)
        }
    }
    
    func setFloatingInfo(isLeft: Bool, isBottom: Bool) {
        if isLeft && isBottom {
            floatingLocation = .bottomLeft
        } else if isLeft && !isBottom {
            floatingLocation = .topLeft
        } else if !isLeft && isBottom {
            floatingLocation = .bottomRight
        } else if !isLeft && !isBottom {
            floatingLocation = .topRight
        }
    }
    
    private func move(view: UIView, toPoint point: CGPoint) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            UIView.animate(withDuration: TimeInterval(moveAnimationDuration), delay: .leastNonzeroMagnitude, options: .curveEaseInOut) {
                view.center = point
            }
        }
        initialCenter = point
    }
    
    private func move(view: UIView, toLocation: FloatingLocation) {
        guard let root = view.superview else { return }
        
        let halfHeight = view.frame.height / 2
        let halfWidth = view.frame.width / 2
        
        var targetPoint = initialCenter
        let safeFrame = root.frame.inset(by: root.safeAreaInsets)
        
        let leftEdge = safeFrame.origin.x + Sizes.edgeGap + halfWidth
        let rightEdge = safeFrame.origin.x + safeFrame.width - Sizes.edgeGap - halfWidth
        
        let topEdge = safeFrame.origin.y + Sizes.edgeGap + halfHeight
        let bottomEdge = safeFrame.origin.y + safeFrame.height - Sizes.edgeGap - halfHeight
        
        switch toLocation {
            
        case .topLeft:
            targetPoint.x = leftEdge
            targetPoint.y = topEdge
        case .topRight:
            targetPoint.x = rightEdge
            targetPoint.y = topEdge
        case .bottomLeft:
            targetPoint.x = leftEdge
            targetPoint.y = bottomEdge
        case .bottomRight:
            targetPoint.x = rightEdge
            targetPoint.y = bottomEdge
        }
        
        move(view: view, toPoint: targetPoint)
    }
    
    public func move(toLocation: FloatingLocation) {
        guard let view else { return }
        move(view: view, toLocation: toLocation)
        floatingLocation = toLocation
    }
    
    public func move(toPoint: CGPoint) {
        guard let view else { return }
        move(view: view, toPoint: toPoint)
    }
    
    func layoutView(
        completion: (() -> Void)? = nil
    ) {
        guard let window = view?.superview
        else {
            print("NOT ATTACHED TO A SUPERVIEW")
            return
        }
        
        UIView.animate(
            withDuration: TimeInterval(resizeAnimationDuration),
            delay: .leastNonzeroMagnitude,
            options: .curveEaseInOut
        ) { [weak self] in
            guard let self else { return }
            
            switch viewCurrentSize {
            case .fullScreen:
                view?.frame = window.frame
            default:
                view?.frame = pipFrame
                doesStickToEdgesAfterPanGesture
                ? move(toLocation: floatingLocation)
                : move(toPoint: initialCenter)
            }
        } completion: { [weak self] _ in
            guard let self else { return }
            view?.layoutIfNeeded()
            completion?()
        }
    }
    
    public func attach(
        _ view: UIView,
        startUpLocation: FloatingLocation,
        startUpSize: SizeModel
    ) {
        
        if let recognizer {
            view.removeGestureRecognizer(recognizer)
        }
        self.view?.removeFromSuperview()
        guard let window = UIApplication.shared.windows.first
        else { return }
        
        self.view = view
        
        let recognizer = UIPanGestureRecognizer(
            target: self,
            action: #selector(onViewPan(_:)))
        
        view.addGestureRecognizer(recognizer)
        self.recognizer = recognizer
        
        view.frame = pipFrame
        self.viewCurrentSize = startUpSize
        
        window.addSubview(view)
        layoutView()
        rootWindow = window
    }
    
    public func bringViewToFront() {
        guard let window = UIApplication.shared.windows.first,
              let view
        else { return }
        
        window.bringSubviewToFront(view)
    }
}

// ------- MARK: - Protocol Implemenetation
extension FloatingViewManager {
    
    public func resizeView(
        to sizeModel: SizeModel,
        completion: (() -> Void)? = nil
    ) {
        viewCurrentSize = sizeModel
        layoutView(completion: completion)
    }
    
    public func removeView() {
        if let recognizer {
            self.view?.removeGestureRecognizer(recognizer)
        }
        self.view?.removeFromSuperview()
        self.view = nil
    }
}
