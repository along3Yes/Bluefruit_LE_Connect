import UIKit
import CoreBluetooth

class DeviceViewController: UITableViewController, BLEManagerDelegate {
    private var peripheral: CBPeripheral
    private var characteristics: [CBCharacteristic] = []

    init(peripheral: CBPeripheral) {
        self.peripheral = peripheral
        super.init(style: .grouped)
        title = peripheral.name ?? "设备"
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        BLEManager.shared.setDelegate(self)
    }

    // MARK: BLEManagerDelegate
    func didDiscover(device: CBPeripheral, rssi: NSNumber) {}
    func didConnect(device: CBPeripheral) {}
    func didReceive(data: Data, from characteristic: CBCharacteristic) {}
    func didDiscoverCharacteristics(for service: CBService) {
        if service.peripheral == peripheral {
            characteristics = service.characteristics ?? []
            tableView.reloadData()
        }
    }



    // MARK: UITableView
    override func numberOfSections(in tableView: UITableView) -> Int {
        return BLEManager.shared.connectedPeripheral?.services?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let service = BLEManager.shared.connectedPeripheral?.services?[section] {
            return service.uuid.uuidString
        }
        return nil
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return characteristics.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "char") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "char")
        let char = characteristics[indexPath.row]
        cell.textLabel?.text = char.uuid.uuidString
        cell.detailTextLabel?.text = char.properties.description
        return cell
    }
}
