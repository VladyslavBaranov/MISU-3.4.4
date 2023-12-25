//
//  DoctorModel.swift
//  CoronaVirTracker
//
//  Created by Dmitriy Kruglov on 4/11/20.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation
import UIKit

struct DoctorModel {
    let id: Int
    
    var fullName: String?
    var image: UIImage?
    var imageURL: String?
    var docPost: DoctorPositionModel?
    //var docPostModel: HospitalWorkPostModel?
    
    var diplomaId: String?
    var verifyingStatus: VerifyingModel = VerifyingModel()
    
    var hospital: LocationModel?
    var hospitalModel: HospitalModel?
    var statistic: HealthStatisticModel = .init(well: 0, weak: 0, ill: 0, dead: 0)
    
    var weNeed: String?
    var weHave: String?
    var weNeedList: [NeedsModel] = []
    var weHaveList: [NeedsModel] = []
    let needsSeparetor: String = " - "
    
    var patients: [UserModel] = []
    
    init(id: Int) {
        self.id = id
    }
    
    init(diploma: String, position: DoctorPositionModel) {
        self.id = -1
        self.diplomaId = diploma
        self.docPost = position
    }
}

extension DoctorModel: Equatable {
    static func ==(first: DoctorModel, second: DoctorModel) -> Bool {
        return first.id == second.id && first.fullName == second.fullName
    }
}

extension DoctorModel {
    func getImage(_ completion: ((UIImage)->Void)? ) {
        guard let imgLink = imageURL else { return }
        ImagesManager.shared.getBy(link: imgLink) { (imageData, error) in
            if let dt = imageData, let img = UIImage(data: dt) {
                completion?(img)
            }
            
            if let er = error {
                print("Get profile image error: \(er)")
            }
        }
    }
    
    func encodeForCreateRequest() -> Parameters {
        return [:]//[Keys.diplomaId.rawValue:diplomaId ?? ""]
    }
    
    func getHospital() -> HospitalModel? {
        return nil//ListDHUSingleManager.shared.hospitals[safe: Int.random(in: 0...ListDHUSingleManager.shared.hospitals.count-1)]
    }
    
    func getStatusImage() -> UIImage? {
        if verifyingStatus.approved {
            return UIImage(named: "approvedDocStatus")
        }
        return UIImage(named: "notApprovedDocStatus")
    }
    
    func getStatusTitle() -> String {
        if verifyingStatus.verified, verifyingStatus.approved {
            return NSLocalizedString("Your profile approved", comment: "")
        } else if verifyingStatus.verified {
            return NSLocalizedString("Profile was denied \nPlease, check information", comment: "")
        }
        return NSLocalizedString("Your profile is currently verifying...", comment: "")
    }
    
    func getNeedsList() -> [NeedsModel] {
        return weNeedList+weHaveList
    }
    
    mutating func setNeedsFrom(list: [NeedsModel]) {
        var needs: [NeedsModel] = []
        var haves: [NeedsModel] = []
        list.forEach { need in
            if need.done ?? false {
                haves.append(need)
            } else {
                needs.append(need)
            }
        }
        weNeedList = needs
        weHaveList = haves
    }
    
    func getDiferentParams(with old: DoctorModel) -> Parameters {
        var params: Parameters = [:]
        
        if !(image?.compare(with: ImageCM.shared.get(byLink: old.imageURL)) ?? true) { }
        //print("\(docPost?.id) != \(old.id)")
        if fullName != old.fullName { params.updateValue(fullName ?? "", forKey: Keys.fullName.rawValue) }
        if docPost?.id != old.docPost?.id { params.updateValue(docPost?.id as Any, forKey: Keys.docPostModel.rawValue) }
        if diplomaId != old.diplomaId { params.updateValue(diplomaId as Any, forKey: Keys.diplomaId.rawValue) }
        if hospitalModel?.id != old.hospitalModel?.id { params.updateValue(hospitalModel?.id as Any, forKey: Keys.hospital.rawValue) }
        if weNeedList != old.weNeedList { params.updateValue(encodeNeedsAsPram(weNeedList), forKey: Keys.weNeedList.rawValue) }
        if weHaveList != old.weHaveList { params.updateValue(encodeNeedsAsPram(weHaveList), forKey: Keys.weHaveList.rawValue) }
        
        return params
    }
    
    func getDiferentFiles(with old: DoctorModel) -> Files {
        var files: Files = []
        
        if !(image?.compare(with: ImageCM.shared.get(byLink: old.imageURL)) ?? true) {
            let file = FileModel(name: "image_new\(Date().getTimeDate(format: "HH_mm_ss-d_M_y")).jpg", type: .imageJpg, data: image?.jpegData(compressionQuality: 1))
            files.append(file)
        }
        
        return files
    }
    
