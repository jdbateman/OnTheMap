//
//  RESTConvenience.swift
//  OnTheMap
//
//  Created by john bateman on 7/24/15.
//  Copyright (c) 2015 John Bateman. All rights reserved.
//
// Udacity API for On The Map Instructions:  https://docs.google.com/document/d/1MECZgeASBDYrbBg7RlRu9zBBLGd3_kfzsN-0FtURqn0/pub?embedded=true

import Foundation

extension RESTClient {
    
    // MARK: GET Convenience Methods
    
    func getStudentLocations(completionHandler: (success: Bool, arrayOfLocationDictionaries: [AnyObject]?, errorString: String?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}) */
        var parameters = [
            "limit" : "100"
        ]
        
        // set up http header parameters
        let headerParms = [
            "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr" : "X-Parse-Application-Id",
            "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY" : "X-Parse-REST-API-Key"
        ]
            
        /* 2. Make the request */
        taskForGETMethod(baseUrl: Constants.parseBaseURL, method: Methods.parseGetStudentLocations, headerParameters: headerParms, queryParameters: parameters) { JSONResult, error in
        //taskForGETMethod(Methods.AuthenticationSessionNew, parameters: parameters) { JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandler(success: false, arrayOfLocationDictionaries: nil, errorString: "Get Student Locations request to Parse Failed.")
            } else {
                // parse the json response which looks like the following:
                /*
                    {
                        "results":[
                            {
                                "createdAt": "2015-02-25T01:10:38.103Z",
                                "firstName": "Jarrod",
                                "lastName": "Parkes",
                                "latitude": 34.7303688,
                                "longitude": -86.5861037,
                                "mapString": "Huntsville, Alabama ",
                                "mediaURL": "https://www.linkedin.com/in/jarrodparkes",
                                "objectId": "JhOtcRkxsh",
                                "uniqueKey": "996618664",
                                "updatedAt": "2015-03-09T22:04:50.315Z"
                            },
                            ...
                        ]
                    }
                */
                if let arrayOfLocationDicts = JSONResult.valueForKey("results") as? [AnyObject] {
                    completionHandler(success: true, arrayOfLocationDictionaries: arrayOfLocationDicts, errorString: nil)
                } else {
                    completionHandler(success: false, arrayOfLocationDictionaries: nil, errorString: "No results key in JSON response to the Parse Get Student Locations request.")
                }
            }
        }
    }
    
    // MARK: POST Convenience Methods

    /* 
        @brief Login to Udacity.
        @return void
            completion handler: 
                result Contains true if login was successful, else it contains false if an error occurred.
                error  An error if something went wrong, else nil.
    */
    func loginUdacity(#username: String, password: String, completionHandler: (result: Bool, error: NSError?) -> Void) {
        
        /* 1. Specify parameters */
        let parameters: String? = nil
        
        // specify base URL
        let baseURL = Constants.udacityBaseURL
        
        // specify method
        var mutableMethod : String = Methods.udacitySessionMethod
        
        // specify HTTP body (for POST method)
            /* The Udacity http body for creating a session:
                {
                    "udacity" : {
                    "username" : "account@domain.com"
                    "password" : "********"
                }
            */
        let credentials: Dictionary = ["username" : username, "password" : password]
        let jsonBody : [String:AnyObject] = [
            "udacity" : credentials
        ]
        
        /* 2. Make the request */
        let task = taskForPOSTMethod(apiKey: "", baseUrl: baseURL, method: mutableMethod, parameters: nil, jsonBody: jsonBody) { JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandler(result: false, error: error)
            } else {
                // parse the json response which looks like the following:
                /*
                    {
                        "account":{
                            "registered":true,
                            "key":"3903878747"
                        },
                        "session":{
                            "id":"1457628510Sc18f2ad4cd3fb317fb8e028488694088",
                            "expiration":"2015-05-10T16:48:30.760460Z"
                        }
                    }
                */
                if let account = JSONResult.valueForKey("account") as? [String : AnyObject] {
                    var registered = false
                    if let _registered = account["registered"] as? Bool {
                        registered = _registered
                    }
                    completionHandler(result: registered, error: nil)
                } else {
                    completionHandler(result: false, error: NSError(domain: "postToFavoritesList parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse postToFavoritesList"]))
                }
            }
        }
    }
    /* 
        @brief logout of a Udacity session.
    */
    func logoutUdacity(completionHandler: (result: Bool, error: NSError?) -> Void) {

        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies as! [NSHTTPCookie] {
            if cookie.name == "XSRF-TOKEN" {
                xsrfCookie = cookie
            }
        }
        if let xsrfCookie = xsrfCookie {
            request.addValue(xsrfCookie.value!, forHTTPHeaderField: "X-XSRF-Token")
        }
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error…
                completionHandler(result: false, error: error)
            } else {
                // the json response looks like the following:
                /*
                {
                    "session": {
                        "id": "1463940997_7b474542a32efb8096ab58ced0b748fe",
                        "expiration": "2015-07-22T18:16:37.881210Z"
                    }
                }
                */

                let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
                println(NSString(data: newData, encoding: NSUTF8StringEncoding))
                
                completionHandler(result: true, error: nil)
            }
        }
        task.resume()
    }
    
    //TODO - register maile for fall soccer
}
    