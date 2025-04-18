//
//  KeyChainHelper.swift
//  DishWish
//
//  Created by Choi Siu Lun Alan on 13/4/2025.
//
import Security
import Foundation
class KeychainHelper {
    static let shared = KeychainHelper()

//    private init() {
//        print("123")
//        self.clearAll()
//    }

    
    public func save(_ value: String, forKey key: String) {
        guard let data = value.data(using: .utf8) else { return }

        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecValueData: data,
            kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]

        // Remove existing item if it exists
        SecItemDelete(query as CFDictionary)
        // Add new item
        SecItemAdd(query as CFDictionary, nil)
    }

    public func load(forKey key: String) -> String? {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecSuccess, let data = result as? Data {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
    
    public func delete(forKey key: String) {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key
        ]
        SecItemDelete(query as CFDictionary)
    }
    
    private func clearAll() {
        let secItemClasses = [
            kSecClassGenericPassword,
            kSecClassInternetPassword,
            kSecClassCertificate,
            kSecClassKey,
            kSecClassIdentity,
        ]

        for itemClass in secItemClasses {
            let query: [CFString: Any] = [kSecClass: itemClass]
            SecItemDelete(query as CFDictionary)
        }
    }
}
