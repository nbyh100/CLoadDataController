//
//  CLoadDataController.h
//  Pods
//
//  Created by Jiuzhou Zhang on 2017/9/11.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CLoadDataMode) {
    CLoadDataModeInit, // 首次加载
    CLoadDataModeRefresh, // 手动刷新
    CLoadDataModePullRefresh, // 下拉刷新
    CLoadDataModeLoadMore // 上拉翻页
};

@interface CLoadDataHandler : NSObject

+ (instancetype)handlerWithCancelBlock:(void (^)(void))cancelBlock;

- (void)cancel;

@end

typedef void (^CLoadDataCompleteBlock)(id data, NSError *error, NSInteger length);

@protocol CLoadDataControllerDelegate <NSObject>

@required
- (CLoadDataHandler *)loadData:(CLoadDataCompleteBlock)complete
                          mode:(CLoadDataMode)mode
                    pageNumber:(int)pageNumber;
- (void)beginLoad:(CLoadDataMode)mode;
- (void)endLoad:(CLoadDataMode)mode;
- (void)loadSuccess:(id)data length:(int)length mode:(CLoadDataMode)mode;
- (void)loadFailed:(NSError *)error mode:(CLoadDataMode)mode;

@end

@interface CLoadDataController : NSObject

@property (nonatomic, weak) id<CLoadDataControllerDelegate> delegate;
@property (nonatomic, strong) NSString *cacheKey;
@property (nonatomic, strong) NSString *cacheVersion;
@property (nonatomic, assign, readonly) BOOL loaded;
@property (nonatomic, assign, readonly) BOOL isLoading;

- (void)load;
- (void)pullRefresh;
- (void)loadMore;
- (void)cancel;

@end
