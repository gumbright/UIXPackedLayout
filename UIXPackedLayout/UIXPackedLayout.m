//
//  UIXPackedLayout.m
//  UIXVerticalPackedLayoutDemo
//
//  Created by Guy Umbright on 8/17/15.
//  Copyright (c) 2015 Umbright Consulting, Inc. All rights reserved.
//

#import "UIXPackedLayout.h"

@interface UIXPackedLayout ()
@property (nonatomic, assign) UIXPackedLayoutOrientation orientation;

@property (nonatomic, strong) NSArray* layoutData;
@property (nonatomic, strong) NSArray* headerData;

@property (nonatomic, assign) CGFloat maxSliceLength;
@property (nonatomic, assign) CGSize layoutContentSize;
@end

@implementation UIXPackedLayout

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (void) commonInit
{
    self.alignment = UIXPackedLayoutAlignmentLeft;
    self.justification = UIXPackedLayoutJustificationLeft;
    self.headerJustification = UIXPackedLayoutHeaderJustificationLeft;
    self.sectionInset = UIEdgeInsetsZero;
    self.layoutData = nil;
    self.headerData = nil;
}

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (id) init
{
    if (self = [super init])
    {
        self.orientation = UIXPackedLayoutOrientationVertical;
        [self commonInit];
    }
    
    return self;
}

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (id) initWithOrientation:(UIXPackedLayoutOrientation) orientation
{
    if (self = [super init])
    {
        self.orientation = orientation;
        [self commonInit];
    }
    
    return self;
}

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (void) awakeFromNib
{
    [self commonInit];
}

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (CGSize) collectionViewContentSize
{
    return self.layoutContentSize;
}

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (BOOL) shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (NSArray*) layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray* result = [NSMutableArray array];
    
    for (int sectionNdx=0; sectionNdx < self.layoutData.count; ++sectionNdx)
    {
        NSArray* itemArr = self.layoutData[sectionNdx];
        for (int itemNdx=0; itemNdx < itemArr.count; ++itemNdx)
        {
            UICollectionViewLayoutAttributes* attr = itemArr[itemNdx];
            CGRect intersect = CGRectIntersection(rect, attr.frame);
            if (!CGRectIsEmpty(intersect))
            {
                [result addObject:attr];
            }
        }
    }
    
    for (UICollectionViewLayoutAttributes* attr in self.headerData)
    {
        CGRect intersect = CGRectIntersection(rect, attr.frame);
        if (!CGRectIsEmpty(intersect))
        {
            [result addObject:attr];
        }
    }
    return result;
}

