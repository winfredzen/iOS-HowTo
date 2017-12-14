//
//  EOCLazyTableView.m
//  TableView懒加载解析
//
//  Created by class on 08/12/2016.
//  Copyright © 2016 八点钟学院. All rights reserved.
//

#import "EOCLazyTableView.h"
#import "EOCParseOperation.h"
#import "EOCAppRecord.h"
#import "EOCImageLoader.h"

@interface EOCLazyTableView ()

@end

@implementation EOCLazyTableView

static NSString *const dataUrl = @"http://phobos.apple.com/WebObjects/MZStoreServices.woa/ws/RSS/toppaidapplications/limit=100/xml";


- (void)viewDidLoad {
   
    [super viewDidLoad];
    
    //保存正在运行的网络加载
    imageLoadDict = [NSMutableDictionary dictionary];
    
    self.navigationItem.title = @"八点钟学院";
    self.tableView.rowHeight = 64.0f;
    
    [self getNetWorkData];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    //获取当前正在运行的网络线程对象
    NSArray *currentImageLoaders = imageLoadDict.allValues;  //imageLoader
    [currentImageLoaders makeObjectsPerformSelector:@selector(cancelLoadImage)];
    
}

- (void)getNetWorkData {
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:dataUrl]];
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if (error) {
            
            NSLog(@"error!");
            
        } else {
            //current thread 1: <NSThread: 0x600000262380>{number = 3, name = (null)}
            NSLog(@"current thread 1: %@", [NSThread currentThread]);
            
            //顺利获取到网络数据
            EOCParseOperation *parseOperation = [[EOCParseOperation alloc] init];
            parseOperation.data = data;
            
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            [queue addOperation:parseOperation];
            
            //防止循环引用
            __weak typeof(parseOperation) weakParseOperation = parseOperation;
            
            //完成解析
            parseOperation.completionBlock = ^{
                
                //current thread 2: <NSThread: 0x608000465540>{number = 6, name = (null)}
                NSLog(@"current thread 2: %@", [NSThread currentThread]);
                
                _dataArray = weakParseOperation.parseDataArr;
                //线程上面的操作，你在UI上显示，需要回到主线程
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
                
            };
            
        }
        
    }];
    [dataTask resume];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
}

#pragma mark - UITableView delegate && dataSource method
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    EOCAppRecord *appRecord = _dataArray[indexPath.row];
    cell.textLabel.text = appRecord.appName;
    
    if (appRecord.appIcon) {  //有图片的情况
        
        cell.imageView.image = appRecord.appIcon;
        
    } else {   //没有图片的情况
        
        //runloop 两种mode：defaultMode、trackingMode，当我滑动的时候，它会处于trackingMode下，defaultMode下的任务就暂停，直到切换到defaultMode下的时候，才会继续之前的任务
        
        //默认图片
        cell.imageView.image = [UIImage imageNamed:@"Placeholder"];
        
        //也可以使用runloop来实现
//        [self performSelector:@selector(loadCellImage:) withObject:indexPath afterDelay:0.f inModes:@[NSDefaultRunLoopMode]];
        
        //在非拖动和非减速的情况下，加载网络图片
        if (!tableView.dragging && !tableView.decelerating) {
            
            //加载网络图片数据，并赋值给cell.imageView
            [self loadCellImage:indexPath];
            
        }
        
    }
    
    //cell.imageView.image它的大小是跟image的size以及tableVIewcell的高度两者一起决定的
    
    NSLog(@"cell.imageView.size %@", NSStringFromCGSize(cell.imageView.frame.size));
    
    return cell;
    
}

//加载网路图片
- (void)loadCellImage:(NSIndexPath *)indexPath {
    
    EOCAppRecord *appRecord = _dataArray[indexPath.row];
    //先从字典中取
    EOCImageLoader *imageLoader = imageLoadDict[indexPath];
    
    if (!imageLoader) {
        
        imageLoader = [[EOCImageLoader alloc] init];
        imageLoadDict[indexPath] = imageLoader;
        
    }
    
    imageLoader.appRecord = appRecord;
    
    imageLoader.completionBlock = ^{
        
        //把图片赋值给cell，并展示出来
        dispatch_async(dispatch_get_main_queue(), ^{
           
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            cell.imageView.image = appRecord.appIcon;
            
        });
        [imageLoadDict removeObjectForKey:indexPath];
        
    };
    [imageLoader startLoadImage];
    
}

#pragma mark - UIScrollView delegate method
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {//停止时加载
    
    [self loadVisibleCellImages];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    if (decelerate) {  //停止拖动的时候，scrollView有减速动画
        
        
        
    } else {  //停止拖动的时候，scrollView没有减速动画
        
        [self loadVisibleCellImages];
        
    }
    
}

- (void)loadVisibleCellImages {
    
    //获取到当前可见范围内的cell数组，如果说该cell没有图片(appRecord没图片就行了)，网络加载图片数据
    NSArray *visibleCellIndexesArr = [self.tableView indexPathsForVisibleRows];
    for (NSIndexPath *indexPath in visibleCellIndexesArr) {
        
        EOCAppRecord *appRecord = _dataArray[indexPath.row];
        if (!appRecord.appIcon) {
            
            [self loadCellImage:indexPath];
            
        }
    }
    
}

- (void)dealloc {
    
    NSLog(@"tableView dealloc!");
    
}

@end
