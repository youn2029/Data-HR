//
//  EmployeeDAO.swift
//  Data-HR
//
//  Created by 윤성호 on 02/05/2019.
//  Copyright © 2019 윤성호. All rights reserved.
//

// Employee 테이블의 재직 상태를 표시하는 열거형
enum EmpStateType: Int {
    case ING = 0, STOP, OUT // 순서대로 재직중(0), 휴직(1), 퇴사(2)
    
    // 재직 상태를 문자열로 변환해 주는 메소드
    func desc() -> String {
        switch self {
        case .ING:
            return "재직중"
        case .STOP:
            return "휴직"
        case .OUT:
            return "퇴사"
        }
    }
}

// 사원 VO
struct EmployeeVO {
    var empCd = 0                       // 사원코드
    var empName = ""                    // 사원명
    var joinDate = ""                   // 입사일
    var stateCd = EmpStateType.ING      // 재직 상태
    var departCd = 0                    // 부서코드
    var departTitle = ""                // 부서명
}

class EmployeeDAO {
    
    // FMDatebase 객체 생성 및 초기화
    lazy var fmdb: FMDatabase! = {
       
        // 파일 매니저
        let fileMng = FileManager.default
        
        // 샌드박스 내 문서 디렉터리 경로에서 데이터베이스 파일을 읽어온다
        let docURLS = fileMng.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dbPath = docURLS.appendingPathComponent("hr.sqlite").path
        
        // hr.sqlite 파일이 없으면 메인 번들에 만들어 둔 파일을 가져와 복사
        if fileMng.fileExists(atPath: dbPath) == false {
            let dbSource = Bundle.main.path(forResource: "hr", ofType: "sqlite")
            try! fileMng.copyItem(atPath: dbSource!, toPath: dbPath)
        }
        
        // 객체 생성
        return FMDatabase(path: dbPath)
    }()
    
    init(){     // 생성자
        self.fmdb.open()
    }
    deinit {    // 소멸자
        self.fmdb.close()
    }
    
    // 사원 목록을 가져오는 메소드
    func find() -> [EmployeeVO] {
        
        var empList = [EmployeeVO]()
        
        do {
            
            // SQL
            let sql = """
                        SELECT e.emp_cd as '사원코드'
                             , e.emp_name as '사원명'
                             , e.join_date as '입사일'
                             , e.state_cd as '재직상태'
                             , d.depart_title as '부서명'
                          FROM employee e, department d
                         WHERE e.depart_cd = d.depart_cd
                      ORDER BY e.depart_cd ASC
                      """
            
            // 쿼리 실행
            let rs = try self.fmdb.executeQuery(sql, values: nil)
            
            while rs.next() {
                var emp = EmployeeVO()
                
                emp.empCd = Int(rs.int(forColumn: "사원코드"))
                emp.empName = rs.string(forColumn: "사원명")!
                emp.joinDate = rs.string(forColumn: "입사일")!
                emp.stateCd = EmpStateType(rawValue: Int(rs.int(forColumn: "재직상태")))!
                emp.departTitle = rs.string(forColumn: "부서명")!
                
                empList.append(emp)
            }
        } catch let error as NSError {
            print("조회 실패 : \(error.localizedDescription)")
        }
        
        return empList
    }
    
    // 특정 사원을 가져오는 메소드
    func get(cd: Int) -> EmployeeVO? {
        
        // SQL
        let sql = """
                    SELECT e.emp_name
                         , e.join_date
                         , e.state_cd
                         , d.depart_title
                      FROM employee e
                      JOIN department d
                        ON e.depart_cd = d.depart_cd
                     WHERE e.emp_cd = ?
                  """
        
        // 쿼리 실행
        let rs = self.fmdb.executeQuery(sql, withArgumentsIn: [cd])
        
        if let _rs = rs {
            _rs.next()
            
            var emp = EmployeeVO()
            
            emp.empCd = cd
            emp.empName = _rs.string(forColumn: "emp_name")!
            emp.joinDate = _rs.string(forColumn: "join_date")!
            emp.stateCd = EmpStateType(rawValue: Int(_rs.int(forColumn: "state_cd")))!
            emp.departTitle = _rs.string(forColumn: "depart_title")!
            
            return emp
            
        }else {
            return nil
        }
    }
    
    // 사원을 등록하는 메소드
    func create(param: EmployeeVO) -> Bool {
        
        do {
            let sql = """
                        INSERT INTO employee (emp_name, join_date, state_cd, depart_cd)
                             VALUES (?, ?, ?, ?)
                      """
            try self.fmdb.executeUpdate(sql, values: [param.empName, param.joinDate, param.stateCd.rawValue, param.departCd])
            return true
        } catch let error as NSError {
            print("등록 실패 : \(error.localizedDescription)")
            return false
        }
    }
    
    // 사원을 삭제하는 메소드 -> 퇴사 처리
    func delete(cd: Int) -> Bool {
        do {
            let sql = """
                        UPDATE employee
                           SET state_cd = 2
                         WHERE emp_cd = ?
                      """
            try self.fmdb.executeUpdate(sql, values: [cd])
            return true
        } catch let error as NSError {
            print("삭제 실패 : \(error.localizedDescription)")
            return false
        }
    }
}
