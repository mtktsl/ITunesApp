
import UIKit

public protocol LoadingShower: AnyObject {
    func showLoading()
    func showLoading(_ frame: CGRect, cornerRadius: CGFloat)
    func showLoading(on view: UIView)
    func hideLoading()
}

public extension LoadingShower {
    func showLoading() {
        LoadingView.shared.startLoading()
    }
    func showLoading(_ frame: CGRect, cornerRadius: CGFloat = 0) {
        LoadingView.shared.startLoading(frame, cornerRadius: cornerRadius)
    }
    func showLoading(on view: UIView) {
        LoadingView.shared.startLoading(on: view)
    }
    func hideLoading() {
        LoadingView.shared.hideLoading()
    }
}