/////////////////////////////////////////////////////
//
////////////////////////////////////////////////////
- (UICollectionViewLayoutAttributes*) layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray* arr = self.layoutData[indexPath.section];
    return arr[indexPath.item];
}

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (void) prepareLayout
{
    switch (self.orientation)
    {
        case UIXPackedLayoutOrientationHorizontal:
        {
            [self prepareHorizontalLayout];
        }
            break;
            
        case UIXPackedLayoutOrientationVertical:
        {
            [self prepareVerticalLayout];
        }
            break;
    }
}

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (void) prepareHorizontalLayout
{
    [super prepareLayout];

    CGFloat currentX, currentY;
    NSUInteger numSections;
    NSUInteger numItems;
    NSMutableArray* sectionData;
    
    currentX = self.sectionInset.left;
    currentY = self.sectionInset.top;
    self.maxSliceLength = self.collectionView.bounds.size.width - (self.sectionInset.left + self.sectionInset.right);
    NSMutableArray* currentRow = [NSMutableArray array];
    
    numSections = [self.collectionView.dataSource numberOfSectionsInCollectionView:self.collectionView];
    sectionData = [NSMutableArray arrayWithCapacity:numSections];

    //for each section
    for (int sectionNdx=0; sectionNdx < numSections; ++sectionNdx)
    {
        currentX = self.sectionInset.left;
        
        numItems = [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:sectionNdx];
        
        //allocate container for section items
        NSMutableArray* itemData = [NSMutableArray arrayWithCapacity:numItems];
        
        //header
        if ([self.delegate respondsToSelector:@selector(UIXPackedLayout:sizeOfHeaderForSection:)])
        {
            CGSize headerSize = [self.delegate UIXPackedLayout:self sizeOfHeaderForSection:sectionNdx];
            CGRect frame;
            
            if (headerSize.height > 0 && headerSize.width > 0)
            {
                switch (self.headerJustification)
                {
                    case UIXPackedLayoutHeaderJustificationLeft:
                    {
                        frame = CGRectMake(self.sectionInset.left, currentY, headerSize.width, headerSize.height);
                    }
                        break;
                        
                    case UIXPackedLayoutHeaderJustificationCenter:
                    {
                        CGFloat x = (self.collectionView.bounds.size.width - (self.sectionInset.right + self.sectionInset.left + headerSize.width))/2.0;
                        frame = CGRectMake(self.sectionInset.left + x, currentY, headerSize.width, headerSize.height);
                    }
                        break;
                        
                    case UIXPackedLayoutHeaderJustificationRight:
                    {
                        CGFloat x = self.collectionView.bounds.size.width - self.sectionInset.right - headerSize.width;
                        frame = CGRectMake(x, currentY, headerSize.width, headerSize.height);
                    }
                        break;
                }
                
                //CGRect frame = CGRectMake(self.sectionInset.left, currentY, headerSize.width, headerSize.height);
                UICollectionViewLayoutAttributes* attr = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UIXPackedLayoutHeader withIndexPath:[NSIndexPath indexPathWithIndex:sectionNdx]];
                attr.frame = frame;
                currentY = currentY + frame.size.height + self.sliceSpacing;
                [itemData addObject:attr];
            }
        }

        for (int itemNdx = 0; itemNdx < numItems; ++itemNdx)
        {
            CGSize sz = [self.delegate UIXPackedLayout: self sizeForItemAtIndex:[NSIndexPath indexPathForItem:itemNdx inSection:sectionNdx]];
            
            //if not single slice and current slice is full
            if (currentX + sz.width > self.maxSliceLength)
            {
                currentX = self.sectionInset.left;
                
                CGFloat sliceHeight= [self postProcessHorizontalSlice:currentRow];
                currentY+= (sliceHeight + self.sliceSpacing);

                [itemData addObjectsFromArray:currentRow];
                currentRow = [NSMutableArray array];
            }
            
            //if an item does not fit after advancing the column, just let it hang off the bottom
            UICollectionViewLayoutAttributes* attr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForItem:itemNdx inSection:sectionNdx]];
            CGRect frame = CGRectMake(currentX, currentY, sz.width, sz.height);
            attr.frame = frame;
            [currentRow addObject:attr];
            
            currentX += (sz.width + self.cellSpacing);
        }
        
        //clean up any remaining
        if (currentRow.count > 0)
        {
            CGFloat sliceHeight= [self postProcessHorizontalSlice:currentRow];
            
            currentY += (sliceHeight + self.sliceSpacing);
            [itemData addObjectsFromArray:currentRow];
        }
        
        [sectionData addObject:itemData];
        
//        currentX = self.sectionInset.left;
////        if (self.justified)
////        {
////            [self justifyHorizontal:currentRow];
////        }
//        currentRow = [NSMutableArray array];
    }
    
    self.layoutData = sectionData;
    self.layoutContentSize = CGSizeMake(self.collectionView.bounds.size.width,currentY-self.sliceSpacing + self.sectionInset.bottom);
}

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (CGFloat) postProcessHorizontalSlice:(NSArray*) slice
{
//    if (self.justified)
//    {
//        [self justifyVertical:slice];
//    }
    
    __block CGFloat sliceHeight = 0;
    [slice enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         UICollectionViewLayoutAttributes* attr = obj;
         CGFloat h = attr.frame.size.height;
         sliceHeight = MAX(sliceHeight, MAX(h, self.minimumSliceWidth));
     }];
    
    [self justifyHorizontal:slice];
    
    switch (self.alignment)
    {
        case UIXPackedLayoutAlignmentCenter:
        {
            [self horizontalCenterAlignSlice:slice ofHeight:sliceHeight];
        }
            break;
            
        case UIXPackedLayoutAlignmentBottom:
        {
            [self bottomAlignSlice:slice ofHeight:sliceHeight];
        }
            break;
    }
    //align items in slice
    return sliceHeight;
}

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (void) horizontalCenterAlignSlice:(NSArray*) slice ofHeight:(CGFloat) sliceHeight
{
    [slice enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         UICollectionViewLayoutAttributes* attr = obj;
         CGRect frame = attr.frame;
         frame.origin.y = frame.origin.y + ((sliceHeight - frame.size.height)/2);
         attr.frame = frame;
     }];
}

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (void) bottomAlignSlice:(NSArray*) slice ofHeight:(CGFloat) sliceHeight
{
    [slice enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         UICollectionViewLayoutAttributes* attr = obj;
         CGRect frame = attr.frame;
         frame.origin.y = frame.origin.y + (sliceHeight - frame.size.height);
         attr.frame = frame;
     }];
    
}

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (void) justifyHorizontal:(NSArray*) currentRow
{
    switch (self.justification)
    {
        case UIXPackedLayoutJustificationCenter:
            {
                [self centerJustifyHorizontalSlice:currentRow];
            }
            break;
            
        case UIXPackedLayoutJustificationRight:
        {
            [self rightJustifyHorizontalSlice:currentRow];
        }
            break;
            
    }
    //if item = 1, stick it to top
}

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (void) centerJustifyHorizontalSlice:(NSArray*) slice
{
    if (slice.count > 1)
    {
        CGFloat totalWidth = 0;
        
        for (UICollectionViewLayoutAttributes* attr in slice)
        {
            totalWidth += attr.frame.size.width;
        }
        
        CGFloat totalPad = self.maxSliceLength - totalWidth;
        CGFloat itemPad = totalPad / (slice.count - 1);
        
        UICollectionViewLayoutAttributes* attr0 = slice[0];
        CGFloat currentX = CGRectGetMaxX(attr0.frame) + itemPad;
        
        for (UICollectionViewLayoutAttributes* attr in slice)
        {
            if (attr != slice[0])
            {
                CGRect frame = attr.frame;
                frame.origin.x = currentX;
                attr.frame = frame;
                
                currentX = CGRectGetMaxX(frame)+itemPad;
            }
        }
    }
}

