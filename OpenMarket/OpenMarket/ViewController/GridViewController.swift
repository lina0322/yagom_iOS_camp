//
//  GridViewController.swift
//  OpenMarket
//
//  Created by Jinho Choi on 2021/01/29.
//

import UIKit

final class GridViewController: UIViewController {
    var isPaging: Bool = false
    var hasPaging: Bool = true
    let itemSpacing: CGFloat = 8
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
    }
    
    private func configureCollectionView() {
        configureConstraintToSafeArea(for: collectionView)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .white
        collectionView.register(ProductCollectionViewCell.self, forCellWithReuseIdentifier: ProductCollectionViewCell.identifier)
        collectionView.register(LoadingCollectionViewCell.self, forCellWithReuseIdentifier: LoadingCollectionViewCell.identifier)
    }
}

// MARK: - CollectionView Delegate FlowLayout
extension GridViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            let width: CGFloat = (collectionView.frame.width - itemSpacing * 4) / 2
            let height: CGFloat = width * 1.4
            return CGSize(width: width, height: height)
        }
        return CGSize(width: collectionView.frame.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: itemSpacing, left: itemSpacing, bottom: itemSpacing, right: itemSpacing)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return itemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return itemSpacing
    }
}

// MARK: - CollectionView DataSource
extension GridViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return OpenMarketData.shared.collectionViewProductList.count
        }
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let productList = OpenMarketData.shared.collectionViewProductList
            let product = productList[indexPath.row]
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductCollectionViewCell.identifier, for: indexPath) as? ProductCollectionViewCell, let price = product.price, let currency = product.currency, let stock = product.stock  else {
                return UICollectionViewCell()
            }
            
            cell.titleLabel.text = product.title
            cell.stockLabel.text = "잔여수량 : \(stock.addComma())"
            cell.priceLabel.text = "\(currency) \(price.addComma())"
            cell.priceBeforeSaleLabel.text = " "
            
            if stock == 0 {
                cell.stockLabel.text = "품절"
                cell.stockLabel.textColor = .systemOrange
            }
            
            if let salePrice = product.discountedPrice {
                let originalPrice = "\(currency) \(price.addComma())"
                let priceLabelText = "\(currency) \(salePrice.addComma())"
                let priceBeforeSaleLabelText = NSMutableAttributedString(string: originalPrice)
                let range = priceBeforeSaleLabelText.mutableString.range(of: originalPrice)
                priceBeforeSaleLabelText.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 1, range: range)
                
                cell.priceBeforeSaleLabel.attributedText = priceBeforeSaleLabelText
                cell.priceLabel.text = priceLabelText
            } else {
                cell.removePriceBeforeSaleLabel()
            }
            
            DispatchQueue.global().async {
                guard let imageURLText = product.thumbnailURLs?.first, let thumbnailURL = URL(string: imageURLText), let imageData: Data = try? Data(contentsOf: thumbnailURL) else {
                    return
                }
                DispatchQueue.main.async {
                    cell.thumbnailImageView.image = UIImage(data: imageData)
                }
            }
            return cell
            
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LoadingCollectionViewCell.identifier, for: indexPath) as? LoadingCollectionViewCell else {
                return UICollectionViewCell()
            }
            if hasPaging {
                cell.startIndicator()
            } else {
                cell.showLabel()
            }
            return cell
        }
    }
}

// MARK: - CollectionView Delegate
extension GridViewController: UICollectionViewDelegate {
}

// MARK: - Extension Scroll
extension GridViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.height
        
        if offsetY > (contentHeight - height) {
            if isPaging == false {
                isPaging = true
                let page = OpenMarketData.shared.collectionViewCurrentPage
                OpenMarketJSONDecoder<ProductList>.decodeData(about: .loadPage(page: page)) { result in
                    switch result {
                    case .success(let data):
                        if data.items.count == 0 {
                            self.hasPaging = false
                            DispatchQueue.main.async {
                                self.collectionView.reloadSections(IndexSet(1...1))
                                self.isPaging = false
                            }
                        } else {
                            OpenMarketData.shared.collectionViewProductList.append(contentsOf: data.items)
                            OpenMarketData.shared.collectionViewCurrentPage += 1
                            DispatchQueue.main.async {
                                self.collectionView.reloadData()
                                self.isPaging = false
                            }
                        }
                    case .failure(let error):
                        debugPrint(error.localizedDescription)
                    }
                }
            }
        }
    }
}
