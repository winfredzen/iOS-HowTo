//
//  EOCLazyTableView.h
//  TableView懒加载解析
//
//  Created by class on 08/12/2016.
//  Copyright © 2016 八点钟学院. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface EOCLazyTableView : UITableViewController
{
    NSMutableDictionary *imageLoadDict;

}
@property(nonatomic, strong)NSMutableArray *dataArray;
@end
