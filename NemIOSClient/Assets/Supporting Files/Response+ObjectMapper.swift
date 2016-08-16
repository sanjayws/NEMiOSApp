//
//  Observable+ObjectMapper.swift
//
//  Created by Ivan Bruel on 09/12/15.
//  Copyright © 2015 Ivan Bruel. All rights reserved.
//

import Foundation
import Moya
import SwiftyJSON
import ObjectMapper

public extension Response {
    
    /// Maps data received from the signal into an object which implements the Mappable protocol.
    /// If the conversion fails, the signal errors.
    public func mapObject<T: Mappable>(type: T.Type) throws -> T {
        guard let object = Mapper<T>().map(try mapJSON()) else {
            throw Error.JSONMapping(self)
        }
        return object
    }
    
    /// Maps data received from the signal into an array of objects which implement the Mappable
    /// protocol.
    /// If the conversion fails, the signal errors.
    public func mapArray<T: Mappable>(type: T.Type) throws -> [T] {
        guard let objects = Mapper<T>().mapArray(try mapJSON()) else {
            throw Error.JSONMapping(self)
        }
        return objects
    }
    
}

public protocol SwiftyJSONMappable {
    init?(jsonData:JSON)
}

public extension JSON {
    
    /// Maps data received from the signal into an object which implements the ALSwiftyJSONAble protocol.
    /// If the conversion fails, the signal errors.
    public func mapObject<T: SwiftyJSONMappable>(type:T.Type) throws -> T {
        
        guard let mappedObject = T(jsonData: self) else {
            throw Error.JSONMapping(Response(statusCode: 200, data: NSData()))
        }
        
        return mappedObject
    }
    
    /// Maps data received from the signal into an array of objects which implement the ALSwiftyJSONAble protocol
    /// If the conversion fails, the signal errors.
    public func mapArray<T: SwiftyJSONMappable>(type:T.Type) throws -> [T] {
        
        let mappedArray = self
        let mappedObjectsArray = mappedArray.arrayValue.flatMap { T(jsonData: $0) }
        
        return mappedObjectsArray
    }
    
}
