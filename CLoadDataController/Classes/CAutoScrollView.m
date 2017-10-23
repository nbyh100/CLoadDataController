//
//  CAutoScrollView.m
//  CLoadDataController
//
//  Created by 张九州 on 2017/9/11.
//

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

@implementation CAutoScrollViewOptions

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.pageSize = 10;
        self.emptyText = @"暂无内容";
        self.getErrorText = ^NSString *(NSError *error) {
            return @"加载遇到问题，请稍后重试";
        };
    }
    return self;
}

@end

@interface CAutoScrollView () <CLoadDataControllerDelegate>

@property (nonatomic, strong) CLoadDataController *loadDataController;
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, assign) BOOL *haveMoreData;

@property (nonatomic, strong) MJRefreshHeader* (^getRefreshHeader)(void (^refreshingBlock)(void));
@property (nonatomic, strong) MJRefreshFooter* (^getRefreshFooter)(void (^refreshingBlock)(void));
@property (nonatomic, assign) int pageSize;
@property (nonatomic, strong) NSString *emptyText;
@property (nonatomic, strong) NSString* (^getErrorText)(NSError *error);
@property (nonatomic, strong) UIView<CEmptyDataViewProtocol> *emptyDataView;
@property (nonatomic, strong) CLoadDataHandler* (^loadData)(
    CLoadDataCompleteBlock complete,
    CLoadDataMode mode,
    int pageNumber,
    int pageSize
);
@property (nonatomic, strong) void (^loadSuccess)(CLoadDataMode mode, id data, BOOL isMore);
@property (nonatomic, strong) void (^loadFailed)(CLoadDataMode mode, NSError *error);

@end

@implementation CAutoScrollView

- (void)dealloc
{
    [self.loadDataController cancel];
    self.loadDataController.delegate = nil;
}

- (instancetype)initWithScrollView:(UIScrollView *)scrollView options:(CAutoScrollViewOptions *)options
{
    if (self = [super init]) {
        self.scrollView = scrollView;
        __weak CAutoScrollView *wSelf = self;
        if (options.getRefreshHeader) {
            scrollView.mj_header = options.getRefreshHeader(^{
                __strong CAutoScrollView *sSelf = wSelf;
                [sSelf.loadDataController pullRefresh];
            });
            scrollView.mj_header.hidden = YES;
        }
        if (options.getRefreshFooter) {
            scrollView.mj_footer = options.getRefreshFooter(^{
                __strong CAutoScrollView *sSelf = wSelf;
                [sSelf.loadDataController loadMore];
            });
            scrollView.mj_footer.hidden = YES;
        }
        self.pageSize = options.pageSize;
        self.emptyText = options.emptyText;
        self.getErrorText = options.getErrorText;
        self.emptyDataView = options.emptyDataView;
        self.loadData = options.loadData;
        self.loadSuccess = options.loadSuccess;
        self.loadFailed = options.loadFailed;

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
        if (self.loadSuccess) {
            self.loadSuccess(mode, data, YES);
        }
        break;

        default:
        self.emptyDataView.hidden = length > 0;
        self.emptyDataView.message = self.emptyText;
        if (self.loadSuccess) {
            self.loadSuccess(mode, data, NO);
        }
        break;
    }
}

- (void)loadFailed:(NSError *)error mode:(CLoadDataMode)mode
{
    if (!self.loadDataController.loaded) {
        self.emptyDataView.hidden = NO;
        self.emptyDataView.message = self.getErrorText(error);
    }

    if (self.loadFailed) {
        self.loadFailed(mode, error);
    }
}

- (void)endLoad:(CLoadDataMode)mode
{
    switch (mode) {
        case CLoadDataModeInit:
        case CLoadDataModeRefresh:
        self.scrollView.mj_header.hidden = NO;
        self.scrollView.mj_footer.hidden = !self.haveMoreData;
        [self.activityIndicatorView stopAnimating];
        break;

        case CLoadDataModePullRefresh:
        self.scrollView.mj_footer.hidden = !self.haveMoreData;
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

#pragma mark - Private props

- (CLoadDataController *)loadDataController
{
    if (!_loadDataController) {
        _loadDataController = [CLoadDataController new];
        _loadDataController.delegate = self;
    }
    return _loadDataController;
}

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

@end
