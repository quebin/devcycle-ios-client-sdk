//
//  DVCUser.swift
//  DevCycle-iOS-SDK
//
//

import Foundation
import UIKit

enum UserError: Error {
    case MissingUserId
    case MissingUserIdAndIsAnonymousFalse
    case InvalidUser
}

public class DVCUser: Codable {
    public var userId: String?
    public var isAnonymous: Bool?
    public var email: String?
    public var name: String?
    public var language: String?
    public var country: String?
    public var appVersion: String?
    public var appBuild: Int?
    public var customData: Data?
    public var privateCustomData: Data?
    public var lastSeenDate: Date
    public let createdDate: Date
    public let platform: String
    public let platformVersion: String
    public let deviceModel: String
    public let sdkType: String
    public let sdkVersion: String
    
    init() {
        self.lastSeenDate = Date()
        self.createdDate = Date()
        self.platform = UIDevice.current.systemName
        self.platformVersion = UIDevice.current.systemVersion
        self.deviceModel = UIDevice.current.model
        self.sdkType = "client"
        self.sdkVersion = DevCycleVersion
    }
    
    enum CodingKeys: String, CodingKey {
           case userId = "user_id"
           case isAnonymous, email, name, language, country, appVersion, appBuild, customData, privateCustomData, lastSeenDate, createdDate, platform, platformVersion, deviceModel, sdkType, sdkVersion
    }
    
    public func update(with user: DVCUser) {
        self.lastSeenDate = Date()
        self.email = user.email
        self.name = user.name
        self.language = user.language
        self.country = user.country
        self.appVersion = user.appVersion
        self.appBuild = user.appBuild
        self.customData = user.customData
        self.privateCustomData = user.privateCustomData
    }
    
    func update(with user: ObjCDVCUser) {
        self.userId = user.userId
        self.isAnonymous = user.isAnonymous != nil ? Bool(truncating: user.isAnonymous!) : false
        self.lastSeenDate = Date()
        self.email = user.email
        self.name = user.name
        self.language = user.language
        self.country = user.country
        self.appVersion = user.appVersion
        self.appBuild = user.appBuild?.intValue
        if let customData = user.customData, let data = try? JSONSerialization.data(withJSONObject: customData, options: []) {
            self.customData = data
        }
        if let privateCustomData = user.privateCustomData, let data = try? JSONSerialization.data(withJSONObject: privateCustomData, options: []) {
            self.privateCustomData = data
        }
    }
    
    public class UserBuilder {
        var user: DVCUser
        
        init() {
            self.user = DVCUser()
        }
        
        public func userId(_ userId: String) -> UserBuilder {
            self.user.userId = userId
            self.user.isAnonymous = false
            return self
        }
        
        public func isAnonymous(_ isAnonymous: Bool) -> UserBuilder {
            if (self.user.isAnonymous != nil) { return self }
            self.user.isAnonymous = isAnonymous
            self.user.userId = UUID().uuidString
            return self
        }
        
        public func email(_ email: String) -> UserBuilder {
            self.user.email = email
            return self
        }
        
        public func name(_ name: String) -> UserBuilder {
            self.user.name = name
            return self
        }
        
        public func language(_ language: String) -> UserBuilder {
            self.user.language = language
            return self
        }
        
        public func country(_ country: String) -> UserBuilder {
            self.user.country = country
            return self
        }
        
        public func appVersion(_ appVersion: String) -> UserBuilder {
            self.user.appVersion = appVersion
            return self
        }
        
        public func appBuild(_ appBuild: Int) -> UserBuilder {
            self.user.appBuild = appBuild
            return self
        }
        
        public func customData(_ customData: [String:Any]) -> UserBuilder {
            guard let data = try? JSONSerialization.data(withJSONObject: customData, options: []) else {
                return self
            }
            self.user.customData = data
            return self
        }
        
        public func privateCustomData(_ privateCustomData: [String:Any]) -> UserBuilder {
            guard let data = try? JSONSerialization.data(withJSONObject: privateCustomData, options: []) else {
                return self
            }
            self.user.privateCustomData = data
            return self
        }
        
        public func build() throws -> DVCUser {
            guard let _ = self.user.userId,
                  let _ = self.user.isAnonymous
            else {
                throw UserError.MissingUserIdAndIsAnonymousFalse
            }

            
            let result = self.user
            self.user = DVCUser()
            return result
        }
    }
    
    public static func builder() -> UserBuilder {
        return UserBuilder()
    }
}

extension DVCUser {
    class QueryItemBuilder {
        var items: [URLQueryItem]
        let user: DVCUser
        
        init(user: DVCUser) {
            self.items = []
            self.user = user
        }
        
        func formatToQueryItem<T>(name: String, value: T?) -> QueryItemBuilder {
            guard let property = value else { return self }
            if let map = property as? Data {
                items.append(URLQueryItem(name: name, value: String(data: map, encoding: String.Encoding.utf8)))
            } else if let date = property as? Date {
                items.append(URLQueryItem(name: name, value: "\(Int(date.timeIntervalSince1970))"))
            } else {
                items.append(URLQueryItem(name: name, value: "\(property)"))
            }
            
            return self
        }
        
        func build() -> [URLQueryItem] {
            let result = self.items
            self.items = []
            return result
        }
    }
    
    func toQueryItems() -> [URLQueryItem] {
        let builder = QueryItemBuilder(user: self)
            .formatToQueryItem(name: "user_id", value: self.userId)
            .formatToQueryItem(name: "isAnonymous", value: self.isAnonymous)
            .formatToQueryItem(name: "email", value: self.email)
            .formatToQueryItem(name: "name", value: self.name)
            .formatToQueryItem(name: "language", value: self.language)
            .formatToQueryItem(name: "country", value: self.country)
            .formatToQueryItem(name: "appVersion", value: self.appVersion)
            .formatToQueryItem(name: "appBuild", value: self.appBuild)
            .formatToQueryItem(name: "customData", value: self.customData)
            .formatToQueryItem(name: "privateCustomData", value: self.privateCustomData)
            .formatToQueryItem(name: "lastSeenDate", value: self.lastSeenDate)
            .formatToQueryItem(name: "createdDate", value: self.createdDate)
            .formatToQueryItem(name: "platform", value: self.platform)
            .formatToQueryItem(name: "platformVersion", value: self.platformVersion)
            .formatToQueryItem(name: "deviceModel", value: self.deviceModel)
            .formatToQueryItem(name: "sdkType", value: self.sdkType)
            .formatToQueryItem(name: "sdkVersion", value: self.sdkVersion)
        return builder.build()
    }
}
