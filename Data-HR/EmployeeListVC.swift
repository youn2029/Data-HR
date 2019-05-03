//
//  EmployeeListVC.swift
//  Data-HR
//
//  Created by 윤성호 on 02/05/2019.
//  Copyright © 2019 윤성호. All rights reserved.
//

import UIKit

class EmployeeListVC: UITableViewController {
    
    var empList: [EmployeeVO]!  // 사원 List
    let empDao = EmployeeDAO()
    
    @IBOutlet var btnEdit: UIBarButtonItem!
    
    func setUI(){
        
        // 내비게이션 타이틀
        let navTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 60))
        navTitle.numberOfLines = 2
        navTitle.textAlignment = .center
        navTitle.font = .systemFont(ofSize: 14)
        navTitle.text = "사원 목록 \n"+"총 \(self.empList.count)개"
        
        self.navigationItem.titleView = navTitle
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.empList = self.empDao.find()
        self.setUI()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.empList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row = self.empList[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Emp_Cell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "Emp_Cell")
        
        
        cell.textLabel?.text = row.empName + " (\(row.stateCd.desc()))"
        cell.textLabel?.font = .systemFont(ofSize: 14)
        
        cell.detailTextLabel?.text = row.departTitle
        cell.detailTextLabel?.font = .systemFont(ofSize: 12)
        
        return cell
    }

    // 사원 추가 Action
    @IBAction func add(_ sender: Any) {
        
        let alert = UIAlertController(title: "사원 등록", message: "등록할 사원 정보를 입력해주세요", preferredStyle: .alert)
        
        // contentViewContrller에 추가될 피커 뷰
        let pickerView = DepartPickerVC()
        alert.setValue(pickerView, forKey: "contentViewController")
        
        alert.addTextField { (tf) in tf.placeholder = "사원명" }
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "확인", style: .default) { (_) in
            
            // 사원 DB에 추가
            var empVo = EmployeeVO()
            
            empVo.departCd = pickerView.selectDepartCd      // 부서코드
            empVo.empName = (alert.textFields?[0].text)!    // 사원명
            empVo.stateCd = EmpStateType.ING                // 재직상태
            
            let format = DateFormatter()
            format.dateFormat = "yyyy-MM-dd"
            empVo.joinDate = format.string(from: Date())    // 입사일
            
            
            if self.empDao.create(param: empVo) {
                self.empList = self.empDao.find()
                self.tableView.reloadData()
                
                if let navTitle = self.navigationItem.titleView as? UILabel {
                    navTitle.text = "사원 목록 \n" + "총 \(self.empList.count)개"
                }                
            }
        })
        
        self.present(alert, animated: false, completion: nil)
    }
    
    @IBAction func editing(_ sender: Any) {
        
        if self.tableView.isEditing == false {
            self.setEditing(true, animated: true)
            (sender as? UIBarButtonItem)?.title = "Done"
        }else {
            self.setEditing(false, animated: true)
            (sender as? UIBarButtonItem)?.title = "Edit"
        }
    }
    
    // 편집 모드에서 처리될 때 호출되는 메소드
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        // 삭제될 사원코드
        let empCd = self.empList[indexPath.row].empCd
        
        if self.empDao.delete(cd: empCd) {
            self.empList = self.empDao.find()
            tableView.reloadData()
            
            if let titleView = self.navigationItem.titleView as? UILabel {
                titleView.text = "사원 목록 \n" + "총 \(self.empList.count)개"
            }
        }
        
    }
    

}
