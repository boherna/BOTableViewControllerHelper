//
//  BOTableViewControllerHelper.m
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

#import "BOTableViewControllerHelper.h"
#import <QuartzCore/QuartzCore.h>

// Section keys
NSString *const kEditingSectionHeaderTitleKey = @"EditingSectionHeaderTitle";
NSString *const kEditingSectionFooterTitleKey = @"EditingSectionFooterTitle";
NSString *const kSectionHeaderTitleKey = @"SectionHeaderTitle";
NSString *const kSectionHeaderHeightKey = @"SectionHeaderHeight";
NSString *const kSectionFooterTitleKey = @"SectionFooterTitle";
NSString *const kSectionFooterHeightKey = @"SectionFooterHeight";
NSString *const kSectionFooterViewKey = @"SectionFooterView";

// Row keys
NSString *const kRowsArrayKey = @"RowsArray";
NSString *const kRowCellStyleKey = @"RowCellStyle";
NSString *const kRowCellNibNameKey = @"RowCellNibName";
NSString *const kRowCellClassNameKey = @"RowCellClassName";
NSString *const kRowCellReuseIdentifierKey = @"RowCellReuseIdentifier";
NSString *const kRowHeightKey = @"RowHeight";
NSString *const kRowFlagsKey = @"RowFlags";
NSString *const kRowImageKey = @"RowImage";
NSString *const kRowBackgroundColorKey = @"RowBackgroundColor";
NSString *const kRowSelectedBackgroundColorKey = @"RowSelectedBackgroundColor";
NSString *const kRowSelectedTextColorKey = @"RowSelectedTextColor";
NSString *const kRowLabelKey = @"RowLabel";
NSString *const kRowLabelFontKey = @"RowLabelFont";
NSString *const kRowLabelTextColorKey = @"RowLabelTextColor";
NSString *const kRowLabelLineBreakModeKey = @"RowLabelLineBreakMode";
NSString *const kRowLabelTextAlignmentKey = @"RowLabelTextAlignment";
NSString *const kRowDetailLabelKey = @"RowDetailLabel";
NSString *const kRowDetailLabelFontKey = @"RowDetailLabelFont";
NSString *const kRowDetailLabelTextColorKey = @"RowDetailLabelTextColor";
NSString *const kRowDetailLabelLineBreakModeKey = @"RowDetailLabelLineBreakMode";
NSString *const kRowDetailLabelTextAlignmentKey = @"RowDetailLabelTextAlignment";
NSString *const kRowRightViewKey = @"RowRightView";
NSString *const kRowRightViewWidthKey = @"RowRightViewWidth";
NSString *const kRowRightViewHeightKey = @"RowRightViewHeight";
NSString *const kRowRightViewIndentationKey = @"RowRightViewIndentation";
NSString *const kRowButtonBackgroundNormalKey = @"RowButtonBackgroundNormal";
NSString *const kRowButtonBackgroundHighlightedKey = @"RowButtonBackgroundHighlighted";
NSString *const kRowViewControllerNibNameKey = @"RowViewControllerNibName";
NSString *const kRowSelectorNameKey = @"RowSelectorName";
NSString *const kRowBlockKey = @"RowBlock";
NSString *const kRowUserInfoKey = @"RowUserInfo";
NSString *const kRowInitCellBlockKey = @"RowInitCellBlock";

// For removing embedded views at cell recycling time
int kRowRightViewTag = 1;
int kRowTextLabelTag = 2;
int kRowButtonTag = 3;

#define DETAILTEXTLABEL_FONTSIZE 15
#define DETAILTEXTLABEL_POSX 83

#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_6_0
#define TEXTALIGNMENTLEFT UITextAlignmentLeft
#define TEXTALIGNMENTCENTER UITextAlignmentCenter
#define TEXTALIGNMENTRIGHT UITextAlignmentRight
#define LINEBREAKMODETAILTRUNCATION UILineBreakModeTailTruncation
#define LINEBREAKMODECHARACTERWRAP UILineBreakModeCharacterWrap
#define LINEBREAKBYWORDWRAPPING UILineBreakModeWordWrap
#else
#define TEXTALIGNMENTLEFT NSTextAlignmentLeft
#define TEXTALIGNMENTCENTER NSTextAlignmentCenter
#define TEXTALIGNMENTRIGHT NSTextAlignmentRight
#define LINEBREAKMODETAILTRUNCATION NSLineBreakByTruncatingTail
#define LINEBREAKMODECHARACTERWRAP NSLineBreakByCharWrapping
#define LINEBREAKBYWORDWRAPPING NSLineBreakByWordWrapping
#endif

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0
#define SYSTEMFONTOFSIZE systemFontOfSize
#else
#define SYSTEMFONTOFSIZE boldSystemFontOfSize
#endif

@interface NSString (BOTableViewControllerHelper)

- (NSUInteger)occurrencesOfString:(NSString *)string;

@end

@implementation NSString (BOTableViewControllerHelper)

