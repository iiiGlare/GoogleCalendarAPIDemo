//
//  ViewController.m
//  GoogleCalendarAPIDemo
//
//  Created by Hua Cao on 13-6-18.
//  Copyright (c) 2013年 Hoewo. All rights reserved.
//

#import "ViewController.h"
#import <GKit/GCore.h>
#import <AFOAuth2Client/AFOAuth2Client.h>
#import <AFNetworking/AFNetworking.h>
#import <JLRoutes/JLRoutes.h>
#import <JSONKit/JSONKit.h>

static NSString * const kClientID = @"766253935815.apps.googleusercontent.com";
static NSString * const kClientSecret = @"8LL7pg3W5zbye7gR3xrOkvWP";
static NSString * const kAPIKey = @"AIzaSyD6QaSlPDz_tnNjcsfXXunZTFLk4exwFN0";

static NSString * const kCredentialIdentifier = @"org.dreamo.llolli.google_calendar_oauth_credential";

@interface ViewController () <
    UIWebViewDelegate
>

@property (nonatomic, strong) AFOAuth2Client * oauth2Client;
@property (nonatomic, weak) UIWebView * webView;

@property (nonatomic, copy) void (^authorizationCallback)(void);

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    UITextView * textView = [[UITextView alloc] init];
    [self.view addSubviewToFill:textView];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [self getCalendarListWithCallback:^(NSDictionary * calendarListDic) {
        NSArray * items = [calendarListDic valueForKey:@"items"];
        for (NSDictionary * itemDic in items) {
            //
            [self getCalendarWithCalendarId:[itemDic valueForKey:@"id"] callback:^(NSDictionary * calendarDic) {
            }];
            
            //
            [self getEventListWithCalendarId:[itemDic valueForKey:@"id"] callback:^(NSDictionary * calendarDic) {
            }];
        }
    }];
}

#pragma mark -

- (void)getCalendarListWithCallback:(void (^)(NSDictionary * calendarListDic))callback {
    
    [self checkAuthorizationWithCallBack:^{
        GPRINT(@"\n获取日历清单");
        
        AFOAuthCredential * credential = [AFOAuthCredential retrieveCredentialWithIdentifier:kCredentialIdentifier];
        
        NSURL * url = [NSURL URLWithString:@"https://www.googleapis.com/"];
        AFOAuth2Client * client = [AFOAuth2Client clientWithBaseURL:url clientID:kClientID secret:kClientSecret];
        
        [client setAuthorizationHeaderWithToken:credential.accessToken];
        
        [client getPath:@"calendar/v3/users/me/calendarList"
             parameters:@{@"minAccessRole":@"owner",
                          @"key":kAPIKey}
                success:^(AFHTTPRequestOperation * operation, NSData * responseObject) {
                    if ([operation.response statusCode] == 200) {
                        NSDictionary * calendarListDic = [responseObject objectFromJSONData];
                        GPRINT(@"\n日历清单：\n%@",calendarListDic);
                        if (callback) {
                            callback(calendarListDic);
                        }
                    } else {
                        GPRINT(@"\n日历清单获取失败 \n%@",[responseObject objectFromJSONData]);
                        if (callback) {
                            callback(nil);
                        }
                    }
                }
                failure:^(AFHTTPRequestOperation * operation, NSError * error) {
                    GPRINTError(error);
                    if (callback) {
                        callback(nil);
                    }
                }];
    }];
}

- (void)getCalendarWithCalendarId:(NSString *)calendarId
                         callback:(void (^)(NSDictionary * calendarDic))callback {
    [self checkAuthorizationWithCallBack:^{
        GPRINT(@"\n获取日历");
        
        AFOAuthCredential * credential = [AFOAuthCredential retrieveCredentialWithIdentifier:kCredentialIdentifier];
        
        NSURL * url = [NSURL URLWithString:@"https://www.googleapis.com/"];
        AFOAuth2Client * client = [AFOAuth2Client clientWithBaseURL:url clientID:kClientID secret:kClientSecret];
        
        [client setAuthorizationHeaderWithToken:credential.accessToken];
        
        [client getPath: [NSString stringWithFormat:@"/calendar/v3/calendars/%@",calendarId]
             parameters: nil
                success: ^(AFHTTPRequestOperation * operation, NSData * responseObject) {
                    if ([operation.response statusCode] == 200) {
                        NSDictionary * calendarDic = [responseObject objectFromJSONData];
                        GPRINT(@"\n日历：\n%@",calendarDic);
                        if (callback) {
                            callback(calendarDic);
                        }
                    } else {
                        GPRINT(@"\n日历获取失败 \n%@",[responseObject objectFromJSONData]);
                        if (callback) {
                            callback(nil);
                        }
                    }
                }
                failure:^(AFHTTPRequestOperation * operation, NSError * error) {
                    GPRINTError(error);
                    if (callback) {
                        callback(nil);
                    }
                }];
    }];
}

