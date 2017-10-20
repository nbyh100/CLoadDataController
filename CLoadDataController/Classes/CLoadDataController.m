//
//  CLoadDataController.m
//  Pods
//
//  Created by Jiuzhou Zhang on 2017/9/11.
//
//

#import "CLoadDataController.h"

@interface CLoadDataHandler ()

@property (nonatomic, strong) void (^cancelBlock)(void);

@end

@implementation CLoadDataHandler

+ (instancetype)handlerWithCancelBlock:(void (^)(void))cancelBlock
{
    return [[self alloc] initWithCancelBlock:cancelBlock];
}

- (instancetype)initWithCancelBlock:(void (^)(void))cancelBlock
{
    if (self = [super init]) {
        self.cancelBlock = cancelBlock;
    }
    return self;
}

- (void)cancel
{
    self.cancelBlock();
}

@end

@interface CLoadDataController ()

@property (nonatomic, assign) BOOL initialized;
@property (nonatomic, assign) BOOL loaded;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, assign) BOOL pageNumber;
@property (nonatomic, strong) CLoadDataHandler *loadDataHandler;

@end

@implementation CLoadDataController

- (instancetype)init
{
    if (self = [super init]) {
        self.initialized = NO;
        self.loaded = NO;
        self.isLoading = NO;
        self.pageNumber = 1;
    }
    return self;
}

- (void)load
{
    [self _load:self.initialized ? CLoadDataModeRefresh : CLoadDataModeInit];
    self.initialized = YES;
}

- (void)pullRefresh
{
    [self _load:CLoadDataModePullRefresh];
}

- (void)loadMore
{
    [self _load:CLoadDataModeLoadMore];
}

- (void)cancel
{
    if (!self.isLoading) {
        return;
    }

    [self.loadDataHandler cancel];
}

- (void)_load:(CLoadDataMode)mode
{
    [self.delegate beginLoad:mode];
    if (self.isLoading) {
        [self.delegate endLoad:mode];
        return;
    }

    self.isLoading = YES;

    self.loadDataHandler = [self.delegate loadData:^(id data, NSError *error, NSInteger length) {
        self.isLoading = NO;
        self.loadDataHandler = nil;

        if (!error) {
            self.loaded = YES;
            self.pageNumber = mode != CLoadDataModeLoadMore ? 1 : self.pageNumber + 1;
            [self.delegate loadSuccess:data length:length mode:mode];
        } else {
            [self.delegate loadFailed:error mode:mode];
        }

        [self.delegate endLoad:mode];
    } mode:mode pageNumber:mode != CLoadDataModeLoadMore ? 1 : self.pageNumber + 1];
}

@end
