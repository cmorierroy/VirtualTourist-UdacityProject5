//
//  FlickrClient.swift
//  VirtualTourist-UdacityProject5
//
//  Created by Cédric Morier-Roy on 2020-11-08.
//

import Foundation
import UIKit

class FlickrClient
{
    struct Auth
    {
        static var key = "dd583d2583074e50df2dc66378e4df25"
        //static var secret = "e7a41ae4558e515c"
    }
    
    //MARK: Endpoints
    enum Endpoints
    {
        static let base = "https://www.flickr.com/services/rest"
        
        case getPhotosForLocation(Double,Double,Int)
        case downloadPhoto(String,String,String)
        
        var stringValue: String
        {
            switch self {
            case .getPhotosForLocation(let lat, let lon, let page): return Endpoints.base +  "?method=flickr.photos.search&api_key=\(Auth.key)&lat=\(lat)&lon=\(lon)&per_page=12&page=\(page)&format=json&nojsoncallback=1"
            case .downloadPhoto(let serverId, let id, let secret): return "https://live.staticflickr.com/\(serverId)/\(id)_\(secret).jpg"
            }
        }
        
        var url: URL
        {
            return URL(string: stringValue)!
        }
    }
    
    //MARK: GET Request Generic function
    class func taskForGETRequest<ResponseType:Decodable>(url: URL, response: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionTask
    {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let task = URLSession.shared.dataTask(with: request)
        { data, response, error in
            guard let data = data else
            {
                DispatchQueue.main.async
                {
                    completion(nil, error)
                }
                return
            }
                        
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async
                {
                    completion(responseObject, nil)
                }
            } 
            catch
            {
                DispatchQueue.main.async
                {
                    completion(nil, error)
                }
            }
        }
        task.resume()
        
        return task
    }
    
    //MARK: Get Requests
    class func photosForLocation(lat: Double, lon: Double, page:Int, completion: @escaping (ImageCollection?, Error?) -> Void)
    {
        _ = taskForGETRequest(url: Endpoints.getPhotosForLocation(lat,lon,page).url, response: PhotosForLocationResponse.self) { (response, error) in
            if let response = response
            {
                completion(response.photos, nil)
            }
            else
            {
                completion(nil, error)
            }
        }
    }
    
    class func downloadPhoto(image: Image, completion: @escaping (UIImage?,Error?)->Void)
    {
        let task = URLSession.shared.dataTask(with: Endpoints.downloadPhoto(image.server,image.id,image.secret).url)
        { (data, response, error) in
            guard let data = data else
            {
                completion(nil, error)
                return
            }
            let downloadedPhoto = UIImage(data: data)
            completion(downloadedPhoto,nil)
        }
        task.resume()
    }
}