/////////////////////////////////////////////////////
// kinda seems this should just be done in the prepare, but
// no matter what, need to figure out contents of the slice and
// going forward is easiser, so pay the price here on
// what I am assuming the less used option
/////////////////////////////////////////////////////
- (void) rightJustifyHorizontalSlice:(NSArray*) slice
{
    CGFloat currentX = self.collectionView.bounds.size.width - self.sectionInset.right;
    NSEnumerator* enumerator = [slice reverseObjectEnumerator];
    UICollectionViewLayoutAttributes* attr;
    
    while (attr = [enumerator nextObject])
    {
        CGRect frame = attr.frame;
        frame.origin.x = currentX - frame.size.width;
        attr.frame = frame;
        currentX = attr.frame.origin.x - self.cellSpacing;
    }
}

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (void) prepareVerticalLayout
{
    [super prepareLayout];
    
    CGFloat currentX, currentY;
    NSUInteger numSections;
    NSUInteger numItems;
    NSMutableArray* sectionData;
    
    currentX = self.sectionInset.left;
    currentY = self.sectionInset.top;
    self.maxSliceLength = self.collectionView.bounds.size.height - (self.sectionInset.top + self.sectionInset.bottom);
    NSMutableArray* currentColumn = [NSMutableArray array];
    
    numSections = [self.collectionView.dataSource numberOfSectionsInCollectionView:self.collectionView];
    sectionData = [NSMutableArray arrayWithCapacity:numSections];
    
    //for each section
    for (int sectionNdx=0; sectionNdx < numSections; ++sectionNdx)
    {
        currentY = self.sectionInset.top;
        
        //get # items for section
        numItems = [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:sectionNdx];
        
        //allocate container for section items
        NSMutableArray* itemData = [NSMutableArray arrayWithCapacity:numItems];
        
        //header
        if ([self.delegate respondsToSelector:@selector(UIXPackedLayout:sizeOfHeaderForSection:)])
        {
            CGRect frame;
            CGSize headerSize = [self.delegate UIXPackedLayout:self sizeOfHeaderForSection:sectionNdx];
            if (headerSize.height > 0 && headerSize.width > 0)
            {
                switch (self.headerJustification)
                {
                    case UIXPackedLayoutHeaderJustificationTop:
                    {
                        frame = CGRectMake(currentX, self.sectionInset.top, headerSize.width, headerSize.height);
                    }
                        break;
                        
                    case UIXPackedLayoutHeaderJustificationCenter:
                    {
                        CGFloat y = (self.collectionView.bounds.size.height - (self.sectionInset.top + self.sectionInset.bottom + headerSize.height))/2.0;
                        frame = CGRectMake(currentX, self.sectionInset.top + y, headerSize.width, headerSize.height);
                    }
                        break;
                        
                    case UIXPackedLayoutHeaderJustificationBottom:
                    {
                        CGFloat y = self.collectionView.bounds.size.height - self.sectionInset.bottom - headerSize.height;
                        frame = CGRectMake(currentX, y, headerSize.width, headerSize.height);
                    }
                        break;
                }
                
                //CGRect frame = CGRectMake(currentX, self.sectionInset.top, headerSize.width, headerSize.height);
                UICollectionViewLayoutAttributes* attr = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UIXPackedLayoutHeader withIndexPath:[NSIndexPath indexPathWithIndex:sectionNdx]];
                attr.frame = frame;
                currentX = currentX + frame.size.width + self.sliceSpacing;
                [itemData addObject:attr];
            }
        }
        
        
        //for each item in section
        for (int itemNdx = 0; itemNdx < numItems; ++itemNdx)
        {
            //get item size
            CGSize sz = [self.delegate UIXPackedLayout: self sizeForItemAtIndex:[NSIndexPath indexPathForItem:itemNdx inSection:sectionNdx]];
            
            //if not single slice and current slice is full
            if (currentY + sz.height > self.maxSliceLength)
            {
                //reset current Y
                currentY = self.sectionInset.top;
                
                //justify if needed
                CGFloat sliceWidth = [self postProcessVerticalSlice:currentColumn];
                
                //figure x of next slice
                currentX += (sliceWidth + self.sliceSpacing);   
                
                [itemData addObjectsFromArray:currentColumn];
                currentColumn = [NSMutableArray array];
            }
            
            //if an item does not fit after advancing the column, just let it hang off the bottom
            UICollectionViewLayoutAttributes* attr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForItem:itemNdx inSection:sectionNdx]];
            CGRect frame = CGRectMake(currentX, currentY, sz.width, sz.height);
            attr.frame = frame;
            
            [currentColumn addObject:attr];
            
            //advance Y
            currentY += (sz.height + self.cellSpacing);
        }
        
        //handle anything in the last slice
        if (currentColumn.count > 0)
        {
            CGFloat sliceWidth = [self postProcessVerticalSlice:currentColumn];
            currentX += (sliceWidth + self.sliceSpacing);
            
            [itemData addObjectsFromArray:currentColumn];
        }
        
        [sectionData addObject:itemData];
    }
    
    self.layoutData = sectionData;
    
    self.layoutContentSize = CGSizeMake(currentX-self.sliceSpacing + self.sectionInset.right, self.collectionView.bounds.size.height);

}

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (CGFloat) postProcessVerticalSlice:(NSArray*) slice
{
//    if (self.justified)
//    {
//        [self justifyVertical:slice];
//    }
    
    __block CGFloat sliceWidth = 0;
    [slice enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        UICollectionViewLayoutAttributes* attr = obj;
        CGFloat w = attr.frame.size.width;
        sliceWidth = MAX(sliceWidth, MAX(w, self.minimumSliceWidth));
    }];
    
    [self justifyVertical:slice];
    
    switch (self.alignment)
    {
        case UIXPackedLayoutAlignmentCenter:
        {
            [self verticalCenterAlignSlice:slice ofWidth:sliceWidth];
        }
            break;
            
        case UIXPackedLayoutAlignmentRight:
        {
            [self rightAlignSlice:slice ofWidth:sliceWidth];
        }
            break;
    }
    //align items in slice
    return sliceWidth;
}

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (void) verticalCenterAlignSlice:(NSArray*) slice ofWidth:(CGFloat) sliceWidth
{
    [slice enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         UICollectionViewLayoutAttributes* attr = obj;
         CGRect frame = attr.frame;
         frame.origin.x = frame.origin.x + ((sliceWidth - frame.size.width)/2);
         attr.frame = frame;
     }];
}

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (void) rightAlignSlice:(NSArray*) slice ofWidth:(CGFloat) sliceWidth
{
    [slice enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         UICollectionViewLayoutAttributes* attr = obj;
         CGRect frame = attr.frame;
         frame.origin.x = frame.origin.x + (sliceWidth - frame.size.width);
         attr.frame = frame;
     }];
    
}

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (void) justifyVertical:(NSArray*) slice
{
    switch (self.justification)
    {
        case UIXPackedLayoutJustificationCenter:
        {
            [self centerJustifyVerticalSlice:slice];
        }
            break;
            
        case UIXPackedLayoutJustificationBottom:
        {
            [self bottomJustifyVerticalSlice:slice];
        }
            break;
            
    }
}

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (void) centerJustifyVerticalSlice:(NSArray*) slice
{
    //if item = 1, stick it to top
    if (slice.count > 1)
    {
        CGFloat totalHeight = 0;
        
        for (UICollectionViewLayoutAttributes* attr in slice)
        {
            totalHeight += attr.frame.size.height;
        }
        
        CGFloat totalPad = self.maxSliceLength - totalHeight;
        CGFloat itemPad = totalPad / (slice.count - 1);
        
        UICollectionViewLayoutAttributes* attr0 = slice[0];
        CGFloat currentY = CGRectGetMaxY(attr0.frame) + itemPad;
        
        for (UICollectionViewLayoutAttributes* attr in slice)
        {
            if (attr != slice[0])
            {
                CGRect frame = attr.frame;
                frame.origin.y = currentY;
                attr.frame = frame;
                
                currentY = CGRectGetMaxY(frame)+itemPad;
            }
        }
    }
}

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (void) bottomJustifyVerticalSlice:(NSArray*) slice
{
    CGFloat currentY = self.collectionView.bounds.size.height - self.sectionInset.bottom;
    NSEnumerator* enumerator = [slice reverseObjectEnumerator];
    UICollectionViewLayoutAttributes* attr;
    
    while (attr = [enumerator nextObject])
    {
        CGRect frame = attr.frame;
        frame.origin.y = currentY - frame.size.height;
        attr.frame = frame;
        currentY = attr.frame.origin.y - self.cellSpacing;
    }
}

@end
