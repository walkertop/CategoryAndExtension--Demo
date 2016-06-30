//
//  Programmer+Category.m
//  category -Demo
//
//  Created by 郭彬 on 16/6/30.
//  Copyright © 2016年 walker. All rights reserved.
//

#import "Programmer+Category.h"
#import <objc/runtime.h>


static NSString *nameWithSetterGetterKey = @"nameWithSetterGetterKey";

@implementation Programmer (Category)


- (void)setNameWithSetterGetter:(NSString *)nameWithSetterGetter {
        objc_setAssociatedObject(self, &nameWithSetterGetterKey, nameWithSetterGetter, OBJC_ASSOCIATION_COPY);
}
- (NSString *)nameWithSetterGetter {
    return objc_getAssociatedObject(self, &nameWithSetterGetterKey);

}

- (void)programCategoryMethod {
    NSLog(@"实现分类方法");
}
@end
