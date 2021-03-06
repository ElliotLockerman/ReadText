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


let DARK_KEY = "dark_key"
let INSET_KEY = "inset_key"
let FONT_SIZE_KEY = "font_size_key"


class ActionViewController: UIViewController, UIPopoverPresentationControllerDelegate, UIAdaptivePresentationControllerDelegate {

    @IBOutlet var textView: UITextView!
    @IBOutlet var backgroundView: UIView!
    @IBOutlet var navBar: UINavigationBar!
    @IBOutlet var optionsButton: UIBarButtonItem!
    var isDark = false
    var theInsetWidth: CGFloat = 25
    var theFontSize: CGFloat = 14
    
    var unwrapped: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let defaults = UserDefaults.standard
        
        if let wasDark = defaults.object(forKey: DARK_KEY) {
            dark = wasDark as! Bool
        } else {
            dark = false
        }
        
        if let tmpInsetWidth = defaults.object(forKey: INSET_KEY) {
            insetWidth = tmpInsetWidth as! CGFloat
        } else if UIDevice.current.userInterfaceIdiom == .pad {
            insetWidth = 50
        } else {
            insetWidth = 0
        }
        
        if let tmpFontSize = defaults.object(forKey: FONT_SIZE_KEY) {
            fontSize = tmpFontSize as! CGFloat
        } else {
            fontSize = 14
        }
        
        // Get the item[s] we're handling from the extension context.
        var providers = [String: NSItemProvider]()
        
        for item in self.extensionContext!.inputItems as! [NSExtensionItem] {
            for provider in item.attachments! as! [NSItemProvider] {
                if provider.hasItemConformingToTypeIdentifier("public.url") {
                    if providers["public.url"] != nil {
                        print("Got more than one url")
                    }
                    providers["public.url"] = provider
                    
                } else if provider.hasItemConformingToTypeIdentifier("public.text") {
                    if providers["public.text"] != nil {
                        print("Got more than one text")
                    }
                    providers["public.text"] = provider
                    
                } else if provider.hasItemConformingToTypeIdentifier("public.html") {
                    if providers["public.html"] != nil {
                        print("Got more than one html")
                    }
                    providers["public.html"] = provider
                }
            }
        }
        
        if providers.isEmpty {
            self.setText("Error: No usable attachments")
            return
        }

        print("\(providers)")
        
        if let provider = providers["public.text"] {
            provider.loadItem(forTypeIdentifier: "public.text", options: nil) { (str, error) in
                guard let str = str as? String else {
                    self.setText("Error: \(error ??  "couldn't get url" as! Error)")
                    return
                }
                
                self.process(text: str)
            }
        } else if let provider = providers["public.html"] {
            provider.loadItem(forTypeIdentifier: "public.html", options: nil) { (html, error) in
                guard let html = html as? String else {
                    self.setText("Error: \(error ??  "couldn't get url" as! Error)")
                    return
                }
                
                self.process(html: html)
            }
        } else if let provider = providers["public.url"] {
            provider.loadItem(forTypeIdentifier: "public.url", options: nil) { (url, error) in
                 guard let url = url as? URL else {
                    self.setText("Error: \(error ?? "couldn't get url" as! Error)")
                     return
                 }
             
                 self.process(url: url)
             }
        }
        textView.textContainerInset = UIEdgeInsets(top: 0, left: theInsetWidth, bottom: 50, right: theInsetWidth)

    }
    

    
    
    
    func process(text: String) {
        unwrapped = unwrap(text)
        self.setText(unwrapped!)
    }
    
    func process(url: URL) {
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(String(describing: error))")
                return
            }
            var text: String
            if url.pathExtension == "txt" || url.pathExtension == "TXT" {
                guard let tmp = String(data: data, encoding: String.Encoding.utf8) else {
                    self.setText("Error decoding text")
                    return
                }
                text = tmp
            } else {
                var html: HTMLDocument
                do {
                    try html = HTML(html: data, encoding: .utf8)
                } catch {
                    self.setText("Error processing url")
                    return
                }
                
                text = extractTextFrom(html: html)
                
                if text == "" {
                    self.setText("Error: no <pre> tags, or <pre> tags were empty")
                    return
                }
            }
                
            self.unwrapped = unwrap(text)
            self.setText(self.unwrapped!)
        }

        task.resume()
        
    }

    func process(html: String) {
        let html = try! HTML(html: html, encoding: .utf8)
        
        let text = extractTextFrom(html: html)
        
        if text == "" {
            print("Pre tags were empty")
            return
        }
        
        let unwrapped = unwrap(text)
        self.setText(unwrapped)
    }


    func setText(_ text: String) {
        DispatchQueue.main.async(execute: {
            self.textView.text = text
        })
    }

    let navDark = UIColor.black
    let navLight = UIColor(red: (247/255), green: (247/255), blue: (247/255), alpha: 1)
    var dark: Bool {
        get {
            return isDark
        }
        
        set {
            self.isDark = newValue
            DispatchQueue.main.async(execute: {
                if self.isDark {
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
                self.setNeedsStatusBarAppearanceUpdate()
            })
        }
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if isDark {
            return .lightContent
        } else {
            return .default
            
        }
    }

    var insetWidth: CGFloat {
        get {
            return theInsetWidth
        }
        
        set {
            theInsetWidth = newValue
            textView.textContainerInset = UIEdgeInsets(top: 25, left: theInsetWidth, bottom: 50, right: theInsetWidth)
        }
    }
    
    
    var fontSize: CGFloat {
        get {
            return theFontSize
        }
        
        set {
            theFontSize = newValue
            textView.font = UIFont.systemFont(ofSize: theFontSize)
        }
    }

    
    @IBAction func showOptions(_ sender: Any) {
        let storyboard = UIStoryboard(name: "MainInterface", bundle: nil)
        let optionsVC = storyboard.instantiateViewController(withIdentifier: "optionsPopover")
        (optionsVC as! OptionsController).setParentView(self)
        optionsVC.modalPresentationStyle = .popover
        optionsVC.popoverPresentationController?.barButtonItem = optionsButton
        optionsVC.presentationController!.delegate = self
    
        self.present(optionsVC, animated: true) {}
    }
    

    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection trairCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        print("didReceiveMemoryWarning() called")
    }

    
    @IBAction func done() {
        let defaults = UserDefaults.standard
        defaults.set(dark, forKey: DARK_KEY)
        defaults.set(insetWidth, forKey: INSET_KEY)
        defaults.set(fontSize, forKey: FONT_SIZE_KEY)

        /*
        if let unwrapped = unwrapped {
            let provider = NSItemProvider(item: unwrapped as NSSecureCoding, typeIdentifier: "public.text")
            let item = NSExtensionItem()
            item.attachments = [provider]
            print("Returning data")
            return self.extensionContext!.completeRequest(returningItems: [item], completionHandler: nil)
        } else {
            self.extensionContext!.completeRequest(returningItems: self.extensionContext!.inputItems, completionHandler: nil)
        }
        */
        self.extensionContext!.completeRequest(returningItems: self.extensionContext!.inputItems, completionHandler: nil)
    }

}














