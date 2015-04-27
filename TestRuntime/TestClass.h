//
//  TestClass.h
//  TestRuntime
//
//  Created by malong on 15/4/26.
//  Copyright (c) 2015年 SanFenXian. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

@interface TestClass : NSObject
{
    NSString * varTest1;
    UILabel * varTest2;
    UIImageView * varTest3;

}

@property (nonatomic,copy)NSString * varTest1;
@property (nonatomic,strong)UILabel * varTest2;
@property (nonatomic,strong)UIImageView * varTest3;

- (void)function1;


@end
