//
//  ImageGalleryCollectionViewController.swift
//  ImageGallery
//
//  Created by Tatiana Kornilova on 19/06/2018.
//  Copyright © 2018 Stanford University. All rights reserved.
//

import UIKit

class ImageGalleryCollectionViewController: UICollectionViewController,UICollectionViewDelegateFlowLayout, UICollectionViewDropDelegate, UICollectionViewDragDelegate,  GarbageViewDelegate {
    
     // MARK: - Public API, Model
    var imageGallery = ImageGallery (){
        didSet {
                collectionView?.reloadData()
        }
    }
    
    var document: ImageGalleryDocument?
    
    var firstImage: UIImageView? {
        return (self.collectionView!.cellForItem(at:
                                  IndexPath(item: 0, section: 0))
            as? ImageCollectionViewCell)?.imageGallery
    }
    
 //   @IBAction func save(_ sender: UIBarButtonItem? = nil) {
     func documentChanged() {
        document?.imageGallery = imageGallery
        if  document?.imageGallery != nil {
            document?.updateChangeCount(.done)
        }
    }
    
    @IBAction func close(_ sender: UIBarButtonItem? = nil) {
  //      save()
        if document?.imageGallery != nil {
            if let firstImage = firstImage?.snapshot {
                document?.thumbnail = firstImage
            }
        }
        dismiss(animated: true) {
            self.document?.close()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        document?.open { success in
            if success {
                self.title = self.document?.localizedName
                self.imageGallery = self.document?.imageGallery ?? ImageGallery ()
            }
        }
    }
    
    // MARK: - Live cycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView!.dropDelegate = self
        collectionView!.dragDelegate = self
        collectionView!.dragInteractionEnabled = true
        collectionView?.addGestureRecognizer(UIPinchGestureRecognizer(
            target: self,
            action: #selector(ImageGalleryCollectionViewController.zoom(_:)))
            
        )
    }
    
    var garbageView =  GarbageView()
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let trashBounds = navigationController?.navigationBar.bounds {
            garbageView.delegate = self
            garbageView.frame = CGRect(x: trashBounds.size.width*0.6,
                                       y: 0.0, width: trashBounds.size.width*0.4,
                                       height: trashBounds.size.height)
            let barButton = UIBarButtonItem(customView: garbageView)
            navigationItem.rightBarButtonItem = barButton
     
        }
    }
    
    //  MARK: - GarbageViewDelegate
    
