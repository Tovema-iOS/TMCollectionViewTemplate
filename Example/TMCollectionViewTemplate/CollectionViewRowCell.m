//
//  CollectionViewRowCell.m
//  TMCollectionViewTemplate_Example
//
//  Created by XiaobinLin on 2019/10/11.
//  Copyright © 2019 lxb_0605@qq.com. All rights reserved.
//

#import "CollectionViewRowCell.h"
#import <Masonry/Masonry.h>

@implementation CollectionViewRowCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor lightGrayColor];
        [self.contentView addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(2, 2, 2, 2));
            make.height.equalTo(@(100));
        }];

        self.contentView.backgroundColor = [UIColor darkGrayColor];
    }
    return self;
}

+ (NSString *)reuseIdentifier
{
    return @"CollectionViewRowCell";
}

+ (CGSize)maxCellSize
{
    CGFloat width = UIScreen.mainScreen.bounds.size.width - 30;
    return CGSizeMake(width, 300);
}

@end