- (NSUInteger)occurrencesOfString:(NSString *)string
{
	return [[NSMutableString stringWithString:self] replaceOccurrencesOfString:string withString:@"" options:0 range:NSMakeRange(0, [self length])];
}

@end

@implementation BOTableViewControllerHelper

+ (id)dataSourceWithArray:(NSMutableArray *)array
{
	BOTableViewControllerHelper *dataSource = [[BOTableViewControllerHelper alloc] init];
	dataSource.dataSource = array;
	dataSource.variableRowHeight = NO;
	dataSource.autoCheckItems = NO;
	dataSource.autoDisableItems = NO;
	return dataSource;
}

- (NSInteger)numberOfSections
{
	NSArray	*rowsArray = [[self dictionaryForSection:0] valueForKey:kRowsArrayKey];
	return rowsArray ? [self.dataSource count] : 1;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section
{
	NSArray	*rowsArray = [[self dictionaryForSection:section] valueForKey:kRowsArrayKey];
	return rowsArray ? [rowsArray count] : (section == 0 ? [self.dataSource count] : 0);
}

- (NSMutableDictionary *)dictionaryForSection:(NSInteger)section
{
	id dictionary = section < (NSInteger)[self.dataSource count] ? [self.dataSource objectAtIndex:section] : nil;
	return dictionary && [dictionary isKindOfClass:[NSDictionary class]] ? dictionary : nil;
}

- (NSMutableArray *)rowsArrayForSection:(NSInteger)section
{
	NSMutableArray *rowsArray = [[self dictionaryForSection:section] valueForKey:kRowsArrayKey];
	return rowsArray ? rowsArray : self.dataSource;
}

- (NSMutableDictionary *)dictionaryForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSArray	*rowsArray = [[self dictionaryForSection:indexPath.section] valueForKey:kRowsArrayKey];
	return rowsArray ? (indexPath.row < rowsArray.count ? [rowsArray objectAtIndex:indexPath.row] : nil) :
					   (indexPath.row < self.dataSource.count ? [self.dataSource objectAtIndex:indexPath.row] : nil);
}

- (id)objectForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [[self dictionaryForRowAtIndexPath:indexPath] objectForKey:kRowUserInfoKey];
}

- (BOOL)rowEnabledAtIndexPath:(NSIndexPath *)indexPath
{
	return [[[self dictionaryForRowAtIndexPath:indexPath] valueForKey:kRowFlagsKey] unsignedIntegerValue] & kDisabled ? NO : YES;
}

- (BOOL)rowSelectableAtIndexPath:(NSIndexPath *)indexPath
{
	return [[[self dictionaryForRowAtIndexPath:indexPath] valueForKey:kRowFlagsKey] unsignedIntegerValue] & kSelectable ? YES : NO;
}

- (BOOL)rowEditableAtIndexPath:(NSIndexPath *)indexPath
{
	return [[[self dictionaryForRowAtIndexPath:indexPath] valueForKey:kRowFlagsKey] unsignedIntegerValue] & kEditable ? YES : NO;
}

- (BOOL)rowMovableAtIndexPath:(NSIndexPath *)indexPath
{
	return [[[self dictionaryForRowAtIndexPath:indexPath] valueForKey:kRowFlagsKey] unsignedIntegerValue] & (kMovable | kMovableInItsSection) ? YES : NO;
}

- (void)deleteRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSMutableArray *rowsArray = [self rowsArrayForSection:indexPath.section];
	if (rowsArray)
	{
		[rowsArray removeObjectAtIndex:indexPath.row];
	}
}

- (void)insertRow:(NSMutableDictionary *)row atIndexPath:(NSIndexPath *)indexPath
{
	NSMutableArray *rowsArray = [self rowsArrayForSection:indexPath.section];
	if (rowsArray)
	{
		[rowsArray insertObject:row atIndex:indexPath.row];
	}
}

#pragma mark - UITableView data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self numberOfRowsInSection:section];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	NSString *key = tableView.editing && [[self dictionaryForSection:section] objectForKey:kEditingSectionHeaderTitleKey] ? kEditingSectionHeaderTitleKey : kSectionHeaderTitleKey;
	return [[self dictionaryForSection:section] valueForKey:key];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	NSString *key = tableView.editing && [[self dictionaryForSection:section] objectForKey:kEditingSectionFooterTitleKey]? kEditingSectionFooterTitleKey :	kSectionFooterTitleKey;
	NSString *title = [[self dictionaryForSection:section] valueForKey:key];
	
	if (title && (NSNull *)title == [NSNull null])
	{
		title = nil;
		if ([self.delegate respondsToSelector:@selector(tableView:titleForFooterInSection:)]) title = [self.delegate tableView:tableView titleForFooterInSection:section];
	}
	return title;
}