- (void)getEventListWithCalendarId:(NSString *)calendarId
                          callback:(void (^)(NSDictionary * calendarDic))callback {
    [self checkAuthorizationWithCallBack:^{
        GPRINT(@"\n获取事件列表");
        
        AFOAuthCredential * credential = [AFOAuthCredential retrieveCredentialWithIdentifier:kCredentialIdentifier];
        
        NSURL * url = [NSURL URLWithString:@"https://www.googleapis.com/"];
        AFOAuth2Client * client = [AFOAuth2Client clientWithBaseURL:url clientID:kClientID secret:kClientSecret];
        
        [client setAuthorizationHeaderWithToken:credential.accessToken];
        
        [client getPath: [NSString stringWithFormat:@"/calendar/v3/calendars/%@/events",calendarId]
             parameters: nil
                success: ^(AFHTTPRequestOperation * operation, NSData * responseObject) {
                    if ([operation.response statusCode] == 200) {
                        NSDictionary * eventListDic = [responseObject objectFromJSONData];
                        GPRINT(@"\n事件列表：\n%@",eventListDic);
                        if (callback) {
                            callback(eventListDic);
                        }
                    } else {
                        GPRINT(@"\n事件列表获取失败 \n%@",[responseObject objectFromJSONData]);
                        if (callback) {
                            callback(nil);
                        }
                    }
                }
                failure:^(AFHTTPRequestOperation * operation, NSError * error) {
                    GPRINTError(error);
                    if (callback) {
                        callback(nil);
                    }
                }];
    }];
}

#pragma mark -

- (void)checkAuthorizationWithCallBack:(void (^)(void))callback {
    self.authorizationCallback = callback;
    
    AFOAuthCredential * credential = [AFOAuthCredential retrieveCredentialWithIdentifier:kCredentialIdentifier];
    if (credential==nil) {
        GPRINT(@"\n未授权，开启网页请用户授权");
        [self authorizate];
    }
    else {
        [self.webView removeFromSuperview];
        if (credential.isExpired) {
            GPRINT(@"\n已授权，但是授权过期，需要重新授权");
            [self refreshAccesstoken];
        }
        else {
            GPRINT(@"\n已授权");
            if (callback) {
                callback();
            }
        }
    }
}

#pragma mark - Authorizate

- (void)authorizate {
    // 打开授权页
    UIWebView * webView = [[UIWebView alloc] init];
    webView.delegate = self;
    [self.view addSubviewToFill:webView];
    self.webView = webView;
    
    NSURL * url = [NSURL URLWithString:@"https://accounts.google.com/"];
    AFHTTPClient * oauthClient = [AFHTTPClient clientWithBaseURL:url];
    [self.webView loadRequest:
     [oauthClient requestWithMethod:@"GET"
                               path:@"/o/oauth2/auth"
                         parameters:@{@"response_type":@"code",
                                      @"client_id":kClientID,
                                      @"redirect_uri":@"http://localhost",
                                      @"scope":@"https://www.googleapis.com/auth/calendar"}]];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    [JLRoutes routeURL:request.URL];
    [JLRoutes addRoute:@"/localhost" handler:^(NSDictionary * parameters) {
        // get code
        NSString * code = parameters[@"code"];
        GPRINT(@"\n code: %@", code);
        
        /*         
         NSURL * url = [NSURL URLWithString:@"https://accounts.google.com/"];
         AFHTTPClient * oauthClient = [AFHTTPClient clientWithBaseURL:url];
         [oauthClient registerHTTPOperationClass:[AFJSONRequestOperation class]];
         [oauthClient setDefaultHeader:@"Accept" value:@"application/json"];
         
         [oauthClient postPath: @"/o/oauth2/token"
         parameters: @{@"code":code,
         @"client_id":kClientID,
         @"client_secret":kClientSecret,
         @"redirect_uri":@"http://localhost",
         @"grant_type":@"authorization_code"}
         success: ^(AFHTTPRequestOperation * operation, id responseObject) {
         GPRINT(@"%@", responseObject);
         }
         failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
         GPRINTError(error);
         }];
         */
        
        NSURL * url = [NSURL URLWithString:@"https://accounts.google.com/"];
        [[AFOAuth2Client clientWithBaseURL:url clientID:kClientID secret:kClientSecret] authenticateUsingOAuthWithPath:@"/o/oauth2/token" code:code redirectURI:@"http://localhost" success:^(AFOAuthCredential * credential) {

            GPRINT(@"\n授权成功：%@",credential);
            
            [AFOAuthCredential storeCredential:credential withIdentifier:kCredentialIdentifier];
            
            if (_authorizationCallback) {
                _authorizationCallback();
            }
            
        } failure: ^(NSError * error) {
            GPRINTError(error);
        }];
                
        return YES;
    }];
    
    return YES;
}

#pragma mark - Refresh Accesstoken 
- (void)refreshAccesstoken {
    NSURL * url = [NSURL URLWithString:@"https://accounts.google.com/"];
    AFOAuth2Client * client = [AFOAuth2Client clientWithBaseURL:url clientID:kClientID secret:kClientSecret];
    AFOAuthCredential * credential = [AFOAuthCredential retrieveCredentialWithIdentifier:kCredentialIdentifier];
    [client authenticateUsingOAuthWithPath:@"/o/oauth2/token"
                              refreshToken:credential.refreshToken
                                   success:^(AFOAuthCredential * credential) {
                                       GPRINT(@"\n重新授权成功：\n%@",credential);
                                       [AFOAuthCredential storeCredential:credential withIdentifier:kCredentialIdentifier];
                                       
                                       if (_authorizationCallback) {
                                           _authorizationCallback();
                                       }
                                   }
                                   failure: ^(NSError * error) {
                                       GPRINTError(error);
                                   }];
    
}

@end
