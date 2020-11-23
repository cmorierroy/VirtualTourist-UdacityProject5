//
//  PhotosForLocationResponse.swift
//  VirtualTourist-UdacityProject5
//
//  Created by Cédric Morier-Roy on 2020-11-19.
//

import Foundation

struct PhotosForLocationResponse : Codable
{
    let photos: ImageCollection
    let stat: String
    
    enum CodingKeys: String, CodingKey
    {
        case photos
        case stat
    }
}

struct ImageCollection : Codable
{
    let page: Int
    let pages: Int
    let perpage: Int
    let total: String
    let photo: [Image]
    
    enum CodingKeys: String, CodingKey
    {
        case page
        case pages
        case perpage
        case total
        case photo
    }
}

struct Image : Codable
{
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
    let title: String
    let ispublic:Int
    let isfriend:Int
    let isfamily:Int
    
    enum CodingKeys: String, CodingKey
    {
        case id
        case owner
        case secret
        case server
        case farm
        case title
        case ispublic
        case isfriend
        case isfamily
    }
}
