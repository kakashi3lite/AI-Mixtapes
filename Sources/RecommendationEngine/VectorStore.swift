import Foundation

class VectorStore {
    private let fileManager = FileManager.default
    private let cachePath: URL
    
    init(cachePath: URL? = nil) {
        self.cachePath = cachePath ?? FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("vectorCache")
        try? fileManager.createDirectory(at: self.cachePath, withIntermediateDirectories: true, attributes: nil)
    }
    
    func store(vector: [Float], forKey key: String) throws {
        let data = try JSONEncoder().encode(vector)
        let fileURL = cachePath.appendingPathComponent("\(key).vector")
        try data.write(to: fileURL)
    }
    
    func retrieve(forKey key: String) throws -> [Float] {
        let fileURL = cachePath.appendingPathComponent("\(key).vector")
        let data = try Data(contentsOf: fileURL)
        return try JSONDecoder().decode([Float].self, from: data)
    }
    
    func exists(forKey key: String) -> Bool {
        let fileURL = cachePath.appendingPathComponent("\(key).vector")
        return fileManager.fileExists(atPath: fileURL.path)
    }
    
    func delete(forKey key: String) throws {
        let fileURL = cachePath.appendingPathComponent("\(key).vector")
        if fileManager.fileExists(atPath: fileURL.path) {
            try fileManager.removeItem(at: fileURL)
        }
    }
    
    func getAllKeys() -> [String] {
        guard let files = try? fileManager.contentsOfDirectory(at: cachePath, includingPropertiesForKeys: nil) else {
            return []
        }
        
        return files.compactMap { url -> String? in
            guard url.pathExtension == "vector" else { return nil }
            return url.deletingPathExtension().lastPathComponent
        }
    }
    
    func clear() throws {
        let files = try fileManager.contentsOfDirectory(at: cachePath, includingPropertiesForKeys: nil)
        for file in files {
            try fileManager.removeItem(at: file)
        }
    }
}