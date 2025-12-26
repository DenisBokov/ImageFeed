//
//  ViewController.swift
//  ImageFeed
//
//  Created by Denis Bokov on 06.10.2025.
//

import UIKit
import Kingfisher

protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListPresenterProtocol? { get set }
    
    func updateTableViewWithDeletedRows(at indexPaths: [IndexPath])
    func updateTableViewWithInsertedRows(at indexPaths: [IndexPath])
}

final class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol {
    var presenter: ImagesListPresenterProtocol?
    
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
//    private var photos: [Photo] = []
//    private let imagesListService = ImagesListService.shared
//    private var imagesListServiceObserver: NSObjectProtocol?
    private var alertPresenter: AlertPresenter = AlertPresenter()
    
    @IBOutlet private var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagesListService.fetchPhotosNextPage()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }
            
            let photo = photos[indexPath.row]
            
            viewController.fullImageURL = URL(string: photo.largeImageURL)
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    // Обработка удаления строк
    func updateTableViewWithDeletedRows(at indexPaths: [IndexPath]) {
        tableView.performBatchUpdates {
            tableView.deleteRows(at: indexPaths, with: .automatic)
        }
    }
    
    // Обработка вставки строк
    func updateTableViewWithInsertedRows(at indexPaths: [IndexPath]) {
        tableView.performBatchUpdates {
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
    
    
    //    private func updateTableViewAnimated() {
    //        let oldCount = photos.count
    //        let newCount = imagesListService.photos.count
    //        photos = imagesListService.photos
    //         if newCount < oldCount {
    //             let indexPaths = (newCount..<oldCount).map { IndexPath(row: $0, section: 0) }
    //
    //             tableView.performBatchUpdates {
    //                 tableView.deleteRows(at: indexPaths, with: .automatic)
    //             }
    //             return
    //         }
    //
    //         if newCount > oldCount {
    //             let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
    //
    //             tableView.performBatchUpdates {
    //                 tableView.insertRows(at: indexPaths, with: .automatic)
    //             }
    //             return
    //         }
    //    }
}

extension ImagesListViewController {
    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        
        let cellData = presenter?.configureCellData(at: indexPath)
        
        cell.cellImage.kf.setImage(
            with: cellData?.imageUrl,
            placeholder: UIImage(resource: .loadCard),
            options: [
                .transition(.fade(0.25)),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage,
                .forceRefresh
            ])
        
        // Настройка даты
        cell.dateLabel.text = cellData?.dateString
        
        // Настройка кнопки лайка
        if let isLiked = cellData?.isLiked {
            let likeImage = isLiked ? UIImage(resource: .likeButtonOn) : UIImage(resource: .likeButtonOff)
            cell.likeButton.setImage(likeImage, for: .normal)
        }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter?.getNumberOfPhotos() ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "ImagesListCell",
            for: indexPath
        )
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        imageListCell.delegate = self
        
        configCell(for: imageListCell, with: indexPath)
        
        return imageListCell
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let photo = presenter?.getIndexOfPhoto(for: indexPath) else { return 0 }
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = photo.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if indexPath.row == photos.count - 1 {
//            imagesListService.fetchPhotosNextPage()
//        }
        
        presenter?.loadNextPageIfNeeded(for: indexPath)
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            // Уберам лоадер до - self
            UIBlockingProgressHUD.dismiss()
            
            guard let self else { return }
            switch result {
            case .success:
                // Синхронизируем массив картинок с сервисом
                self.photos = self.imagesListService.photos
                // Изменим индикацию лайка картинки
                cell.setIsLiked(self.photos[indexPath.row].isLiked)
            case .failure:
                // Покажем, что что-то пошло не так
                // TODO: Показать ошибку с использованием UIAlertController
                alertPresenter.showAlertError(vc: self)
            }
        }
    }
}


