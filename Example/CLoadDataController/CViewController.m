//
//  CViewController.m
//  CLoadDataController
//
//  Created by nbyh100@sina.com on 09/11/2017.
//  Copyright (c) 2017 nbyh100@sina.com. All rights reserved.
//

#import "CViewController.h"
#import <PromiseKit/PromiseKit.h>
#import <MJRefresh/MJRefreshNormalHeader.h>
#import <MJRefresh/MJRefreshBackNormalFooter.h>
#import <CLoadDataController/CAutoScrollView.h>

@interface CViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) CAutoScrollView *autoScrollView;
@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation CViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    UITableView *tableView = [UITableView new];
    tableView.delegate = self;
    tableView.dataSource = self;
    CAutoScrollViewOptions *options = [CAutoScrollViewOptions new];
    options.getRefreshHeader = ^MJRefreshHeader *(void (^refreshingBlock)(void)) {
        return [MJRefreshNormalHeader headerWithRefreshingBlock:refreshingBlock];
    };
    options.getRefreshFooter = ^MJRefreshFooter *(void (^refreshingBlock)(void)) {
        return [MJRefreshBackStateFooter footerWithRefreshingBlock:refreshingBlock];
    };
    options.loadData = ^CLoadDataHandler *(CLoadDataCompleteBlock complete, CLoadDataMode mode, int pageNumber, int pageSize) {
        __block BOOL canceled = NO;
        PMKPromise *promise = [PMKPromise new:^(PMKFulfiller fulfill, PMKRejecter reject) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (!canceled) {
                    fulfill(@[
                              @"one",
                              @"two",
                              @"three",
                              @"four",
                              @"five",
                              @"six",
                              @"seven",
                              @"eight",
                              @"nine",
                              @"ten"
                              ]);
                } else {
                    reject([NSError errorWithDomain:@"HO~~HO~~" code:0 userInfo:nil]);
                }
            });
        }];
        promise.then(^(id data) {
            complete(data, nil, [(NSArray *)data count]);
        }).catch(^(NSError *error) {
            complete(nil, error, 0);
        });
        return [CLoadDataHandler handlerWithCancelBlock:^{
            canceled = YES;
        }];
    };
    options.loadSuccess = ^(CLoadDataMode mode, id data, BOOL isMore) {
        if (!isMore) {
            self.dataSource = data;
        } else {
            self.dataSource = [self.dataSource arrayByAddingObjectsFromArray:data];
        }
        [(UITableView *)self.autoScrollView.scrollView reloadData];
    };
    CAutoScrollView *autoScrollView = [[CAutoScrollView alloc] initWithScrollView:tableView options:options];
    [self.view addSubview:autoScrollView];
    self.autoScrollView = autoScrollView;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.autoScrollView.frame = self.view.bounds;
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.autoScrollView.loadDataController load];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource ? self.dataSource.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    cell.textLabel.text = self.dataSource[indexPath.row];
    return cell;
}

@end
