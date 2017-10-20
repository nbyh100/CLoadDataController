//
//  CAutoScrollView.m
//  CLoadDataController
//
//  Created by 张九州 on 2017/9/11.
//

#import <MJRefresh/MJRefreshNormalHeader.h>
#import <MJRefresh/MJRefreshBackNormalFooter.h>
#import "CAutoScrollView.h"

@interface CEmptyDataView : UIView <CEmptyDataViewProtocol>

@property (nonatomic, strong) UILabel *messageLabel;

@end

@implementation CEmptyDataView

- (instancetype)init
{
    if (self = [super init]) {
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.messageLabel];
    }
    return self;
}

- (void)setMessage:(NSString *)message
{
    self.messageLabel.text = message;
    [self.messageLabel sizeToFit];
}

- (UILabel *)messageLabel
{
    if (!_messageLabel) {
        _messageLabel = [UILabel new];
        _messageLabel.font = [UIFont systemFontOfSize:14];
        _messageLabel.textColor = [UIColor colorWithWhite:0.6 alpha:1];
    }
    return _messageLabel;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.messageLabel.center = CGPointMake(CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(self.bounds) / 2);
}

@end

@interface CAutoScrollView () <CLoadDataControllerDelegate>

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong) CEmptyDataView *emptyDataView;
@property (nonatomic, strong) CLoadDataController *loadDataController;
@property (nonatomic, assign) BOOL *haveMoreData;

@end

@implementation CAutoScrollView

- (void)dealloc
{
    [self.loadDataController cancel];
    self.loadDataController.delegate = nil;
}

- (instancetype)initWithScrollView:(UIScrollView *)scrollView
{
    if (self = [super init]) {
        self.scrollView = scrollView;
        self.pageSize = 10;
        [self.scrollView addSubview:self.emptyDataView];
        [self addSubview:self.scrollView];
        [self addSubview:self.activityIndicatorView];
    }
    return self;
}

#pragma mark - CLoadDataControllerDelegate

- (CLoadDataHandler *)loadData:(CLoadDataCompleteBlock)complete mode:(CLoadDataMode)mode pageNumber:(int)pageNumber
{
    return self.loadData(complete, mode, pageNumber, self.pageSize);
}

- (void)beginLoad:(CLoadDataMode)mode
{
    switch (mode) {
        case CLoadDataModeInit:
        case CLoadDataModeRefresh:
        [self.activityIndicatorView startAnimating];
        break;
    }
}

- (void)loadSuccess:(id)data length:(int)length mode:(CLoadDataMode)mode
{
    self.haveMoreData = length >= self.pageSize;

    switch (mode) {
        case CLoadDataModeLoadMore:
        self.refreshUI(mode, data, YES);
        break;

        default:
        self.emptyDataView.hidden = length > 0;
        self.emptyDataView.message = @"暂无数据";
        self.scrollView.mj_footer.hidden = !self.haveMoreData;
        self.refreshUI(mode, data, NO);
        break;
    }
}

- (void)loadFailed:(NSError *)error mode:(CLoadDataMode)mode
{
    if (!self.loadDataController.loaded) {
        self.emptyDataView.hidden = NO;
        self.emptyDataView.message = @"加载失败";
    }
}

- (void)endLoad:(CLoadDataMode)mode
{
    switch (mode) {
        case CLoadDataModeInit:
        case CLoadDataModeRefresh:
        [self.activityIndicatorView stopAnimating];
        break;

        case CLoadDataModePullRefresh:
        [self.scrollView.mj_header endRefreshing];
        break;

        case CLoadDataModeLoadMore:
        if (self.haveMoreData) {
            [self.scrollView.mj_footer endRefreshing];
        } else {
            [self.scrollView.mj_footer endRefreshingWithNoMoreData];
        }
        break;
    }
}

#pragma mark - Override

- (void)layoutSubviews
{
    self.scrollView.frame = self.bounds;
    self.activityIndicatorView.center = CGPointMake(CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(self.bounds) / 2);
    self.emptyDataView.frame = self.bounds;
}

#pragma mark - Public props

- (void)setPullRefreshEnabled:(BOOL)pullRefreshEnabled
{
    _pullRefreshEnabled = pullRefreshEnabled;
    if (pullRefreshEnabled) {
        __weak CAutoScrollView *wSelf = self;
        self.scrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            __strong CAutoScrollView *sSelf = wSelf;
            [sSelf.loadDataController pullRefresh];
        }];
    } else {
        self.scrollView.mj_header = nil;
    }
}

- (void)setPaginizeEnabled:(BOOL)paginizeEnabled
{
    _paginizeEnabled = paginizeEnabled;
    if (paginizeEnabled) {
        __weak CAutoScrollView *wSelf = self;
        self.scrollView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
            __strong CAutoScrollView *sSelf = wSelf;
            [sSelf.loadDataController loadMore];
        }];
    } else {
        self.scrollView.mj_footer = nil;
    }
}

#pragma mark - Private props

- (UIActivityIndicatorView *)activityIndicatorView
{
    if (!_activityIndicatorView) {
        UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activityIndicatorView.color = [UIColor colorWithWhite:0 alpha:0.6];
        _activityIndicatorView = activityIndicatorView;
    }
    return _activityIndicatorView;
}

- (CEmptyDataView *)emptyDataView
{
    if (!_emptyDataView) {
        CEmptyDataView *emptyDataView = [CEmptyDataView new];
        emptyDataView.hidden = YES;
        emptyDataView.layer.zPosition = 10000;
        _emptyDataView = emptyDataView;
    }
    return _emptyDataView;
}

- (CLoadDataController *)loadDataController
{
    if (!_loadDataController) {
        _loadDataController = [CLoadDataController new];
        _loadDataController.delegate = self;
    }
    return _loadDataController;
}

@end