- (void)initCell:(UITableViewCell *)cell withRowFlags:(TableViewCellFlags)rowFlags
{
	if (cell)
	{
		cell.selectionStyle = rowFlags & kSelectable ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.showsReorderControl = rowFlags & (kMovable | kMovableInItsSection) ? YES : NO;

		if (rowFlags & kAccessoryDisclosureIndicator)
		{
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
		if (rowFlags & kAccessoryDetailDisclosureButton)
		{
			cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
		}
		if (rowFlags & kAccessoryCheckmark)
		{
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
		}

		cell.editingAccessoryType = UITableViewCellAccessoryNone;//cell.accessoryType;
		cell.shouldIndentWhileEditing = rowFlags & kEditable ? YES : NO;

		if (rowFlags & kNoSeparatorInset && [cell respondsToSelector:@selector(setSeparatorInset:)])
		{
			[cell setSeparatorInset:UIEdgeInsetsZero];
		}

		UIView *selectedBackgroundView = [[UIView alloc] init];
		selectedBackgroundView.backgroundColor = cell.tintColor;
		selectedBackgroundView.layer.masksToBounds = YES;
		cell.selectedBackgroundView = selectedBackgroundView;
		cell.textLabel.highlightedTextColor = [UIColor whiteColor];
		cell.detailTextLabel.highlightedTextColor = [UIColor whiteColor];
	}
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSMutableDictionary *rowDictionary = [self dictionaryForRowAtIndexPath:indexPath];
	TableViewCellFlags rowFlags = [[rowDictionary valueForKey:kRowFlagsKey] unsignedIntegerValue];
	NSString *cellID = [rowDictionary objectForKey:kRowCellReuseIdentifierKey];
	UITableViewCell *cell = cellID ? [tableView dequeueReusableCellWithIdentifier:cellID] : nil;

	if (cell)
	{
		[self initCell:cell withRowFlags:rowFlags];

		RowInitCellBlock initCellBlock = [rowDictionary valueForKey:kRowInitCellBlockKey];
		if (initCellBlock)
		{
			initCellBlock(cell, indexPath, [self objectForRowAtIndexPath:indexPath]);
		}

		if ([self.delegate respondsToSelector:@selector(tableView:initCell:forRowAtIndexPath:)])
		{
			[self.delegate tableView:tableView initCell:cell forRowAtIndexPath:indexPath];
		}
		return cell;
	}

	if ([rowDictionary objectForKey:kRowCellNibNameKey])
	{
		if (!cellID)
		{
			cellID = [rowDictionary objectForKey:kRowCellNibNameKey];
		}
		
		cell = [tableView dequeueReusableCellWithIdentifier:cellID];
		if (!cell)
		{
			for (id nibObject in [[NSBundle mainBundle] loadNibNamed:[rowDictionary objectForKey:kRowCellNibNameKey] owner:nil options:nil])
			{
				if ([nibObject isKindOfClass:[UITableViewCell class]])
				{
					cell = nibObject;
					break;
				}
			}

			[self initCell:cell withRowFlags:rowFlags];

			if (cell && [self.delegate respondsToSelector:@selector(tableView:initCell:forRowAtIndexPath:)])
			{
				[self.delegate tableView:tableView initCell:cell forRowAtIndexPath:indexPath];
			}
			if (!cell)
			{
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DefaultCell"];
			}
		}
		else
		{
			if ([self.delegate respondsToSelector:@selector(tableView:initCell:forRowAtIndexPath:)])
			{
				[self.delegate tableView:tableView initCell:cell forRowAtIndexPath:indexPath];
			}
		}
		return cell;
	}

	if ([rowDictionary objectForKey:kRowCellClassNameKey])
	{
		if (!cellID)
		{
			cellID = [rowDictionary objectForKey:kRowCellClassNameKey];
		}

		cell = [tableView dequeueReusableCellWithIdentifier:cellID];
		if (!cell)
		{
			cell = [[NSClassFromString([rowDictionary objectForKey:kRowCellClassNameKey]) alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
			[self initCell:cell withRowFlags:rowFlags];

			if (cell && [self.delegate respondsToSelector:@selector(tableView:initCell:forRowAtIndexPath:)])
			{
				[self.delegate tableView:tableView initCell:cell forRowAtIndexPath:indexPath];
			}
			if (!cell)
			{
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DefaultCell"];
			}
		}
		else
		{
			if ([self.delegate respondsToSelector:@selector(tableView:initCell:forRowAtIndexPath:)])
			{
				[self.delegate tableView:tableView initCell:cell forRowAtIndexPath:indexPath];
			}
		}
		return cell;
	}

	UITableViewCellStyle rowCellStyle = [[rowDictionary valueForKey:kRowCellStyleKey] integerValue];
	if (!rowCellStyle)
	{
		rowCellStyle = UITableViewCellStyleDefault;
	}
	if (!cellID)
	{
		if (![rowDictionary objectForKey:kRowBackgroundColorKey] &&	![rowDictionary objectForKey:kRowHeightKey] &&
			![rowDictionary objectForKey:kRowLabelFontKey] && ![rowDictionary objectForKey:kRowLabelTextColorKey] &&
			![rowDictionary objectForKey:kRowLabelLineBreakModeKey] && ![rowDictionary objectForKey:kRowLabelTextAlignmentKey] &&
			![rowDictionary objectForKey:kRowDetailLabelFontKey] && ![rowDictionary objectForKey:kRowDetailLabelTextColorKey] &&
			![rowDictionary objectForKey:kRowDetailLabelLineBreakModeKey] && ![rowDictionary objectForKey:kRowDetailLabelTextAlignmentKey] &&
			![rowDictionary objectForKey:kRowSelectedBackgroundColorKey] && ![rowDictionary objectForKey:kRowSelectedTextColorKey])
		{
			cellID = [NSString stringWithFormat:@"CellID%d", (unsigned int)rowCellStyle];
		}
	}
    if (cellID)
	{
		cell = [tableView dequeueReusableCellWithIdentifier:cellID];
	}
	if (!cell)
	{
		cell = [[UITableViewCell alloc] initWithStyle:rowCellStyle reuseIdentifier:cellID];
	}
	else
	{
		// the cell is being recycled, remove old embedded views
		[[cell.contentView viewWithTag:kRowRightViewTag] removeFromSuperview];
		[[cell.contentView viewWithTag:kRowTextLabelTag] removeFromSuperview];
		[[cell.contentView viewWithTag:kRowButtonTag] removeFromSuperview];

		cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width, tableView.rowHeight);
		cell.textLabel.text = nil;
		cell.detailTextLabel.text = nil;
		cell.imageView.image = nil;

		switch (rowCellStyle)
		{
			case UITableViewCellStyleDefault:

			cell.textLabel.font = [UIFont SYSTEMFONTOFSIZE:[UIFont labelFontSize]];
			cell.textLabel.textAlignment = TEXTALIGNMENTLEFT;
			break;

			default:
			break;
		}
	}

	[self initCell:cell withRowFlags:rowFlags];

	UIImage *image = [rowDictionary valueForKey:kRowImageKey];
	if (image && (NSNull *)image == [NSNull null])
	{
		image = nil;
		if ([self.delegate respondsToSelector:@selector(tableView:imageForRowAtIndexPath:)])
		{
			image = [self.delegate tableView:tableView imageForRowAtIndexPath:indexPath];
		}
	}

	if (image)
	{
		cell.imageView.autoresizingMask = UIViewAutoresizingNone;
		cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
		cell.imageView.image = image;

		if (rowFlags & kImageWithShadow && [CALayer instancesRespondToSelector:@selector(setShadowOffset:)])
		{
			cell.imageView.layer.shadowOffset = CGSizeMake(0.0, 1.0);
			cell.imageView.layer.shadowOpacity = 0.2;
			cell.imageView.layer.shadowRadius = 1.0;
		}
	}

	UIView *rowRightView = [rowDictionary valueForKey:kRowRightViewKey];
	if (rowRightView)
	{
		CGFloat contentViewHeight = [rowDictionary objectForKey:kRowHeightKey] ? [[rowDictionary valueForKey:kRowHeightKey] floatValue] : cell.contentView.frame.size.height;
		CGFloat rowRightViewWidth = [rowDictionary objectForKey:kRowRightViewWidthKey] ? [[rowDictionary valueForKey:kRowRightViewWidthKey] floatValue] : rowRightView.frame.size.width;
        CGFloat rowRightViewHeight = [rowDictionary objectForKey:kRowRightViewHeightKey] ? [[rowDictionary valueForKey:kRowRightViewHeightKey] floatValue] : rowRightView.frame.size.height;
		CGFloat rowRightViewIndentation = [rowDictionary objectForKey:kRowRightViewIndentationKey] ? [[rowDictionary valueForKey:kRowRightViewIndentationKey] floatValue] : cell.indentationWidth;

		if (rowRightViewWidth > 0)
		{
			if (rowRightViewHeight > 0)
			{
				rowRightView.frame = CGRectMake((contentViewHeight >= rowRightViewHeight ? cell.contentView.frame.size.width - rowRightViewWidth - rowRightViewIndentation : 0.0),
												(contentViewHeight >= rowRightViewHeight ? (int)((contentViewHeight - rowRightViewHeight) / 2) : 0.0),
												rowRightViewWidth, rowRightViewHeight);
			}
			else
			{
				rowRightView.frame = CGRectMake(cell.contentView.frame.size.width - rowRightViewWidth - rowRightViewIndentation,
												rowRightViewIndentation, rowRightViewWidth, contentViewHeight - rowRightViewIndentation *2);
			}
		}
		else
		{
			if (rowRightViewHeight > 0)
			{
				rowRightView.frame = CGRectMake(rowRightViewIndentation, (contentViewHeight >= rowRightViewHeight ? (int)((contentViewHeight - rowRightViewHeight) / 2) : 0.0),
												cell.contentView.frame.size.width - rowRightViewIndentation *2, rowRightViewHeight);
			}
			else
			{
				rowRightView.frame = CGRectMake(rowRightViewIndentation, rowRightViewIndentation, cell.contentView.frame.size.width - rowRightViewIndentation *2,
												contentViewHeight - rowRightViewIndentation *2);
			}
		}

		if ([(id)rowRightView respondsToSelector:@selector(setEnabled:)])
		{
			[(id)rowRightView setEnabled:(rowFlags & kDisabled ? NO : YES)];
		}
		if ([rowDictionary valueForKey:kRowLabelKey])
		{
			if (image) rowRightViewIndentation += rowRightViewIndentation + image.size.width;
			
			UILabel *rowTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(rowRightViewIndentation, 0.0,
																			  rowRightView.frame.origin.x - rowRightViewIndentation - 5.0,
																			  contentViewHeight - 2.0)];
			rowTextLabel.text = [rowDictionary valueForKey:kRowLabelKey];
			rowTextLabel.textAlignment = rowFlags & TEXTALIGNMENTRIGHT ? TEXTALIGNMENTRIGHT : TEXTALIGNMENTLEFT;
			rowTextLabel.font = [UIFont SYSTEMFONTOFSIZE:[UIFont labelFontSize]];
			rowTextLabel.textColor = [UIColor blackColor];
			rowTextLabel.highlightedTextColor = [UIColor whiteColor];
			rowTextLabel.backgroundColor = [UIColor clearColor];
			rowTextLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
			rowTextLabel.tag = kRowTextLabelTag;
			rowTextLabel.enabled = rowFlags & kDisabled ? NO : YES;

			[cell.contentView addSubview:rowTextLabel];
		}

		[cell.contentView addSubview:rowRightView];
	}
	else
	if (rowFlags & kButton)
	{
		SEL selector = NSSelectorFromString([rowDictionary valueForKey:kRowSelectorNameKey]);
		if (selector && ![self.delegate respondsToSelector:selector])
		{
			selector = NULL;
		}

		CGFloat contentViewHeight = [rowDictionary objectForKey:kRowHeightKey] ? [[rowDictionary valueForKey:kRowHeightKey] floatValue] : cell.contentView.frame.size.height;
		UIImage *backgroundNormal = [[UIImage imageNamed:[rowDictionary valueForKey:kRowButtonBackgroundNormalKey]] stretchableImageWithLeftCapWidth:6.0 topCapHeight:0.0];
		UIImage *backgroundHighlighted = [[UIImage imageNamed:[rowDictionary valueForKey:kRowButtonBackgroundHighlightedKey]] stretchableImageWithLeftCapWidth:6.0 topCapHeight:0.0];
		UIButton *rowButton = [UIButton buttonWithType:UIButtonTypeCustom];

		rowButton.backgroundColor = [UIColor clearColor];
		rowButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		rowButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
		rowButton.titleLabel.font = [UIFont SYSTEMFONTOFSIZE:[UIFont buttonFontSize]];
		rowButton.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
		rowButton.frame = CGRectMake(0.0, 0.0, cell.contentView.frame.size.width - cell.indentationWidth *2, contentViewHeight);
		rowButton.tag = kRowButtonTag;
		rowButton.enabled = rowFlags & kDisabled ? NO : YES;

		[rowButton setTitle:[rowDictionary valueForKey:kRowLabelKey] forState:UIControlStateNormal];
		[rowButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[rowButton setTitleShadowColor:[UIColor colorWithRed:(0.0 / 255.0) green:(0.0 / 255.0) blue:(0.0 / 255.0) alpha:0.7] forState:UIControlStateNormal];
		[rowButton setBackgroundImage:backgroundNormal forState:UIControlStateNormal];
		[rowButton setBackgroundImage:backgroundHighlighted forState:UIControlStateHighlighted];
		[rowButton addTarget:(selector ? self.delegate : nil) action:(selector ? selector : nil) forControlEvents:UIControlEventTouchUpInside];

		cell.backgroundView = nil;
		[cell.contentView addSubview:rowButton];
	}
	else
	{
		NSString *labelText = [rowDictionary valueForKey:kRowLabelKey];
		if (labelText && (NSNull *)labelText == [NSNull null])
		{
			labelText = nil;
			if ([self.delegate respondsToSelector:@selector(tableView:textForRowAtIndexPath:)])
			{
				labelText = [self.delegate tableView:tableView textForRowAtIndexPath:indexPath];
			}
		}
		
		cell.textLabel.text = labelText;
		cell.textLabel.enabled = rowFlags & kDisabled ? NO : YES;

		UIFont *labelFont = [rowDictionary valueForKey:kRowLabelFontKey];
		if (labelFont)
		{
			cell.textLabel.font = labelFont;
		}
		
		UIColor *labelTextColor = [rowDictionary objectForKey:kRowLabelTextColorKey];
		if (labelTextColor && (NSNull *)labelTextColor == [NSNull null])
		{
			labelTextColor = nil;

			if ([self.delegate respondsToSelector:@selector(tableView:textColorForRowAtIndexPath:)])
			{
				labelTextColor = [self.delegate tableView:tableView textColorForRowAtIndexPath:indexPath];
			}
		}

		if (labelTextColor)
		{
			cell.textLabel.textColor = labelTextColor;
		}
		if ([rowDictionary objectForKey:kRowLabelLineBreakModeKey])
		{
			cell.textLabel.lineBreakMode = [[rowDictionary valueForKey:kRowLabelLineBreakModeKey] integerValue];
		}
		if ([rowDictionary objectForKey:kRowLabelTextAlignmentKey])
		{
			cell.textLabel.textAlignment = [[rowDictionary valueForKey:kRowLabelTextAlignmentKey] integerValue];
		}
		if (rowFlags & kMultiLineLabel)
		{
			CGFloat cellWidth = MIN([UIScreen mainScreen].applicationFrame.size.width, [UIScreen mainScreen].applicationFrame.size.height);
			if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))
			{
				cellWidth = MAX([UIScreen mainScreen].applicationFrame.size.width, [UIScreen mainScreen].applicationFrame.size.height);
			}
			
			CGFloat textLabelWidth = rowCellStyle == UITableViewCellStyleValue2 ? DETAILTEXTLABEL_POSX : cellWidth - cell.indentationWidth *4;
			CGFloat textHeight = 0;

			if ([cell.textLabel.text respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)])
			{
				NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
				paragraphStyle.lineBreakMode = LINEBREAKBYWORDWRAPPING;
				paragraphStyle.alignment = NSTextAlignmentLeft;

				textHeight = ceilf([cell.textLabel.text boundingRectWithSize:CGSizeMake(textLabelWidth, 1024)
																	 options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
																  attributes:@{NSFontAttributeName : cell.textLabel.font,
																			   NSParagraphStyleAttributeName : paragraphStyle}
																	 context:nil].size.height);
			}
			else
			{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
				textHeight = [cell.textLabel.text sizeWithFont:cell.textLabel.font
											 constrainedToSize:CGSizeMake(textLabelWidth, 1024)
												 lineBreakMode:LINEBREAKBYWORDWRAPPING].height;
#pragma clang diagnostic pop
			}

			cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width, textHeight + cell.indentationWidth *2);
			cell.textLabel.numberOfLines = 0;
		}

		if (cell.detailTextLabel)
		{
            NSString *detailText = [rowDictionary valueForKey:kRowDetailLabelKey];
            if (detailText && (NSNull *)detailText == [NSNull null])
            {
                detailText = nil;
                
                if ([self.delegate respondsToSelector:@selector(tableView:detailTextForRowAtIndexPath:)])
				{
					detailText = [self.delegate tableView:tableView detailTextForRowAtIndexPath:indexPath];
				}
            }
            
			cell.detailTextLabel.text = detailText;
			cell.detailTextLabel.enabled = rowFlags & kDisabled ? NO : YES;

			UIFont *detailLabelFont = [rowDictionary valueForKey:kRowDetailLabelFontKey];
			if (detailLabelFont)
			{
				cell.detailTextLabel.font = detailLabelFont;
			}
			
			UIColor *detailLabelTextColor = [rowDictionary objectForKey:kRowDetailLabelTextColorKey];
			if (detailLabelTextColor && (NSNull *)detailLabelTextColor == [NSNull null])
            {
                detailLabelTextColor = nil;

                if ([self.delegate respondsToSelector:@selector(tableView:detailTextColorForRowAtIndexPath:)])
				{
					detailLabelTextColor = [self.delegate tableView:tableView detailTextColorForRowAtIndexPath:indexPath];
				}
            }
			if (detailLabelTextColor)
			{
				cell.detailTextLabel.textColor = detailLabelTextColor;
			}
			if ([rowDictionary objectForKey:kRowDetailLabelLineBreakModeKey])
			{
				cell.detailTextLabel.lineBreakMode = [[rowDictionary valueForKey:kRowDetailLabelLineBreakModeKey] integerValue];
			}
			if ([rowDictionary objectForKey:kRowDetailLabelTextAlignmentKey])
			{
				cell.detailTextLabel.textAlignment = [[rowDictionary valueForKey:kRowDetailLabelTextAlignmentKey] integerValue];
			}
			if (rowFlags & kMultiLineDetailLabel && rowCellStyle == UITableViewCellStyleValue2)
			{
				CGFloat cellWidth = MIN([UIScreen mainScreen].applicationFrame.size.width, [UIScreen mainScreen].applicationFrame.size.height);

				if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))
				{
					cellWidth = MAX([UIScreen mainScreen].applicationFrame.size.width, [UIScreen mainScreen].applicationFrame.size.height);
				}
				
				CGFloat detailTextLabelWidth = cellWidth - cell.indentationWidth - ([[UIDevice currentDevice].systemVersion floatValue] >= 5 ? cell.indentationWidth *2 : 0) - DETAILTEXTLABEL_POSX;
				CGFloat textHeight = 0;

				if ([cell.textLabel.text respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)])
				{
					NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
					paragraphStyle.lineBreakMode = LINEBREAKBYWORDWRAPPING;
					paragraphStyle.alignment = NSTextAlignmentLeft;

					textHeight = ceilf([cell.detailTextLabel.text boundingRectWithSize:CGSizeMake(detailTextLabelWidth, 1024)
																		 options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
																	  attributes:@{NSFontAttributeName : cell.detailTextLabel.font,
																				   NSParagraphStyleAttributeName : paragraphStyle}
																		 context:nil].size.height);
				}
				else
				{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
					textHeight = [cell.detailTextLabel.text sizeWithFont:cell.detailTextLabel.font
													   constrainedToSize:CGSizeMake(detailTextLabelWidth, 1024)
														   lineBreakMode:LINEBREAKBYWORDWRAPPING].height;
#pragma clang diagnostic pop
				}

				cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width, textHeight + cell.indentationWidth *2);
				cell.detailTextLabel.numberOfLines = 0;
			}
		}
	}

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [self rowEditableAtIndexPath:indexPath] || [self rowMovableAtIndexPath:indexPath];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [self rowMovableAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
	if ([self.delegate respondsToSelector:@selector(tableView:moveRowAtIndexPath:toIndexPath:)])
	{
		[self.delegate tableView:tableView moveRowAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
	}
	
	NSMutableDictionary *rowDictionary = [self dictionaryForRowAtIndexPath:fromIndexPath];
    [[self rowsArrayForSection:fromIndexPath.section] removeObjectAtIndex:fromIndexPath.row];
    [[self rowsArrayForSection:toIndexPath.section] insertObject:rowDictionary atIndex:toIndexPath.row];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete)
	{
		if ([self.delegate respondsToSelector:@selector(tableView:willDeleteRowAtIndexPath:)])
		{
			[self.delegate tableView:tableView willDeleteRowAtIndexPath:indexPath];
		}

		[[self rowsArrayForSection:indexPath.section] removeObjectAtIndex:indexPath.row];
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];

		if ([self.delegate respondsToSelector:@selector(tableView:didDeleteRowAtIndexPath:)])
		{
			[self.delegate tableView:tableView didDeleteRowAtIndexPath:indexPath];
		}
	}
	else
	{
		if ([self.delegate respondsToSelector:@selector(tableView:commitEditingStyle:forRowAtIndexPath:)])
		{
			[self.delegate tableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
		}
	}
}

