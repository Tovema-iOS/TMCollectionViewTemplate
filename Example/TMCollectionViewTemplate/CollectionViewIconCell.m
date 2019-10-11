//
//  TestSimpleCollectionViewCell.m
//  OCSimpleDemo
//
//  Created by Xiaobin Lin on 2019/1/7.
//  Copyright © 2019年 Felink. All rights reserved.
//

#import "CollectionViewIconCell.h"
#import <Masonry/Masonry.h>

@implementation CollectionViewIconCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor lightGrayColor];
        [self.contentView addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(2, 2, 2, 2));
            make.height.equalTo(@(80));
        }];

        self.contentView.backgroundColor = [UIColor darkGrayColor];
    }
    return self;
}

+ (NSString *)reuseIdentifier
{
    return @"CollectionViewIconCell";
}

+ (CGSize)maxCellSize
{
    return CGSizeMake(80, 300);
}

@end
