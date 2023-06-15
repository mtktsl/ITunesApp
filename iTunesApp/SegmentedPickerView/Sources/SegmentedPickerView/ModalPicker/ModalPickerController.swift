//
//  File.swift
//  
//
//  Created by Metin Tarık Kiki on 12.06.2023.
//

import UIKit
import GridLayout

internal protocol ModalPickerControllerProtocol: AnyObject {
    
    func reloadData()
    func setupView()
    func layoutViews()
    func dismiss()
    func sendToDelegate(_ filter: String)
}

internal protocol ModalPickerControllerDelegate: AnyObject {
    func onFilterSelected(_ filter: String)
}

internal class ModalPickerController: UIViewController {
    
    var presenter: ModalPickerPresenter!
    
    weak var delegate: ModalPickerControllerDelegate?
    
    //var collection = [String]()
    //private var filteredCollection = [String]()
    
    var height: CGFloat = 0
    var horizontalInset: CGFloat = 0
    var minTableHeight: CGFloat = 200
    
    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.delegate = self
        return searchBar
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "defaultCell")
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    lazy var cancelButton: UIButton = {
        let cancelButton = UIButton()
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.layer.cornerRadius = 10
        cancelButton.addTarget(self,
                               action: #selector(cancelTap(_:)),
                               for: .touchUpInside)
        cancelButton.backgroundColor = .systemGray
        return cancelButton
    }()
    
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textAlignment = .center
        return titleLabel
    }()

    lazy var mainGrid = Grid.vertical {
        Grid.horizontal {
            UIView()
                .Constant(value: 100)
            titleLabel
                .Expanded()
            cancelButton
                .Constant(value: 100, margin: .init(top: 10, left: 10, bottom: 10, right: 10))
        }.Constant(value: 50)
        
        searchBar
            .Auto()
        tableView
            .Expanded()
    }
    
    static func build(_ collection: [String]) -> ModalPickerController {
        let view = ModalPickerController()
        let presenter = ModalPickerPresenter(view: view)
        presenter.collection = collection
        view.presenter = presenter
        return view
    }
    
    override func viewDidLayoutSubviews() {
        presenter.viewDidLoad()
        presenter.viewDidLayout()
    }
    
    @objc private func cancelTap(_ sender: UIButton) {
        presenter.onCancelTap()
    }
}

extension ModalPickerController: UISearchBarDelegate {
    func searchBar(
        _ searchBar: UISearchBar,
        textDidChange searchText: String
    ) {
        presenter.onSearch(searchText)
    }
}

extension ModalPickerController: ModalPickerControllerProtocol {
    
    func sendToDelegate(_ filter: String) {
        delegate?.onFilterSelected(filter)
    }
    
    func dismiss() {
        dismiss(animated: true)
    }
    
    func reloadData() {
        tableView.reloadData()
    }
    
    func setupView() {
        view.backgroundColor = .white
        view.addSubview(mainGrid)
        mainGrid.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainGrid.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainGrid.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            mainGrid.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            mainGrid.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    func layoutViews() {
        
        guard let window = view.window else { return }
        
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        
        let calculatedInset = window.safeAreaInsets.left
        + window.safeAreaInsets.right
        + horizontalInset
        
        let calculatedWidth = window.bounds.size.width
        - calculatedInset * 2
        
        let calculatedHeight = mainGrid.sizeThatFits(
            .init(width: calculatedWidth,
                  height: height)
        ).height + minTableHeight
        
        let finalHeight = height < calculatedHeight
        ? calculatedHeight
        : height
        
        let y = window.bounds.size.height
        - window.safeAreaInsets.top
        - window.safeAreaInsets.bottom
        - finalHeight
        
        view.frame = CGRect(x: calculatedInset,
                            y: y,
                            width: calculatedWidth,
                            height: finalHeight
        )
        
        mainGrid.setNeedsLayout()
    }
    
    
}

extension ModalPickerController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        presenter.onItemSelected(at: indexPath.row)
    }
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return presenter.itemCount
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell")
        else { fatalError("Failed to retreive default cell in modal picker controller") }
        
        let cellText = presenter.getFilter(at: indexPath.row)
        
        if #available(iOS 14, *) {
            var config = cell.defaultContentConfiguration()
            config.text = cellText
            cell.contentConfiguration = config
        } else {
            cell.textLabel?.text = cellText
        }
        return cell
    }
}
