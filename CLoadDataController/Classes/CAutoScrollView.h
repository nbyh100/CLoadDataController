//
//  CAutoScrollView.h
//  CLoadDataController
//
//  Created by 张九州 on 2017/9/11.
//

#import <UIKit/UIKit.h>
#import <MJRefresh/MJRefreshHeader.h>
#import <MJRefresh/MJRefreshFooter.h>
#import "CLoadDataController.h"

@protocol CEmptyDataViewProtocol

@required
@property (nonatomic) NSString *message;

@end

@interface CAutoScrollViewOptions : NSObject

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

@interface CAutoScrollView : UIView

@property (nonatomic, strong, readonly) CLoadDataController *loadDataController;
@property (nonatomic, weak, readonly) UIScrollView *scrollView;

- (instancetype)initWithScrollView:(UIScrollView *)scrollView options:(CAutoScrollViewOptions *)options;

@end
