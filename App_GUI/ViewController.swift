//
//  ViewController.swift
//  App_GUI
//
//  Created by AJ Leonard on 1/21/19.
//  Copyright © 2019 AJ Leonard. All rights reserved.
//

import Cocoa
import Alamofire
import SwiftyJSON

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        //url for the github raw data
        let githubRaw = "https://raw.githubusercontent.com/Homebrew/homebrew-cask/master/Casks/"
//        var casks = [String]
        
        //read the file in the resources folder
        if let path = Bundle.main.path(forResource: "cask_names", ofType: "txt" , inDirectory: "Resources"){
            let text = try! String(contentsOfFile: path, encoding: String.Encoding.utf8)
            let casks = text.components(separatedBy: .newlines)
            for cask in casks {
                let url = githubRaw+cask
                Alamofire.request(url).responseString{
                    response in
                        switch(response.result) {
                            case .success(_):
                                if let data = response.result.value{
                                    //separate the files
                                    let com = data.components(separatedBy: .newlines)
                                    var version = ""
                                    var url = ""
                                    var app = ""
                                    for item in com {
                                        //split on space
                                        let line = item.trimmingCharacters(in: .whitespacesAndNewlines)
                                        let lineSep = line.components(separatedBy: .whitespaces)
                                        //get the app name
                                        if(lineSep[0]=="app"){
                                            for i in 1..<lineSep.count{
                                                app+=lineSep[i]
                                            }
                                            app = String(app.split(separator: ".")[0])
                                            print(app)
                                        }
                                        //get the version
                                        if(lineSep[0]=="version"){
                                            version = lineSep[1].replacingOccurrences(of: "'", with: "")
                                        }
                                        if(lineSep[0]=="url"){
                                            var url = ""
                                            for i in 1..<lineSep.count{
                                                url+=lineSep[i]
                                            }
                                            url = url.replacingOccurrences(of: "'", with: "")
                                            url = url.replacingOccurrences(of: "\"", with: "")

                                            if(url.contains("#{version}")){
                                                url = url.replacingOccurrences(of: "#{version}", with: version)
                                            }
                                            //perform the download
                                            let destination = DownloadRequest.suggestedDownloadDestination(for: .downloadsDirectory)
                                            Alamofire.download(url, to: destination)
                                                .downloadProgress {progress in
                                                    print("Progress: \(Double(round(progress.fractionCompleted*1000)/1000))")
                                                }
                                                .response{
                                                    response in
                                                        //get the suggested file name chosen by alamofire
                                                        let destination = response.destinationURL!.absoluteString.split(separator: "/")
                                                        let fileName = destination[destination.count-1]
                                                        print(fileName)
                                                }
                                        }
                                    }
                                }
                            case .failure(_):
                                print("Error message:\(String(describing: response.result.error))")
                                break
                        }
                }
            }
        }else{
            print("File not found")
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

}

