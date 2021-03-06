//
//  TopicListModel.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/13/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit

import ObjectMapper
import Alamofire

import Ji

class TopicListModel {
    var topicId: String?
    var avata: String?
    var nodeName: String?
    var userName: String?
    var topicTitle: String?
    var date: String?
    var lastReplyUserName: String?
    var replies: String?
    
    var hits: String?
    
    init() {
        
    }
    init(rootNode: JiNode) {
        self.avata = rootNode.xPath("./table/tr/td[1]/a[1]/img[@class='avatar']").first?["src"]
        self.nodeName = rootNode.xPath("./table/tr/td[3]/span[1]/a[1]").first?.content
        self.userName = rootNode.xPath("./table/tr/td[3]/span[1]/strong[1]/a[1]").first?.content
        
        let node = rootNode.xPath("./table/tr/td[3]/span[2]/a[1]").first
        self.topicTitle = node?.content
        
        var topicIdUrl = node?["href"];
        
        if var id = topicIdUrl {
            if let range = id.rangeOfString("/t/") {
                id.replaceRange(range, with: "");
            }
            if let range = id.rangeOfString("#") {
                id = id.substringToIndex(range.startIndex)
                topicIdUrl = id
            }
        }
        self.topicId = topicIdUrl
        
        
        self.date = rootNode.xPath("./table/tr/td[3]/span[3]").first?.content
        
        var lastReplyUserName:String? = nil
        if let lastReplyUser = rootNode.xPath("./table/tr/td[3]/span[3]/strong[1]/a[1]").first{
            lastReplyUserName = lastReplyUser.content
        }
        self.lastReplyUserName = lastReplyUserName
        
        var replies:String? = nil;
        if let reply = rootNode.xPath("./table/tr/td[4]/a[1]").first {
            replies = reply.content
        }
        self.replies  = replies

    }
    init(favoritesRootNode:JiNode) {
        self.avata = favoritesRootNode.xPath("./table/tr/td[1]/a[1]/img[@class='avatar']").first?["src"]
        self.nodeName = favoritesRootNode.xPath("./table/tr/td[3]/span[2]/a[1]").first?.content
        self.userName = favoritesRootNode.xPath("./table/tr/td[3]/span[2]/strong[1]/a").first?.content
        
        let node = favoritesRootNode.xPath("./table/tr/td[3]/span/a[1]").first
        self.topicTitle = node?.content
        
        var topicIdUrl = node?["href"];
        
        if var id = topicIdUrl {
            if let range = id.rangeOfString("/t/") {
                id.replaceRange(range, with: "");
            }
            if let range = id.rangeOfString("#") {
                id = id.substringToIndex(range.startIndex)
                topicIdUrl = id
            }
        }
        self.topicId = topicIdUrl
        
        
        let date = favoritesRootNode.xPath("./table/tr/td[3]/span[2]").first?.content
        if let date = date {
            let array = date.componentsSeparatedByString("•")
            if array.count == 4 {
                self.date = array[3].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            }
        }
        
        self.lastReplyUserName = favoritesRootNode.xPath("./table/tr/td[3]/span[2]/strong[2]/a[1]").first?.content
        
        self.replies = favoritesRootNode.xPath("./table/tr/td[4]/a[1]").first?.content
    }
    
    init(nodeRootNode:JiNode) {
        self.avata = nodeRootNode.xPath("./table/tr/td[1]/a[1]/img[@class='avatar']").first?["src"]
        self.userName = nodeRootNode.xPath("./table/tr/td[3]/span[2]/strong").first?.content
        
        let node = nodeRootNode.xPath("./table/tr/td[3]/span/a[1]").first
        self.topicTitle = node?.content
        
        var topicIdUrl = node?["href"];
        
        if var id = topicIdUrl {
            if let range = id.rangeOfString("/t/") {
                id.replaceRange(range, with: "");
            }
            if let range = id.rangeOfString("#") {
                id = id.substringToIndex(range.startIndex)
                topicIdUrl = id
            }
        }
        self.topicId = topicIdUrl
        
        
        self.hits = nodeRootNode.xPath("./table/tr/td[3]/span[last()]/text()").first?.content
        if var hits = self.hits {
            hits = hits.substringFromIndex(hits.startIndex.advancedBy(5))
            self.hits = hits
        }
        var replies:String? = nil;
        if let reply = nodeRootNode.xPath("./table/tr/td[4]/a[1]").first {
            replies = reply.content
        }
        self.replies  = replies
    }
    
