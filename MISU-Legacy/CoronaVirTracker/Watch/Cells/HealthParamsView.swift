//
//  HealthParamsView.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 05.03.2021.
//  Copyright © 2021 CVTCompany. All rights reserved.
//

import UIKit

class HealthParamsView: UIView {
    let paramStack: UIStackView = {
        let st = UIStackView()
        st.translatesAutoresizingMaskIntoConstraints = false
        st.axis = .horizontal
        st.distribution = .equalSpacing
        st.alignment = .center
        st.spacing = 8
        
        return st
    }()
    let paramImages: [UIImageView] = {
        var p: [UIImageView] = []
        HeadersParamEnum.allCases.forEach { param in
            p.append(.makeImageView(param.rawValue))
        }
        return p
    }()
    let paramBack: [UIView] = {
        var p: [UIView] = []
        HeadersParamEnum.allCases.forEach { param in
            let v = UIView.createCustom(bgColor: .white)
            v.cornerRadius = 5
            p.append(.createCustom(bgColor: .white))
        }
        return p
    }()
    let paramLabels: [UILabel] = {
        var p: [UILabel] = []
        HeadersParamEnum.allCases.forEach { param in
            p.append(.createTitle(text: "-"+param.label, fontSize: 12))
        }
        return p
    }()
    
    let paramStackHeight: CGFloat = 40
    let contentInsetCustom: CGFloat = 24
    
    var healthParams: [Float]? {
        didSet {
            guard let hParams = healthParams else { return }
            if let boIndex = HeadersParamEnum.bloodOxygen.index, let boParam = hParams[safe: boIndex], boParam > 0 {
                paramLabels[safe: boIndex]?.text = "\(boParam)" + HeadersParamEnum.bloodOxygen.label
            }
            if let tempIndex = HeadersParamEnum.temperature.index, let tempParam = hParams[safe: tempIndex], tempParam > 0 {
                paramLabels[safe: tempIndex]?.text = "\((tempParam*10).rounded()/10)" + HeadersParamEnum.temperature.label
            }
            if let hrIndex = HeadersParamEnum.heartBeat.index, let hrParam = hParams[safe: hrIndex], hrParam > 0 {
                paramLabels[safe: hrIndex]?.text = "\(Int(hrParam))" + HeadersParamEnum.heartBeat.label
            }
            if let bpIndex = HeadersParamEnum.pressure.index,
               let bpsParam = hParams[safe: bpIndex], bpsParam > 0,
               let bpdParam = hParams[safe: bpIndex+1], bpdParam > 0 {
                paramLabels[safe: bpIndex]?.text = "\(Int(bpsParam)) | \(Int(bpdParam))" + HeadersParamEnum.heartBeat.label
            }
        }
    }
    
    init() {
        super.init(frame: .zero)
        setUpSubViews()
        setUpView()
    }
    
    func setHealthParams(bo: Float?, hr: Float?, temp: Float?, bps: Float?, bpd: Float?) {
        var params: [Float] = []
        HeadersParamEnum.allCases.forEach { type in
            switch type {
            case .bloodOxygen:
                params.append(bo ?? 0)
            case .heartBeat:
                params.append(hr ?? 0)
            case .temperature:
                params.append(temp ?? 0)
            case .pressure:
                params.append(bps ?? 0)
                params.append(bpd ?? 0)
            }
        }
        healthParams = params
    }
    
    func setUpView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .white
        self.cornerRadius = Constants.cornerRadius
        self.addCustomShadow()
    }
    
    func setUpSubViews() {
        addSubview(paramStack)
        
        paramStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: standartInset/2).isActive = true
        paramStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -standartInset/2).isActive = true
        paramStack.setContentHuggingPriority(.defaultLow, for: .vertical)
        paramStack.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        //paramStack.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        paramStack.topAnchor.constraint(equalTo: topAnchor, constant: standartInset/2).isActive = true
        paramStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -standartInset/2).isActive = true
        paramStack.heightAnchor.constraint(equalToConstant: paramStackHeight).isActive = true
        
        paramImages.enumerated().forEach { index, imgV in
            var vws: [UIView] = []
            if let back = paramBack[safe: index] {
                back.addSubview(imgV)
                
                imgV.centerYAnchor.constraint(equalTo: back.centerYAnchor).isActive = true
                imgV.centerXAnchor.constraint(equalTo: back.centerXAnchor).isActive = true
                back.heightAnchor.constraint(equalToConstant: paramStackHeight).isActive = true
                back.widthAnchor.constraint(equalToConstant: paramStackHeight).isActive = true
                back.cornerRadius = 5
                vws.append(back)
            }
            if let lbl = paramLabels[safe: index] {
                vws.append(lbl)
            }
            let stk = UIStackView(arrangedSubviews: vws)
            stk.axis = .horizontal
            stk.spacing = 2
            stk.distribution = .equalSpacing
            let w = (imgV.image?.size.width ?? 1)/(imgV.image?.size.height ?? 1)
            imgV.heightAnchor.constraint(equalToConstant: paramStackHeight-standart24Inset).isActive = true
            imgV.widthAnchor.constraint(equalToConstant: (paramStackHeight-standart24Inset)*w).isActive = true
            paramStack.addArrangedSubview(stk)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

