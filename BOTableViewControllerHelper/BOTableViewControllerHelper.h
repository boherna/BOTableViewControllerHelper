//
//  BOTableViewControllerHelper.h
//
//  Created by Bohdan Hernandez Navia on 05/10/10.
//  Copyright (c) 2010-2012 Bohdan Hernandez Navia. All rights reserved.
//

#import <Foundation/Foundation.h>

enum
{
	kSelectable = (1 << 1),
	kRightView = (1 << 2),
	kAccessoryDisclosureIndicator = (1 << 3),
	kAccessoryDetailDisclosureButton = (1 << 4),
	kAccessoryCheckmark = (1 << 5),
	kTextAlignmentCenter = (1 << 6),
	kTextAlignmentRight = (1 << 7),
	kButton = (1 << 8),
	kMultiLineLabel = (1 << 9),
	kMultiLineDetailLabel = (1 << 10),
	kDisabled = (1 << 11),
	kImageWithShadow = (1 << 12),
	kEditable = (1 << 13),
	kMovable = (1 << 14)
};
typedef NSUInteger TableViewCellFlags;

// Section keys
#define kEditingSectionHeaderTitleKey @"EditingSectionHeaderTitle"
#define kEditingSectionFooterTitleKey @"EditingSectionFooterTitle"
#define kSectionHeaderTitleKey @"SectionHeaderTitle"
#define kSectionHeaderHeightKey @"SectionHeaderHeight"
#define kSectionFooterTitleKey @"SectionFooterTitle"
#define kSectionFooterHeightKey @"SectionFooterHeight"
#define kSectionFooterViewKey @"SectionFooterView"

// Row keys
#define kRowsArrayKey @"RowsArray"
#define kRowCellStyleKey @"RowCellStyle"
#define kRowHeightKey @"RowHeight"
#define kRowFlagsKey @"RowFlags"
#define kRowImageKey @"RowImage"
#define kRowBackgroundColorKey @"RowBackgroundColor"
#define kRowLabelKey @"RowLabel"
#define kRowLabelFontKey @"RowLabelFont"
#define kRowLabelTextColorKey @"RowLabelTextColor"
#define kRowLabelLineBreakModeKey @"RowLabelLineBreakMode"
#define kRowDetailLabelKey @"RowDetailLabel"
#define kRowDetailLabelFontKey @"RowDetailLabelFont"
#define kRowDetailLabelTextColorKey @"RowDetailLabelTextColor"
#define kRowDetailLabelLineBreakModeKey @"RowDetailLabelLineBreakMode"
#define kRowRightViewKey @"RowRightView"
#define kRowRightViewWidthKey @"RowRightViewWidth"
#define kRowRightViewHeightKey @"RowRightViewHeight"
#define kRowRightViewIndentationKey @"RowRightViewIndentation"
#define kRowButtonBackgroundNormalKey @"RowButtonBackgroundNormal"
#define kRowButtonBackgroundHighlightedKey @"RowButtonBackgroundHighlighted"
#define kRowViewControllerNibNameKey @"RowViewControllerNibName"
#define kRowSelectorNameKey @"RowSelectorName"
#define kRowUserInfoKey @"RowUserInfo"

// For removing embedded views at cell recycling time
#define kRowRightViewTag 1
#define kRowTextLabelTag 2
#define kRowButtonTag 3

@protocol BOTableViewControllerHelperDelegate;

@interface BOTableViewControllerHelper : NSObject <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) NSMutableArray * dataSource;
@property (nonatomic, assign) id<BOTableViewControllerHelperDelegate> delegate;
@property (nonatomic, assign) BOOL variableRowHeight; // YES when using multi-line text in rows

+ (id)dataSourceWithArray:(NSMutableArray *)array;
- (NSInteger)numberOfSections;
- (NSInteger)numberOfRowsInSection:(NSInteger)section;
- (NSMutableArray *)rowsArrayForSection:(NSInteger)section;
- (NSMutableDictionary *)dictionaryForSection:(NSInteger)section;
- (NSMutableDictionary *)dictionaryForRowAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)rowSelectableAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)rowEditableAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)rowMovableAtIndexPath:(NSIndexPath *)indexPath;

@end

@protocol BOTableViewControllerHelperDelegate <UITableViewDelegate>
@optional

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section;
- (UIImage *)tableView:(UITableView *)tableView imageForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSString *)tableView:(UITableView *)tableView textForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSString *)tableView:(UITableView *)tableView detailTextForRowAtIndexPath:(NSIndexPath *)indexPath;

@end
