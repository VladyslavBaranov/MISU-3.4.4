//
//  CitySelectorModalView.swift
//  CoronaVirTracker
//
//  Created by Dmitriy Kruglov on 3/28/20.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class CitySelectorModalView: UIView {
    let mainView: UIView = {
        let vw = UIView()
        vw.translatesAutoresizingMaskIntoConstraints = false
        vw.backgroundColor = UIColor.white
        vw.isUserInteractionEnabled = true
        vw.cornerRadius = 10
        return vw
    }()
    
    let navigationView: UIView = {
        let vw = UIView()
        vw.translatesAutoresizingMaskIntoConstraints = false
        vw.backgroundColor = UIColor.init(hexString: "#EFEFF4")
        vw.isUserInteractionEnabled = true
        vw.addShadow(radius: 1, offset: CGSize.zero, opacity: 1, color: .black)
        return vw
    }()
    
    let doneButton: UIButton = {
        let bt = UIButton(type: .system)
        bt.translatesAutoresizingMaskIntoConstraints = false
        bt.setTitle(NSLocalizedString("Done", comment: ""), for: .normal)
        bt.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium)//.boldSystemFont(ofSize: 16)
        bt.sizeToFit()
        return bt
    }()
    
    let cancelButton: UIButton = {
        let bt = UIButton(type: .system)
        bt.translatesAutoresizingMaskIntoConstraints = false
        bt.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
        bt.setTitleColor(UIColor.init(hexString: "#EE3838"), for: .normal)
        bt.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        bt.sizeToFit()
        return bt
    }()
    
    let firstTitle: UILabel = {
        let tl = UILabel()
        tl.translatesAutoresizingMaskIntoConstraints = false
        tl.textAlignment = .center
        tl.textColor = UIColor.black
        tl.font = UIFont.systemFont(ofSize: 16)
        tl.text = NSLocalizedString("Location", comment: "")
        return tl
    }()
    
    let infoLabel: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.textAlignment = .center
        lb.font = UIFont.systemFont(ofSize: 16)
        lb.numberOfLines = 13
        lb.text = NSLocalizedString("You can choose your exact address or just your city or your other specific location", comment: "")
        return lb
    }()
    
    let infoView: UIView = {
        let iv = UIView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.backgroundColor = UIColor.white
        return iv
    }()
    
    let infoImage: UIImageView = {
        let img = UIImageView()
        img.translatesAutoresizingMaskIntoConstraints = false
        img.contentMode = .scaleAspectFit
        img.clipsToBounds = true
        img.image = UIImage(named: "selectLocationImage")
        return img
    }()
    
    let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.translatesAutoresizingMaskIntoConstraints = false
        sb.searchBarStyle = .minimal
        sb.enablesReturnKeyAutomatically = true
        sb.placeholder = NSLocalizedString("Search", comment: "")
        sb.sizeToFit()
        return sb
    }()
    
    let firstTableView: UITableView = {
        let cl = UITableView()
        cl.translatesAutoresizingMaskIntoConstraints = false
        return cl
    }()
    
    var tableData: [LocationModel] = []
    
    var selectedLocation: LocationModel?
    
    var completion: ((LocationModel) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.frame = frame
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(cancelActionBack))
        tap.delegate = self
        self.addGestureRecognizer(tap)
        self.isUserInteractionEnabled = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        initSetUp()
    }
    
    func initSetUp() {
        self.addSubview(mainView)
        mainView.addSubview(navigationView)
        navigationView.addSubview(cancelButton)
        navigationView.addSubview(firstTitle)
        navigationView.addSubview(doneButton)
        mainView.addSubview(searchBar)
        mainView.addSubview(firstTableView)
        
        cancelButton.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        doneButton.addTarget(self, action: #selector(doneAction), for: .touchUpInside)
        
        setUpConstraints()
        prapareInfoView()
    }
    
    func setUpConstraints() {
        mainView.bottomAnchor .constraint(equalTo: self.bottomAnchor, constant: standartInset).isActive = true
        mainView.heightAnchor.constraint(greaterThanOrEqualToConstant: self.frame.height*0.8).isActive = true
        mainView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        mainView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
        navigationView.topAnchor.constraint(equalTo: mainView.topAnchor).isActive = true
        navigationView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor).isActive = true
        navigationView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor).isActive = true
        navigationView.heightAnchor.constraint(equalToConstant: doneButton.frame.height+standartInset/2).isActive = true
        
        cancelButton.centerYAnchor.constraint(equalTo: navigationView.centerYAnchor).isActive = true
        cancelButton.leadingAnchor.constraint(equalTo: navigationView.leadingAnchor, constant: standartInset).isActive = true
        
        firstTitle.centerYAnchor.constraint(equalTo: navigationView.centerYAnchor).isActive = true
        firstTitle.centerXAnchor.constraint(equalTo: navigationView.centerXAnchor).isActive = true
        
        
        doneButton.centerYAnchor.constraint(equalTo: navigationView.centerYAnchor).isActive = true
        doneButton.trailingAnchor.constraint(equalTo: navigationView.trailingAnchor, constant: -standartInset).isActive = true
        
        searchBar.delegate = self
        searchBar.topAnchor.constraint(equalTo: navigationView.bottomAnchor).isActive = true
        searchBar.leadingAnchor.constraint(equalTo: mainView.leadingAnchor).isActive = true
        searchBar.trailingAnchor.constraint(equalTo: mainView.trailingAnchor).isActive = true
        
        firstTableView.delegate = self
        firstTableView.dataSource = self
        firstTableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor).isActive = true
        firstTableView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor).isActive = true
        firstTableView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor).isActive = true
        firstTableView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: -standartInset).isActive = true
    }
    
    func prapareInfoView() {
        mainView.addSubview(infoView)
        infoView.addSubview(infoLabel)
        infoView.addSubview(infoImage)
        
        infoView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor).isActive = true
        infoView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor).isActive = true
        infoView.topAnchor.constraint(equalTo: searchBar.bottomAnchor).isActive = true
        infoView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: -standartInset).isActive = true
        
        infoLabel.topAnchor.constraint(equalTo: infoView.topAnchor, constant: standartInset*2).isActive = true
        infoLabel.centerXAnchor.constraint(equalTo: infoView.centerXAnchor).isActive = true
        infoLabel.leadingAnchor.constraint(equalTo: infoView.leadingAnchor, constant: standartInset).isActive = true
        infoLabel.trailingAnchor.constraint(equalTo: infoView.trailingAnchor, constant: -standartInset).isActive = true
        
        infoImage.bottomAnchor.constraint(equalTo: infoView.bottomAnchor).isActive = true
        infoImage.centerXAnchor.constraint(equalTo: infoView.centerXAnchor).isActive = true
        infoImage.widthAnchor.constraint(equalTo: infoView.widthAnchor).isActive = true
        infoImage.heightAnchor.constraint(equalTo: infoImage.widthAnchor, multiplier: 0.8).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



