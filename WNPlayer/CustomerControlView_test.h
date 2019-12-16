//
//  CustomerControlView_test.h
//  WNPlayer
//
//  Created by apple on 2019/11/19.
//  Copyright © 2019 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WNControlViewProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface CustomerControlView_test : UIView<WNControlViewProtocol>
@property (nonatomic,strong) UIImageView *coverImageView;// 播放器默认背景

@end

NS_ASSUME_NONNULL_END
