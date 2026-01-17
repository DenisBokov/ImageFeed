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
    func showLoading()
    func hideLoading()
    func updatePhoto(at index: Int, isLiked: Bool)
    func showError()
}

final class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol {
    var presenter: ImagesListPresenterProtocol?
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private var alertPresenter: AlertPresenter = AlertPresenter()
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter?.viewDidLoad()
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
            
            let photo = presenter?.getPhoto(at: indexPath)
            
            viewController.fullImageURL = URL(string: photo?.largeImageURL ?? "")
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    func configure(presenter: ImagesListPresenterProtocol) {
        self.presenter = presenter
        presenter.view = self
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
        guard let photo = presenter?.getPhoto(at: indexPath) else { return 0 }
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = photo.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        presenter?.loadNextPageIfNeeded(for: indexPath)
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        presenter?.didTapLike(at: indexPath.row)
    }
    
    func showLoading() {
        UIBlockingProgressHUD.show()
    }
    
    func hideLoading() {
        UIBlockingProgressHUD.dismiss()
    }
    
    func updatePhoto(at index: Int, isLiked: Bool) {
        let indexPath = IndexPath(row: index, section: 0)
        guard let cell = tableView.cellForRow(at: indexPath) as? ImagesListCell else { return }
        cell.setIsLiked(isLiked)
    }
    
    func showError() {
        alertPresenter.showAlertError(vc: self)
    }
}


