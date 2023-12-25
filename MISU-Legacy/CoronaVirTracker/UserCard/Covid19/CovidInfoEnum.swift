//
//  CovidInfoEnum.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 14.07.2021.
//  Copyright © 2021 CVTCompany. All rights reserved.
//

import UIKit

enum CovidInfoEnum {
    case inRisk
    case noRisk
    case bodyIndex
    
    var image: UIImage? {
        return UIImage(named: imageName)
    }
    
    var ttLocalized: String {
        return NSLocalizedString(titleText, comment: "")
    }
    
    var attributedText: NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.25
        switch self {
        case .inRisk:
            let allRiskText = NSLocalizedString("• Tell your doctor about symptoms and history of travel. You need to tell whether you have been in contact with people who could potentially become infected (for example, people who have returned from countries with a local spread of the virus).\n• Follow your doctor's instructions \n\n❌ You do not need to make your own decisions and go for testing for COVID-19\n• Firstly, the decision to make a test is making by your family doctor or therapist. \n• At second, the risk of catching the virus in a laboratory or hospital increases if there is a person with the coronavirus nearby.", comment: "")
            let redRiskText = NSLocalizedString("❌ You do not need to make your own decisions and go for testing for COVID-19", comment: "")
            let attrStr = NSMutableAttributedString(string: allRiskText, attributes: [.paragraphStyle: paragraphStyle])
            attrStr.setAttributes([.foregroundColor:UIColor.appDefault.redNew,
                                   .font:UIFont.systemFont(ofSize: 16, weight: .bold),
                                   .paragraphStyle: paragraphStyle],
                                  range: (allRiskText as NSString).range(of: redRiskText))
            return attrStr
        case .noRisk:
            let allText = NSLocalizedString("• Keep the rules of hand hygiene. Wash your hands often with soap or treat them with an alcohol-based hand antiseptic. \n• Keep the distance from people who sneezes or coughs. \n• Wear a mask, where you are surrounded by other people. \n• Don't touch your eyes or nose by hand. \n• During sneezing or coughing cover your mouth and nose with an elbow or handkerchief. \n• If you are feeling bad, please, stay home. \n• If you have a fever, cough, or shortness of breath, visit a doctor.", comment: "")
            let lastPhar = NSLocalizedString("• If you have a fever, cough, or shortness of breath, visit a doctor.", comment: "")
            let redText = NSLocalizedString("visit a doctor.", comment: "")
            let attrStr = NSMutableAttributedString(string: allText, attributes: [.paragraphStyle: paragraphStyle])
            attrStr.setAttributes([.font:UIFont.systemFont(ofSize: 16, weight: .bold),
                                   .paragraphStyle: paragraphStyle],
                                  range: (allText as NSString).range(of: lastPhar))
            attrStr.setAttributes([.foregroundColor:UIColor.appDefault.redNew,
                                   .font:UIFont.systemFont(ofSize: 16, weight: .bold),
                                   .paragraphStyle: paragraphStyle],
                                  range: (allText as NSString).range(of: redText))
            return attrStr
        case .bodyIndex:
            let txt = NSLocalizedString("• Body mass index (BMI) - a value that allows you to assess the degree of compliance of human mass and height, and then, indirectly assess whether the mass is insufficient, normal or excessive\n\nAdult BMI Calculator:\nBelow 18.5       Underweight\n18.5—24.9        Normal\n25.0—29.9        Overweight\n30.0 and above   Obese\n\n• BMI is a person’s weight in kilograms divided by the square of height in meters. A high BMI can indicate high body fatness. BMI screens for weight categories that may lead to health problems, but it does not diagnose the body fatness or health of an individual", comment: "")
            
            let txtb = NSLocalizedString("Adult BMI Calculator:", comment: "")
            let txtY1 = NSLocalizedString("Underweight", comment: "")
            let txtG = NSLocalizedString("Normal", comment: "")
            let txtY2 = NSLocalizedString("Overweight", comment: "")
            let txtR = NSLocalizedString("Obese", comment: "")
            let txtMono1 = NSLocalizedString("Below 18.5       Underweight", comment: "")
            let txtMono2 = NSLocalizedString("18.5—24.9        Normal", comment: "")
            let txtMono3 = NSLocalizedString("25.0—29.9        Overweight", comment: "")
            let txtMono4 = NSLocalizedString("30.0 and above   Obese", comment: "")
            
            let attrStr = NSMutableAttributedString(string: txt, attributes: [.paragraphStyle: paragraphStyle])
            
            [txtMono1, txtMono2, txtMono3,txtMono4].forEach { str in
                attrStr.setAttributes([.font:UIFont.monospacedSystemFont(ofSize: 16, weight: .regular),
                                       .paragraphStyle: paragraphStyle],
                                      range: (txt as NSString).range(of: str))
            }
            
            attrStr.setAttributes([.font:UIFont.systemFont(ofSize: 16, weight: .bold),
                                   .paragraphStyle: paragraphStyle],
                                  range: (txt as NSString).range(of: txtb))
            attrStr.setAttributes([.foregroundColor:UIColor.appDefault.yellow,
                                   .font:UIFont.monospacedSystemFont(ofSize: 16, weight: .bold),
                                   .paragraphStyle: paragraphStyle],
                                  range: (txt as NSString).range(of: txtY1))
            attrStr.setAttributes([.foregroundColor:UIColor.appDefault.yellow,
                                   .font:UIFont.monospacedSystemFont(ofSize: 16, weight: .bold),
                                   .paragraphStyle: paragraphStyle],
                                  range: (txt as NSString).range(of: txtY2))
            attrStr.setAttributes([.foregroundColor:UIColor.appDefault.green,
                                   .font:UIFont.monospacedSystemFont(ofSize: 16, weight: .bold),
                                   .paragraphStyle: paragraphStyle],
                                  range: (txt as NSString).range(of: txtG))
            attrStr.setAttributes([.foregroundColor:UIColor.appDefault.redNew,
                                   .font:UIFont.monospacedSystemFont(ofSize: 16, weight: .bold),
                                   .paragraphStyle: paragraphStyle],
                                  range: (txt as NSString).range(of: txtR))
            
            return attrStr
        }
    }
    
    var titleText: String {
        switch self {
        case .inRisk:
            return "What I need to do if I am at risk group"
        case .noRisk:
            return "Prevention of Covid-19"
        case .bodyIndex:
            return "Body mass index"
        }
    }
    
    var imageName: String {
        switch self {
        case .inRisk:
            return "covidRiskImage"
        case .noRisk:
            return "covidProfImage"
        case .bodyIndex:
            return "IndexMassImage"
        }
    }
}
