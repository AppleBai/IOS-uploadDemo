//
//  ViewController.m
//  UploadFileDemo
//
//  Created by xiaobai on 2017/9/19.
//  Copyright © 2017年 xiaobai. All rights reserved.
//

#import "ViewController.h"
#import "AFURLSessionManager.h"
#import "AFHTTPSessionManager.h"
#import "JSONKit.h"
@interface ViewController ()<NSStreamDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    NSDateFormatter* formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyyMMddHHmmss"];
    NSString *timeStamp = [NSString stringWithFormat:@"%@",[formater stringFromDate:[NSDate date]]];
    NSFileManager *fm;
    fm = [NSFileManager defaultManager];
    NSDictionary *attr =[fm attributesOfItemAtPath:[[NSBundle mainBundle] pathForResource:@"IMG_0811" ofType:@"PNG"] error:nil];//文件属性
    long fileSize = [[attr objectForKey:NSFileSize] longValue];
    NSString *filesize = [NSString stringWithFormat:@"%ld",fileSize];
    NSLog(@"文件大小:%@",filesize);
    [self getHttpToken:filesize fileName:@"IMG_0811.png" timestamp:timeStamp];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//http://192.168.2.55:8080/videoupload/upload?token=A723323962_7364301&client=html5&name=Lanternpro.zip&size=7364301
-(void)uploadNetWorkWithParam:(NSString *)token fileName:(NSString *)fileName fileSize:(NSString *)fileSize
{
    NSMutableString *paramString = [NSMutableString stringWithCapacity:0];
    [paramString appendString:@"http://192.168.2.55:8080/videoupload/upload"];
    [paramString appendString:@"?"];
    [paramString appendFormat:@"token=%@",token];
    [paramString appendString:@"&"];
    [paramString appendFormat:@"client=%@",@"html5"];
    [paramString appendString:@"&"];
    [paramString appendFormat:@"name=%@",fileName];
    [paramString appendString:@"&"];
    [paramString appendFormat:@"size=%@",fileSize];
    NSString *finalUrlS = paramString;
    UIImage *image = [UIImage imageNamed:@"IMG_0811.PNG"];
    NSData *data = [NSData dataWithContentsOfFile:@"IMG_0883.mp4"];
    NSLog(@"data大小:%lu",(unsigned long)data.length);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:finalUrlS]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"keep-alive" forHTTPHeaderField:@"Connection"];
    [request setValue:fileSize forHTTPHeaderField:@"Content-Length"];
    [request setValue:[NSString stringWithFormat:@"bytes 0-%@/%@",fileSize,fileSize] forHTTPHeaderField:@"Content-Range"];
    request.timeoutInterval = 60;
    [request setHTTPBody:data];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSLog(@"%@",request.allHTTPHeaderFields);
    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithStreamedRequest:request progress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"上传失败信息:%@",error);
        } else {
            NSDictionary *resultDict = [responseObject objectFromJSONData];
            NSLog(@"上传返回信息:%@",resultDict);
        }
    }];
    [uploadTask resume];
}
- (void)getHttpToken:(NSString *)fileSize fileName:(NSString*)fileName timestamp:(NSString *)timestamp{
    NSString *urlStr = [NSString stringWithFormat:@"http://192.168.2.55:8080/videoupload/tk?name=%@&type=&size=%@&timestamp=%@",fileSize,fileName,timestamp];
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
    responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/xml",@"text/xml",@"text/plain",@"application/json",@"text/html",nil];
    mgr.responseSerializer = responseSerializer;
    [mgr GET:urlStr parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *resultDict = [responseObject objectFromJSONData];
        NSLog(@"请求成功---%@", resultDict);
        [self getfileInfo:fileSize fileName:fileName token:[resultDict objectForKey:@"token"] timeStamp:timestamp];
        //[self uploadNetWorkWithParam:[resultDict objectForKey:@"token"] fileName:fileName fileSize:fileSize];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"请求失败---%@", error);
    }];
}
- (void)getfileInfo:(NSString *)fileSize fileName:(NSString*)fileName token:(NSString *)token timeStamp:(NSString *)timeStamp{
    NSString *urlStr = [NSString stringWithFormat:@"http://192.168.2.55:8080/videoupload/upload?token=%@&client=html5&name=%@&size=%@&timestamp=%@",token,fileName,fileSize,timeStamp];
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
    responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/xml",@"text/xml",@"text/plain",@"application/json",@"text/html",nil];
    mgr.responseSerializer = responseSerializer;
    [mgr GET:urlStr parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *resultDict = [responseObject objectFromJSONData];
        NSLog(@"请求成功---%@", resultDict);
        [self uploadNetWorkWithParam:token fileName:fileName fileSize:fileSize];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"请求失败---%@", error);
    }];
}
@end
