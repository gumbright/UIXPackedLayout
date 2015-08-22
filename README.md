# UIXPackedLayout
UIXPackedLayout is a UICollectionViewLayout that fits as many cells a possible in either horizontal or vertical slices.
  
![UIXPackedLayout demo](https://github.com/gumbright/UIXPackedLayout/blob/master/img/UIXPackedLayout.gif)

UIXPackedLayout is UICollectionView Layout which lays out cells fitting as many as possible in
a row/column maintaining the order of data provided by the datasource.

The layout can be oriented vertically, which lays out colums from left to right, horizontal lays out
rows from top to bottom.  These rows and columns are generically referred to as "slices".

Additionally, there are a number of alignments and justifications that can be applied.

Slice justification can be set to left,center,right for horizontal, or top,center,bottom for vertical. 
For each slice, cells will be shifted according to the justification, center evenly distributes cells
across the available width/height.

Header justification is also available.  It is independent of slice justification but operates in the
same way.

Cells can be variably sized. Slices are sized based upon the largest cell (in the dimension appropriate
to the orientation).  Cells can then be aligned (for the whole UICollectionView) within the slice to left,
center,right for vertical or top,center,bottom for horizontal.
