//
//  ActionViewController.swift
//  ReadTextAction
//
//  Created by EL on 1/3/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit
import MobileCoreServices

import Kanna


class ActionViewController: UIViewController {

    @IBOutlet var textView: UITextView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Get the item[s] we're handling from the extension context.
        var found = false
        for item in self.extensionContext!.inputItems as! [NSExtensionItem] {
            for provider in item.attachments! as! [NSItemProvider] {
                if provider.hasItemConformingToTypeIdentifier("public.url") {
                    provider.loadItem(forTypeIdentifier: "public.url", options: nil) { (url, _) in
                        if let url = url as? URL {
                            // do what you want to do with shareURL
                            
                            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                                guard let data = data, error == nil else {
                                    print("\(String(describing: error))")
                                    return
                                }
                                
                                var html: HTMLDocument
                                do {
                                    try html = HTML(html: data, encoding: .utf8)
                                } catch {
                                    self.setText("Error parsing html")
                                    return
                                }
                                let tags = html.css("pre")
                                var any = false
                                
                                var text = ""
                                for tag in tags {
                                    text += tag.text!
                                    any = true
                                }
                                
                                if !any {
                                    self.setText("No pre tags")
                                    return
                                }
                                
                                if text == "" {
                                    self.setText("Pre tags were empty")
                                    return

                                }
                                
                                var unwrapped = ""
                                let unwrapper = Unwrapper(text)
                                for line in unwrapper {
                                    unwrapped += line + "\n"
                                }
                                
                                
                                self.setText(unwrapped)
                                
                            }
                            task.resume()
                            
                            found = true
                        }
                    
                    }
                }
            
                if found { return }
            }
        }
    }

    func setText(_ text: String) {
        DispatchQueue.main.async(execute: {
            self.textView.text = text;
        })
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        print("didReceiveMemoryWarning() called")
    }

    @IBAction func done() {
        // Return any edited content to the host app.
        // This template doesn't do anything, so we just echo the passed in items.
        self.extensionContext!.completeRequest(returningItems: self.extensionContext!.inputItems, completionHandler: nil)
    }

}
