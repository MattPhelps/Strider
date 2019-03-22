//
//  SelectNumberVC.swift
//  Strider
//
//  Created by Matt Phelps on 2018-09-12.
//  Copyright © 2018 Matt Phelps. All rights reserved.
//

import UIKit
import Firebase

protocol PickerRefreshDelegate {
    func refreshAfterRangeChange()
}

class SelectNumberVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var pickerDelegate: PickerRefreshDelegate?
    var arrayOfNumbers = ["1","2","3","4","5","10","20","50","100","250","500"]
    var receivedNumber: String?
    
    lazy var dismissButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Save", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 25)
        button.addTarget(self, action: #selector(handlePress), for: .touchUpInside)
        button.backgroundColor = .white
        button.layer.cornerRadius = 5
        button.backgroundColor = .googleRed()
        return button
    }()
    
    @objc fileprivate func handlePress(){
        if selectedNumber == nil {
            selectedNumber = "1"
        }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let range = self.selectedNumber else { return }
        let values = ["range" : range]
        let ref = Database.database().reference().child("users").child(uid)
        ref.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if let err = err {
                print("Failed to save user info into db:", err)
                return
            }
        })
        self.pickerDelegate?.refreshAfterRangeChange()
        dismiss(animated: true, completion: nil)
    }
    
    let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        return view
    }()
    
    let picker: UIPickerView = {
        let pick = UIPickerView()
        pick.translatesAutoresizingMaskIntoConstraints = false
        pick.backgroundColor = .facebookBlue()
        pick.layer.masksToBounds = true
        pick.setValue(UIColor.white, forKeyPath: "textColor")
       return pick
    }()
    
    fileprivate func setupView(){
        view.addSubview(containerView)
        view.addSubview(dismissButton)
        containerView.addSubview(picker)
        
        containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        containerView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        
        dismissButton.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 10).isActive = true
        dismissButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        dismissButton.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        dismissButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        dismissButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        
        picker.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        picker.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        picker.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        picker.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        picker.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0, alpha: 0.2)
        picker.delegate = self
        picker.dataSource = self
        setupView()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return arrayOfNumbers.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return arrayOfNumbers[row]
    }
    
    var selectedNumber: String?
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedNumber = arrayOfNumbers[row]
        print(selectedNumber)
    }
    
}
