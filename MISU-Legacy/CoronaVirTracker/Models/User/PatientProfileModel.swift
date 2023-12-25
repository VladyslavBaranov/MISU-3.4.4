//
//  PatientProfileModel.swift
//  CoronaVirTracker
//
//  Created by WH ak on 11.06.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

struct UserCardModel {
    let id: Int
    var name: String?
    var image: UIImage?
    var imageURL: String?
    var status: HealthStatus?
    var temperature: Float = 36.6
    var bloodSugar: HealthParameterModel?
    var insulinValue: HealthParameterModel?
    var scaleCF: ScaleFCEnum = .celsius
    var symptoms: [String] = []
    var whatIDo: String?
    var whatINeed: String?
    var age: Int?
    var weight: Double?
    var height: Double?
    var birthdayDate: Date?
    var gender: Gender = .none
    var isToday: Bool = false
    var familyDoctor: DoctorModel?
    
    init(id: Int) {
        self.id = id
    }
    
    init(age: Int, gender: Gender, status: HealthStatus) {
        self.id = -1
        self.age = age
        self.gender = gender
        self.status = status
    }
}

extension UserCardModel: Equatable {
    static func ==(first: UserCardModel, second: UserCardModel) -> Bool {
        return first.id == second.id && first.name == second.name
    }
}

extension UserCardModel {
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
    
    func getDiferentParams(with old: UserCardModel) -> Parameters {
        var params: Parameters = [:]
        
        if name != old.name { params.updateValue(name ?? "", forKey: Keys.name.rawValue) }
        if status?.rawValue != old.status?.rawValue { params.updateValue(status?.rawValue ?? 0, forKey: Keys.status.rawValue) }
        if temperature != old.temperature { params.updateValue(temperature, forKey: Keys.temperature.rawValue) }
        if weight != old.weight { params.updateValue(weight as Any, forKey: Keys.weight.rawValue) }
        if height != old.height { params.updateValue(height as Any, forKey: Keys.height.rawValue) }
        //if bloodSugar != old.bloodSugar { params.updateValue(bloodSugar ?? 0, forKey: Keys.bloodSugar.rawValue) }
        if symptoms != old.symptoms { params.updateValue(symptoms, forKey: Keys.symptoms.rawValue) }
        //if age != old.age { params.updateValue(age ?? 0, forKey: Keys.age.rawValue) }
        if birthdayDate != old.birthdayDate { params.updateValue(birthdayDate?.getDateForRequest() as Any, forKey: Keys.birthday.rawValue) }
        if gender.rawValue != old.gender.rawValue { params.updateValue(gender.rawValue, forKey: Keys.gender.rawValue) }
        if familyDoctor?.id != old.familyDoctor?.id { params.updateValue(familyDoctor?.id as Any, forKey: Keys.familyDoctor.rawValue) }
        
        return params
    }
    
    func getDiferentFiles(with old: UserCardModel) -> Files {
        var files: Files = []
        
        if !(image?.compare(with: ImageCM.shared.get(byLink: old.imageURL)) ?? true) {
            let file = FileModel(name: "image_new\(Date().getTimeDate(format: "HH_mm_ss-d_M_y")).jpg", type: .imageJpg, data: image?.jpegData(compressionQuality: 1))
            files.append(file)
        }
        
        return files
    }
    
    func getFamilyDoctorUserModel() -> UserModel? {
        guard let famDoc = familyDoctor else { return nil }
        var user = UserModel(id: famDoc.id)
        user.doctor = famDoc
        user.userType = UserTypeEnum.determine(user)
        return user
    }
    
    mutating func requestFamilyDoctorUserModel(completion: ((UserModel?) -> Void)?) {
        ListDHManager.shared.getAllDoctors(onlyOneDoctor: getFamilyDoctorUserModel(), one: true) { (doctorsList, error) in
            if let famDoc = doctorsList?.first {
                completion?(famDoc)
            }
            if let er = error {
                print("Get Fam Doc Error: \(er)")
                completion?(nil)
            }
        }
    }
    
    func encodeForCreateRequest() -> Parameters {
        return [Keys.age.rawValue:age ?? 0,
                Keys.gender.rawValue:gender.rawValue,
                Keys.status.rawValue:status?.rawValue ?? 0]
    }
    
