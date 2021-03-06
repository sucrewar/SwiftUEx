
import Foundation

public class KeychainWrapper {

    public class func set(key: String, value: String) -> Bool {
        if let data = value.dataUsingEncoding(NSUTF8StringEncoding) {
            return set(key, value: data)
        }
        return false
    }

    public class func set(key: String, value: NSData) -> Bool {
        let keyQuery = [
            (kSecClass as String)       : kSecClassGenericPassword,
            (kSecAttrAccount as String) : key,
            (kSecValueData as String)   : value
        ]
        SecItemDelete(keyQuery as CFDictionaryRef)
        return SecItemAdd(keyQuery as CFDictionaryRef, nil) == noErr
    }

    public class func get(key: String) -> NSString? {
        if let data = getData(key) {
            return NSString(data: data, encoding: NSUTF8StringEncoding)
        }
        return nil
    }

    public class func getData(key: String) -> NSData? {
        let keyQuery = [
            (kSecClass as String)       : kSecClassGenericPassword,
            (kSecAttrAccount as String) : key,
            (kSecReturnData as String)  : kCFBooleanTrue,
            (kSecMatchLimit as String)  : kSecMatchLimitOne
        ]
        var dataTypeRef: Unmanaged<AnyObject>?
        let status: OSStatus = withUnsafeMutablePointer(&dataTypeRef) { SecItemCopyMatching(keyQuery as CFDictionaryRef, UnsafeMutablePointer($0)) }

        if status == noErr && dataTypeRef != nil {
            return dataTypeRef!.takeRetainedValue() as? NSData
        }
        return nil
    }

    public class func delete(key: String) -> Bool {
        let query = [
            (kSecClass as String)       : kSecClassGenericPassword,
            (kSecAttrAccount as String) : key
        ]
        return SecItemDelete(query as CFDictionaryRef) == noErr
    }

    public class func clear() -> Bool {
        let keyQuery = [
            (kSecClass as String): kSecClassGenericPassword
        ]
        return SecItemDelete(keyQuery as CFDictionaryRef) == noErr
    }
}
