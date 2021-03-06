// Copyright 2019-2020 Gohilla Ltd.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Cocoa
import FlutterMacOS
import CryptoKit

public class CryptographyFlutterPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "cryptography_flutter", binaryMessenger: registrar.messenger)
    let instance = CryptographyFlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if call.method == "ping" {
      result("ok")
      return
    }
    let args = call.arguments as! [String: Any];
    if #available(iOS 13.0, OSX 15.0, tvOS 13.0, watchOS 6.0, *) {
    switch call.method {
      case "aes_gcm_encrypt":
        let input = (args["data"] as! FlutterStandardTypedData).data
        let symmetricKeyBytes = (args["key"] as! FlutterStandardTypedData).data
        let symmetricKey = SymmetricKey(data: symmetricKeyBytes)
        let nonceBytes = (args["nonce"] as! FlutterStandardTypedData).data
        let nonce = try! AES.GCM.Nonce(data: nonceBytes)
        let sealedBox = try! AES.GCM.seal(input, using:symmetricKey, nonce:nonce)
        let response: [String: Any] = [
          "cipherText": sealedBox.ciphertext,
          "tag": sealedBox.tag,
        ]
        result(response)

      case "aes_gcm_decrypt":
        let input = (args["data"] as! FlutterStandardTypedData).data
        let symmetricKeyBytes = (args["key"] as! FlutterStandardTypedData).data
        let symmetricKey = SymmetricKey(data: symmetricKeyBytes)
        let nonceBytes = (args["nonce"] as! FlutterStandardTypedData).data
        let nonce = try! AES.GCM.Nonce(data: nonceBytes)
        let tag = (args["tag"] as! FlutterStandardTypedData).data
        let sealedBox = try! AES.GCM.SealedBox(nonce:nonce, ciphertext:input, tag:tag)
        let output = try! AES.GCM.open(sealedBox, using:symmetricKey)
        result(output)

      case "chacha20_poly1305_encrypt":
        let input = (args["data"] as! FlutterStandardTypedData).data
        let symmetricKeyBytes = (args["key"] as! FlutterStandardTypedData).data
        let symmetricKey = SymmetricKey(data: symmetricKeyBytes)
        let nonceBytes = (args["nonce"] as! FlutterStandardTypedData).data
        let nonce = try! ChaChaPoly.Nonce(data: nonceBytes)
        let sealedBox = try! ChaChaPoly.seal(input, using:symmetricKey, nonce:nonce)
        let response: [String: Any] = [
          "cipherText": sealedBox.ciphertext,
          "tag": sealedBox.tag,
        ]
        result(response)

      case "chacha20_poly1305_decrypt":
        let input = (args["data"] as! FlutterStandardTypedData).data
        let symmetricKeyBytes = (args["key"] as! FlutterStandardTypedData).data
        let symmetricKey = SymmetricKey(data: symmetricKeyBytes)
        let nonceBytes = (args["nonce"] as! FlutterStandardTypedData).data
        let nonce = try! ChaChaPoly.Nonce(data: nonceBytes)
        let tag = (args["tag"] as! FlutterStandardTypedData).data
        let sealedBox = try! ChaChaPoly.SealedBox(nonce:nonce, ciphertext:input, tag:tag)
        let output = try! ChaChaPoly.open(sealedBox, using:symmetricKey)
        result(output)

      default:
        result("Unsupported method: \(call.method)")
      }
    } else {
      result("old_operating_system")
    }
  }
}