//
//  EOCImageLoader.m
//  TableView懒加载公开课
//
//  Created by 八点钟学院 on 2017/5/27.
//  Copyright © 2017年 八点钟学院. All rights reserved.
//

#import "EOCImageLoader.h"

@interface EOCImageLoader () {
    
    NSURLSessionDataTask *dataTask;
    
}

@end

@implementation EOCImageLoader
static const CGFloat kAppIconSize = 48.f;

//开始加载图片
- (void)startLoadImage {
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.appRecord.imageUrlString]];
    
    dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error) {
            
            NSLog(@"error!");
            
        } else {
            
            //图片赋值
            UIImage *image = [UIImage imageWithData:data];
            
            NSLog(@"image size %@", NSStringFromCGSize(image.size));
            
            //图片重绘
            if (image.size.width != kAppIconSize || image.size.height != kAppIconSize) {
                
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(kAppIconSize, kAppIconSize), YES, 0.f);
                [image drawInRect:CGRectMake(0.f, 0.f, kAppIconSize, kAppIconSize)];
                self.appRecord.appIcon = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
            } else {
            
                self.appRecord.appIcon = image;
                
            }
            
            if (_completionBlock) {
                _completionBlock();
            }
            
        }
        
    }];
    [dataTask resume];
    
}

//取消加载图片
- (void)cancelLoadImage {
    
    [dataTask cancel];
    dataTask = nil;
    
}

@end
