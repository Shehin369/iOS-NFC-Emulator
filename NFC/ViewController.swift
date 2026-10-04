//
//  ViewController.swift
//  NFC
//
//  Created by Adviciya on 29/06/25.
//

import UIKit
import CoreNFC
import CoreBluetooth

class ViewController: UIViewController, NFCTagReaderSessionDelegate, CBPeripheralManagerDelegate, UITextFieldDelegate {
   
    

    @IBOutlet weak var messageTextField: UITextField!
    var nfcSession: NFCNDEFReaderSession?
    var session: NFCTagReaderSession?
//    let msg="Hello Test"
    
    var peripheralManager: CBPeripheralManager!
        var transferCharacteristic: CBMutableCharacteristic!
        
        let serviceUUID = CBUUID(string: "00001234-0000-1000-8000-00805f9b34fb")
        let characteristicUUID = CBUUID(string: "00005678-0000-1000-8000-00805f9b34fb")
//        let messageToSend = "👋 Hello from iPhone"
    

    override func viewDidLoad() {
        super.viewDidLoad()
//        print("Bluetooth state: \(peripheralManager.state.rawValue)")
        self.navigationController?.setNavigationBarHidden(false, animated: true)
           self.title = "NFC Writer"
        
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)

        // Do any additional setup after loading the view.
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    func startAdvertising() {
          // Define characteristic
          transferCharacteristic = CBMutableCharacteristic(
              type: characteristicUUID,
              properties: [.read],
              value: messageTextField.text!.data(using: .utf8),
              permissions: [.readable]
          )

          // Define service
          let service = CBMutableService(type: serviceUUID, primary: true)
          service.characteristics = [transferCharacteristic]
          
          // Add service and start advertising  
          peripheralManager.add(service)
          peripheralManager.startAdvertising([
              CBAdvertisementDataServiceUUIDsKey: [serviceUUID],
              CBAdvertisementDataLocalNameKey: "iPhoneBLE"
          ])
//        peripheralManager.stopAdvertising()
      }

      func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
          if let error = error {
              print("❌ Error adding service: \(error.localizedDescription)")
          } else {
              print("✅ Service added")
          }
      }
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
            case .poweredOn:
                print("✅ Bluetooth is ON")
//                startAdvertising()

            case .poweredOff:
                print("❌ Bluetooth is OFF – ask user to turn it on")

            case .unauthorized:
                print("🚫 App not authorized to use Bluetooth")
                // Could prompt user to update settings

            case .unsupported:
                print("❌ Device doesn't support Bluetooth LE")

            case .resetting:
                print("🔁 Bluetooth is resetting...")

            case .unknown:
                print("❓ Bluetooth state is unknown")
                
            @unknown default:
                print("⚠️ New unknown state: \(peripheral.state)")
            }
    }

      func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
          if let error = error {
              print("❌ Advertising failed: \(error.localizedDescription)")
          } else {
              print("📡 Now Advertising!")
          }
      }

      func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
          print("📥 Central subscribed!")
      }
    

    @IBAction func writeToTagTapped(_ sender: UIButton) {
        guard let message = messageTextField.text, !message.isEmpty else {
            showAlert("Please enter a message to write.")
            return
        }
        beginSession()
//        nfcSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
//        nfcSession?.alertMessage = "Hold your iPhone near the NFC tag to write the message."
//        nfcSession?.begin()
    }

//    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
//        print("Session Invalidated: \(error.localizedDescription)")
//    }
//
//    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
//        // Not used for writing
//    }
//
//    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
//        if tags.count > 1 {
//            session.alertMessage = "More than one tag detected. Please try again."
//            session.invalidate()
//            return
//        }
//
//        guard let tag = tags.first else { return }
//
//        session.connect(to: tag) { (error: Error?) in
//            if let error = error {
//                session.invalidate(errorMessage: "Connection failed: \(error.localizedDescription)")
//                return
//            }
//
//            tag.queryNDEFStatus { (status, capacity, error) in
//                if status == .readWrite {
//                    guard let userMessage = self.messageTextField.text else { return }
//                    let payload = NFCNDEFPayload.wellKnownTypeTextPayload(string: userMessage, locale: Locale.current)!
//                    let message = NFCNDEFMessage(records: [payload])
//
//                    tag.writeNDEF(message) { (error) in
//                        if let error = error {
//                            session.invalidate(errorMessage: "Failed to write: \(error.localizedDescription)")
//                        } else {
//                            session.alertMessage = "Successfully wrote message to tag!"
//                            session.invalidate()
//                        }
//                    }
//                } else {
//                    session.invalidate(errorMessage: "Tag is not writable.")
//                }
//            }
//        }
//    }
//
    func showAlert(_ message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "NFC Writer", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }


//        @IBOutlet weak var messageTextField: UITextField!
//        var nfcSession: NFCNDEFReaderSession?
//    
//        override func viewDidLoad() {
//            super.viewDidLoad()
//            // Do any additional setup after loading the view.
//        }
        func beginSession() {
            session = NFCTagReaderSession(pollingOption: .iso14443, delegate: self)
            session?.alertMessage = "Hold your iPhone near the NFC tag to write."
            session?.begin()
        }

        func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
            if let firstTag = tags.first {
                print("Shehin 1")
                session.connect(to: firstTag) { error in
                    print("Shehin 2")
                    self.startAdvertising()
                    if let error = error {
                        print("Shehin 3")
                        print("Connection failed: \(error)")
                        session.invalidate()
                        return
                    }

//                    if case let .miFare(mifareTag) = firstTag {
//                        let payload = "Hello NFC".data(using: .utf8)!
//                        let message = NFCNDEFMessage(records: [
//                            NFCNDEFPayload(format: .nfcWellKnown, type: "T".data(using: .utf8)!, identifier: Data(), payload: payload)
//                        ])
//
//                        mifareTag.writeNDEF(message) { error in
//                            if let error = error {
//                                
//                                print("Write failed: \(error)")
//                            } else {
//                                print("Write successful!")
//                                session.alertMessage = "Message written to tag."
//                            }
//                            session.invalidate()
//                        }
//                    }
                }
            }
        }

        func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {}
        func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
            print("Session invalidated: \(error)")
        }
}

