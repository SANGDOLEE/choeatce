//
//  ViewController.swift
//  choeatce
//
//  Created by 이상도 on 2023/04/10.
//

import UIKit
import NMapsMap
import AVFoundation
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var naverMapApiButton: UIButton! /// 나중에 hidden 풀기
    
    @IBOutlet weak var goNaverMapApp: UIButton!
    
    @IBOutlet weak var NaverMapsButton: UIButton!
    @IBOutlet weak var KaKaoMapsButton: UIButton!
    
    @IBOutlet weak var foodName: UILabel! // 음식 Text
    @IBOutlet weak var mainImage: UIImageView! // 메인 사진
    @IBOutlet weak var imageView: UIImageView! // 음식 변경 버튼
    @IBOutlet weak var startImage: UIImageView! // 시작 Click Image
    @IBOutlet weak var startTextLabel: UILabel!
    @IBOutlet weak var touchImage: UIImageView!
    @IBOutlet weak var deliveryImage: UIImageView!
    
    @IBOutlet weak var addMenuButton: UIBarButtonItem!
    
    var num = 0 // 음식 List 접근 index 변수
    
    var player: AVAudioPlayer! // sound 변수
    
    var foodList : [String] = []
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
       
        // Hidden 속성
        naverMapApiButton.isHidden = true
        
        mainImage.isHidden = true
        NaverMapsButton.isHidden = true
        KaKaoMapsButton.isHidden = true
        imageView.isHidden = true
        deliveryImage.isHidden = true
        
        // UI, 색상 지정
        self.view.backgroundColor = .systemOrange
        NaverMapsButton.backgroundColor = .systemYellow
        KaKaoMapsButton.backgroundColor = .systemYellow
        
        NaverMapsButton.layer.cornerRadius = 10
        KaKaoMapsButton.layer.cornerRadius = 10
        
        // imageView2 2개 -> 터치이벤트 적용
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(changeMenuButton))
        imageView.addGestureRecognizer(tapGesture)
        imageView.isUserInteractionEnabled = true
        
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(startMenu))
        startImage.addGestureRecognizer(tapGesture2)
        startImage.isUserInteractionEnabled = true
        
        let deliveryGesture = UITapGestureRecognizer(target: self, action: #selector(deliveryMenu))
        deliveryImage.addGestureRecognizer(deliveryGesture)
        deliveryImage.isUserInteractionEnabled = true
        
    }
    
    
    /// 앱 연동은 모두 URL 스키마를 이용하고 info.plist에 해당 URL스키마 선언 할 것
    // 배달의 민족 어플 바로가기
    @objc func deliveryMenu(_ sender: UITapGestureRecognizer) {
        let urlString = "baemin://openSearch?query=pizza" // 배달의 민족은 메뉴 검색된 동적화면은 구현이 안된다. ( 아마 기능을 지원하지 않는거 같음 )
        if let url = URL(string: urlString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                let appStoreDelivryURL = URL(string: "https://apps.apple.com/kr/app/id378084485")!
                UIApplication.shared.open(appStoreDelivryURL)
            }
        }
    }
    
    
    // 네이버 지도로 검색
    @IBAction func goNaver(_ sender: UIButton) {
        let searchFood = Food.FoodList[num]
               let result = searchFood.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) // 인코딩된 장소 URL
               
               
               let url_naver = URL(string:"nmap://search?query=\(result!)&appname=com.sangdolee.choeatce")! // 장소 URL
               let appStoreNaverUrl = URL(string: "http://itunes.apple.com/app/id311867728?mt=8")! // 네이버지도 AppStore URL
               
               if UIApplication.shared.canOpenURL(url_naver){
                   UIApplication.shared.open(url_naver)
               } else {
                   UIApplication.shared.open(appStoreNaverUrl)
               }
    }
    
    // 카카오 지도로 검색
    @IBAction func goKakao(_ sender: Any) {
       
        
        let searchFood = Food.FoodList[num]
        
        if let kakaoMapURL = URL(string: "kakaomap://search?q=\(searchFood.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"), UIApplication.shared.canOpenURL(kakaoMapURL) {
            UIApplication.shared.open(kakaoMapURL, options: [:], completionHandler: nil)
        }
         
    }

    // 앱 시작 -> 메인 imageView 터치 ( 첫 음식만 보여주고 사라짐 )
    var selectedSet = Set<String>() // 중복제거 변수
    var allFoods = [String]() // 전체 음식 배열
    var currentIndex = -1 // 현재 선택된 음식 인덱스
    @objc func startMenu() -> Int {
        
        mainImage.isHidden = false
        NaverMapsButton.isHidden = false
        KaKaoMapsButton.isHidden = false
        imageView.isHidden = false
        deliveryImage.isHidden = false
        startImage.isHidden = true
        startTextLabel.isHidden = true
        touchImage.isHidden = true
        addMenuButton.tintColor = .systemYellow
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                fatalError("Could not get app delegate")
            }
            
            // NSManagedObjectContext 가져오기
            let context = appDelegate.persistentContainer.viewContext
            
            let request: NSFetchRequest<FoodModel> = FoodModel.fetchRequest()
            
            do {
                let foods = try context.fetch(request)
                allFoods = foods.map { $0.name! } // 음식 이름을 배열에 저장
                
                // Set에 모든 음식이 들어있는 경우, 다시 초기화
                if selectedSet.count == allFoods.count {
                    selectedSet.removeAll()
                }
                
                // Set에 있는 음식 제외하고 랜덤으로 음식 이름 뽑기
                let availableFoods = allFoods.filter { !selectedSet.contains($0) }
                
                // availableFoods 배열에 값이 없는 경우, selectedSet을 초기화하고 다시 실행
                if availableFoods.isEmpty {
                    selectedSet.removeAll()
                    return startMenu()
                }
                
                let randomIndex = Int.random(in: 0..<availableFoods.count)
                let selectedFoodName = availableFoods[randomIndex]
                
                // Label에 음식 이름 출력하기
                foodName.text = selectedFoodName
                
                // Set에 선택한 음식 추가
                selectedSet.insert(selectedFoodName)
                
            } catch {
                print("Error fetching foods: \(error)")
            }
            
           
        
        playSound() // tapped -> sound
        
        return num
         
    }
    
    // 메뉴 변경 버튼
    @objc func changeMenuButton() -> Int {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                fatalError("Could not get app delegate")
            }
            
            // NSManagedObjectContext 가져오기
            let context = appDelegate.persistentContainer.viewContext
            
            let request: NSFetchRequest<FoodModel> = FoodModel.fetchRequest()
            
            do {
                let foods = try context.fetch(request)
                allFoods = foods.map { $0.name! } // 음식 이름을 배열에 저장
                
                // Set에 모든 음식이 들어있는 경우, 다시 초기화
                if selectedSet.count == allFoods.count {
                    selectedSet.removeAll()
                }
                
                // Set에 있는 음식 제외하고 랜덤으로 음식 이름 뽑기
                let availableFoods = allFoods.filter { !selectedSet.contains($0) }
                
                // availableFoods 배열에 값이 없는 경우, selectedSet을 초기화하고 다시 실행
                if availableFoods.isEmpty {
                    selectedSet.removeAll()
                    return startMenu()
                }
                
                let randomIndex = Int.random(in: 0..<availableFoods.count)
                let selectedFoodName = availableFoods[randomIndex]
                
                // Label에 음식 이름 출력하기
                foodName.text = selectedFoodName
                
                // Set에 선택한 음식 추가
                selectedSet.insert(selectedFoodName)
                
            } catch {
                print("Error fetching foods: \(error)")
            }
            
           
        playSound() // tapped -> sound
        return num
    }
    
    
    
    // 메뉴 변경 사운드
    func playSound() {
        guard let soundURL = Bundle.main.url(forResource: "tappedSound", withExtension: "mp3") else { return }
        var soundID: SystemSoundID = 0
        AudioServicesCreateSystemSoundID(soundURL as CFURL, &soundID)
        AudioServicesPlaySystemSound(soundID)
    }
  
}

