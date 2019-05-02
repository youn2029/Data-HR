//
//  DepartmentListVC.swift
//  Data-HR
//
//  Created by 윤성호 on 02/05/2019.
//  Copyright © 2019 윤성호. All rights reserved.
//

import UIKit

class DepartmentListVC: UITableViewController {
    
    var departList: [(departCd: Int, departTitle: String, departAddr: String)]!     // 테이터 변수
    let departDao = DepartmentDAO()         // Dao 객체

    // 기본 UI를 설정하는 메소드
    func setUI(){
        
        // 내비게이션 Title
        let title = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 60))
        title.numberOfLines = 2
        title.textAlignment = .center
        title.font = .systemFont(ofSize: 14)
        title.text = "부서 목록 \n "+"총 \(self.departList.count)개"
        
        // 내비게이션 바
        self.navigationItem.titleView = title
        self.navigationItem.leftBarButtonItem = self.editButtonItem     // 편집 버튼 추가
        
        // 셀을 스와이프했을 때 편집 모드 설정
        self.tableView.allowsSelectionDuringEditing = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.departList = self.departDao.find() // 전체 부서 리스트 조회
        self.setUI()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.departList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row = self.departList[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Depart_Cell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "Depart_Cell")
        
        cell.textLabel?.text = row.departTitle
        cell.textLabel?.font = .systemFont(ofSize: 14)
        
        cell.detailTextLabel?.text = row.departAddr
        cell.detailTextLabel?.font = .systemFont(ofSize: 12)

        return cell
    }
  
    // 부서 add Action
    @IBAction func add(_ sender: Any) {
        let alert = UIAlertController(title: "신규 부서 등록", message: "신규 부서를 등록해 주세요", preferredStyle: .alert)
        
        alert.addTextField { (tf) in tf.placeholder = "부서명" }   // 부서명 텍스트 필드
        alert.addTextField { (tf) in tf.placeholder = "주소" }    // 주소 텍스트 필드
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "확인", style: .default){ (_) in
            
            let departTitle = alert.textFields?[0].text
            let departAddr = alert.textFields?[1].text
            
            if self.departDao.create(title: departTitle, addr: departAddr) {
                // 부서 목록 리스트 갱신
                self.departList = self.departDao.find()
                self.tableView.reloadData()
                
                // 내비게이션 타이틀 갱신
                let navTitle = self.navigationItem.titleView as! UILabel
                navTitle.text = "부서 목록 \n "+"총 \(self.departList.count)개"
            }
        })
        
        self.present(alert, animated: false, completion: nil)
    }
    
    // 목록 편집 형식을 결정하는 함수 (삭제 / 수정)
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle.delete
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        // 삭제할 행의 depart_cd 값
        let departCd = self.departList[indexPath.row].departCd
        
        if self.departDao.delete(departCd: departCd) {
            self.departList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            // 내비게이션 타이틀 갱신
            let navTitle = self.navigationItem.titleView as! UILabel
            navTitle.text = "부서 목록 \n "+"총 \(self.departList.count)개"
        }
    }
}
