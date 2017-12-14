//
//  EOCAppRecord.h
//  TableView懒加载解析
//
//  Created by class on 08/12/2016.
//  Copyright © 2016 八点钟学院. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface EOCAppRecord : NSObject

@property(nonatomic, strong)NSString *appName;
@property(nonatomic, strong)NSString *imageUrlString;
@property(nonatomic, strong)NSString *artist;
@property(nonatomic, strong)UIImage *appIcon;


@end
