//
//  ViewController.swift
//  AppleSnack
//
//  Created by 박성원 on 2023/08/14.
//

import UIKit // Foundation 프레임워크를 내부적으로 import하고 있음

class ViewController: UIViewController {
    
    let categorieManager = CategorieManager.shared
    let snackManager = SnackManager.shared
    
    fileprivate var systemImageNameArray = ["클래스", "구조체", "테스트", "일요일"]
    
    @IBOutlet weak var myCollectionView: UICollectionView!
    @IBOutlet weak var floatingStackView: UIStackView!
    @IBOutlet weak var floatingButton: UIButton!
    @IBOutlet weak var fixButton: UIButton!
    @IBOutlet weak var deletButton: UIButton!
    
    lazy var floatingDimView: UIView = {
        let view = UIView(frame: self.view.frame)
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        view.alpha = 0
        view.isHidden = true
        
        self.view.insertSubview(view, belowSubview: self.floatingStackView)
        
        return view
        
    }()
    
    var isShowFloating: Bool = false
    
    lazy var buttons: [UIButton] = [self.fixButton, self.deletButton]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Categorie"
        // MARK: - Lifecycles
        
        let itemSize = (UIScreen.main.bounds.width - 2) / 3
        // Layout 간격 설정
        let flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: itemSize, height: itemSize)
        flowLayout.minimumLineSpacing = 10
        flowLayout.minimumInteritemSpacing = 1
        //        myCollectionView.collectionViewLayout = flowLayout // 기본 레이아웃으로 설정?!
        
        deletButton.clipsToBounds = true
        deletButton.layer.cornerRadius = 15
        deletButton.backgroundColor = .gray
        
        fixButton.clipsToBounds = true
        fixButton.layer.cornerRadius = 15
        fixButton.backgroundColor = .gray
        
        floatingButton.backgroundColor = .gray
        
        
        
        // 콜렉션 뷰에 대한 설정
        myCollectionView.collectionViewLayout = flowLayout
        myCollectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        myCollectionView.dataSource = self
        myCollectionView.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        floatingButton.clipsToBounds = true
        floatingButton.layer.cornerRadius = floatingButton.bounds.height / 2
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        let title = "삭제를 원하시는 카테고리명을 입력해주세요"
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        
        alert.addTextField(){ (tf) in
            tf.placeholder = "카테고리 이름"
        }
        
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        let complete = UIAlertAction(title: "확인", style: .default) { (_)
            in // 확인버튼 누를 경우 취할 행동
            if let txt = alert.textFields?.first {
                if txt.text?.isEmpty != true {
                    let deleteCategorie = self.categorieManager.getCategorieData().filter { $0.categorie?.contains(txt.text!) ?? false }
                    
                    let deleteSnack = self.snackManager.getSnackFromCoreData().filter({ $0.categorie == (deleteCategorie.first)?.categorie})
                    
                    let allCategorie = self.categorieManager.getCategorieData().map { $0.categorie }
                    
                    guard deleteCategorie.count != 0 else {
                        let errorAlert = UIAlertController(title: "일치하는 카테고리가 없습니다.", message: nil, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "확인", style: .default)
                        errorAlert.addAction(okAction)
                        self.present(errorAlert, animated: true)
                        return
                    }
                    
                    self.categorieManager.deleteCategorie(data: deleteCategorie.first!) {
                        for snack in deleteSnack {
                            self.snackManager.deleteSnack(data: snack) {}
                        }
                        self.myCollectionView.reloadData()
                        print("카테고리 생성완료")
                    }
                } else {
                }
            }
        }
        
        
        alert.addAction(cancel)
        alert.addAction(complete)
        
        self.present(alert, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    @IBAction func fixButtonTapped(_ sender: UIButton) {
        let title = "카테고리를 작성해주세요."
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        
        alert.addTextField(){ (tf) in
            tf.placeholder = "카테고리 이름"
        }
        
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        let complete = UIAlertAction(title: "확인", style: .default) { (_)
            in // 확인버튼 누를 경우 취할 행동
            if let txt = alert.textFields?.first {
                let allCategorie = self.categorieManager.getCategorieData().map { $0.categorie }
                
                guard txt.text?.isEmpty != true else {
                    let errorAlert = UIAlertController(title: "입력된 카테고리가 없습니다.", message: "1글자 이상 입력해주세요.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "확인", style: .default)
                    errorAlert.addAction(okAction)
                    self.present(errorAlert, animated: true)
                    return
                }
                
                
                guard self.categorieManager.getCategorieData().count != 0 else {
                    self.categorieManager.saveCategorieData(categorie: txt.text) {
                        self.myCollectionView.reloadData()
                        print("카테고리 생성완료")
                    }
                    return
                }
                
                for str in allCategorie {
                    if txt.text == str {
                        let errorAlert = UIAlertController(title: "중복된 카테고리가 있습니다.", message: nil, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "확인", style: .default)
                        errorAlert.addAction(okAction)
                        self.present(errorAlert, animated: true)
                        return
                    }
                }
                
                self.categorieManager.saveCategorieData(categorie: txt.text) {
                    self.myCollectionView.reloadData()
                    print("카테고리 생성완료")
                    return
                }
            } else {
                let errorAlert = UIAlertController(title: "입력된 카테고리가 없습니다.", message: "1글자 이상 입력해주세요.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "확인", style: .default)
                errorAlert.addAction(okAction)
                self.present(errorAlert, animated: true)
            }
        }
        alert.addAction(cancel)
        alert.addAction(complete)
        
        self.present(alert, animated: true)
    }
    
    @IBAction func floatingButtonAction(_ sender: UIButton) {
        
        if isShowFloating {
            buttons.reversed().forEach { button in
                UIView.animate(withDuration: 0.3){
                    button.isHidden = true
                    self.view.layoutIfNeeded()
                    
                }
            }
            
            UIView.animate(withDuration: 0.5, animations:  {
                self.floatingDimView.alpha = 0
            }) { (_) in
                self.floatingDimView.isHidden = true
            }
        } else {
            self.floatingDimView.isHidden = false
            
            UIView.animate(withDuration: 0.5) {
                self.floatingDimView.alpha = 1
            }
            
            buttons.forEach { [weak self] button in
                button.isHidden = false
                button.alpha = 0
                
                UIView.animate(withDuration: 0.5) {
                    button.alpha = 1
                    self?.view.layoutIfNeeded()
                    
                }
            }
            
        }
        
        isShowFloating = !isShowFloating
        
        let image = isShowFloating ? UIImage(named: "Hide") : UIImage(named: "Show")
        let roatation = isShowFloating ? CGAffineTransform(rotationAngle: .pi - (.pi / 1)) : CGAffineTransform.identity
        
        UIView.animate(withDuration: 0.3) {
            sender.setImage(image, for: .normal)
            sender.transform = roatation
        }
    }
}


extension ViewController: UICollectionViewDataSource {
    // 지정된 섹션에 표시할 셀의 개수를 묻는 메서드
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.categorieManager.getCategorieData().count // 내가 표시할 컬렉션뷰의 개수
        
    }
    
    // 각 컬렉션뷰 셀에 대한 설정 or 컬렉션 뷰의 지정된 위치에 표시할 셀울 요청하는 메서드
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // 셀의 인스턴스
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainCollectionViewCell", for: indexPath) as! MainCollectionViewCell
        
        // 배경화면
        
        
        // 데이터에 따른 UI 변경
        // 라벨 설정
        cell.categorie = categorieManager.getCategorieData()[indexPath.item].categorie
        
        return cell
    }
    //        return UICollectionViewCell() // 내가 표시하고자하는 셀
}


extension ViewController : UICollectionViewDelegate {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "snackList" {
            let listVC = segue.destination as! SnackListController
            
            guard let number = sender as? IndexPath else { return }
            listVC.listCategorie = categorieManager.getCategorieData()[number.item].categorie!
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            cell.contentView.backgroundColor = .green
        }
        
        //        let storyboard = UIStoryboard(name: "snackList", bundle: nil)
        //        let vc = storyboard.instantiateViewController(withIdentifier: "snackList") as! SnackListController
        //        vc.categorie = systemImageNameArray[indexPath.item]
        
        performSegue(withIdentifier: "snackList", sender: indexPath)
        //        present(vc, animated: true)
        
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        // 선택 해제된 셀의 배경색을 원래대로 되돌립니다.
        if let cell = collectionView.cellForItem(at: indexPath) {
            cell.contentView.backgroundColor = .systemBlue
        }
    }
    
}

extension ViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
}
