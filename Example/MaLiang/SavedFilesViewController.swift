//
//  SavedFilesViewController.swift
//  MaLiang_Example
//
//  Created by Harley-xk on 2019/4/23.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import Comet
import QuickLook

class SavedFilesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let path = Path.documents()
        let contents = try? FileManager.default.contentsOfDirectory(atPath: path.string)
        files = contents?.map { path.resource($0) } ?? []
        tableView.reloadData()
    }
    
    
    private var files: [Path] = []

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SavedFilesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return files.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FileListCell", for: indexPath)
        let fileInfo = files[indexPath.row]
        cell.textLabel?.text = fileInfo.url.lastPathComponent
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//         let quicklook = QLPreviewController()
//        quicklook.dataSource = self
//        quicklook.currentPreviewItemIndex = indexPath.row
//        present(quicklook, animated: true, completion: nil)
        let vc = ViewController.createFromStoryboard()
        vc.filePath = files[indexPath.row].string
        navigationController?.push(vc)
    }
}

extension SavedFilesViewController: QLPreviewControllerDataSource {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return files.count
    }

    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return files[index].url as NSURL
    }


}
