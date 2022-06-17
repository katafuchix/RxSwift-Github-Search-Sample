# RxSwift-Github-Search-Sample

![Simulator Screen Recording - iPhone 13 Pro - 2022-06-17 at 18 41 54](https://user-images.githubusercontent.com/6063541/174273786-15b4104e-583f-47e5-b7ef-51e8a6207277.gif)

```
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
 ```
