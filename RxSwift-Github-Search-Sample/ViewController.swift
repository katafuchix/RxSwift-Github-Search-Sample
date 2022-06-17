//
//  ViewController.swift
//  RxSwift-Github-Search-Sample
//
//  Created by cano on 2022/06/17.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class ViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.bind()
    }

    func bind() {
        self.searchBar.rx.text
            .orEmpty
            .filter { query in
                return query.count > 2
            }
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .map { query in
                var apiUrl = URLComponents(string: "https://api.github.com/search/repositories")!
                apiUrl.queryItems = [URLQueryItem(name: "q", value: query)]
                return URLRequest(url: apiUrl.url!)
            }
            .flatMapLatest { request in
                return URLSession.shared.rx.json(request: request)
                    //.catchErrorJustReturn([])
            }
            .map { json -> [Repo] in
                guard let json = json as? [String: Any],
                    let items = json["items"] as? [[String: Any]]  else {
                        return []
                }
                return items.compactMap(Repo.init)
            }
            .bind(to: tableView.rx.items) { tableView, row, repo in
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
                cell.textLabel!.text = repo.name
                cell.detailTextLabel?.text = repo.language
                return cell
            }
            .disposed(by: self.rx.disposeBag)
    }
}

struct Repo {
    let id: Int
    let name: String
    let language: String

    init?(object: [String: Any]) {
        guard let id = object["id"] as? Int,
            let name = object["name"] as? String,
            let language = object["language"] as? String else {
                return nil
        }
        self.id = id
        self.name = name
        self.language = language
    }

    init(_ id: Int, _ name: String, _ language: String) {
        self.id = id
        self.name = name
        self.language = language
    }
}