    func garbageViewDidChange(_ sender: GarbageView) {
        // just let our document know that the document has changed
        // that way it can autosave it at an opportune time
        documentChanged()
    }
  
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        flowLayout?.invalidateLayout()
    }
    
    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                   numberOfItemsInSection section: Int) -> Int {
        return imageGallery.images.count
    }
    
    override func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
        ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "Image Cell",
            for: indexPath)
        
        if let imageCell = cell as? ImageCollectionViewCell {
            imageCell.changeAspectRatio = { [weak self] in
              if let aspectRatio =
                self?.imageGallery.images[indexPath.item].aspectRatio,
                    aspectRatio < 0.95 || aspectRatio > 1.05 {
                self?.imageGallery.images[indexPath.item].aspectRatio = 1.0
                self?.flowLayout?.invalidateLayout()
                }
            }
           imageCell.imageURL = imageGallery.images[indexPath.item].url
        }
        return cell
    }
    
    var flowLayout: UICollectionViewFlowLayout? {
        return collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
    }
    
    @objc func zoom(_ gesture: UIPinchGestureRecognizer) {
        if gesture.state == .changed {
            scale *= gesture.scale
            gesture.scale = 1.0
        }
    }
    
    struct Constants {
        static let columnCount = 3.0
        static let minWidthRation = CGFloat(0.03)
    }
    
    var boundsCollectionWidth: CGFloat  {return (collectionView?.bounds.width)!}
    var gapItems: CGFloat  {return (flowLayout?.minimumInteritemSpacing)! *
                  CGFloat((Constants.columnCount - 1.0))}
    var gapSections: CGFloat  {return (flowLayout?.sectionInset.right)! * 2.0}
    
    var scale: CGFloat = 1  {
        didSet {
            collectionView?.collectionViewLayout.invalidateLayout()
        }
    }
    
    var predefinedWidth:CGFloat {
        let width = floor((boundsCollectionWidth - gapItems - gapSections)
            / CGFloat(Constants.columnCount)) * scale
        return  min (max (width , boundsCollectionWidth * Constants.minWidthRation),
                     boundsCollectionWidth)}
    
    // MARK: UICollectionViewDelegateFlowLayout
   
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = predefinedWidth
        let aspectRation = CGFloat(imageGallery.images[indexPath.item].aspectRatio)
        return CGSize(width: width, height: width / aspectRation)
    }
    
     // MARK: - Navigation
     
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "Show Image":
                if let imageCell = sender as? ImageCollectionViewCell,
                    let indexPath = collectionView?.indexPath(for: imageCell),
                    let imgvc = segue.destination as? ImageViewController {
                    imgvc.imageURL = imageGallery.images[indexPath.item].url
                }
            default: break
            }
        }
    }
    
    // MARK: UICollectionViewDragDelegate
    
    func collectionView(_ collectionView: UICollectionView,
               itemsForBeginning session: UIDragSession,
                            at indexPath: IndexPath) -> [UIDragItem] {
        session.localContext = collectionView
        return dragItems(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                itemsForAddingTo session: UIDragSession,
                            at indexPath: IndexPath,
                                   point: CGPoint) -> [UIDragItem] {
        return dragItems(at: indexPath)
    }
    
    private func dragItems(at indexPath: IndexPath) -> [UIDragItem] {
        if let itemCell = collectionView?.cellForItem(at: indexPath)
                                                    as? ImageCollectionViewCell,
            let image = itemCell.imageGallery.image {
            let dragItem = UIDragItem(itemProvider: NSItemProvider(object: image))
            dragItem.localObject = imageGallery.images[indexPath.item]
            return [dragItem]
        } else {
            return []
        }
    }
    
    // MARK: UICollectionViewDropDelegate
    
    func collectionView(_ collectionView: UICollectionView,
                       canHandle session: UIDropSession) -> Bool {
        let isSelf = (session.localDragSession?.localContext as?
                                     UICollectionView) == collectionView
        if isSelf {
            return session.canLoadObjects(ofClass: UIImage.self)
        } else {
            return session.canLoadObjects(ofClass: NSURL.self) &&
                   session.canLoadObjects(ofClass: UIImage.self)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
            dropSessionDidUpdate session: UIDropSession,
            withDestinationIndexPath destinationIndexPath: IndexPath?
        ) -> UICollectionViewDropProposal {
        let isSelf = (session.localDragSession?.localContext as?
                                              UICollectionView) == collectionView
        return UICollectionViewDropProposal(operation: isSelf ? .move : .copy,
                                            intent: .insertAtDestinationIndexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView,
             performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath = coordinator.destinationIndexPath ??
                                               IndexPath(item: 0, section: 0)
        
        for item in coordinator.items {
            if let sourceIndexPath = item.sourceIndexPath { // Drag locally
                if  let imageInfo = item.dragItem.localObject as? ImageModel {
                    collectionView.performBatchUpdates({
                      imageGallery.images.remove(at: sourceIndexPath.item)
                      imageGallery.images.insert(imageInfo,
                                            at: destinationIndexPath.item)
                        
                      collectionView.deleteItems(at: [sourceIndexPath])
                      collectionView.insertItems(at: [destinationIndexPath])
                    })
                    coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
                    documentChanged()
                }
            } else {  // Drag from other app
                let placeholderContext = coordinator.drop(
                    item.dragItem,
                    to: UICollectionViewDropPlaceholder(
                                insertionIndexPath: destinationIndexPath,
                                reuseIdentifier: "DropPlaceholderCell"
                        )
                )
           
                var imageURLLocal: URL?
                var aspectRatioLocal: Double?
                
                // Load UIImage
                item.dragItem.itemProvider.loadObject(ofClass: UIImage.self) {
                    (provider, error) in
                    DispatchQueue.main.async {
                        if let image = provider as? UIImage {
                            aspectRatioLocal = Double(image.size.width) /
                                Double(image.size.height)
                        }
                    }
                }
                // Load URL
                item.dragItem.itemProvider.loadObject(ofClass: NSURL.self) {
                    (provider, error) in
                    DispatchQueue.main.async {
                        if let url = provider as? URL {
                            imageURLLocal = url.imageURL
                        }
                        if imageURLLocal != nil, aspectRatioLocal != nil {
                            placeholderContext.commitInsertion(dataSourceUpdates:
                                {  insertionIndexPath in
                              self.imageGallery.images.insert(ImageModel(url: imageURLLocal!,
                                                               aspectRatio: aspectRatioLocal!),
                                                              at: insertionIndexPath.item)
                            })
                            self.documentChanged()
                        } else {
                            placeholderContext.deletePlaceholder()
                        }
                    }
                }
            }
        }
    }
}

