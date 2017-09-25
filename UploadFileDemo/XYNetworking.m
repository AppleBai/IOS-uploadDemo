//
//  XYNetworking.m
//  AFNDemo
//
//  Created by xiyang on 16/3/7.
//  Copyright © 2016年 xiyang. All rights reserved.
//

#import "XYNetworking.h"

@interface XYNetworking()


@end


@implementation XYNetworking

#pragma mark - Public

+(void)GET:(NSString *)url params:(NSDictionary *)params
            success:(XYResponseSuccess)success fail:(XYResponseFail)fail{
    
    AFHTTPSessionManager *manager = [XYNetworking managerWithBaseURL:nil sessionConfiguration:NO];
    [manager GET:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        id dic = [XYNetworking responseConfiguration:responseObject];
        
        success(task,dic);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        fail(task,error);
    }];

}

+(void)GET:(NSString *)url baseURL:(NSString *)baseUrl params:(NSDictionary *)params
   success:(XYResponseSuccess)success fail:(XYResponseFail)fail{
    
    AFHTTPSessionManager *manager = [XYNetworking managerWithBaseURL:baseUrl sessionConfiguration:NO];
    [manager GET:url parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        
        id dic = [XYNetworking responseConfiguration:responseObject];
        
        success(task,dic);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        fail(task,error);
    }];
    
}

+(void)POST:(NSString *)url params:(NSDictionary *)params
            success:(XYResponseSuccess)success fail:(XYResponseFail)fail{
    
    AFHTTPSessionManager *manager = [XYNetworking managerWithBaseURL:nil sessionConfiguration:NO];
    
    [manager POST:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        id dic = [XYNetworking responseConfiguration:responseObject];
        
        success(task,dic);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        fail(task,error);
    }];
    
}

+(void)POST:(NSString *)url baseURL:(NSString *)baseUrl params:(NSDictionary *)params
    success:(XYResponseSuccess)success fail:(XYResponseFail)fail{
    
    AFHTTPSessionManager *manager = [XYNetworking managerWithBaseURL:baseUrl sessionConfiguration:NO];
    [manager POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        id dic = [XYNetworking responseConfiguration:responseObject];
        
        success(task,dic);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        fail(task,error);
    }];
     
}

+(void)uploadWithURL:(NSString *)url
                params:(NSDictionary *)params
                fileData:(NSData *)filedata
                name:(NSString *)name
                fileName:(NSString *)filename
                    mimeType:(NSString *) mimeType
                            progress:(XYProgress)progress
                            success:(XYResponseSuccess)success
                            fail:(XYResponseFail)fail{
    
    AFHTTPSessionManager *manager = [XYNetworking managerWithBaseURL:nil sessionConfiguration:NO];
    
    [manager POST:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        [formData appendPartWithFileData:filedata name:name fileName:filename mimeType:mimeType];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
        progress(uploadProgress);
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        id dic = [XYNetworking responseConfiguration:responseObject];
        success(task,dic);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        fail(task,error);
    }];
    
}


+(void)uploadWithURL:(NSString *)url
                baseURL:(NSString *)baseurl
                    params:(NSDictionary *)params
                    fileData:(NSData *)filedata
                        name:(NSString *)name
                        fileName:(NSString *)filename
                            mimeType:(NSString *) mimeType
                                    progress:(XYProgress)progress
                                        success:(XYResponseSuccess)success
                                        fail:(XYResponseFail)fail{
    
    AFHTTPSessionManager *manager = [XYNetworking managerWithBaseURL:baseurl sessionConfiguration:YES];
    
    [manager POST:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:filedata name:name fileName:filename mimeType:mimeType];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        progress(uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        id dic = [XYNetworking responseConfiguration:responseObject];
        
        success(task,dic);

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        fail(task,error);
    }];
    
    
}


+(NSURLSessionDownloadTask *)downloadWithURL:(NSString *)url
            savePathURL:(NSURL *)fileURL
               progress:(XYProgress )progress
                    success:(void (^)(NSURLResponse *, NSURL *))success
                        fail:(void (^)(NSError *))fail{
    AFHTTPSessionManager *manager = [self managerWithBaseURL:nil sessionConfiguration:YES];
    
    NSURL *urlpath = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:urlpath];
    
     NSURLSessionDownloadTask *downloadtask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
         progress(downloadProgress);
         
     } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
         
         return [fileURL URLByAppendingPathComponent:[response suggestedFilename]];
     } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
         
         if (error) {
             fail(error);
         }else{
             
             success(response,filePath);
         }
     }];
    
    [downloadtask resume];
    
    return downloadtask;
    
}

#pragma mark - Private

+(AFHTTPSessionManager *)managerWithBaseURL:(NSString *)baseURL  sessionConfiguration:(BOOL)isconfiguration{
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFHTTPSessionManager *manager =nil;
    
    NSURL *url = [NSURL URLWithString:baseURL];
    
    if (isconfiguration) {
        
        manager = [[AFHTTPSessionManager alloc] initWithBaseURL:url sessionConfiguration:configuration];
    }else{
        manager = [[AFHTTPSessionManager alloc] initWithBaseURL:url];
    }
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    return manager;
}

+(void)uploadWithURL:(NSString *)url
              params:(NSDictionary *)params
            fileData:(NSData *)filedata
                name:(NSString *)name
            fileName:(NSString *)filename
            mimeType:(NSString *) mimeType
             success:(HttpRequestSuccess)success failure:(HttpRequestFailed)failure
{
    
    NSURL *video_url = [NSURL URLWithString:@"http://datasp1.nongji360.mobi/"];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:video_url sessionConfiguration:configuration];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    [manager POST:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:filedata name:name fileName:filename mimeType:mimeType];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
//        NSLog(@"%@",uploadProgress.)
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSJSONSerialization * json = [NSJSONSerialization JSONObjectWithData:responseObject options: NSJSONReadingMutableContainers error:nil];
        NSDictionary * dic = (NSDictionary*)json;
        success(dic);
        //        NSLog(@"%@",dic);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        failure(error);
    }];
    
    
}

+(id)responseConfiguration:(id)responseObject{
    
    NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
    string = [string stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    return dic;
    
}








@end
