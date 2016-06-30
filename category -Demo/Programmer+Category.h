//
//  Programmer+Category.h
//  category -Demo
//
//  Created by 郭彬 on 16/6/30.
//  Copyright © 2016年 walker. All rights reserved.
//

#import "Programmer.h"

@interface Programmer (Category)

@property(nonatomic,copy) NSString *nameWithSetterGetter;           //设置setter/getter方法的属性

@property(nonatomic,copy) NSString *nameWithoutSetterGetter;        //不设置setter/getter方法的属性，注意编译的警告部分

- (void) programCategoryMethod;                                     //分类方法

@end
