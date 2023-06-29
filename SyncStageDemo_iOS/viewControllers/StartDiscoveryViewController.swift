//
//  StartDiscoveryViewController.swift
//  SyncStageDemo_iOS
//
//  Created by bilal mahfouz on 20/05/2023.
//

import UIKit
import SyncStageSDK

class StartDiscoveryViewController: UIViewController {
    
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var nextButton: UIButton!
    
    var server: ServerInstance?
    var displayName = ""

    private let joinCreateSegueIdentifier = "joinOrCreateSession"
    
    private struct ZoneModel {
        let zoneName: String
        let latency: Int
    }

    private var latencyResults = [ZoneModel]()
    private var results: [ZoneModel] {
        get {
            return latencyResults
        }
        set {
            latencyResults = newValue
            self.tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        statusLabel.text = "Looking for the best Studio Server..."

        SyncStageHelper.instance.discoveryDelegate = self
        startDiscovery()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if server == nil {
            nextButton.isEnabled = false
        }
    }

    func startDiscovery() {
        let hud = HUDView.show(view: view)
        SyncStageHelper.instance.getBestAvailableServer { result in
            hud.hide()
            switch result {
            case .success(let instance):
                self.server = instance
                self.nextButton.isEnabled = true
            case .failure(let error):
                NSLog(error.localizedDescription)
                let retryAction = UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
                    self?.startDiscovery()
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
                self.showAlert(with: "Warning", message: error.localizedDescription, actions: [retryAction, cancelAction])
                return
            }
        }
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if server != nil {
            return true
        } else {
            return false
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == joinCreateSegueIdentifier,
           let destVC = segue.destination as? CreateOrJoinSessionViewController {
            destVC.displayName = displayName
            destVC.server = server
        }
    }
}

extension StartDiscoveryViewController: SyncStageDiscoveryDelegate {
    func discoveryResults(zones: [String]) {
        self.results = zones.map({ ZoneModel(zoneName: $0, latency: -1) })
    }
    
    func discoveryLatencyTestResults(results: [SyncStageSDK.ZoneLatency]) {
        statusLabel.text = "Network latency to different Studio Servers."
        self.results = results.map({ ZoneModel(zoneName: $0.name, latency: $0.latency) })
    }
}

extension StartDiscoveryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return latencyResults.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let zoneLatency = results[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ZoneLatencyCell") as? ZoneLatencyCell {
            cell.update(zone: zoneLatency.zoneName, latency: zoneLatency.latency)
            return cell
        }
        return UITableViewCell()
    }
}

class ZoneLatencyCell: UITableViewCell {
    @IBOutlet var zoneLabel: UILabel!
    @IBOutlet var latencyLabel: UILabel!

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    func update(zone: String, latency: Int) {
        zoneLabel.text = zone
        latencyLabel.text = latency == -1 ? "? ms" : "\(latency) ms"
    }
}
