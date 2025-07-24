import Foundation
import CoreBluetooth

protocol BLEManagerDelegate: AnyObject {
    func didDiscover(device: CBPeripheral, rssi: NSNumber)
    func didConnect(device: CBPeripheral)
    func didReceive(data: Data, from characteristic: CBCharacteristic)
    func didDiscoverCharacteristics(for service: CBService)
}

class BLEManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    static let shared = BLEManager()
    private var central: CBCentralManager!
    private var delegate: BLEManagerDelegate?
    private var discovered: [CBPeripheral: NSNumber] = [:]
    private var connected: CBPeripheral?
    var connectedPeripheral: CBPeripheral? { connected }

    func start(delegate: BLEManagerDelegate) {
        self.delegate = delegate
        central = CBCentralManager(delegate: self, queue: nil)
    }

    func setDelegate(_ delegate: BLEManagerDelegate?) {
        self.delegate = delegate
    }

    // MARK: CBCentralManagerDelegate
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            central.scanForPeripherals(withServices: nil, options: nil)
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        discovered[peripheral] = RSSI
        delegate?.didDiscover(device: peripheral, rssi: RSSI)
    }

    func connect(_ peripheral: CBPeripheral) {
        central.stopScan()
        central.connect(peripheral, options: nil)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connected = peripheral
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        delegate?.didConnect(device: peripheral)
    }

    // MARK: CBPeripheralDelegate
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services ?? [] {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for char in service.characteristics ?? [] {
            if char.properties.contains(.read) {
                peripheral.readValue(for: char)
            }
            if char.properties.contains(.notify) {
                peripheral.setNotifyValue(true, for: char)
            }
        }
        delegate?.didDiscoverCharacteristics(for: service)
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let value = characteristic.value {
            delegate?.didReceive(data: value, from: characteristic)
        }
    }

    func write(data: Data, to characteristic: CBCharacteristic) {
        connected?.writeValue(data, for: characteristic, type: .withResponse)
    }
}
