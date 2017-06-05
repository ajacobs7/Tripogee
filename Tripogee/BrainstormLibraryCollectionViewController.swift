//
//  BrainstormLibraryCollectionViewController.swift
//  Tripogee
//
//  Created by Austin Jacobs on 3/6/17.
//  Copyright © 2017 Austin Jacobs. All rights reserved.
//

import UIKit
import CoreData
import Social

class BrainstormLibraryCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate {

    var container: NSPersistentContainer? =
        (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
        { didSet { updateUI() } }
    
    var fetchedResultsController: NSFetchedResultsController<Brainstorm>?
    
    @IBOutlet weak var selectButton: UIBarButtonItem!
    
    private var brainstorms: [Brainstorm]?
    private var selecting = false
    private var selectedItems: [BrainstormCollectionViewCell] = []

    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
        updateUI()
    }

    //Load all brainstorms by date created
    private func updateUI() {
        if let context = container?.viewContext {
            let request: NSFetchRequest<Brainstorm> = Brainstorm.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(
                key: "dateCreated",
                ascending: false,
                selector: #selector(NSDate.compare(_:)))
            ]
            fetchedResultsController = NSFetchedResultsController<Brainstorm>(
                fetchRequest: request,
                managedObjectContext: context,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            fetchedResultsController?.delegate = self
            try? fetchedResultsController?.performFetch()
            collectionView?.reloadData()
        }
    }
    
    //Selection mode
    
    @IBAction func selectBrainstorms(_ sender: UIBarButtonItem) {
        if selecting {
            collectionView?.allowsMultipleSelection = false
            navigationController?.setToolbarHidden(true, animated: true)

            deselectAllSelected()
            sender.title = "Select"
            selecting = false
        } else {
            collectionView?.allowsSelection = true
            collectionView?.allowsMultipleSelection = true
            navigationController?.setToolbarHidden(false, animated: true)
            setToolbar(enabled: false)
            
            sender.title = "Cancel"
            selecting = true
        }
    }
    
    private func setToolbar(enabled: Bool) {
        for item in (navigationController?.toolbar.items)! {
            item.isEnabled = enabled
        }
    }
    
    @IBAction func export(_ sender: UIBarButtonItem) {
        let items = selectedItems.flatMap { (cell) -> UIImage? in
            return cell.brainstormImage.image
        }
        let vc = UIActivityViewController(activityItems: items, applicationActivities: [])
        vc.completionWithItemsHandler = { (_) in
            for indexPath in (self.collectionView?.indexPathsForSelectedItems)! {
                self.collectionView(self.collectionView!, didDeselectItemAt: indexPath)
            }
            self.selectBrainstorms(self.selectButton)
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func deleteBrainstorms(_ sender: UIBarButtonItem) {
        if let context = container?.viewContext {
            for cell in selectedItems {
                Brainstorm.delete(cell.brainstorm!, in: context)
            }
            updateUI()
        }
        self.selectBrainstorms(self.selectButton)
    }


    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (fetchedResultsController?.sections![section].numberOfObjects)!
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "brainstorm", for: indexPath) as! BrainstormCollectionViewCell
        if let brainstorm = fetchedResultsController?.object(at: indexPath) {
            cell.brainstorm = brainstorm
        }
        return cell
    }

    //http://stackoverflow.com/questions/40974973/how-to-resize-the-collection-view-cells-according-to-device-screen-size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width = self.view.frame.size.width
        var height = self.view.frame.size.height
        if height > width {
            width = width * 0.47
            return CGSize(width: width, height: width*1.5)
        } else {
            height = height * 0.9
            return  CGSize(width: height/1.5, height: height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    // UICollectionViewDelegate, Brainstorm selection/deselection
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selecting {
            if selectedItems.isEmpty {
                setToolbar(enabled: true)
            }
            let cell = collectionView.cellForItem(at: indexPath) as! BrainstormCollectionViewCell
            selectedItems.append(cell)
            cell.layer.borderWidth = 2
            cell.layer.borderColor = UIColor.blue.cgColor
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if selecting {
            let cell = collectionView.cellForItem(at: indexPath) as! BrainstormCollectionViewCell
            let index = selectedItems.index(of: cell)
            selectedItems.remove(at: index!)
            cell.layer.borderWidth = 0
            if selectedItems.isEmpty {
                setToolbar(enabled: false)
            }
        }
    }
    
    private func deselectAllSelected(){
        for selected in selectedItems {
            selected.layer.borderWidth = 0
        }
        selectedItems = []
    }
    
    // Navigation
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return !selecting
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! BrainstormViewController
        if let cell = sender as? BrainstormCollectionViewCell {
            destination.brainstorm = cell.brainstorm
            let appdelegate = UIApplication.shared.delegate as! AppDelegate
            appdelegate.supportAllOrientations = false
        }
    }

}
