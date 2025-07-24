# SimpleBLE 项目结构说明

```
SimpleBLE/
├── Assets.xcassets     # 应用图标等资源
├── README.md           # 简要说明
└── SimpleBLEApp/       # Swift 源码
    ├── AppDelegate.swift
    ├── BLEManager.swift
    ├── MainViewController.swift
    └── DeviceViewController.swift
```

* **AppDelegate.swift** – 应用入口，创建窗口并加载主界面。
* **BLEManager.swift** – 封装 `CBCentralManager` 与 `CBPeripheral` 逻辑，提供扫描、连接、特征读写等核心功能。
* **MainViewController.swift** – 设备扫描列表，点击设备后发起连接并进入详情界面。
* **DeviceViewController.swift** – 显示已连接设备的服务和特征列表，可根据需要扩展读写操作。

该示例仅保留了与 BLE 连接和数据交互相关的最基本功能，可在此基础上进一步扩展 UI 和业务逻辑。