    func encodeForGeneralInfoRequest() -> Parameters {
        return [Keys.name.rawValue:(name ?? nil) as Any,
                Keys.birthday.rawValue:(birthdayDate?.getDateForRequest() ?? nil) as Any,
                Keys.gender.rawValue:gender.rawValue]
    }
}

extension UserCardModel: Codable {
    private enum Keys: String, CodingKey {
        case id = "id"
        case name = "name"
        case status = "status"
        case temperature = "temperature"
        case bloodSugar = "sugar_level"
        case insulinValue = "insulin"
        case scaleCF = "scaleCF"
        case symptoms = "symptoms"
        case whatIDo = "whatIDo"
        case whatINeed = "whatINeed"
        case age = "age"
        case weight = "weight"
        case height = "height"
        case birthday = "birth_date"
        case gender = "gender"
        case isToday = "isToday"
        case image = "imageModel"
        case imageURL = "image"
        case familyDoctor = "doctor"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        
        id = (try? container.decode(Int.self, forKey: .id)) ?? -1
        name = try? container.decode(String.self, forKey: .name)
        if let imgData = try? container.decode(Data.self, forKey: .image) {
            image = UIImage(data: imgData)
        }
        imageURL = try? container.decode(String.self, forKey: .imageURL)
        
        let hStatusId = try? container.decode(Int.self, forKey: .status)
        status = .get(hStatusId)
        
        if let temp = try? container.decode(Float.self, forKey: .temperature) {
            temperature = temp
        }
        
        bloodSugar = try? container.decode(HealthParameterModel.self, forKey: .bloodSugar)
        insulinValue = try? container.decode(HealthParameterModel.self, forKey: .insulinValue)
        
        if let sc = try? container.decode(Int.self, forKey: .scaleCF) {
            scaleCF = .get(sc)
        }
        
        if let sympt = try? container.decode([String].self, forKey: .symptoms) {
            symptoms = sympt
        }
        whatIDo = try? container.decode(String.self, forKey: .whatIDo)
        whatINeed = try? container.decode(String.self, forKey: .whatINeed)
        age = try? container.decode(Int.self, forKey: .age)
        if let birthDay = try? container.decode(String.self, forKey: .birthday) {
            birthdayDate = birthDay.toDate()
        }
        
        if let sx = try? container.decode(Int.self, forKey: .gender) {
            gender = .get(sx)
        }
        
        if let isTod = try? container.decode(Bool.self, forKey: .isToday) {
            isToday = isTod
        }
        familyDoctor = try? container.decode(DoctorModel.self, forKey: .familyDoctor)
        if familyDoctor == nil, let famDocID = try? container.decode(Int.self, forKey: .familyDoctor) {
            familyDoctor = DoctorModel(id: famDocID)
        }
        
        weight = try? container.decode(type(of: weight).self, forKey: .weight)
        height = try? container.decode(type(of: height).self, forKey: .height)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        
        try container.encode(id, forKey: .id)
        try? container.encode(name, forKey: .name)
        try? container.encode(image?.pngData(), forKey: .image)
        try? container.encode(imageURL, forKey: .imageURL)
        try? container.encode(status?.rawValue, forKey: .status)
        try container.encode(temperature, forKey: .temperature)
        try? container.encode(bloodSugar, forKey: .bloodSugar)
        try? container.encode(insulinValue, forKey: .insulinValue)
        try container.encode(scaleCF.rawValue, forKey: .scaleCF)
        
        try? container.encode(symptoms, forKey: .symptoms)
        try? container.encode(whatIDo, forKey: .whatIDo)
        try? container.encode(whatINeed, forKey: .whatINeed)
        try? container.encode(age, forKey: .age)
        try? container.encode(birthdayDate?.getTimeDateForRequest(), forKey: .birthday)
        try? container.encode(gender.rawValue, forKey: .gender)
        try container.encode(isToday, forKey: .isToday)
        
        try? container.encode(weight, forKey: .weight)
        try? container.encode(height, forKey: .height)
        
        try? container.encode(familyDoctor, forKey: .familyDoctor)
    }
}
