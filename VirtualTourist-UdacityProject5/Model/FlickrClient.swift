//
//  FlickrClient.swift
//  VirtualTourist-UdacityProject5
//
//  Created by Cédric Morier-Roy on 2020-11-08.
//

import Foundation

class FlickrClient
{
    struct Auth
    {
        static var key = "dd583d2583074e50df2dc66378e4df25"
        static var secret = "79cbdf6cbf20e836"
        static var sessionId = ""
    }
    
    enum Endpoints
    {
        static let base = "https://api.flickr.com/services"
        static let location = "/StudentLocation"
        
        case login
        case signUp
        case getUserInformation(String)
        case getStudentLocationList
        case postLocation
        case logout
        
        var stringValue: String
        {
            switch self {
            case .signUp: return "https://auth.udacity.com/sign-up"
            case .login: return Endpoints.base + "/session"
            case .getStudentLocationList: return Endpoints.base + Endpoints.location + "?limit=100&order=-updatedAt"
            case .getUserInformation(let userID): return Endpoints.base + "/users/\(userID)"
            case .postLocation: return Endpoints.base + Endpoints.location
            case .logout: return Endpoints.base + "/session"
            }
        }
        
        var url: URL
        {
            return URL(string: stringValue)!
        }
    }
    
    class func taskForGETRequest<ResponseType:Decodable>(url: URL, response: ResponseType.Type, cutFive: Bool, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionTask
    {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else
            {
                DispatchQueue.main.async
                {
                    completion(nil, error)
                }
                return
            }
            
            var checkedData:Data
            
            if(cutFive)
            {
                let range = 5..<data.count
                let newData = data.subdata(in: range)
                checkedData = newData
            }
            else
            {
                checkedData = data
            }
            
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: checkedData)
                DispatchQueue.main.async
                {
                    completion(responseObject, nil)
                }
            } catch {
                do
                    {
//                        let errorResponse = try decoder.decode(LoginError.self, from: checkedData)
//                        DispatchQueue.main.async
//                        {
//                            completion(nil, errorResponse)
//                        }
                    }
                catch
                {
                    DispatchQueue.main.async
                    {
                        completion(nil, error)
                    }
                }
            }
        }
        task.resume()
        
        return task
    }
    
    
    class func taskForPOSTRequest<RequestType: Encodable, ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, body: RequestType,addAccept: Bool,cutFive:Bool, completion: @escaping (ResponseType?, Error?) -> Void)
    {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        if(addAccept)
        {
            request.addValue("application/json", forHTTPHeaderField: "Accept")
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = try! JSONEncoder().encode(body)

        let task = URLSession.shared.dataTask(with: request)
        { (data, response, error) in
            guard let data = data else
            {
                DispatchQueue.main.async
                {
                    completion(nil, error)
                }
                return
            }
            
            //get rid of first 5 characters in data
            var checkedData:Data
            if(cutFive)
            {
                let range = 5..<data.count
                let newData = data.subdata(in: range)
                checkedData = newData
            }
            else
            {
                checkedData = data
            }
            
            let decoder = JSONDecoder()
            do
            {
                let responseObject = try decoder.decode(ResponseType.self, from: checkedData)

                DispatchQueue.main.async
                {
                    completion(responseObject,nil)
                }
            }
            catch
            {
                do
                {
//                    let errorResponse = try decoder.decode(LoginError.self, from: checkedData)
//                    DispatchQueue.main.async
//                    {
//                        completion(nil, errorResponse)
//                    }
                }
                catch
                {
                    DispatchQueue.main.async
                    {
                        completion(nil, error)
                    }
                }
            }
        }
        task.resume()
    }
    
    class func taskForDELETERequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void)
    {
        var request = URLRequest(url: url)
        
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
    
        for cookie in sharedCookieStorage.cookies!
        {
          if cookie.name == "XSRF-TOKEN"
          {
            xsrfCookie = cookie
          }
        }
    
        if let xsrfCookie = xsrfCookie
        {
          request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
    
        let session = URLSession.shared
        let task = session.dataTask(with: request)
        { data, response, error in
          if error != nil
          {
            DispatchQueue.main.async
            {
                completion(nil, error)
            }
            return
          }
            
          //completion()
            
          let range = 5..<data!.count
          let newData = data?.subdata(in: range)

          let decoder = JSONDecoder()
            do
          {
            let responseObject = try decoder.decode(ResponseType.self, from: newData!)
            DispatchQueue.main.async
            {
                completion(responseObject, nil)
            }
          }
            catch
            {
                DispatchQueue.main.async
                {
                    print(error)
                    completion(nil, error)
                }
            }
        }
        task.resume()
    }
    
    //POST
    class func login(username: String, password: String, completion: @escaping (Bool, Error?) -> Void)
    {
        let udacity = ["username":username,"password":password]
        //let body = LoginRequest(udacity: udacity)
        
//        taskForPOSTRequest(url: Endpoints.login.url, responseType: LoginResponse.self, body: body, addAccept: true, cutFive: true) { (response, error) in
//            if let response = response
//            {
//                //save session id and user id
//                Auth.sessionId = response.session.id
//                UserData.user?.userID = response.account.key
//
//                completion(true, nil)
//            }
//            else
//            {
//                completion(false, error)
//            }
//        }
    }
    
    class func postLocation(mapString: String, mediaURL: String, latitude: Double, longitude: Double, completion: @escaping (Bool, Error?)->Void)
    {
//        let body = PostLocationRequest(uniqueKey: UserData.user?.userID ?? "", firstName: UserData.user?.firstName ?? "", lastName: UserData.user?.lastName ?? "", mapString: mapString, mediaURL: mediaURL, latitude: latitude, longitude: longitude)
//
//        taskForPOSTRequest(url: Endpoints.postLocation.url, responseType: PostLocationResponse.self, body: body, addAccept: false, cutFive: false) { (response, error) in
//            if let response = response
//            {
//                //save object id of current location (PUTTING a location is not part of current functionality, however)
//                UserData.currentLocationId = response.objectId
//                completion(true, nil)
//            }
//            else
//            {
//                completion(false, error)
//            }
//        }
        
    }
    
    //DELETE
    class func logout(completion: @escaping (Bool, Error?) -> Void)
    {
//        taskForDELETERequest(url: Endpoints.logout.url, responseType: LogoutResponse.self) { (response, error) in
//            if let _ = response
//            {
//                //save session id and user id
//                Auth.sessionId = ""
//                UserData.reset()
//                completion(true, nil)
//            }
//            else
//            {
//                completion(false, error)
//            }
//        }
    }
    
//    //GET
//    class func getStudentLocationList(completion: @escaping ([StudentInformation], Error?) -> Void)
//    {
////        _ = taskForGETRequest(url: Endpoints.getStudentLocationList.url, response: StudentLocationResponse.self, cutFive:false)
////        {(response, error) in
////            if let response = response
////            {
////                completion(response.results,nil)
////            }
////            else
////            {
////                completion([], error)
////            }
////        }
//    }
    
    class func getUserInformation(completion: @escaping (Bool, Error?) -> Void)
    {
//        _ = taskForGETRequest(url: Endpoints.getUserInformation(UserData.user?.userID ?? "").url, response: User.self, cutFive: true)
//        {(response, error) in
//            if let response = response
//            {
//                UserData.user?.firstName = response.firstName
//                UserData.user?.lastName = response.lastName
//                
//                completion(true,nil)
//            }
//            else
//            {
//                completion(false, error)
//            }
//        }
    }

}

