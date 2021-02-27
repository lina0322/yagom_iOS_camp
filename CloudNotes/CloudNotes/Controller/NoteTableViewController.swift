//
//  NoteTableViewController.swift
//  CloudNotes
//
//  Created by 김태형 on 2021/02/15.
//

import UIKit
import CoreData

final class NoteTableViewController: UITableViewController {
       
    override func viewDidLoad() {
        registerCell()
        configureNavigationItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DataModel.shared.loadCoreData()
    }
    
    private func registerCell() {
        tableView.register(NoteTableViewCell.self, forCellReuseIdentifier: NoteTableViewCell.identifier)
    }
    
    private func configureNavigationItem() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(touchUpAddButton))
        navigationItem.rightBarButtonItem = addButton
        navigationItem.title = NoteString.memo
    }
    
    @objc private func touchUpAddButton() {
        let detailView = DetailViewController()
        splitViewController?.showDetailViewController(detailView, sender: nil)
        
        DataModel.shared.saveData("새로운 메모 \n 추가 텍스트 없음")
        tableView.reloadData()
    }
}

// MARK: - DataSource
extension NoteTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataModel.shared.noteList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NoteTableViewCell.identifier, for: indexPath) as? NoteTableViewCell else {
            debugPrint(ErrorCase.cellError.localizedDescription)
            return UITableViewCell()
        }
        let note = DataModel.shared.noteList[indexPath.row]
        cell.configure(note)
        return cell
    }
}

// MARK: - Delegate
extension NoteTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailView = DetailViewController()
        detailView.note = DataModel.shared.noteList[indexPath.row]
        splitViewController?.showDetailViewController(detailView, sender: nil)
    }
}
