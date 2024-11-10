//
//  LocalFileManager.swift
//  CryptoDemo
//
//  Created by Philophobic on 09/11/24.
//

import Foundation
import SwiftUI
//This class is used for if once image is downloaed then it will save in our local device 
class LocalFileManager  {
    
    static let instance = LocalFileManager()
    private init(){}
    
    func saveImage(image:UIImage,imageName:String,folderName:String) {
        //Create folder
        createFolderIfNeeded(folderName: folderName)
        //get path for Image
        guard let data = image.pngData(),
              let url = getUrlForImage(imageName: imageName, folderName: folderName) else  {
            return
        }
        //save image to path
        do {
            try  data.write(to: url)
        } catch let error {
            print("Error in saving image \(imageName), error : \(error)")
        }
    }
    
    
    func getImage(imageName:String,folderName:String) -> UIImage? {
        
        guard let url = getUrlForImage(imageName: imageName, folderName: folderName),
              FileManager.default.fileExists(atPath: url.path) else {
                  return nil
              }
        
        return UIImage(contentsOfFile: url.path(percentEncoded: true))
    }
    
    private func getUrlForImage(imageName:String,folderName:String) -> URL? {
        guard let folderURL = getURLForFolder(name: folderName) else  {
            return nil
        }
        
        return folderURL.appendingPathComponent(imageName + ".png")
    }
    private func createFolderIfNeeded(folderName:String) {
        
        guard let url = getURLForFolder(name: folderName) else  {
            return
        }
        
        if !FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
            } catch let error {
                print("Error at creating directory \(folderName) , \(error.localizedDescription)")
            }
        }
    }
    
    private func getURLForFolder(name:String) -> URL? {
        guard let  url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else  {
            return nil
        }
        return url.appendingPathComponent(name)
    }
    
    
}
