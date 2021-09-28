//
//  FileManagerFacade.swift
//  GMaps
//
//  Created by Ruslan Safargalin on 28.09.2021.
//

import Foundation
import UIKit
import UniformTypeIdentifiers.UTType

// MARK: - FileManager Protocol

protocol FileManagerFacade: AnyObject {
    
    func isExistFolder(_ folder: Folders,
                       in directory: Directories) -> Bool
    
    func isExistFile(name: String,
                     type: UTType,
                     directory: Directories,
                     folder: Folders) -> Bool
    
    func save(file name: String,
              type: UTType,
              data: Data,
              directory: Directories,
              folder: Folders) -> Bool
    
    @discardableResult
    func replace(file name: String,
                 type: UTType,
                 data: Data,
                 directory: Directories,
                 folder: Folders) -> Result<Bool, FileManagerErrors>
    
    @discardableResult
    func replace(image name: String,
                 image: UIImage,
                 directory: Directories,
                 folder: Folders) -> Result<Bool, FileManagerErrors>
    
    @discardableResult
    func remove(file name: String,
                type: UTType,
                directory: Directories,
                folder: Folders) -> Result<Bool, FileManagerErrors>
    
    func fetch(file name: String,
               type: UTType,
               directory: Directories,
               folder: Folders) -> Result<Data, FileManagerErrors>
    
    func fetch(image name: String,
               directory: Directories,
               folder: Folders) -> Result<UIImage, FileManagerErrors>

}

// MARK: - Enums

enum FileManagerErrors: Error {
    
    case NotFoundDirectoryURL,
         NotFoundFolderURL,
         FolderNotExist,
         FolderExist,
         
         FailedCreateFile,
         FailedRemoveFile,
         FailedCreateFolder,
         
         FileExist,
         FileNotFound,
         
         InvalidData
    
}

/// Перечисление системных директорий
enum Directories {
    case cache,
         documents
}

/// Перечисление расширений имени файлов
enum FilenameExtension: String {
    case png
}

/// Перечисление  директорий
enum Folders: String {
    case none,
         images = "images/"
}

// MARK: - FileManagerImpl

final class FileManagerImpl: FileManagerFacade {
    
    // MARK: - Public methods
    
    func isExistFolder(_ folder: Folders, in directory: Directories) -> Bool {
        switch fetchURL(for: directory, folder: folder) {
        case .success:
            return true
            
        case .failure:
            return false
        }
    }
    
    func isExistFile(name: String,
                     type: UTType,
                     directory: Directories,
                     folder: Folders) -> Bool {
        switch fetchURL(for: name, type: type, directory: directory, folder: folder) {
        case .success:
            return true
            
        case .failure:
            return false
        }
    }
    
