//
//  DepartPickerVC.swift
//  Data-HR
//
//  Created by 윤성호 on 03/05/2019.
//  Copyright © 2019 윤성호. All rights reserved.
//

import UIKit

class DepartPickerVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let departDao = DepartmentDAO()
    var departList: [(departCd: Int, departTitle: String, departAddr: String)]!
    var pickerView: UIPickerView!
    
    // 선택되어있는 부서의 코드를 가져온다
    var selectDepartCd: Int {
        let index = self.pickerView.selectedRow(inComponent: 0)
        return departList[index].departCd
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.departList = self.departDao.find()     // 부서 리스트 초기화
        
        // 피커 뷰 설정
        self.pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
        
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        self.view.addSubview(self.pickerView)
        
        // 외부에서 뷰 컨트롤러를 참조할 때를 위한 사이즈 지정
        let pWidth = self.pickerView.frame.width
        let pHeight = self.pickerView.frame.height
        self.preferredContentSize = CGSize(width: pWidth, height: pHeight)
    }
    
    // 피커 뷰의 컨퍼너트 갯수
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // 피커 뷰의 객수
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.departList.count
    }
    
    // 피커 뷰의 각 행에 표시될 뷰를 결정하는 메소드 -> 뷰의 속성을 설정 할 수 있다
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let titleView = view as? UILabel ?? {
            let titleView = UILabel()
            titleView.font = .systemFont(ofSize: 14)
            titleView.textAlignment = .center
            return titleView
        }()
        
        titleView.text = departList[row].departTitle + " (\(departList[row].departAddr))"
        return titleView
    }

}
