//
//  UICollectionView+TMIndexPathCache.h
//  WeGamers
//
//  Created by Xiaobin Lin on 2019/1/8.
//  Copyright © 2019年 TM. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface TMIndexPathSizeCache : NSObject

// Enable automatically if you're using index path driven height cache
@property (nonatomic, assign) BOOL automaticallyInvalidateEnabled;

- (BOOL)existsSizeAtIndexPath:(NSIndexPath *)indexPath;
- (void)cacheSize:(CGSize)size byIndexPath:(NSIndexPath *)indexPath;
- (CGSize)heightForIndexPath:(NSIndexPath *)indexPath;
- (void)invalidateSizeAtIndexPath:(NSIndexPath *)indexPath;
- (void)invalidateAllHeightCache;

@end


@interface UICollectionView(TMIndexPathSizeCache)
/// Height cache by index path. Generally, you don't need to use it directly.
@property (nonatomic, strong, readonly) TMIndexPathSizeCache *tm_indexPathSizeCache;
@end

@interface UICollectionView(TMIndexPathSizeCacheInvalidation)
/// Call this method when you want to reload data but don't want to invalidate
/// all height cache by index path, for example, load more data at the bottom of
/// table view.
- (void)tm_reloadDataWithoutInvalidateIndexPathHeightCache;
@end
