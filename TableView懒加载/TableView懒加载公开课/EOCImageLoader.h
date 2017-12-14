//
//  EOCImageLoader.h
//  TableView懒加载公开课
//
//  Created by 八点钟学院 on 2017/5/27.
//  Copyright © 2017年 八点钟学院. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EOCAppRecord.h"

typedef void(^imageLoadCompletion)();
@interface EOCImageLoader : NSObject

@property(nonatomic, strong)EOCAppRecord *appRecord;//图片网址数据
@property(nonatomic, strong)imageLoadCompletion completionBlock;

- (void)startLoadImage;
- (void)cancelLoadImage;


@end