    /**
     获取首页帖子列表
     
     - parameter tab:               tab名
     */
    class func getTopicList(
        tab: String? = nil ,
        completionHandler: V2ValueResponse<[TopicListModel]> -> Void
        )->Void{
            
            var params:[String:String] = [:]
            if let tab = tab {
                params["tab"]=tab
            }
            else {
                params["tab"] = "hot"
            }
            
            
            Alamofire.request(.GET, V2EXURL, parameters: params, encoding: .URL, headers: MOBILE_CLIENT_HEADERS).responseJiHtml { (response) -> Void in
                var resultArray:[TopicListModel] = []
                if  let jiHtml = response.result.value{
                    if let aRootNode = jiHtml.xPath("//body/div[@id='Wrapper']/div[@class='content']/div[@class='box']/div[@class='cell item']"){
                        for aNode in aRootNode {
                            let topic = TopicListModel(rootNode:aNode)
                            resultArray.append(topic);
                        }
                        
                        //更新通知数量
                        V2Client.sharedInstance.getNotificationsCount(jiHtml.rootNode!)
                    }
                }
                
                let t = V2ValueResponse<[TopicListModel]>(value:resultArray, success: response.result.isSuccess)
                completionHandler(t);
            }
    }
    
    class func getTopicList(
        nodeName: String,
        page:Int,
        completionHandler: V2ValueResponse<[TopicListModel]> -> Void
        )->Void{
            
            let url =  V2EXURL + "go/" + nodeName + "?p=" + "\(page)"
            
            Alamofire.request(.GET, url, parameters: nil, encoding: .URL, headers: MOBILE_CLIENT_HEADERS).responseJiHtml { (response) -> Void in
                var resultArray:[TopicListModel] = []
                if  let jiHtml = response.result.value{
                    if let aRootNode = jiHtml.xPath("//*[@id='Wrapper']/div[@class='content']/div[@class='box']/div[@class='cell']"){
                        for aNode in aRootNode {
                            let topic = TopicListModel(nodeRootNode: aNode)
                            resultArray.append(topic);
                        }
                        
                        //更新通知数量
                        V2Client.sharedInstance.getNotificationsCount(jiHtml.rootNode!)
                    }
                }
                
                let t = V2ValueResponse<[TopicListModel]>(value:resultArray, success: response.result.isSuccess)
                completionHandler(t);
            }
    }
    
    
    /**
     获取我的收藏帖子列表
     
     */
    class func getFavoriteList(completionHandler: V2ValueResponse<[TopicListModel]> -> Void){
        Alamofire.request(.GET, V2EXURL+"my/topics", parameters: nil, encoding: .URL, headers: MOBILE_CLIENT_HEADERS).responseJiHtml { (response) -> Void in
            var resultArray:[TopicListModel] = []
            
            if let jiHtml = response.result.value {
                if let aRootNode = jiHtml.xPath("//*[@id='Main']/div[@class='box']/div[@class='cell item']"){
                    for aNode in aRootNode {
                        let topic = TopicListModel(favoritesRootNode:aNode)
                        resultArray.append(topic);
                    }
                    
                    //更新通知数量
                    V2Client.sharedInstance.getNotificationsCount(jiHtml.rootNode!)
                }
            }
            let t = V2ValueResponse<[TopicListModel]>(value:resultArray, success: response.result.isSuccess)
            completionHandler(t);
        }
    }
    
}
