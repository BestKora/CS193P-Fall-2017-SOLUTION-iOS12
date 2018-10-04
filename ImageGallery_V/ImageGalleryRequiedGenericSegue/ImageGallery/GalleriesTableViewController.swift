//
//  GalleriesTableViewController.swift
//  ImageGallery
//
//  Created by Tatiana Kornilova on 04/08/2018.
//  Copyright © 2018 Stanford University. All rights reserved.
//

import UIKit

class GalleriesTableViewController: UITableViewController {
    
    // MARK: - Public API
    var imageGalleries = [[ImageGallery]] ()
    
    @IBAction func newGallery(_ sender: UIBarButtonItem) {
        imageGalleries[0] += [
            ImageGallery(name: "New Gallery".madeUnique(
                withRespectTo: imageGalleries.flatMap{$0}.map{$0.name}))
        ]
        tableView.reloadData()
        selectRow(at: IndexPath(row: imageGalleries[0].count - 1, section: 0))
    }
    
    private func galleryName(at indexPath: IndexPath) -> String {
        return imageGalleries[indexPath.section][indexPath.row].name
    }
    
    // MARK: - Life Cycle View Controller
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageGalleries =
            [
                [ImageGallery(name: "Galery 1"),
                 ImageGallery(name: "Galery 2"),
                 ImageGallery(name: "Galery 3")
                ],
                [
                    ImageGallery(name: "Галерея 66")
                ]
        ]
        let im1 = ImageModel(url: URL(string: "https://i.imgur.com/Wm1xcNZ.jpg")!, aspectRatio: 1.1)
        let im2 = ImageModel(url: URL(string: "https://i.imgur.com/pDygWBH.jpg")!, aspectRatio: 1.7)
        let im3 = ImageModel(url: URL(string: "https://i.imgur.com/a8uy2uy.png")!, aspectRatio: 0.8)
        imageGalleries[0][0].images = [im1,im2,im3]
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if lastIndexPath != nil {
            self.tableView.selectRow(at: lastIndexPath!,
                                     animated: false,
                                     scrollPosition: .none)
        } else {
        selectRow(at: IndexPath(row: 0, section: 0))
        }
    }
    
    override func viewWillLayoutSubviews() {
        if splitViewController?.preferredDisplayMode != .primaryOverlay {
            splitViewController?.preferredDisplayMode = .primaryOverlay
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
       return imageGalleries.count
    }

    override func tableView(_ tableView: UITableView,
                             numberOfRowsInSection section: Int) -> Int {
       return imageGalleries[section].count
    }

    override func tableView(_ tableView: UITableView,
                 cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "Gallery Cell",
                                                            for: indexPath)
            if let galleryCell = cell as? GalleryTableViewCell {
                galleryCell.nameTextField.text = galleryName(at: indexPath)
                galleryCell.resignationHandler = { [weak self, unowned galleryCell] in
                    if let name = galleryCell.nameTextField.text {
                        self?.imageGalleries[indexPath.section][indexPath.row].name = name
                        self?.tableView.reloadData()
                        self?.selectRow(at: indexPath)
                    }
                }
            }
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "Title Cell",
                                                            for: indexPath)
            cell.textLabel?.text = galleryName(at: indexPath)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView,
        titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1:
            return imageGalleries[section].count > 0
                                 ? "Recently Deleted" : nil
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            switch indexPath.section {
            case 0:
                tableView.performBatchUpdates({
                    imageGalleries[1].insert(
                        imageGalleries[0].remove(at: indexPath.row), at: 0)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    tableView.insertRows(
                         at: [IndexPath(row: 0, section: 1)], with: .automatic)
                }, completion: {finished in
                    self.selectRow(at: IndexPath(row: 0, section: 1),after: 0.6)
                })
            case 1:
                tableView.performBatchUpdates({
                    imageGalleries[1].remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }, completion: {finished in
                    self.selectRow(at: IndexPath(row: 0, section: 0))
                })
            default:
                break
            }
        }
    }
    
     // MARK: - Instance Methods of Table View
    
    override func tableView(_ tableView: UITableView,
                leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath
        ) -> UISwipeActionsConfiguration? {
        if indexPath.section == 1 {
            let lastIndexIn0 = self.imageGalleries[0].count
            let undelete = UIContextualAction(
                style: .normal,
                title: "Undelete",
                handler: { (contextAction, sourceView, completionHandler) in
                tableView.performBatchUpdates({
                self.imageGalleries[0]
                    .insert(self.imageGalleries[1].remove(at: indexPath.row),at: lastIndexIn0)
                tableView.deleteRows(at: [indexPath], with: .fade)
                tableView.insertRows(at: [IndexPath(row: lastIndexIn0, section: 0)],
                                   with: .automatic)
                     }, completion: {finished in
                           self.selectRow(at: IndexPath(row: lastIndexIn0, section: 0),after: 0.7)
                     })
                completionHandler(true)
            })
            undelete.backgroundColor = UIColor.blue
            return UISwipeActionsConfiguration(actions: [undelete])
        } else {
            return nil
        }
    }
   
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "Show Gallery", sender: indexPath)
    }
 
    // MARK: - Navigation

    private var lastIndexPath: IndexPath?
    
    private var splitViewDetailCollectionController: ImageGalleryCollectionViewController? {
        let navCon = splitViewController?.viewControllers.last as? UINavigationController
        return navCon?.viewControllers.first as? ImageGalleryCollectionViewController
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "Show Gallery":
                if let indexPath = sender as? IndexPath {
                     if let ivc = segue.destination.contents as?
                                        ImageGalleryCollectionViewController {
                        lastIndexPath = indexPath
                        if indexPath.section != 1 {
                           ivc.imageGallery =
                                imageGalleries[indexPath.section][indexPath.row]
                           ivc.title =
                                imageGalleries[indexPath.section][indexPath.row].name
                           ivc.collectionView?.isUserInteractionEnabled = true
                            
                        } else {
                           let newName = "Recently Deleted '" +
                                imageGalleries[indexPath.section][indexPath.row].name
                                + "'"
                           ivc.imageGallery  = ImageGallery (name: newName)
                           ivc.title = newName
                           ivc.collectionView?.isUserInteractionEnabled = false
                           ivc.collectionView?.backgroundColor = UIColor.gray
                        }
                        ivc.navigationItem.leftBarButtonItem =
                            splitViewController?.displayModeButtonItem
                    }
                }
            default:
                break
            }
        }
    }
    
    private func selectRow(at indexPath: IndexPath,
                           after timeDelay:  TimeInterval = 0.0) {
      if tableView(self.tableView,
                     numberOfRowsInSection: indexPath.section) >= indexPath.row {
            Timer.scheduledTimer(
                withTimeInterval: timeDelay,
                repeats: false,
                block: { (timer) in
                        self.tableView.selectRow(at: indexPath,
                                                 animated: false,
                                                 scrollPosition: .none)
                        self.tableView(self.tableView, didSelectRowAt: indexPath)
                }
            )
        }
    }
}
