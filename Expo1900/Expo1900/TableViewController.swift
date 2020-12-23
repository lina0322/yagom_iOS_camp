import UIKit

class TableViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var entries: [Entry] = []
   
    override func viewDidLoad() {
        super.viewDidLoad()
        decodeData(from: Constants.entriesDataAssetName)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    private func decodeData(from assetName: String) {
        guard let dataAsset = NSDataAsset(name: assetName) else {
            showAlert(about: .dataSetting)
            return
        }
        let jsonDecoder = JSONDecoder()
        
        do {
            self.entries = try jsonDecoder.decode([Entry].self, from: dataAsset.data)
        } catch {
            showAlert(about: .dataSetting)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = tableView.indexPathForSelectedRow,
              let detailView = segue.destination as? DetailViewController else {
            showAlert(about: .unknown)
            return
        }
        detailView.entry = entries[indexPath.row]
    }
}

extension TableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIndentifier, for: indexPath)
        let entry = entries[indexPath.row]
        var content = cell.defaultContentConfiguration()

        content.image = entry.image
        content.text = entry.name
        content.secondaryText = entry.shortDescription
        cell.accessoryType = .disclosureIndicator
        cell.contentConfiguration = content
        return cell
    }
}
