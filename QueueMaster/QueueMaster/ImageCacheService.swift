import UIKit
import Combine

/// Image cache service for efficient image loading and caching
class ImageCacheService {
    static let shared = ImageCacheService()
    
    private let cache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    private init() {
        let paths = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        cacheDirectory = paths[0].appendingPathComponent("ImageCache")
        
        try? fileManager.createDirectory(
            at: cacheDirectory,
            withIntermediateDirectories: true
        )
        
        // Configure cache limits
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB
    }
    
    /// Get image from cache or download
    /// - Parameter url: Image URL
    /// - Returns: Publisher with cached or downloaded image
    func getImage(for url: URL?) -> AnyPublisher<UIImage?, Never> {
        guard let url = url else {
            return Just(nil).eraseToAnyPublisher()
        }
        
        let cacheKey = url.absoluteString as NSString
        
        // 1. Check memory cache
        if let cachedImage = cache.object(forKey: cacheKey) {
            return Just(cachedImage).eraseToAnyPublisher()
        }
        
        // 2. Check disk cache
        let fileURL = cacheDirectory.appendingPathComponent(url.lastPathComponent)
        if let diskImage = UIImage(contentsOfFile: fileURL.path) {
            cache.setObject(diskImage, forKey: cacheKey)
            return Just(diskImage).eraseToAnyPublisher()
        }
        
        // 3. Download from network (if needed)
        return Future { promise in
            URLSession.shared.dataTask(with: url) { data, _, _ in
                guard let data = data, let image = UIImage(data: data) else {
                    promise(.success(nil))
                    return
                }
                
                // Save to cache
                self.cache.setObject(image, forKey: cacheKey)
                try? data.write(to: fileURL)
                
                promise(.success(image))
            }.resume()
        }
        .eraseToAnyPublisher()
    }
    
    /// Clear all cached images
    func clearCache() {
        cache.removeAllObjects()
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(
            at: cacheDirectory,
            withIntermediateDirectories: true
        )
    }
    
    /// Get cache size in bytes
    func getCacheSize() -> Int {
        var totalSize: Int = 0
        
        if let contents = try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey]) {
            for url in contents {
                if let resources = try? url.resourceValues(forKeys: [.fileSizeKey]),
                   let fileSize = resources.fileSize {
                    totalSize += fileSize
                }
            }
        }
        
        return totalSize
    }
    
    /// Get cache size formatted for display
    func getFormattedCacheSize() -> String {
        let size = getCacheSize()
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(size))
    }
}
