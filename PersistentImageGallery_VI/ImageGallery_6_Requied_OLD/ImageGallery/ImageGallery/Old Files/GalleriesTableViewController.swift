//
//  GalleriesTableViewController.swift
//  ImageGallery
//
//  Created by Tatiana Kornilova on 04/08/2018.
//  Copyright © 2018 Stanford University. All rights reserved.
//

import UIKit

/*class GalleriesTableViewController: UITableViewController {
    
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
    
    let defaults = UserDefaults.standard
    var imageGalleriesJSON : [[ImageGallery]]? {
        get {
            if let savedGalleries = defaults.object(forKey: "SavedGalleries") as? Data {
                let decoder = JSONDecoder()
                if let loadedGalleries = try? decoder.decode([[ImageGallery]].self,
                                                             from: savedGalleries) {
                    return loadedGalleries
                }
            }
            return nil
        }
        set {
            if newValue != nil {
                let encoder = JSONEncoder()
                if let json = try? encoder.encode(newValue!) {
                    defaults.set(json, forKey: "SavedGalleries")
                }
            }
        }
    }
    // MARK: - Life Cycle View Controller
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let imageGalleriesFROM = imageGalleriesJSON {
            imageGalleries = imageGalleriesFROM
        } else  {
            imageGalleries =
                [[ImageGallery(name: "Gallery 1")]]
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let currentIndex = lastIndexPath != nil
            ? lastIndexPath!
            : IndexPath(row: 0, section: 0)
        selectRow(at: currentIndex)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        imageGalleriesJSON = imageGalleries
    }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        imageGalleriesJSON = imageGalleries
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
                            commit editingStyle: UITableViewCellEditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            switch indexPath.section {
            case 0:
                if imageGalleries.count < 2 {
                    let removedRow = imageGalleries[0].remove(at: indexPath.row)
                    imageGalleries.insert([removedRow], at: 0)
                    tableView.reloadData()
                } else {
                tableView.performBatchUpdates({
                    imageGalleries[1].insert(imageGalleries[0].remove(at: indexPath.row), at: 0)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    tableView.insertRows(
                         at: [IndexPath(row: 0, section: 1)], with: .automatic)
                    }, completion: {finished in
                    self.selectRow(at: IndexPath(row: 0, section: 1),after: 0.3)
                })}
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
        showCollection(at: indexPath)
    }
 
    // MARK: - Navigation

    private var lastIndexPath: IndexPath?
    
    private var splitViewDetailCollectionController: ImageGalleryCollectionViewController? {
        let navCon = splitViewController?.viewControllers.last as? UINavigationController
        return navCon?.viewControllers.first as? ImageGalleryCollectionViewController
    }
    
 
    private func showCollection(at indexPath: IndexPath) {
        if let ivc = splitViewDetailCollectionController {
            lastIndexPath = indexPath
            if indexPath.section != 1 {
                ivc.imageGallery =
                    imageGalleries[indexPath.section][indexPath.row]
                ivc.title =
                    imageGalleries[indexPath.section][indexPath.row].name
                ivc.collectionView?.isUserInteractionEnabled = true
                ivc.collectionView?.backgroundColor = UIColor.white
            } else {
                let newName = "Recently Deleted '" +
                    imageGalleries[indexPath.section][indexPath.row].name
                    + "'"
                ivc.imageGallery  = ImageGallery (name: newName)
                ivc.title = newName
                ivc.collectionView?.isUserInteractionEnabled = false
                ivc.collectionView?.backgroundColor = UIColor.gray
            }
   //         ivc.navigationItem.leftBarButtonItem =
   //             splitViewController?.displayModeButtonItem
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
}*/
