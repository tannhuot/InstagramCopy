//
//  SearchVC.swift
//  InstagramCopy
//
//  Created by Huot on 11/19/19.
//

import UIKit
import Firebase

class SearchVC: UITableViewController {
    //MARK: - Properties
    let searchBar = UISearchBar()
    var filterUsers = [User]()
    var users = [User]()
    var inSearchMode = false
    var collectionViewEnable = true
    var posts = [Post]()
    
    var collectionView: UICollectionView!
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchPost()
        fetchUserData()
    }
    override func viewWillAppear(_ animated: Bool) {
        setupView()
    }
}

//MARK: - Helpers
extension SearchVC {
    func setupView() {
        configureSearchBar()
        
        tableView.register(ProfileUserCell.self, forCellReuseIdentifier: ProfileUserCell.reuseIdentifire)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 64, bottom: 0, right: 0)
        tableView.dataSource = self
        tableView.delegate = self
        
        configureCollectionView()
    }
    
    func configureSearchBar() {
        searchBar.sizeToFit()
        searchBar.delegate = self
        navigationItem.titleView = searchBar
        searchBar.tintColor = .black
    }
    
}

//MARK: - API
extension SearchVC {
    func fetchUserData() {
        users.removeAll()
        tableView.separatorStyle = .none
        showProgressIndicator(view: self.view, title: "Wait...")
        USER_REF.observe(.childAdded) { (snapshot) in
            hideProgressIndicator(view: self.view)
            self.tableView.separatorStyle = .singleLine
            // get currente userID to subtract from search list
            guard let currendUid = Auth.auth().currentUser?.uid else { return }
            // uid
            let uid = snapshot.key
            //snapshot value cast as dictionary
            if uid != currendUid {
                guard let dictionary = snapshot.value as? Dictionary<String, Any> else { return }
                //contruct user
                let user = User(uid: uid, dictionary: dictionary)
                // append user to data source
                self.users.append(user)
            }
            self.tableView.reloadData()
        }
    }
    
    func fetchPost() {
        posts.removeAll()
        
        POSTS_REF.observe(.childAdded) { (snapshot) in
            let postId = snapshot.key
            
            Database.fetchPost(with: postId) { (post) in
                self.posts.append(post)
                self.collectionView.reloadData()
            }
        }
    }
}

//MARK: - Table View
extension SearchVC {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inSearchMode ? filterUsers.count:users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ProfileUserCell.reuseIdentifire, for: indexPath) as! ProfileUserCell
        
        cell.user = inSearchMode ? filterUsers[indexPath.row]:users[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userToLoad = inSearchMode ? filterUsers[indexPath.row]:users[indexPath.row]
        let vc = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        vc.user = userToLoad
        navigationController?.pushViewController(vc, animated: true)
        
    }
}

//MARK: - Search Bar Delegate
extension SearchVC: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        collectionView.isHidden = true
        collectionViewEnable = false
        tableView.separatorColor = .lightGray
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // handle search text change
        let searchText = searchText.lowercased().trimmingCharacters(in: .whitespaces)
        
        if searchText.isEmpty {
            inSearchMode = false
            tableView.reloadData()
        }else{
            inSearchMode = true
            filterUsers = users.filter({ (user) -> Bool in
                return user.userName.contains(searchText)
            })
            tableView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.showsCancelButton = false
        inSearchMode = false
        searchBar.text = nil
        
        collectionViewEnable = true
        collectionView.isHidden = false
        tableView.separatorColor = .clear
        
        tableView.reloadData()
    }
}

//MARK: UI Collection View
extension SearchVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func configureCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical

        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - (tabBarController?.tabBar.frame.height ?? 0) - (navigationController?.navigationBar.frame.height ?? 0))

        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .white
        
        tableView.addSubview(collectionView)
        
        collectionView.register(SearchPostCell.self, forCellWithReuseIdentifier: SearchPostCell.reuseIdentifire)
        
        tableView.separatorColor = .clear
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchPostCell.reuseIdentifire, for: indexPath) as! SearchPostCell
        cell.post = posts[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = FeedVC(collectionViewLayout: UICollectionViewFlowLayout())
        vc.viewSinglePost = true
        vc.post = posts[indexPath.item]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // Layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 2) / 3
        return CGSize(width: width, height: width)
    }
}
