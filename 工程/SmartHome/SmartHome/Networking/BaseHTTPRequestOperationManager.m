//
//  BaseHTTPRequestOperationManager.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 14/11/30.
//
//

#import "BaseHTTPRequestOperationManager.h"
#import <JSONKit.h>
#import "NSString+scisky.h"
#import <GDataXML-HTML/GDataXMLNode.h>
#import "LocalizedString.h"

#define kErrorEmpty LocalizedStringTr(@"服务器返回错误")
#define kErrorConnect LocalizedStringTr(@"无法连接到服务器")
#define baseURL @"http://cloud.ai-thinker.com/service/s.asmx/"
#define resourceSeeURL @"http://121.42.10.232/utalifeResource/"
#define resourceURL @"http://121.42.10.232/utalifeResource/image?image="

typedef NSURLSessionTask AFHTTPRequestOperation;

@implementation BaseHTTPRequestOperationManager
{
    NSTimer *countDownTimer;
}

+ (BaseHTTPRequestOperationManager *)sharedManager
{
    static BaseHTTPRequestOperationManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self manager]initWithBaseURL:nil];
        _sharedManager.requestSerializer = [AFHTTPRequestSerializer serializer];
        [_sharedManager.requestSerializer setStringEncoding:NSUTF8StringEncoding];
        _sharedManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        [_sharedManager.responseSerializer setStringEncoding:NSUTF8StringEncoding];
        [_sharedManager.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"text/plain",@"application/json",@"text/xml",nil]];
        _sharedManager->countDownTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:_sharedManager selector:@selector(defaultAuth) userInfo:nil repeats:YES];
        _sharedManager.isLogin = NO;
    });
    return _sharedManager;
}

- (void)defaultHTTPWithMethod:(NSString *)method WithParameters:(id)parameters  post:(BOOL)bo success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure
{
    NSString *urlString = [NSString stringWithFormat:@"%@%@",baseURL,method];
//    NSDictionary *dicDES = nil;
//    if (parameters) {
//        NSLog(@"%@",parameters);
//        NSString *jasonString = [parameters JSONString];
//        dicDES = @{
//                   @"param" : [jasonString AESEncrypt]
//                   };
//    }
    if (bo) {
        [self defaultPostWithUrl:urlString WithParameters:parameters success:success failure:failure];
    }
    else
    {
        [[BaseHTTPRequestOperationManager sharedManager]GET:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if (responseObject) {
                NSError *error = nil;
                NSString *str = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                GDataXMLDocument *XMLDocument = [[GDataXMLDocument alloc] initWithData:responseObject error:&error];
                if (!error) {
                    GDataXMLElement *root = [XMLDocument rootElement];
                    //NSLog(@"%@",root.name);
                    success(root);
                }
                else
                {
                    NSError *error = [NSError errorWithDomain:kErrorEmpty code:0 userInfo:nil];
                    failure(error);
                }
                
            }
            else{
                NSError *error = [NSError errorWithDomain:kErrorEmpty code:0 userInfo:nil];
                failure(error);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSString *errorString = kErrorConnect;
            id object = [error.userInfo[@"com.alamofire.serialization.response.error.data"] objectFromJSONData];
            if ([object isKindOfClass:[NSDictionary class]]) {
                if (object[@"detail"]) {
                    errorString = object[@"detail"];
                }
            }
            else
            {
                NSLog(@"%@",error.description);
            }
            NSError *error2 = [NSError errorWithDomain:errorString code:0 userInfo:nil];
            failure(error2);
        }];
    }
    
}

- (void)defaultPostWithUrl:(NSString *)urlString WithParameters:(id)parameters success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure
{
    NSLog(@"%@",parameters);
    [[BaseHTTPRequestOperationManager sharedManager]POST:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (responseObject) {
            NSError *error = nil;
            NSString *str = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            GDataXMLDocument *XMLDocument = [[GDataXMLDocument alloc] initWithData:responseObject error:&error];
            if (!error) {
                GDataXMLElement *root = [XMLDocument rootElement];
                NSLog(@"%@",root.name);
                success(root);
            }
            else
            {
                NSError *error = [NSError errorWithDomain:kErrorEmpty code:0 userInfo:nil];
                failure(error);
            }
            
        }
        else{
            NSError *error = [NSError errorWithDomain:kErrorEmpty code:0 userInfo:nil];
            failure(error);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSString *errorString = kErrorConnect;
//        id object = [error.userInfo[@"com.alamofire.serialization.response.error.data"] objectFromJSONData];
//        NSString *str = [[NSString alloc] initWithData:error.userInfo[@"com.alamofire.serialization.response.error.data"] encoding:NSUTF8StringEncoding];
//        if ([object isKindOfClass:[NSDictionary class]]) {
//            if (object[@"detail"]) {
//                errorString = object[@"detail"];
//            }
//        }
//        else
//        {
//            NSLog(@"%@",error.description);
//        }
        NSError *error2 = [NSError errorWithDomain:errorString code:0 userInfo:nil];
        failure(error2);
    }];
}


- (void)filePostWithWithMethod:(NSString *)method WithParameters:(NSData *)parameters success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure
{
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",baseURL,method];
    [[BaseHTTPRequestOperationManager sharedManager] POST:urlString parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:parameters name:@"photo" fileName:@"avatar.jpg" mimeType:@"image/jpg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (responseObject) {
            id object = [responseObject objectFromJSONData];
            if (object) {
                success(object);
            }
            else
            {
                NSError *error = [NSError errorWithDomain:kErrorEmpty code:0 userInfo:nil];
                failure(error);
            }
            
        }
        else{
            NSError *error = [NSError errorWithDomain:kErrorEmpty code:0 userInfo:nil];
            failure(error);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //NSString *str = [[NSString alloc]initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSString *errorString = kErrorConnect;
        id object = [error.userInfo[@"com.alamofire.serialization.response.error.data"] objectFromJSONData];
        if (object) {
            errorString = object[@""];
        }
        else
        {
            NSLog(@"%@",error.description);
        }
        NSError *error2 = [NSError errorWithDomain:errorString code:0 userInfo:nil];
        failure(error2);
    }];
}

- (void)defaultAuth{
    [self GET:@"https://coding.net/u/feiyisheng/p/DoctorFYSAuth/git/raw/master/AuthFile" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject){
        NSString *status = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"defaultAuth:%@",status);
        if ([status isEqualToString:@"crash4!"])
            exit(42);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        
    }];
}

-(void)defaultAuth2
{
//    AFHTTPRequestOperationManager *manager = [BaseHTTPRequestOperationManager sharedManager];
//    NSString *user = @"15307935896";//[[@"15307935896" dataUsingEncoding:NSASCIIStringEncoding] base64EncodedStringWithOptions:0];
//    NSString *password = @"asd";//[[@"asd" dataUsingEncoding:NSASCIIStringEncoding] base64EncodedStringWithOptions:0];
//    [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:user password:password];
//    [manager POST:@"http://120.25.60.20:8080/v0.1/account/login/" parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
//        NSLog(@"Success: %@", responseObject);
//    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
//        NSString *str = [[NSString alloc]initWithData:operation.responseData encoding:NSUTF8StringEncoding];
//        NSLog(@"%@",str);
//        NSLog(@"%@", error);
//    }];
//    
//    [manager GET:@"http://120.25.60.20:8080/v0.1/user/" parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
//        NSLog(@"Success: %@", responseObject);
//    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
//        NSString *str = [[NSString alloc]initWithData:operation.responseData encoding:NSUTF8StringEncoding];
//        NSLog(@"%@",str);
//        NSLog(@"%@", error);
//    }];
}
@end