    func fetch(file name: String,
               type: UTType,
               directory: Directories,
               folder: Folders) -> Result<Data, FileManagerErrors> {
        switch fetchURL(for: name, type: type, directory: directory, folder: folder) {
        case .success(let fileURL):
            guard let data = FileManager.default.contents(atPath: fileURL.path) else { return .failure(.InvalidData) }
            return .success(data)
            
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func fetch(image name: String, directory: Directories, folder: Folders) -> Result<UIImage, FileManagerErrors> {
        switch fetchURL(for: name, type: .png, directory: directory, folder: folder) {
        case .success(let fileURL):
            guard let data = FileManager.default.contents(atPath: fileURL.path) else { return .failure(.InvalidData) }
            guard let image = UIImage(data: data) else { return .failure(.InvalidData) }
            return .success(image)
            
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func save(file name: String,
              type: UTType,
              data: Data,
              directory: Directories,
              folder: Folders) -> Bool {
        switch fetchURL(for: directory, folder: folder) {
        case .success(let directoryURL):
            let fileURL = directoryURL.appendingPathComponent(name)
                                      .appendingPathExtension(for: type)
            guard let _ = try? createFile(data: data, at: fileURL.path) else { return false }
            return true
            
        case .failure:
            return false
        }
        
    }
    
    @discardableResult
    func remove(file name: String,
                type: UTType,
                directory: Directories,
                folder: Folders) -> Result<Bool, FileManagerErrors> {
        switch fetchURL(for: name, type: type, directory: directory, folder: folder) {
        case .success(let fileURL):
            guard let _ = try? FileManager.default.removeItem(at: fileURL) else { return .failure(.FailedRemoveFile) }
            return .success(true)
            
        case .failure(let error):
            return .failure(error)
        }
    }
    
    @discardableResult
    func replace(file name: String,
                 type: UTType,
                 data: Data,
                 directory: Directories,
                 folder: Folders) -> Result<Bool, FileManagerErrors> {
        switch fetchURL(for: name, type: type, directory: directory, folder: folder) {
        case .success(let fileURL):
            guard let _ = try? FileManager.default.removeItem(at: fileURL) else { return .failure(.FailedRemoveFile) }
            guard let _ = try? createFile(data: data, at: fileURL.path) else { return .failure(.FailedCreateFile) }
            return .success(true)
            
        case .failure:
            switch fetchURL(for: directory, folder: folder) {
            case .success(let folderURL):
                let fileURL = folderURL.appendingPathComponent(name)
                                       .appendingPathExtension(for: type)
                guard let _ = try? createFile(data: data, at: fileURL.path) else { return .failure(.FailedCreateFile) }
                return .success(true)
                
            case .failure(let error):
                return .failure(error)
            }
        }
    }
    
    @discardableResult
    func replace(image name: String,
                 image: UIImage,
                 directory: Directories,
                 folder: Folders) -> Result<Bool, FileManagerErrors> {
        guard let data = image.pngData() else { return .failure(.InvalidData) }
        switch fetchURL(for: name, type: .png, directory: directory, folder: folder) {
        case .success(let fileURL):
            guard let _ = try? FileManager.default.removeItem(at: fileURL) else { return .failure(.FailedRemoveFile) }
            
            guard let _ = try? createFile(data: data, at: fileURL.path) else { return .failure(.FailedCreateFile) }
            return .success(true)
            
        case .failure:
            switch fetchURL(for: directory, folder: folder) {
            case .success(let folderURL):
                let fileURL = folderURL.appendingPathComponent(name)
                    .appendingPathExtension(for: .png)
                guard let _ = try? createFile(data: data, at: fileURL.path) else { return .failure(.FailedCreateFile) }
                return .success(true)
                
            case .failure(let error):
                return .failure(error)
            }
        }
    }
    
    // MARK: - Private methods
    
    private func createFile(data: Data, at path: String, attributes: [FileAttributeKey : Any]? = nil) throws -> Bool {
        guard !FileManager.default.fileExists(atPath: path) else { throw FileManagerErrors.FileExist }
        guard FileManager.default.createFile(atPath: path, contents: data, attributes: attributes)
        else { throw FileManagerErrors.FailedCreateFile }
        return true
    }
    
    private func createFolder(in directory: Directories, for folderType: Folders) throws {
        guard folderType == .none
        else { throw FileManagerErrors.FolderNotExist }
        
        let directory: FileManager.SearchPathDirectory = fetchSystemDirectoryID(from: directory)
        
        guard let directoryURL = FileManager.default.urls(for: directory, in: .userDomainMask).first
        else { throw FileManagerErrors.NotFoundDirectoryURL }
        
        let folderURL = directoryURL.appendingPathComponent(folderType.rawValue, isDirectory: true)
        
        guard !FileManager.default.fileExists(atPath: folderURL.path)
        else { throw FileManagerErrors.FolderExist }
        
        guard let _ = try? FileManager.default.createDirectory(at: folderURL,
                                                               withIntermediateDirectories: true,
                                                               attributes: nil)
        else { throw FileManagerErrors.FailedCreateFolder }
    }
    
    private func createFolder(in url: URL) throws {
        guard !FileManager.default.fileExists(atPath: url.path)
        else { throw FileManagerErrors.FolderExist }
        
        guard let _ = try? FileManager.default.createDirectory(at: url,
                                                               withIntermediateDirectories: true,
                                                               attributes: nil)
        else { throw FileManagerErrors.FailedCreateFolder }
    }
    
    private func fetchURL(for fileName: String,
                          type: UTType,
                          directory: Directories,
                          folder: Folders) -> Result<URL, FileManagerErrors> {
        switch fetchURL(for: directory, folder: folder) {
        case .success(let directoryURL):
            let fileURL = directoryURL.appendingPathComponent(fileName)
                                      .appendingPathExtension(for: type)
            
            guard FileManager.default.fileExists(atPath: fileURL.path) else { return .failure(.FileNotFound) }
            return .success(fileURL)
            
        case .failure(let error):
            return .failure(error)
        }
    }
    
    private func fetchURL(for directory: Directories,
                          folder: Folders = .none,
                          in domainMask: FileManager.SearchPathDomainMask = .userDomainMask)
    -> Result<URL, FileManagerErrors> {
        
        let directory: FileManager.SearchPathDirectory = fetchSystemDirectoryID(from: directory)
        guard let directoryURL = FileManager.default.urls(for: directory, in: domainMask).first
        else { return .failure(.NotFoundDirectoryURL) }
        
        switch folder {
        case .none:
            return .success(directoryURL)
            
        default:
            let folderURL = directoryURL.appendingPathComponent(folder.rawValue, isDirectory: true)
            
            guard !FileManager.default.fileExists(atPath: folderURL.path)
            else { return .success(folderURL) }
            
            guard let _ = try? createFolder(in: folderURL) else { return .failure(.FailedCreateFolder) }
            return .success(folderURL)
        }
    }
    
    private func fetchSystemDirectoryID(from alias: Directories) -> FileManager.SearchPathDirectory {
        switch alias {
        case .documents:
            return .documentDirectory
            
        case .cache:
            return .cachesDirectory
        }
    }
}
