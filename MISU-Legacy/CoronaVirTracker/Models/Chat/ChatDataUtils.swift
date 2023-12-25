//
//  ChatDataUtils.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 27.05.2021.
//  Copyright © 2021 CVTCompany. All rights reserved.
//

import Foundation

protocol ChatDataUtils {
}

extension ChatDataUtils {
    func updateAllChatsInCache() {
        ChatCM.shared.cachedChat = ChatsSinglManager.shared.chatsDict
    }
}
