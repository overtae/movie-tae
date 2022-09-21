//
//  ViewController.swift
//  movieTae
//
//  Created by 소프트웨어컴퓨터 on 2022/05/31.
//

import UIKit

let name = ["aaa", "bbb", "ccc", "ddd", "eee"]
struct MovieData : Codable {
    let boxOfficeResult : BoxOfficeResult
}
struct BoxOfficeResult : Codable {
    let dailyBoxOfficeList : [DailyBoxOfficeList]
}
struct DailyBoxOfficeList : Codable {
    let movieNm : String
    let rank : String
    let rankInten : String
    let openDt : String
    let audiCnt : String
    let audiAcc : String
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var table: UITableView!
    var movieData : MovieData?
    var movieURL = "https://www.kobis.or.kr/kobisopenapi/webservice/rest/boxoffice/searchDailyBoxOfficeList.json?key=b495b23ed2c57e5d8d1776861e2699fa&targetDt="
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        table.delegate = self
        table.dataSource = self
        
        movieURL += makeYesterdayString()
        getData()
    }
    
    func makeYesterdayString() -> String {
        let y = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let dateF = DateFormatter()
        dateF.dateFormat = "yyyyMMdd"
        let day = dateF.string(from: y)
        return day
    }
    
    func getData() {
        if let url = URL(string: movieURL) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    print(error!)
                    return
                }
                if let JSONdata = data {
                    // print(JSONdata, response!)
                    // 데이터를 문자열로 찍어보기
                    // let dataString = String(data: JSONdata, encoding: .utf8)
                    // print(dataString!)
                    let decoder = JSONDecoder()
                    do {
                        let decodedData = try decoder.decode(MovieData.self, from: JSONdata)
                        // print(decodedData.boxOfficeResult.dailyBoxOfficeList[0].movieNm)
                        self.movieData = decodedData
                        DispatchQueue.main.async {
                            self.table.reloadData()
                        }
                    } catch {
                        print(error)
                    }
                }
            }
            task.resume()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // destination: UIViewController(부모)형
        // nameLabel: DetailViewController(자식)의 프로퍼티 >> down casting 필요
        
        // as! 사용: 성공 확신 O
        // let dest = segue.destination as! DetailViewController
        
        // as? 사용: 성공 확신 X
        // 1. if let 사용
        // if let dest = segue.destination as? DetailViewController {
        //     dest.movieName = "영화 이름"
        // }
        
        // 2. guard let 사용
        guard let dest = segue.destination as? DetailViewController else {
            return
        }
        
        // prepare 안에서 indexPath 사용 불가 >> indexPathForSelectedRow 사용
        let myIndexPath = table.indexPathForSelectedRow!
        let row = myIndexPath.row
        print(row)
        dest.movieName = (movieData?.boxOfficeResult.dailyBoxOfficeList[row].movieNm)!
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "박스오피스(영화진흥위원회제공: " + makeYesterdayString() + ")"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! MyTableViewCell
        cell.rank.text = movieData?.boxOfficeResult.dailyBoxOfficeList[indexPath.row].rank
        if let rankInten = movieData?.boxOfficeResult.dailyBoxOfficeList[indexPath.row].rankInten {
            if rankInten == "0" {
                cell.rankInten.text = "-"
                cell.rankInten.textColor = UIColor.black
            } else if Int(rankInten)! > 0 {
                cell.rankInten.text = rankInten
                cell.rankInten.textColor = UIColor.red
            } else {
                cell.rankInten.text = rankInten
                cell.rankInten.textColor = UIColor.blue
            }
        }
        
        cell.movieName.text = movieData?.boxOfficeResult.dailyBoxOfficeList[indexPath.row].movieNm
        cell.openDt.text = "개봉일 : " + (movieData?.boxOfficeResult.dailyBoxOfficeList[indexPath.row].openDt ?? "미개봉")
        if let aCnt = movieData?.boxOfficeResult.dailyBoxOfficeList[indexPath.row].audiCnt {
            let numF = NumberFormatter()
            numF.numberStyle = .decimal
            let aCount = Int(aCnt)
            let result = numF.string(for: aCount)! + " 명"
            cell.audiCount.text = "어제 : \(result)"
        }
        if let aAcc = movieData?.boxOfficeResult.dailyBoxOfficeList[indexPath.row].audiAcc {
            let numF = NumberFormatter()
            numF.numberStyle = .decimal
            let aAccc = Int(aAcc)
            let result = numF.string(for: aAccc)! + " 명"
            cell.audiAccumulate.text = "누적 : \(result) 명"
        }
        
        return cell
    }
    
}
