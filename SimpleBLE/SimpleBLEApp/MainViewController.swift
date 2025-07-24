import UIKit
import CoreBluetooth

class MainViewController: UITableViewController, BLEManagerDelegate {
    private var peripherals: [CBPeripheral] = []
    private var rssiValues: [CBPeripheral: NSNumber] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "设备列表"
        BLEManager.shared.start(delegate: self)
    }

    // MARK: BLEManagerDelegate
    func didDiscover(device: CBPeripheral, rssi: NSNumber) {
        if !peripherals.contains(device) {
            peripherals.append(device)
        }
        rssiValues[device] = rssi
        tableView.reloadData()
    }

    func didConnect(device: CBPeripheral) {
        // connection established
    }

    func didReceive(data: Data, from characteristic: CBCharacteristic) {
        // handle data in DeviceViewController
    }

    // MARK: UITableView
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripherals.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let p = peripherals[indexPath.row]
        cell.textLabel?.text = p.name ?? "未知设备"
        if let rssi = rssiValues[p] {
            cell.detailTextLabel?.text = "RSSI: \(rssi)"
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let p = peripherals[indexPath.row]
        let vc = DeviceViewController(peripheral: p)
        BLEManager.shared.setDelegate(vc)
        BLEManager.shared.connect(p)
        navigationController?.pushViewController(vc, animated: true)
    }
}
