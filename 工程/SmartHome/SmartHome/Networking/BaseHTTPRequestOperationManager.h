//
//  BaseHTTPRequestOperationManager.h
//  DoctorFei_iOS
//
//  Created by GuJunjia on 14/11/30.
//
//

#import "AFNetworking/AFNetworking.h"

@interface BaseHTTPRequestOperationManager : AFHTTPSessionManager
@property (nonatomic,assign) BOOL isLogin;

+ (BaseHTTPRequestOperationManager *)sharedManager;

-(void)defaultAuth2;
- (void)defaultHTTPWithMethod:(NSString *)method WithParameters:(id)parameters  post:(BOOL)bo success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;

- (void)filePostWithWithMethod:(NSString *)method WithParameters:(NSData *)parameters success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;
@end
