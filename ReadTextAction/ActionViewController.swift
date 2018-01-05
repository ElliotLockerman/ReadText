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


func extractTextFrom(html: HTMLDocument) -> String {
    let tags = html.css("pre")
    
    var text = ""
    for tag in tags {
        text += tag.text!
    }
    
    return text
}



class ActionViewController: UIViewController {

    @IBOutlet var textView: UITextView!
    @IBOutlet var backgroundView: UIView!
    @IBOutlet var navBar: UINavigationBar!
    

    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Get the item[s] we're handling from the extension context.
        var found = false
        for item in self.extensionContext!.inputItems as! [NSExtensionItem] {
            for provider in item.attachments! as! [NSItemProvider] {
                if provider.hasItemConformingToTypeIdentifier("public.url") {
                    provider.loadItem(forTypeIdentifier: "public.url", options: nil) { (url, _) in
                        guard let url = url as? URL else {
                            print("url wasn't a URL?!?")
                            return
                        }
                        
                        self.process(url: url)
                        found = true
                    }
                }
            
                if found { return }
            }
        }
    }
    
    
    func process(url: URL) {
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("\(String(describing: error))")
                return
            }
            var text: String
            if url.pathExtension == "txt" || url.pathExtension == "TXT" {
                guard let tmp = String(data: data, encoding: String.Encoding.utf8) else {
                    print("Error decoding text")
                    return
                }
                text = tmp
            } else {
                var html: HTMLDocument
                do {
                    try html = HTML(html: data, encoding: .utf8)
                } catch {
                    print("Error processing url")
                    return
                }
                
                text = extractTextFrom(html: html)
                
                if text == "" {
                    print("Pre tags were empty")
                    return
                    
                }
            }
                
            let unwrapper = unwrap(text)
            self.setText(unwrapper)
        }

        task.resume()
        
    }
    

    func setText(_ text: String) {
        DispatchQueue.main.async(execute: {
            self.textView.text = text;
        })
    }

    let navDark = UIColor.black
    let navLight = UIColor(red: (247/255), green: (247/255), blue: (247/255), alpha: 1)
    var darkMode = false
    @IBAction func invert(_ sender: Any) {
        darkMode = !darkMode
        DispatchQueue.main.async(execute: {
            if self.darkMode {
                self.textView.textColor = UIColor.lightText
                self.textView.backgroundColor = UIColor.black
                self.backgroundView.backgroundColor = UIColor.black
                self.navBar.barTintColor = self.navDark
            } else {
                self.textView.textColor = UIColor.darkText
                self.textView.backgroundColor = UIColor.white
                self.backgroundView.backgroundColor = UIColor.white
                self.navBar.barTintColor = self.navLight
            }
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
