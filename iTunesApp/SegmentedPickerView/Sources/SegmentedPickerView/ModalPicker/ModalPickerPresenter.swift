//
//  File.swift
//  
//
//  Created by Metin Tarık Kiki on 15.06.2023.
//

import Foundation

internal protocol ModalPickerPresenterProtocol {
    
    var itemCount: Int { get }
    var isFiltering: Bool { get }
    
    func viewDidLoad()
    func viewDidLayout()
    func onItemSelected(at index: Int)
    func onSearch(_ searchText: String)
    func getFilter(at index: Int) -> String?
    func onCancelTap()
}

internal final class ModalPickerPresenter {
    unowned var view: ModalPickerControllerProtocol!
    
    var collection = [String]()
    var filteredCollection = [String]()
    
    var isFiltering: Bool = false
    
    internal init(view: ModalPickerControllerProtocol!) {
        self.view = view
    }
}

extension ModalPickerPresenter: ModalPickerPresenterProtocol {
    func onCancelTap() {
        view.dismiss()
    }
    
    func getFilter(at index: Int) -> String? {
        if index >= itemCount || index < 0 {
            return nil
        } else {
            return isFiltering
            ? filteredCollection[index]
            : collection[index]
        }
    }
    
    var itemCount: Int {
        isFiltering
        ? filteredCollection.count
        : collection.count
    }
    
    
    func viewDidLoad() {
        view.setupView()
    }
    
    func viewDidLayout() {
        view.layoutViews()
    }
    
    func onSearch(_ searchText: String) {
        filteredCollection = collection.filter({ $0.contains(searchText) })
        isFiltering = !searchText.isEmpty
        view.reloadData()
    }
    
    func onItemSelected(at index: Int) {
        let selectedFilter = getFilter(at: index)
        view.sendToDelegate(selectedFilter ?? "")
        view.dismiss()
    }
    
}