extension CitySelectorModalView {
    func show(completion: ((LocationModel) -> Void)? = nil) {
        self.completion = completion
        
        moveDown(0.0)
        
        guard let appDelegate = UIApplication.shared.delegate else {
            return
        }
        guard let window = appDelegate.window else {
            return
        }
        
        self.frame = window?.frame ?? self.frame
        
        window?.addSubview(self)
        window?.bringSubviewToFront(self)
        window?.endEditing(true)
        
        moveUp(0.3)
    }
    
    @objc func doneAction() {
        if searchBar.isFirstResponder {
            endEditing(true)
        }
        
        if let compl = completion, let loc = selectedLocation {
            compl(loc)
        }
        
        moveDown(0.3) { _ in
            self.removeFromSuperview()
        }
    }
    
    @objc func cancelActionBack() {
        if searchBar.isFirstResponder {
            endEditing(true)
            return
        }
        
        cancelAction()
    }
    
    @objc func cancelAction() {
        if searchBar.isFirstResponder {
            endEditing(true)
        }
        
        moveDown(0.3) { _ in
            self.removeFromSuperview()
        }
    }
    
    func moveUp(_ duration: Double, completion: ((Bool) -> Void)? = nil) {
        self.animateShow(duration: duration)
        mainView.animateMove(y: 0, duration: duration)
        doneButton.animateMove(y: 0, duration: duration)
        cancelButton.animateMove(y: 0, duration: duration, completion: completion)
    }
    
    func moveDown(_ duration: Double, completion: ((Bool) -> Void)? = nil) {
        self.animateFade(duration: duration)
        mainView.animateMove(y: self.frame.height, duration: duration)
        doneButton.animateMove(y: self.frame.height, duration: duration)
        cancelButton.animateMove(y: self.frame.height, duration: duration, completion: completion)
    }
}



extension CitySelectorModalView {
    func updateSearchResults(_ text: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = text
        request.region = .init(.null)
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else {
                print(String(describing: error))
                return
            }
            
            self.tableData = []
            
            for item in response.mapItems {
                var name = ""
                var city = ""
                var country = ""
                
                if let nm = item.name {
                    name = nm
                }
                if let ct = item.placemark.locality {
                    city = ct
                }
                if let cntr = item.placemark.country {
                    country = cntr
                }
                
                let adminCenter = item.placemark.administrativeArea
                let coord = Coordinates(CLLCoord: item.placemark.coordinate)
                
                self.tableData.append(LocationModel(name, city: city, country: country, adminArea: adminCenter, coord: coord))
            }
            
            DispatchQueue.main.async {
                self.firstTableView.reloadData()
            }
        }
    }
}

extension CitySelectorModalView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "locationIdReuse")
        
        cell.textLabel?.text = tableData[indexPath.row].name
        cell.detailTextLabel?.text = tableData[indexPath.row].getFullLocationStr()
        
        if tableData[indexPath.row].compare(with: selectedLocation) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.setSelected(false, animated: true)
            
            if tableData[indexPath.row].compare(with: selectedLocation) {
                cell.accessoryType = .none
                selectedLocation = nil
            } else {
                selectedLocation = tableData[indexPath.row]
                cell.accessoryType = .checkmark
            }
        }
        tableView.reloadData()
    }
}

extension CitySelectorModalView: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("textDidChange")
        updateSearchResults(searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("searchBarSearchButtonClicked")
        endEditing(true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        print("searchBarTextDidEndEditing")
        searchBar.setShowsCancelButton(false, animated: true)
        if tableData.isEmpty {
            infoView.animateShow(duration: 0.3)
        }
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        print("searchBarShouldBeginEditing")
        infoView.animateFade(duration: 0.3)
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
}



extension CitySelectorModalView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view != searchBar, touch.view != self { endEditing(true) }
        return touch.view == gestureRecognizer.view
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        let y = self.frame.height * 0.1
        mainView.animateMove(y: -y, duration: 0.3)
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        mainView.animateMove(y: 0, duration: 0.3)
    }
}
