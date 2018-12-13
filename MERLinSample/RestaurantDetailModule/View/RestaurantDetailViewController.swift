//
//  RestaurantDetailViewController.swift
//  RestaurantDetailModule
//
//  Created by Giuseppe Lanza on 15/08/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import Foundation

enum DetailSectionRows: Int {
    case image
    case detail
    
    var identifier: String {
        switch self {
        case .image: return "imageCell"
        case .detail: return "titleDetailCell"
        }
    }
}

class RestaurantDetailViewController: UIViewController, DisplayingError, UITableViewDelegate, UITableViewDataSource {
    func displayError(_ error: DisplayableError) {
        let alert = UIAlertController(title: error.title, message: error.errorMessage, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    struct Input: RestaurantDetailVMInput {
        var viewWillAppear: Driver<Void>
        var bookButtonTapped: Driver<RestaurantProtocol>
    }
    
    var viewModel: RestaurantDetailViewModelProtcol?
    
    @IBOutlet weak var tableview: UITableView!
    
    @IBOutlet weak var bookButton: UIButton!
    
    var restaurant: RestaurantProtocol?
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        applyTheme()
        bookButton.setTitle("Book a Table", for: .normal)
        
        let viewWillAppear = rx.sentMessage(#selector(viewWillAppear(_:)))
            .toVoid()
            .asDriverIgnoreError()

        let bookTapped = bookButton.rx.tap
            .compactMap { [weak self] in self?.restaurant }
            .asDriverIgnoreError()
        
        let input = Input(viewWillAppear: viewWillAppear, bookButtonTapped: bookTapped)
        guard let output = viewModel?.transform(input: input) else { return }
        
        output.restaurantDetailFetched.drive(onNext: { [unowned self] restaurant in
            self.restaurant = restaurant
            self.tableview.reloadData()
            self.title = self.restaurant?.name
        }).disposed(by: disposeBag)
        
        output.error
            .drive(onNext: displayError)
            .disposed(by: disposeBag)
    }
    
    func applyTheme() {
        bookButton.backgroundColor = view.tintColor
        bookButton.setTitleColor(.white, for: .normal)
        tableview.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return restaurant != nil ? 1 + restaurant!.menus.count : 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard section > 0 else { return 2 }
        return restaurant!.menus[section - 1].items.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard section > 0 else { return nil }
        return restaurant!.menus[section - 1].title
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let row = DetailSectionRows(rawValue: indexPath.row) else { fatalError() }
            let cell = tableView.dequeueReusableCell(withIdentifier: row.identifier, for: indexPath)
            switch row {
            case .image: print("Implement image")
            case .detail:
                cell.textLabel?.text = restaurant!.desc
                cell.detailTextLabel?.text = "\(restaurant!.priceRate)"
            }
            return cell
        } else {
            let menu = restaurant!.menus[indexPath.section - 1]
            let item = menu.items[indexPath.row]
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "menuItemCell", for: indexPath) as! MenuItemCell
            cell.applyAppearance()
            
            cell.title.text = item.title
            cell.descriptionLabel.text = item.shortDescription
            cell.priceLabel.text = "\(item.price) £"
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.section > 0 else { return }
        
        let menu = restaurant!.menus[indexPath.section - 1]
        let item = menu.items[indexPath.row]
        
        let alert = UIAlertController(title: item.title, message: item.longDescription, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true)
    }
}
