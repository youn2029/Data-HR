//
//  DepartmentInfoVC.swift
//  Data-HR
//
//  Created by 윤성호 on 03/05/2019.
//  Copyright © 2019 윤성호. All rights reserved.
//

import UIKit

class DepartmentInfoVC: UITableViewController {
    
    // 부서 정보를 저장할 데이터 타입
    typealias DepartRecord = (departCd: Int, departTitle: String, departAddr: String)
    
    // 전달되는 부서 코드
    var paramDepartCd: Int!
    
    // Dao
    let departDao = DepartmentDAO()
    let empDao = EmployeeDAO()
    
    // 부서정보와 사원 목록을 담을 맴버 변수
    var departInfo: DepartRecord!
    var empList: [EmployeeVO]!

    override func viewDidLoad() {
        super.viewDidLoad()

        // 부서정보와 사원 목록 초기화
        self.departInfo = self.departDao.get(departCd: self.paramDepartCd)
        self.empList = self.empDao.find(departCd: self.paramDepartCd)
        
        self.navigationItem.title = "\(self.departInfo.departTitle)"
    }

    // 테이블 뷰의 섹션 갯수 설정
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    // 섹션의 해더를 UIView로 설정하는 메소드
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        // 헤더에 들어갈 레이블 객체 정의
        let headerTitle = UILabel(frame: CGRect(x: 35, y: 5, width: 200, height: 30))
        headerTitle.font = .systemFont(ofSize: 15, weight: UIFont.Weight(rawValue: 2.5))
        headerTitle.textColor = UIColor(red: 0.03, green: 0.28, blue: 0.71, alpha: 1.0)
        
        // 헤더에 들어갈 이미지 객체
        let headerIcon = UIImageView()
        headerIcon.frame = CGRect(x: 10, y: 10, width: 20, height: 20)
        
        // 섹션에 따른 타이틀과 이미지 설정
        switch section {
        case 0:
            headerTitle.text = "부서정보"
            headerIcon.image = UIImage(imageLiteralResourceName: "depart")
        case 1:
            headerTitle.text = "사원정보"
            headerIcon.image = UIImage(imageLiteralResourceName: "employee")
        default:
            break
        }
        
        // UIView 설정
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
        view.backgroundColor = UIColor(red: 0.93, green: 0.96, blue: 0.99, alpha: 1.0)
        
        // 레이블과 이미지를 추가
        view.addSubview(headerTitle)
        view.addSubview(headerIcon)
        
        return view
    }
    
    // 섹션별 헤더의 높이를 설정하는 메소드
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

    // 섹션별 셀의 갯수를 설정하는 메소드
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {   // 부서정보 섹션
            return 3
        }else {     // 사원정보 섹션
            return self.empList.count
        }
    }
    
    // 셀의 구성을 설정하는 메소드
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {     // 부서정보 섹션
            let cell = tableView.dequeueReusableCell(withIdentifier: "Depart_Cell") ?? UITableViewCell(style: .value2, reuseIdentifier: "Depart_Cell")
            
            cell.textLabel?.font = .systemFont(ofSize: 13)
            cell.detailTextLabel?.font = .systemFont(ofSize: 12)
            
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "부서 코드"
                cell.detailTextLabel?.text = "\(self.departInfo.departCd)"
            case 1:
                cell.textLabel?.text = "부서명"
                cell.detailTextLabel?.text = self.departInfo.departTitle
            case 2:
                cell.textLabel?.text = "부서 주소"
                cell.detailTextLabel?.text = self.departInfo.departAddr
            default :
                ()
            }
            
            return cell
            
        }else {     // 사원정보 섹션
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "Emp_Cell") ?? UITableViewCell(style: .default, reuseIdentifier: "Emp_Cell")
            
            let row = self.empList[indexPath.row]
            
            cell.textLabel?.text = row.empName + " (입사일: \(row.joinDate))"
            cell.textLabel?.font = .systemFont(ofSize: 12)
            
            let state = UISegmentedControl(items: ["재직중", "휴직", "퇴사"])
            state.frame.origin = CGPoint(x: self.view.frame.width - state.frame.width - 10, y: 10)
            state.selectedSegmentIndex = row.stateCd.rawValue
            state.tag = row.empCd       // tag에 사원코드 저장
            state.addTarget(self, action: #selector(changeState(_:)), for: .valueChanged)
            
            cell.contentView.addSubview(state)
            
            return cell
        }
    }
    
    @objc func changeState(_ sender: UISegmentedControl){
        
        let empCd = sender.tag      // 사원코드
        let stateCd = sender.selectedSegmentIndex       // 선택된 재직 상태
        
        if self.empDao.editState(empCd: empCd, stateCd: stateCd) {
            // 완료
            let alert = UIAlertController(title: nil, message: "재직 상태가 변경되었습니다", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .cancel, handler: nil))
            self.present(alert, animated: false, completion: nil)
        }
        
    }
}
