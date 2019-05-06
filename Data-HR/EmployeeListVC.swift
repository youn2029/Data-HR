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
    
    var bgCircle: UIView!
    var loadingImg: UIImageView!    // 커스텀 세로고침의 이미지 뷰
    
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
        
        // 당겨서 세로고침 기능
        self.refreshControl = UIRefreshControl()
//        self.refreshControl?.attributedTitle = NSAttributedString(string: "당겨서 새로고침")
        self.refreshControl?.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)
        
        // 커스텀 세로고침의 이미지 뷰 설정
        self.loadingImg = UIImageView(image: UIImage(named: "refresh"))
        self.loadingImg.center.x = (self.refreshControl?.frame.width)! / 2
        
        // 배경 뷰 초기화 및 노란 원 형태를 위한 속성 설정
        self.bgCircle = UIView()
        self.bgCircle.backgroundColor = .yellow
        self.bgCircle.center.x = (self.refreshControl?.frame.width)! / 2
        
        self.refreshControl?.addSubview(self.bgCircle)
//        self.refreshControl?.bringSubviewToFront(self.loadingImg)     // 인자값으로 사용된 뷰를 가장 앞쪽으로 순서를 바꾼다는 메소드
        
        self.refreshControl?.tintColor = .clear
        self.refreshControl?.addSubview(self.loadingImg)
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
    
    // refreshControl에 연결할 메소드
    @objc func pullToRefresh(_ sender: Any){
        self.empList = self.empDao.find()
        self.tableView.reloadData()
        
        // 당겨서 새로고침 기능 종료
        self.refreshControl?.endRefreshing()
        
        // 노란 원이 로딩 이미지를 중심으로 커지는 애니메이션
        let distance = max(0.0, -(self.refreshControl?.frame.origin.y)!)
        UIView.animate(withDuration: 0.5) {
            self.bgCircle.frame.size = CGSize(width: 80, height: 80)
            self.bgCircle.center = CGPoint(x: (self.refreshControl?.frame.width)! / 2, y: distance / 2)
            self.bgCircle.layer.cornerRadius = self.bgCircle.frame.width / 2
        }
    }
    
    // 스크롤되는 매 순간마다 호출되는 메소드
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 당긴 거리
        let distance = max(0.0, -(self.refreshControl?.frame.origin.y)!)
        self.loadingImg.center.y = distance / 2     // y좌표를 당긴 거리만큼 수정
        
        // 당긴 거리를 회전 각도로 변환하여 로딩 이미지에 설정
        let ts = CGAffineTransform(rotationAngle: CGFloat(distance / 20))
        self.loadingImg.transform = ts
        
        // 배경 뷰의 중심 좌표
        self.bgCircle.center.y = distance / 2
    }
    
    // 스르롤 뷰의 드래그가 끝났을 때 호출되는 메소드
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.bgCircle.frame.size = CGSize(width: 0, height: 0)
    }
}
