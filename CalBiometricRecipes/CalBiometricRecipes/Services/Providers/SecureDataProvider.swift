//
//  SecureDataProvider.swift
//  CalBiometricRecipes
//
//  Created by Jonathan Hoch on 19/11/2024.
//

import LocalAuthentication
import Security
import Combine

class SecureDataProvider {
    
    /// Saves data securely with biometric protection.
    func encrypt<T: Encodable>(with biometricKey: String, object: T) -> Future<Bool, EncryptWithBiometricError> {
        return Future { [weak self] promise in
            guard let strongSelf = self else {
                promise(.failure(.failed))
                return
            }
            
            var data = Data()
            do {
                let encoder = JSONEncoder()
                data = try encoder.encode(object)
            } catch {
                promise(.failure(.failed))
            }
            
            let accessControl = SecAccessControlCreateWithFlags(nil,
                                                                kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
                                                                .userPresence,
                                                                nil)
            
            guard let access = accessControl else {
                promise(.failure(.failed))
                return
            }
            
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: biometricKey,
                kSecValueData as String: data,
                kSecAttrAccessControl as String: access,
                kSecUseAuthenticationContext as String: strongSelf.createAuthenticationContext()
            ]
            
            SecItemDelete(query as CFDictionary) // Remove any existing item.
            
            let status = SecItemAdd(query as CFDictionary, nil)
            if status == errSecSuccess {
                promise(.success(true))
            } else {
                promise(.failure(.failed))
            }
        }
    }
    
    /// Retrieves data securely using biometric protection.
    func getDecryptedObject<T: Decodable>(with biometricKey: String) -> Future<T, DecryptWithBiometricError> {
        return Future { [weak self] promise in
            guard let strongSelf = self else {
                promise(.failure(.failed))
                return
            }
            
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: biometricKey,
                kSecReturnData as String: true,
                kSecUseAuthenticationContext as String: strongSelf.createAuthenticationContext(),
                kSecMatchLimit as String: kSecMatchLimitOne
            ]
            
            var item: CFTypeRef?
            let status = SecItemCopyMatching(query as CFDictionary, &item)
            if status == errSecSuccess, let data = item as? Data {
                
                do {
                    let decoder = JSONDecoder()
                    let object = try decoder.decode(T.self, from: data)
                    promise(.success(object))
                } catch {
                    promise(.failure(.failed))
                }
            } else {
                promise(.failure(.failed))
            }
        }
    }
    
    /// Creates an `LAContext` for biometric authentication.
    private func createAuthenticationContext() -> LAContext {
        let context = LAContext()
        context.localizedReason = "Access your secure data"
        context.interactionNotAllowed = false // Allow user interaction.
        return context
    }
}

enum EncryptWithBiometricError: String, Error {
    case failed
    // Here we could provide more cases detailing why the Encrypt failed
}

enum DecryptWithBiometricError: String, Error {
    case failed
    // Here we could provide more cases detailing why the Decrypt failed
}