#pragma mark - UITableView delegate methods

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [self rowEditableAtIndexPath:indexPath];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [self rowEditableAtIndexPath:indexPath] ? UITableViewCellEditingStyleDelete : UITableViewCellEditingStyleNone;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
	return [[self dictionaryForSection:section] valueForKey:kSectionFooterViewKey];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
	CGFloat sectionFooterHeight = [[[self dictionaryForSection:section] valueForKey:kSectionFooterHeightKey] floatValue];
	return sectionFooterHeight ? sectionFooterHeight : -1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	CGFloat sectionHeaderHeight = [[[self dictionaryForSection:section] valueForKey:kSectionHeaderHeightKey] floatValue];
	return sectionHeaderHeight ? sectionHeaderHeight : ([[UIDevice currentDevice].systemVersion floatValue] >= 5 ? -1 : 30.0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *rowDictionary = [self dictionaryForRowAtIndexPath:indexPath];
	CGFloat rowHeight = [[rowDictionary valueForKey:kRowHeightKey] floatValue];

	if (rowHeight == MAXFLOAT && [self.delegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)])
	{
		rowHeight = [self.delegate tableView:tableView heightForRowAtIndexPath:indexPath];
	}
	if (!rowHeight && self.variableRowHeight)
	{
		rowHeight = [self tableView:tableView cellForRowAtIndexPath:indexPath].frame.size.height;
	}
	return rowHeight ? rowHeight : tableView.rowHeight;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSMutableDictionary *rowDictionary = [self dictionaryForRowAtIndexPath:indexPath];
	TableViewCellFlags rowFlags = [[rowDictionary valueForKey:kRowFlagsKey] unsignedIntegerValue];

	UIColor *backgroundColor = [rowDictionary objectForKey:kRowBackgroundColorKey];
	if (backgroundColor) cell.backgroundColor = backgroundColor;

	UIColor *selectedBackgroundColor = [rowDictionary objectForKey:kRowSelectedBackgroundColorKey];
	if (selectedBackgroundColor)
	{
		UIView *selectedBackgroundView = [[UIView alloc] init];
		selectedBackgroundView.backgroundColor = selectedBackgroundColor;
		selectedBackgroundView.layer.masksToBounds = YES;
		cell.selectedBackgroundView = selectedBackgroundView;
	}

	UIColor *selectedTextColor = [rowDictionary objectForKey:kRowSelectedTextColorKey];
	if (selectedTextColor)
	{
		cell.textLabel.highlightedTextColor = selectedTextColor;
		cell.detailTextLabel.highlightedTextColor = selectedTextColor;
	}

	if (rowFlags & kNoSeparatorInset)
	{
		if ([cell respondsToSelector:@selector(setSeparatorInset:)])
		{
			[cell setSeparatorInset:UIEdgeInsetsZero];
		}
		if ([cell respondsToSelector:@selector(setLayoutMargins:)])
		{
			[cell setLayoutMargins:UIEdgeInsetsZero];
		}
		if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)])
		{
			[cell setPreservesSuperviewLayoutMargins:NO];
		}
	}

	if ([self.delegate respondsToSelector:@selector(tableView:willDisplayCell:forRowAtIndexPath:)])
	{
		[self.delegate tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
	}
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [self rowSelectableAtIndexPath:indexPath] && [self rowEnabledAtIndexPath:indexPath] ? indexPath : nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([self.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)])
	{
		[self.delegate tableView:tableView didSelectRowAtIndexPath:indexPath];
	}

	if (self.autoCheckItems)
	{
		NSInteger numberOfRowsInSection = [self numberOfRowsInSection:indexPath.section];
		for (NSInteger row = 0; row < numberOfRowsInSection; row++)
		{
			NSIndexPath *indexPathForRow = [NSIndexPath indexPathForRow:row inSection:indexPath.section];
			NSMutableDictionary *rowDictionary = [self dictionaryForRowAtIndexPath:indexPathForRow];
			TableViewCellFlags rowFlags = [[rowDictionary valueForKey:kRowFlagsKey] unsignedIntegerValue];

			if (rowFlags & kAccessoryCheckmark)
			{
				rowFlags &= ~kAccessoryCheckmark;
				[rowDictionary setObject:[NSNumber numberWithUnsignedInteger:rowFlags] forKey:kRowFlagsKey];
				[[tableView cellForRowAtIndexPath:indexPathForRow] setAccessoryType:UITableViewCellAccessoryNone];
				break;
			}
		}

		NSMutableDictionary *rowDictionary = [self dictionaryForRowAtIndexPath:indexPath];
		TableViewCellFlags rowFlags = [[rowDictionary valueForKey:kRowFlagsKey] unsignedIntegerValue];
		[rowDictionary setObject:[NSNumber numberWithUnsignedInteger:(rowFlags | kAccessoryCheckmark)] forKey:kRowFlagsKey];
		[[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
	}

	if (self.autoDisableItems)
	{
		NSMutableDictionary *rowDictionary = [self dictionaryForRowAtIndexPath:indexPath];
		TableViewCellFlags rowFlags = [[rowDictionary valueForKey:kRowFlagsKey] unsignedIntegerValue];
		rowFlags |= kDisabled;
		rowFlags &= ~kSelectable;
		[rowDictionary setObject:[NSNumber numberWithUnsignedInteger:rowFlags] forKey:kRowFlagsKey];
		[tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	}

    NSString *viewControllerNibName = [[self dictionaryForRowAtIndexPath:indexPath] valueForKey:kRowViewControllerNibNameKey];
	if (viewControllerNibName)
	{
		Class ViewControllerClass = NSClassFromString(viewControllerNibName);
		UIViewController *tableViewController = (UIViewController *)self.delegate;

		if ([tableViewController isKindOfClass:[UIViewController class]] && tableViewController.navigationController &&
			ViewControllerClass && [ViewControllerClass isSubclassOfClass:[UIViewController class]])
		{
			UIViewController *viewController = [[ViewControllerClass alloc] initWithNibName:viewControllerNibName bundle:nil];
			[tableViewController.navigationController pushViewController:viewController animated:YES];
		}
	}
	else
	{
		[tableView deselectRowAtIndexPath:indexPath animated:YES];

		NSDictionary *rowDictionary = [self dictionaryForRowAtIndexPath:indexPath];
		RowBlock rowBlock = [rowDictionary valueForKey:kRowBlockKey];
		NSString *string = [rowDictionary valueForKey:kRowSelectorNameKey];

		if (rowBlock)
		{
			rowBlock(indexPath, [self objectForRowAtIndexPath:indexPath]);
		}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
		SEL selector = NSSelectorFromString(string);
		if (selector && [self.delegate respondsToSelector:selector])
		{
			if (![string hasSuffix:@":"]) [self.delegate performSelector:selector];
			else
			{
				if ([string occurrencesOfString:@":"] == 1) [self.delegate performSelector:selector withObject:indexPath];
				else
				{
					[self.delegate performSelector:selector	withObject:indexPath withObject:[self objectForRowAtIndexPath:indexPath]];
				}
			}
		}
#pragma clang diagnostic pop
	}
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
	if ([self.delegate respondsToSelector:@selector(tableView:targetIndexPathForMoveFromRowAtIndexPath:toProposedIndexPath:)])
	{
		return [self.delegate tableView:tableView targetIndexPathForMoveFromRowAtIndexPath:sourceIndexPath toProposedIndexPath:proposedDestinationIndexPath];
	}

    if ([[[self dictionaryForRowAtIndexPath:sourceIndexPath] valueForKey:kRowFlagsKey] unsignedIntegerValue] & kMovableInItsSection &&
		sourceIndexPath.section != proposedDestinationIndexPath.section)
	{
        NSUInteger rowInSourceSection =	(sourceIndexPath.section > proposedDestinationIndexPath.section) ? 0 : [tableView numberOfRowsInSection:sourceIndexPath.section] - 1;
        return [NSIndexPath indexPathForRow:rowInSourceSection inSection:sourceIndexPath.section];
    }
    return proposedDestinationIndexPath;
}

@end