    func encodeNeedsAsPram(_ needs: [NeedsModel]) -> [String] {
        var param: [String] = []
        needs.forEach { nd in
            param.append("\(nd.name)\(needsSeparetor)\(nd.count ?? 0)")
        }
        return param
    }
    
    func decodeNeeds(_ needs: [String], done: Bool) -> [NeedsModel] {
        var nedMod: [NeedsModel] = []
        needs.forEach { nd in
            let parts = nd.components(separatedBy: needsSeparetor)
            let name: String = parts.count > 1 ? parts.dropLast().joined(separator: needsSeparetor) : parts.first ?? ""
            let count: Int = parts.count > 1 ? (Int(parts.last ?? "") ?? 0) : 0
            nedMod.append(NeedsModel(name: name, count: count, done: done))
        }
        return nedMod
    }
    
    func encodeForGeneralInfoRequest() -> Parameters {
        return [Keys.fullName.rawValue:(fullName ?? nil) as Any]
    }
}

extension DoctorModel: Codable {
    private enum Keys: String, CodingKey {
        case id = "id"
        case diplomaId = "diploma"
        
        case hospital = "hospital"
        case hospitalLocation = "hospitalLocation"
        case statistic = "Ill"
        case fullName = "name"
        case image = "UIimage"
        case imageURL = "image"
        case docPost = "positionPost"
        case docPostModel = "position"
        case weNeed = "weNeed"
        case weHave = "weHave"
        case weNeedList = "needs"
        case weHaveList = "have"
        case verifyingStatus = "real"
        
        case patients = "patients"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        
        id = (try? container.decode(Int.self, forKey: .id)) ?? -1
        diplomaId = try? container.decode(String.self, forKey: .diplomaId)
        hospital = try? container.decode(LocationModel.self, forKey: .hospitalLocation)
        hospitalModel = try? container.decode(HospitalModel.self, forKey: .hospital)
        if let stat = try? container.decode(HealthStatisticModel.self, forKey: .statistic)  {
            statistic = stat
        }
        fullName = try? container.decode(String.self, forKey: .fullName)
        if let imgData = try? container.decode(Data.self, forKey: .image) {
            image = UIImage(data: imgData)
        }
        imageURL = try? container.decode(String.self, forKey: .imageURL)
//        if let post = try? container.decode(Int.self, forKey: .docPost) {
//            docPost = DocWorkPost.get(id: post)
//        }
        docPost = try? container.decode(DoctorPositionModel.self, forKey: .docPostModel)
//        if let idp = docPostModel?.id {
//            docPost = DocWorkPost.get(id: idp)
//        }
        
        //weNeed = try? container.decode(String.self, forKey: .weNeed)
        //weHave = try? container.decode(String.self, forKey: .weHave)
        
        weNeedList = (try? container.decode([NeedsModel].self, forKey: .weNeedList)) ?? []
        weHaveList = (try? container.decode([NeedsModel].self, forKey: .weHaveList)) ?? []
        
        if let needs = try? container.decode([String].self, forKey: .weNeedList), weNeedList.isEmpty {
            weNeedList = decodeNeeds(needs, done: false)
        }
        if let haves = try? container.decode([String].self, forKey: .weHaveList), weHaveList.isEmpty {
            weHaveList = decodeNeeds(haves, done: true)
        }
        
        if let verif = try? container.decode(Bool.self, forKey: .verifyingStatus) {
            verifyingStatus = VerifyingModel(verified: verif, approved: verif)
        }
        
        if let pati = try? container.decode([UserModel].self, forKey: .patients) {
            patients = pati
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        
        try container.encode(id, forKey: .id)
        try? container.encode(diplomaId, forKey: .diplomaId)
        try? container.encode(hospital, forKey: .hospitalLocation)
        try? container.encode(hospitalModel, forKey: .hospital)
        try container.encode(statistic, forKey: .statistic)
        try? container.encode(fullName, forKey: .fullName)
        try? container.encode(image?.pngData(), forKey: .image)
        try? container.encode(imageURL, forKey: .imageURL)
        try? container.encode(docPost, forKey: .docPostModel)
        //try? container.encode(docPostModel, forKey: .docPostModel)
        try? container.encode(weNeed, forKey: .weNeed)
        try? container.encode(weHave, forKey: .weHave)
        try container.encode(weNeedList, forKey: .weNeedList)
        try container.encode(weHaveList, forKey: .weHaveList)
        try container.encode(verifyingStatus, forKey: .verifyingStatus)
        try container.encode(patients, forKey: .patients)
    }
}
