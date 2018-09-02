//
//  RestaurantsListViewController.swift
//  RestaurantsListModule
//
//  Created by Giuseppe Lanza on 14/08/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import Foundation

class RestaurantsListViewController: UITableViewController, DisplayingError {
    func displayError(_ error: DisplayableError) {
        let alert = UIAlertController(title: error.title, message: error.errorMessage, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    struct Input: RestaurantsListVMInput {
        var getFirstPage: Driver<Void>
        var nextPage: Driver<Void>

        var didSelect: Driver<ShortRestaurantProtocol>
    }
    
    var viewModel: RestaurantsListViewModelProtocol?
    var items = [ShortRestaurantProtocol]()
    
    let disposeBag = DisposeBag()
    
    let requestNewPage = PublishSubject<Void>()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Restaurants list"
        
        let refreshControl = UIRefreshControl()
        tableView.refreshControl = refreshControl
        
        let getFirstPage = Driver.merge(Driver<Void>.just(()), refreshControl.rx.controlEvent(.valueChanged).asDriverIgnoreError())

        let didSelect = tableView.rx.itemSelected.map { [weak self] in
            return self?.items[$0.row]
        }.unwrap().asDriverIgnoreError()
        
        let input = Input(getFirstPage: getFirstPage, nextPage: requestNewPage.asDriverIgnoreError(), didSelect: didSelect)
        guard let output = viewModel?.transform(input: input) else { return }
        
        output.error
            .drive(onNext: displayError)
            .disposed(by: disposeBag)
        
        output.newRestaurantsList.drive(onNext: {[unowned self] restaurants in
            self.items = restaurants
            self.tableView.reloadData()
            self.tableView.refreshControl?.endRefreshing()
        }).disposed(by: disposeBag)
        
        output.newPage.drive(onNext: {[unowned self] restaurants in
            self.items = self.items+restaurants
            self.tableView.reloadData()
        }).disposed(by: disposeBag)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = items[indexPath.row]
        cell.textLabel?.text = item.name
        cell.textLabel?.applyLabelStyle(.body(attribute: .sBold))
        cell.detailTextLabel?.text = "\(item.priceRate)"
        cell.detailTextLabel?.applyLabelStyle(.body(attribute: .regular))
        cell.detailTextLabel?.textColor = UIColor.color(forPalette: .primary)
        
        if indexPath.row == items.count - 1 {
            requestNewPage.onNext(())
        }
        
        return cell
    }
}
