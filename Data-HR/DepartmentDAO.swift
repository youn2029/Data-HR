//
//  DepartmentDAO.swift
//  Data-HR
//
//  Created by 윤성호 on 02/05/2019.
//  Copyright © 2019 윤성호. All rights reserved.
//

class DepartmentDAO {
    
    // 부서 정보를 담을 튜플 타입 정의 (부서코드, 부서명, 부서주소)
    typealias DepartRecord = (Int, String, String)
    
    // SQLite 연결 및 초기화
    lazy var fmdb: FMDatabase! = {
        
        // 파일 매니저 객체를 생성
        let fileMng = FileManager.default
        
        // 샌드박스 내 문서 디렉터리에서 데이터베이스 파일 경로 확인
        let docURLS = fileMng.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dbPath = docURLS.appendingPathComponent("hr.sqlite").path
        
        // 샌드박스 경로에 파일이 없다면 메인 번들에 만들어 둔 hr.sqlite를 가져와 복사
        if fileMng.fileExists(atPath: dbPath) == false {
            let dbSource = Bundle.main.path(forResource: "hr", ofType: "sqlite")
            try! fileMng.copyItem(atPath: dbSource!, toPath: dbPath)
        }
        
        // 준비된 데이터베이스 파일을 바탕으로 FMDatabase 객체를 생성
        return FMDatabase(path: dbPath)
    }()
    
    init(){     // 생성자
        self.fmdb.open()
    }
    deinit {    // 소멸자
        self.fmdb.close()
    }
    
    // 데이터베이스에서 department 테이블의 정보를 읽어오는 메소드
    func find() -> [DepartRecord] {
        
        // 반활할 데이터를 담을 객체
        var departList = [DepartRecord]()
        
        do {
            let sql = """
                        SELECT *
                          FROM department
                      ORDER BY depart_cd ASC
                      """
            
            // 쿼리 실행
            let rs = try self.fmdb.executeQuery(sql, values: nil)
            
            // 결과 추출
            while rs.next() {
                let departCd = rs.int(forColumn: "depart_cd")
                let departTitle = rs.string(forColumn: "depart_title")
                let departAddr = rs.string(forColumn: "depart_addr")
                
                departList.append((Int(departCd), departTitle!, departAddr!))
            }
        } catch let error as NSError {  // 요류시
            print("failed : \(error.localizedDescription)")
        }
        
        return departList
    }
    
    // 특정 부서 정보를 가져오는 메소드
    func get(departCd: Int) -> DepartRecord? {
        
        let sql = """
                    SELECT *
                      FROM department
                     WHERE depart_cd = ?
                  """
        
        // 쿼리 실행
        let rs = self.fmdb.executeQuery(sql, withArgumentsIn: [departCd])
        
        if let _rs = rs {   // 옵셔널 타입으로 반환되므로, 일반 상수에 바인딩하여 해제
            _rs.next()
            
            let cd = _rs.int(forColumn: "depart_cd")
            let title = _rs.string(forColumn: "depart_title")
            let addr = _rs.string(forColumn: "depart_addr")
            
            return (Int(cd), title!, addr!)
            
        }else {             // 값이 없으면 nil을 반환
            return nil
        }
        
    }
    
    // 부서를 생성하는 메소드
    func create(title: String!, addr: String!) -> Bool {
        
        do {
         
            let sql = """
                        INSERT INTO department(depart_title, depart_addr)
                             VALUES (?, ?)
                      """
        
            try! self.fmdb.executeUpdate(sql, values: [title, addr])
            return true
            
        } catch let error as NSError {
            print("Insert failed : \(error.localizedDescription)")
            return false
        }
    }
    
    // 부서를 삭제하는 메소드
    func delete(departCd: Int) -> Bool {
        
        do {
            let sql = """
                        DELETE
                          FROM department
                         WHERE depart_cd = ?
                      """
            try self.fmdb.executeUpdate(sql, values: [departCd])
            return true
        } catch let error as NSError {
            print("삭제 실패 : \(error.localizedDescription)")
            return false
        }
    }
}
