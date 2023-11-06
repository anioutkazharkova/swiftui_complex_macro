import SwifRetrofit
import Foundation


public struct Account: Codable {
    let name: String
    let id: String
    
    init(name: String, id: String) {
        self.name = name
        self.id = id
    }
}

@SwiftRetrofit
public protocol AccountService {
    @Get(path: "/account")
    func getAccount(id: String, name: String) async throws -> Account
    
    @Get(path: "/account")
    func getAccount(activated: QueryParam<Bool>) async throws -> Account
   // func getAccount(@Query(name: "is_activated") activated: Bool) async throws -> Account
}

