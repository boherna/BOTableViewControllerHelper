//
//  BOTableViewControllerHelper.h
//
//  Created by Bohdan Hernandez Navia on 05/10/10.
//  Copyright (c) 2010-2012 Bohdan Hernandez Navia. All rights reserved.
//
//  Get the latest version of BOTableViewControllerHelper from:
//
//  https://github.com/boherna/BOTableViewControllerHelper
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software
//  and associated documentation files (the "Software"), to deal in the Software without restriction,
//  including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial
//  portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
//  LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//  SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import <Foundation/Foundation.h>

enum
{
	kSelectable = (1 << 1),
	kRightView = (1 << 2),
	kAccessoryDisclosureIndicator = (1 << 3),
	kAccessoryDetailDisclosureButton = (1 << 4),
	kAccessoryCheckmark = (1 << 5),
	kButton = (1 << 6),
	kMultiLineLabel = (1 << 7),
	kMultiLineDetailLabel = (1 << 8),
	kDisabled = (1 << 9),
	kImageWithShadow = (1 << 10),
	kEditable = (1 << 11),
	kMovable = (1 << 12),
	kMovableInItsSection = (1 << 13)
};
typedef NSUInteger TableViewCellFlags;

typedef void (^RowBlock)(NSIndexPath *, id);

// Section keys
extern NSString * const kEditingSectionHeaderTitleKey;
extern NSString * const kEditingSectionFooterTitleKey;
extern NSString * const kSectionHeaderTitleKey;
extern NSString * const kSectionHeaderHeightKey;
extern NSString * const kSectionFooterTitleKey;
extern NSString * const kSectionFooterHeightKey;
extern NSString * const kSectionFooterViewKey;

// Row keys
extern NSString * const kRowsArrayKey;
extern NSString * const kRowCellStyleKey;
extern NSString * const kRowCellNibNameKey;
extern NSString * const kRowCellClassNameKey;
extern NSString * const kRowCellReuseIdentifierKey;
extern NSString * const kRowHeightKey;
extern NSString * const kRowFlagsKey;
extern NSString * const kRowImageKey;
extern NSString * const kRowBackgroundColorKey;
extern NSString * const kRowLabelKey;
extern NSString * const kRowLabelFontKey;
extern NSString * const kRowLabelTextColorKey;
extern NSString * const kRowLabelLineBreakModeKey;
extern NSString * const kRowLabelTextAlignmentKey;
extern NSString * const kRowDetailLabelKey;
extern NSString * const kRowDetailLabelFontKey;
extern NSString * const kRowDetailLabelTextColorKey;
extern NSString * const kRowDetailLabelLineBreakModeKey;
extern NSString * const kRowDetailLabelTextAlignmentKey;
extern NSString * const kRowRightViewKey;
extern NSString * const kRowRightViewWidthKey;
extern NSString * const kRowRightViewHeightKey;
extern NSString * const kRowRightViewIndentationKey;
extern NSString * const kRowButtonBackgroundNormalKey;
extern NSString * const kRowButtonBackgroundHighlightedKey;
extern NSString * const kRowViewControllerNibNameKey;
extern NSString * const kRowSelectorNameKey;
extern NSString * const kRowBlockKey;
extern NSString * const kRowUserInfoKey;

// For removing embedded views at cell recycling time
extern int kRowRightViewTag;
extern int kRowTextLabelTag;
extern int kRowButtonTag;

@protocol BOTableViewControllerHelperDelegate;

@interface BOTableViewControllerHelper : NSObject <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) NSMutableArray * dataSource;
@property (nonatomic, assign) id<BOTableViewControllerHelperDelegate> delegate;
@property (nonatomic, assign) BOOL variableRowHeight;	// YES when using multi-line text in rows
@property (nonatomic, assign) BOOL autoCheckItems;		// YES for auto removing checkmark from previously marked row
@property (nonatomic, assign) BOOL autoDisableItems;	// YES for auto disabling a row when selected

+ (id)dataSourceWithArray:(NSMutableArray *)array;
- (NSInteger)numberOfSections;
- (NSInteger)numberOfRowsInSection:(NSInteger)section;
- (NSMutableArray *)rowsArrayForSection:(NSInteger)section;
- (NSMutableDictionary *)dictionaryForSection:(NSInteger)section;
- (NSMutableDictionary *)dictionaryForRowAtIndexPath:(NSIndexPath *)indexPath;
- (id)objectForRowAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)rowEnabledAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)rowSelectableAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)rowEditableAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)rowMovableAtIndexPath:(NSIndexPath *)indexPath;
- (void)deleteRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)insertRow:(NSMutableDictionary *)row atIndexPath:(NSIndexPath *)indexPath;

@end

@protocol BOTableViewControllerHelperDelegate <UITableViewDelegate>
@optional

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section;
- (UIImage *)tableView:(UITableView *)tableView imageForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSString *)tableView:(UITableView *)tableView textForRowAtIndexPath:(NSIndexPath *)indexPath;
- (UIColor *)tableView:(UITableView *)tableView textColorForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSString *)tableView:(UITableView *)tableView detailTextForRowAtIndexPath:(NSIndexPath *)indexPath;
- (UIColor *)tableView:(UITableView *)tableView detailTextColorForRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView willDeleteRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView didDeleteRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView initCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath;
- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath;

@end
