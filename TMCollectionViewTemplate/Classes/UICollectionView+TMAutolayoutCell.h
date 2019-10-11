//
//  UICollectionView+TMAutolayoutCell.h
//  WeGamers
//
//  Created by Xiaobin Lin on 2019/1/8.
//  Copyright © 2019年 TM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UICollectionView+TMIndexPathCache.h"

/**
 自动计算 CollectionViewCell Size
 */
@interface UICollectionView(TMAutolayoutCell)

- (CGSize)tm_heightForCellWithIdentifier:(NSString *)identifier indexPath:(NSIndexPath *)indexPath maxSize:(CGSize)maxSize configuration:(void (^)(id cell))configuration;

@end
