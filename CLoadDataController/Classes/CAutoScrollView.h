//
//  CAutoScrollView.h
//  CLoadDataController
//
//  Created by 张九州 on 2017/9/11.
//

#import <UIKit/UIKit.h>
#import "CLoadDataController.h"

@protocol CEmptyDataViewProtocol

@required
@property (nonatomic) NSString *message;

@end

@interface CAutoScrollView : UIView

@property (nonatomic, strong, readonly) CLoadDataController *loadDataController;
@property (nonatomic, weak, readonly) UIScrollView *scrollView;

@property (nonatomic, assign) BOOL pullRefreshEnabled;
@property (nonatomic, assign) BOOL paginizeEnabled;
@property (nonatomic, assign) int pageSize;
@property (nonatomic, strong) CLoadDataHandler* (^loadData)(CLoadDataCompleteBlock complete, CLoadDataMode mode, int pageNumber, int pageSize);
@property (nonatomic, strong) void (^refreshUI)(CLoadDataMode mode, id data, BOOL isMore);

- (instancetype)initWithScrollView:(UIScrollView *)scrollView;

@end
