import UIKit


class AddressGenerator: NSObject
{

    final class func generateAddress(_ publicKey: String)->String {
        var inBuffer: Array<UInt8> = publicKey.asByteArray()

        var stepOneSHA256: Array<UInt8> = Array(repeating: 0, count: 64)
        SHA256_hash(&stepOneSHA256, &inBuffer ,32)
        let stepOneSHA256Text: String = NSString(bytes: stepOneSHA256, length: stepOneSHA256.count, encoding: String.Encoding.utf8.rawValue) as! String
        
        let stepTwoRIPEMD160Text: String = RIPEMD.hexStringDigest(stepOneSHA256Text) as String
        let stepTwoRIPEMD160Buffer: Array<UInt8> = stepTwoRIPEMD160Text.asByteArray()
        
        var version: Array<UInt8> = Array<UInt8>()
        version.append(network)
        
        var stepThreeVersionPrefixedRipemd160Buffer : Array<UInt8> = version + stepTwoRIPEMD160Buffer
        var checksumHash: Array<UInt8> = Array(repeating: 0, count: 64)
        
        SHA256_hash(&checksumHash, &stepThreeVersionPrefixedRipemd160Buffer ,21)
        
        let checksumText: String = NSString(bytes: checksumHash, length: checksumHash.count, encoding: String.Encoding.utf8.rawValue) as! String
        var checksumBuffer: Array<UInt8> = checksumText.asByteArray()
        var checksum: Array<UInt8> = Array<UInt8>()
        checksum.append(checksumBuffer[0])
        checksum.append(checksumBuffer[1])
        checksum.append(checksumBuffer[2])
        checksum.append(checksumBuffer[3])

        let stepFourResultBuffer =  stepThreeVersionPrefixedRipemd160Buffer + checksum
        
        let result :String = Base32Encode(Data(bytes: UnsafePointer<UInt8>(stepFourResultBuffer), count: stepFourResultBuffer.count))

        return result
    }
    
    final class func generateAddressFromPrivateKey(_ privateKey: String)->String {
//        let publicKey :String =  KeyGenerator.generatePublicKey(privateKey)
        
//        return AddressGenerator.generateAddress(publicKey)
        return String()
    }
}
