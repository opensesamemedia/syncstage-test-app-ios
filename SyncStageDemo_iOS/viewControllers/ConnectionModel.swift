//
//  ConnectionClass.swift
//  SyncStageDemo_iOS
//
//  Created by bilal mahfouz on 18/11/2022.
//

import Foundation
import SyncStageSDK

class ConnectionModel {
    let identifier: String
    let userId: String
    let displayName: String?
    var isMuted: Bool
    var isConnected: Bool = true

    init(connection: Connection) {
        self.identifier = connection.identifier
        self.userId = connection.userId
        self.displayName = connection.displayName
        self.isMuted = connection.isMuted
    }
}
