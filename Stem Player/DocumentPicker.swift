//
//  DocumentPicker.swift
//  Stem Player 1
//
//  Created by Thatcher Clough on 2/26/22.
//

import Foundation
import SwiftUI

struct DocumentPicker : UIViewControllerRepresentable {
    var completion: (URL?) -> Void
    
    static var controller:UIDocumentPickerViewController?
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<DocumentPicker>) -> some UIDocumentPickerViewController {
        if (DocumentPicker.controller == nil) {
            let controller: UIDocumentPickerViewController = UIDocumentPickerViewController(forOpeningContentTypes: [.audio], asCopy: true)
            DocumentPicker.controller = controller
        }
        
        DocumentPicker.controller!.delegate = context.coordinator
        return DocumentPicker.controller!
    }
    
    func makeCoordinator() -> DocumentPickerCoordinator {
        return DocumentPickerCoordinator() { url in
            completion(url)
        }
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}

class DocumentPickerCoordinator: NSObject, UIDocumentPickerDelegate, UINavigationControllerDelegate {
    var completion: (URL?) -> Void
    
    init(completion: @escaping (URL?) -> Void) {
        self.completion = completion
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if(urls.count > 0) {
            return completion(urls[0])
        } else {
            completion(nil)
        }
    }
}
