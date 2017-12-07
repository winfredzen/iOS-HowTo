//
//  ListViewController.m
//  stretchableheader
//
//  Created by wangzhen on 2017/12/6.
//  Copyright © 2017年 wz. All rights reserved.
//

#import "ListViewController.h"
#import "WZCustomNavBar.h"

@interface ListViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    WZCustomNavBar *navBar;
    UIImageView *bgView;
    CGRect originalFrame;
}


@end

@implementation ListViewController


static const CGFloat headHeight = 160.0f;
static const CGFloat ratio = 0.8f;
#define SCREENSIZE [UIScreen mainScreen].bounds.size
#define GREENCOLOR [UIColor colorWithRed:87/255.0 green:173/255.0 blue:104/255.0 alpha:1]

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"可拉伸Header";
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //背景
    bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetWidth(self.view.frame)*ratio)];
    bgView.image = [UIImage imageNamed:@"header"];
    originalFrame = bgView.frame;
    [self.view addSubview:bgView];
    
    //导航条
    navBar = [[WZCustomNavBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 64)];
    [self.view addSubview:navBar];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64.0f, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - 64.0f) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    //背景设置为无颜色
    tableView.backgroundColor = [UIColor clearColor];
    tableView.showsVerticalScrollIndicator = NO;
    
    //第一种方式
    //tableView.contentInset = UIEdgeInsetsMake(headHeight, 0, 0, 0);
    
    
    //第二种方式
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), headHeight)];
    headView.backgroundColor = [UIColor clearColor];
    tableView.tableHeaderView = headView;
    
    
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    
    [self.view addSubview:tableView];
    
}



- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"bounds %@, offset %@", NSStringFromCGRect(scrollView.bounds), NSStringFromCGPoint(scrollView.contentOffset));
    
    CGFloat yOffset = scrollView.contentOffset.y;
    if (yOffset < headHeight) {
        
        //不使用navBar的alpha属性，是因为alpha会对子view也有影响
        CGFloat colorAlpha =  yOffset / headHeight;
        navBar.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:colorAlpha];
        
    }else{
        
        navBar.backgroundColor = [UIColor whiteColor];
        
    }
    
    //处理往上移动效果
    if (yOffset > 0) {
        bgView.frame = ({
            CGRect frame = originalFrame;
            frame.origin.y = originalFrame.origin.y - yOffset;
            frame;
        });
    }else{//往下移动
        //处理放大效果
        
        //复合语句
        bgView.frame = ({
           
            CGRect frame = originalFrame;
            frame.size.height = originalFrame.size.height - yOffset;
            frame.size.width = frame.size.height / ratio;
            frame.origin.x = originalFrame.origin.x - (frame.size.width - originalFrame.size.width) / 2;
            
            frame;
            
        });
        
        
    }
    
    
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.textLabel.text = [NSString stringWithFormat:@"%ld", indexPath.row+1];
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
