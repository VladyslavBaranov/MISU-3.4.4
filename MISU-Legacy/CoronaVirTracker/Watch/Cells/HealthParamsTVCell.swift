//
//  HealthParamsTVCell.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 24.02.2021.
//  Copyright © 2021 CVTCompany. All rights reserved.
//

import UIKit

class HealthParamsTVCell: UITableViewCell, RequestUIController {
    func uniqeKeyForStore() -> String? { return getAddress() }
    
    let hParamView: HealthParamsView = .init()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpSubViews()
        setUpView()
    }
    
    init() {
        super.init(style: .default, reuseIdentifier: "")
        setUpSubViews()
        setUpView()
    }
    
    func setHealthParams(bo: Float?, hr: Float?, temp: Float?, bps: Float?, bpd: Float?) {
        hParamView.setHealthParams(bo: bo, hr: hr, temp: temp, bps: bps, bpd: bpd)
    }
    
    func setUpView() {
        self.backgroundColor = .clear
    }
    
    func setUpSubViews() {
        addSubview(hParamView)
        hParamView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.inset/2).isActive = true
        hParamView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.inset/2).isActive = true
        hParamView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    static func getHeight() -> CGFloat {
        let cell = HealthParamsTVCell()
        cell.layoutIfNeeded()
        return cell.hParamView.frame.height
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

