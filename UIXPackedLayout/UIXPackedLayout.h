//
//  UIXPackedLayout.h
//  UIXVerticalPackedLayoutDemo
//
//  Created by Guy Umbright on 8/17/15.
//  Copyright (c) 2015 Umbright Consulting, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    UIXPackedLayoutOrientationHorizontal,
    UIXPackedLayoutOrientationVertical
} UIXPackedLayoutOrientation;

typedef enum
{
    UIXPackedLayoutAlignmentLeft,                                   //V
    UIXPackedLayoutAlignmentTop = UIXPackedLayoutAlignmentLeft,     //H
    UIXPackedLayoutAlignmentCenter,                                 //H & V
    UIXPackedLayoutAlignmentRight,                                  //V
    UIXPackedLayoutAlignmentBottom = UIXPackedLayoutAlignmentRight  //H
} UIXPackedLayoutAlignment;

typedef enum
{
    UIXPackedLayoutJustificationLeft,                                       //H
    UIXPackedLayoutJustificationTop = UIXPackedLayoutJustificationLeft,     //V
    UIXPackedLayoutJustificationCenter,                                     //H&V
    UIXPackedLayoutJustificationRight,                                      //H
    UIXPackedLayoutJustificationBottom = UIXPackedLayoutJustificationRight  //V
} UIXPackedLayoutJustification;

typedef enum
{
    UIXPackedLayoutHeaderJustificationLeft,                                             //H
    UIXPackedLayoutHeaderJustificationTop = UIXPackedLayoutHeaderJustificationLeft,     //V
    UIXPackedLayoutHeaderJustificationCenter,                                           //H&V
    UIXPackedLayoutHeaderJustificationRight,                                            //H
    UIXPackedLayoutHeaderJustificationBottom = UIXPackedLayoutHeaderJustificationRight  //V
} UIXPackedLayoutHeaderJustification;


#define UIXPackedLayoutHeader @"UIXPackedLayoutHeader"

@class UIXPackedLayout;


///////////////////////////////////////////
//
///////////////////////////////////////////
@protocol UIXPackedLayoutDelegate <NSObject>

- (CGSize) UIXPackedLayout: (UIXPackedLayout*) layout sizeForItemAtIndex:(NSIndexPath*) indexPath;

@optional

//return 0,0 for no header
//
//For vert, headers placed after the last item of previous section, using slice spacing and justified based on current
//justification
//Similar for horz, positioned at left edge of section and justified

- (CGSize) UIXPackedLayout: (UIXPackedLayout*) layout sizeOfHeaderForSection:(NSInteger) section;

@end

///////////////////////////////////////////
//
///////////////////////////////////////////
@interface UIXPackedLayout : UICollectionViewLayout
@property (nonatomic, weak) IBOutlet NSObject<UIXPackedLayoutDelegate>* delegate;
@property (nonatomic, assign) UIEdgeInsets sectionInset;

@property (nonatomic, assign) CGFloat cellSpacing;
@property (nonatomic, assign) CGFloat sliceSpacing;
@property (nonatomic, assign) CGFloat minimumSliceWidth;

//@property (nonatomic, assign) BOOL singleSlice;

//@property (nonatomic, assign) BOOL justified; //forces first and last to edges and spreads rest in between
@property (nonatomic, assign) UIXPackedLayoutAlignment alignment;
@property (nonatomic, assign) UIXPackedLayoutJustification justification;
@property (nonatomic, assign) UIXPackedLayoutHeaderJustification headerJustification;

@property (nonatomic, readonly) UIXPackedLayoutOrientation orientation;

- (id) initWithOrientation:(UIXPackedLayoutOrientation) orientation;

@end

