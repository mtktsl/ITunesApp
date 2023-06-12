import UIKit
import GridLayout

extension SegmentedPickerView {
    fileprivate enum Constants {
        static let segmentGray = UIColor(
            hue: 240.0/360.0,
            saturation: 0,
            brightness: 0.94,
            alpha: 1
        )
        static let darkSegmentGray = UIColor(
            hue: 240.0/360.0,
            saturation: 0,
            brightness: 0.94,
            alpha: 1
        )
        static let segmentRadius: CGFloat = 10
        static let segmentFont: CGFloat = 14
        
        static let buttonInset: CGFloat = 1
        
        static let buttonEdgeInset = UIEdgeInsets (
            top: buttonInset,
            left: buttonInset,
            bottom: buttonInset,
            right: buttonInset
        )
    }
}

public protocol SegmentedPickerViewDelegate: AnyObject {
    func onSelectionChanged(_ newSelection: String)
}

public class SegmentedPickerView: UIView {
    public let segmentedControl: UISegmentedControl
    
    public let moreButton: UIButton
    private var moreButtonTitle: String
    public var moreButtonImage: UIImage?
    
    public var pickerTitle: String
    public let pickerView: UIPickerView
    
    public let segmentedFilters: [String]?
    public let moreFilters: [String]?
    
    public var selectedSegmentTintColor: UIColor = .white
    public var selectedSegmentTitleColor: UIColor = .black
    public var normalTitleColor: UIColor = .black
    public var popupCancelColor: UIColor = .lightGray
    
    public weak var delegate: SegmentedPickerViewDelegate?

    private var mainGrid: Grid!
    
    var pickerWidth: CGFloat {
        return self.window?.screen.bounds.size.width ?? 10 - 10
    }
    
    var pickerHeight: CGFloat {
        return (self.window?.screen.bounds.size.height ?? 300.0) / 5
    }
    
    public init(
        segmentedFilters: [String]? = nil,
        moreFilters: [String]? = nil,
        moreButtonTitle: String = "More",
        moreButtonImage: UIImage? = nil,
        pickerTitle: String = "Select Filter"
    ) {
        self.segmentedFilters = segmentedFilters
        self.moreFilters = moreFilters
        self.moreButtonTitle = moreButtonTitle
        self.pickerTitle = pickerTitle
        self.moreButtonImage = moreButtonImage
        
        segmentedControl = UISegmentedControl(items: segmentedFilters)
        moreButton = UIButton(frame: .zero)
        pickerView = UIPickerView(frame: .zero)
        
        super.init(frame: .zero)
        
        setupMoreButton()
        setupSegmentedControl()
        setupMainGrid()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupMoreButton() {
        moreButton.setTitle(moreButtonTitle, for: .normal)
        moreButton.setImage(moreButtonImage, for: .normal)
        moreButton.tintColor = selectedSegmentTitleColor
        moreButton.setTitleColor(normalTitleColor, for: .normal)
        moreButton.backgroundColor = Constants.darkSegmentGray
        moreButton.layer.cornerRadius = Constants.segmentRadius
        moreButton.layer.shadowRadius = 1
        moreButton.layer.shadowOpacity = 0
        moreButton.layer.shadowColor = UIColor.black.cgColor
        moreButton.layer.shadowOffset = .zero
        
        moreButton.titleLabel?.font = .systemFont(ofSize: Constants.segmentFont)
        
        moreButton.addTarget(
            self,
            action: #selector(onMoreButtonTapped(_:)),
            for: .touchUpInside
        )
    }
    
    private func setupSegmentedControl() {
        segmentedControl.addTarget(
            self,
            action: #selector(onSegmentChanged(_:)),
            for: .valueChanged
        )
        segmentedControl.selectedSegmentTintColor = selectedSegmentTintColor
        segmentedControl.setTitleTextAttributes(
            [NSAttributedString.Key.foregroundColor:selectedSegmentTitleColor],
            for: .selected
        )
        segmentedControl.setTitleTextAttributes(
            [NSAttributedString.Key.foregroundColor:normalTitleColor],
            for: .normal
        )
    }
    
    private func setupMainGrid() {
        guard let segmentedFilters else { return }
        
        if let _ = moreFilters {
            mainGrid = Grid.horizontal {
                segmentedControl
                    .Expanded(value: CGFloat(segmentedFilters.count))
                moreButton
                    .Expanded(value: 1,
                              margin: Constants.buttonEdgeInset)
            }
        } else {
            mainGrid = Grid.horizontal {
                moreButton
                    .Expanded()
            }
        }
        
        //since we initialized the mainGrid above, we can force unwrap
        self.addSubview(mainGrid)
        mainGrid.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainGrid.topAnchor.constraint(equalTo: self.topAnchor),
            mainGrid.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            mainGrid.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            mainGrid.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }
    
    @objc private func onSegmentChanged(_ sender: UISegmentedControl) {
        if let segmentedFilters, sender.selectedSegmentIndex != -1 {
            delegate?.onSelectionChanged(
                segmentedFilters[sender.selectedSegmentIndex]
            )
            toggleMoreButton(moreButtonTitle, selected: false)
            pickerView.selectRow(0, inComponent: 0, animated: false)
        }
    }
    
    @objc private func onMoreButtonTapped(_ sender: UIButton) {
        showPicker()
    }
    
    private func toggleMoreButton(_ title: String, selected: Bool) {
        if selected {
            moreButton.backgroundColor = .white
            moreButton.setTitleColor(selectedSegmentTitleColor, for: .normal)
            moreButton.layer.shadowOpacity = 0.5
        } else {
            moreButton.backgroundColor = self.backgroundColor
            moreButton.setTitleColor(normalTitleColor, for: .normal)
            moreButton.layer.shadowOpacity = 0
        }
        moreButton.setTitle(title, for: .normal)
    }
    
    private func showPicker() {
        let pickerVC = ModalPickerController()
        pickerVC.delegate = self
        pickerVC.horizontalInset = 10
        pickerVC.height = pickerHeight
        pickerVC.modalPresentationStyle = .formSheet
        pickerVC.titleLabel.text = pickerTitle
        pickerVC.cancelButton.backgroundColor = popupCancelColor
        if let moreFilters {
            pickerVC.collection = moreFilters
        }
        self.window?.rootViewController?.present(pickerVC, animated: true)
    }
}

extension SegmentedPickerView: ModalPickerControllerDelegate {
    func onFilterSelected(_ filter: String) {
        delegate?.onSelectionChanged(filter)
        segmentedControl.selectedSegmentIndex = -1
        toggleMoreButton(filter, selected: true)
    }
}
