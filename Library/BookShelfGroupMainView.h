//
//  BookShelfGroupMainView.h
//  ShelfCollectionView
//
//  Created by king.wu on 8/18/16.
//  Copyright © 2016 king.wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "itemData.h"
#import "BookshelfCollectionViewFlowLayout.h"

@interface BookShelfGroupMainView : UIView<BookShelfCollectionViewGestureDelegate>

+ (instancetype)loadFromNib;

- (void)initWithItemData:(ItemData *)itemData groupedItemData:(NSArray<ItemData *> *)groupedItemData snapView:(UIView *)snapView;

@end