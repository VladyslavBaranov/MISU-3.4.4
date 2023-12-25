//
//  UsersCardsSingleManager.swift
//  CoronaVirTracker
//
//  Created by Dmitriy Kruglov on 3/23/20.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation

class UsersCardsSingleManager {
    static let shared = UsersCardsSingleManager()
    
    var users: [UserModel] = [
        UserModel(id: 0),
        UserModel(id: 1),
        UserModel(id: 2),
        UserModel(id: 3),
        UserModel(id: 4),
        UserModel(id: 5),
        UserModel(id: 6),
        UserModel(id: 7),
        UserModel(id: 8),
        UserModel(id: 9),
        UserModel(id: 10),
        UserModel(id: 11),
        UserModel(id: 12)]
    
    private init () {
        users[0].profile = UserCardModel(id: users[0].id)
        users[1].profile = UserCardModel(id: users[1].id)
        users[2].profile = UserCardModel(id: users[2].id)
        users[3].profile = UserCardModel(id: users[3].id)
        users[4].profile = UserCardModel(id: users[4].id)
        users[5].profile = UserCardModel(id: users[5].id)
        users[6].profile = UserCardModel(id: users[6].id)
        users[7].profile = UserCardModel(id: users[7].id)
        users[8].profile = UserCardModel(id: users[8].id)
        users[9].profile = UserCardModel(id: users[9].id)
        users[10].profile = UserCardModel(id: users[10].id)
        users[11].profile = UserCardModel(id: users[11].id)
        users[12].profile = UserCardModel(id: users[12].id)
        
        for (key, _) in users.enumerated() {
            users[key].location = LocationModel("Rivne", city: "Rivne", country: "Ukraine", adminArea: "Rivne",
                                                coord: Coordinates(lat: Double.random(in: 50.573036...50.663654),
                                                                   lon: Double.random(in: 26.129534...26.329348)))
            //50.663654
            //50.573036
            //26.129534 26.329348
            users[key].profile?.age = Int.random(in: 0...100)
            users[key].profile?.gender = .get(Int.random(in: 0...1))
            users[key].profile?.status = .randomItem()
            
            users[key].profile?.isToday = .random()
        }
        
        //requestAllUsers()
    }
    
    func requestAllUsers() {
        UsersListManager.shared.getAllUsers(one: false) { (usersList, error) in
            if let error = error {
                BeautifulOutputer.cPrint(type: .warning, place: .usersSingleM, message1: error.error, message2: String(describing: error))
            }
            
            if let list = usersList {
                //self.users = list
                for item in list {
                    print(item)
                }
            }
        }
    }
}
//50.663654, 26.247111
//50.623921, 26.129534 //50.618258, 26.329348
//50.573036, 26.243678
//Double.random(in: 26.243678...26.247111)
//d
//sh -> 50
