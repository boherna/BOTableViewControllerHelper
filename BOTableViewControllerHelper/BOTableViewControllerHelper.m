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
NSString * const kEditingSectionHeaderTitleKey = @"EditingSectionHeaderTitle";
NSString * const kEditingSectionFooterTitleKey = @"EditingSectionFooterTitle";
NSString * const kSectionHeaderTitleKey = @"SectionHeaderTitle";
NSString * const kSectionHeaderHeightKey = @"SectionHeaderHeight";
NSString * const kSectionFooterTitleKey = @"SectionFooterTitle";
NSString * const kSectionFooterHeightKey = @"SectionFooterHeight";
NSString * const kSectionFooterViewKey = @"SectionFooterView";

// Row keys
NSString * const kRowsArrayKey = @"RowsArray";
NSString * const kRowCellStyleKey = @"RowCellStyle";
NSString * const kRowCellNibNameKey = @"RowCellNibName";
NSString * const kRowCellClassNameKey = @"RowCellClassName";
NSString * const kRowCellReuseIdentifierKey = @"RowCellReuseIdentifier";
NSString * const kRowHeightKey = @"RowHeight";
NSString * const kRowFlagsKey = @"RowFlags";
NSString * const kRowImageKey = @"RowImage";
NSString * const kRowBackgroundColorKey = @"RowBackgroundColor";
NSString * const kRowLabelKey = @"RowLabel";
NSString * const kRowLabelFontKey = @"RowLabelFont";
NSString * const kRowLabelTextColorKey = @"RowLabelTextColor";
NSString * const kRowLabelLineBreakModeKey = @"RowLabelLineBreakMode";
NSString * const kRowLabelTextAlignmentKey = @"RowLabelTextAlignment";
NSString * const kRowDetailLabelKey = @"RowDetailLabel";
NSString * const kRowDetailLabelFontKey = @"RowDetailLabelFont";
NSString * const kRowDetailLabelTextColorKey = @"RowDetailLabelTextColor";
NSString * const kRowDetailLabelLineBreakModeKey = @"RowDetailLabelLineBreakMode";
NSString * const kRowDetailLabelTextAlignmentKey = @"RowDetailLabelTextAlignment";
NSString * const kRowRightViewKey = @"RowRightView";
NSString * const kRowRightViewWidthKey = @"RowRightViewWidth";
NSString * const kRowRightViewHeightKey = @"RowRightViewHeight";
NSString * const kRowRightViewIndentationKey = @"RowRightViewIndentation";
NSString * const kRowButtonBackgroundNormalKey = @"RowButtonBackgroundNormal";
NSString * const kRowButtonBackgroundHighlightedKey = @"RowButtonBackgroundHighlighted";
NSString * const kRowViewControllerNibNameKey = @"RowViewControllerNibName";
NSString * const kRowSelectorNameKey = @"RowSelectorName";
NSString * const kRowUserInfoKey = @"RowUserInfo";

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

@interface NSString (BOTableViewControllerHelper)

- (NSUInteger)occurrencesOfString:(NSString *)string;

@end

@implementation NSString (BOTableViewControllerHelper)

- (NSUInteger)occurrencesOfString:(NSString *)string
{
	return [[NSMutableString stringWithString:self] replaceOccurrencesOfString:string withString:@"" options:0 range:NSMakeRange(0, [self length])];
}

@end

@interface BOTableViewControllerHelper ()
{
	NSMutableArray * _dataSource;
	id<BOTableViewControllerHelperDelegate> _delegate;
	BOOL _variableRowHeight;
}
@end

@implementation BOTableViewControllerHelper

@synthesize dataSource = _dataSource;
@synthesize delegate = _delegate;
@synthesize variableRowHeight = _variableRowHeight;

+ (id)dataSourceWithArray:(NSMutableArray *)array
{
	BOTableViewControllerHelper * dataSource = [[[BOTableViewControllerHelper alloc] init] autorelease];
	dataSource.dataSource = array;
	dataSource.variableRowHeight = NO;
	return dataSource;
}

- (NSInteger)numberOfSections
{
	NSArray	* rowsArray = [[self dictionaryForSection:0] valueForKey:kRowsArrayKey];
	return rowsArray ? [_dataSource count] : 1;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section
{
	NSArray	* rowsArray = [[self dictionaryForSection:section] valueForKey:kRowsArrayKey];
	return rowsArray ? [rowsArray count] : (section == 0 ? [_dataSource count] : 0);
}

- (NSMutableDictionary *)dictionaryForSection:(NSInteger)section
{
	id dictionary = section < (NSInteger)[_dataSource count] ? [_dataSource objectAtIndex:section] : nil;
	return dictionary && [dictionary isKindOfClass:[NSDictionary class]] ? dictionary : nil;
}

- (NSMutableArray *)rowsArrayForSection:(NSInteger)section
{
	NSMutableArray * rowsArray = [[self dictionaryForSection:section] valueForKey:kRowsArrayKey];
	return rowsArray ? rowsArray : _dataSource;
}

- (NSMutableDictionary *)dictionaryForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSArray	* rowsArray = [[self dictionaryForSection:indexPath.section] valueForKey:kRowsArrayKey];
	return rowsArray ? (indexPath.row < rowsArray.count ? [rowsArray objectAtIndex:indexPath.row] : nil) :
					   (indexPath.row < _dataSource.count ? [_dataSource objectAtIndex:indexPath.row] : nil);
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
	return [[[self dictionaryForRowAtIndexPath:indexPath] valueForKey:kRowFlagsKey] unsignedIntegerValue] & kMovable ? YES : NO;
}

- (void)deleteRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSMutableArray * rowsArray = [self rowsArrayForSection:indexPath.section];
	if (rowsArray) [rowsArray removeObjectAtIndex:indexPath.row];
}

- (void)insertRow:(NSMutableDictionary *)row atIndexPath:(NSIndexPath *)indexPath
{
	NSMutableArray * rowsArray = [self rowsArrayForSection:indexPath.section];
	if (rowsArray) [rowsArray insertObject:row atIndex:indexPath.row];
}

#pragma mark - UITableView data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self numberOfRowsInSection:section];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	NSString * key = tableView.editing && [[self dictionaryForSection:section] objectForKey:kEditingSectionHeaderTitleKey] ? kEditingSectionHeaderTitleKey : kSectionHeaderTitleKey;
	return [[self dictionaryForSection:section] valueForKey:key];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	NSString * key = tableView.editing && [[self dictionaryForSection:section] objectForKey:kEditingSectionFooterTitleKey]? kEditingSectionFooterTitleKey :	kSectionFooterTitleKey;
	NSString * title = [[self dictionaryForSection:section] valueForKey:key];
	
	if (title && (NSNull *)title == [NSNull null])
	{
		title = nil;
		
		if ([_delegate respondsToSelector:@selector(tableView:titleForFooterInSection:)]) title = [_delegate tableView:tableView titleForFooterInSection:section];
	}
	return title;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSMutableDictionary * rowDictionary = [self dictionaryForRowAtIndexPath:indexPath];
	TableViewCellFlags rowFlags = [[rowDictionary valueForKey:kRowFlagsKey] unsignedIntegerValue];
	NSString * cellID = [rowDictionary objectForKey:kRowCellReuseIdentifierKey];
	UITableViewCell * cell = nil;

	if ([rowDictionary objectForKey:kRowCellNibNameKey])
	{
		if (!cellID) cellID = [rowDictionary objectForKey:kRowCellNibNameKey];
		
		cell = [tableView dequeueReusableCellWithIdentifier:cellID];

		if (!cell)
		{
			for (id nibObject in [[NSBundle mainBundle] loadNibNamed:[rowDictionary objectForKey:kRowCellNibNameKey] owner:nil options:nil])

				if ([nibObject isKindOfClass:[UITableViewCell class]])
				{
					cell = nibObject;
					break;
				}

			if (cell && [_delegate respondsToSelector:@selector(tableView:initCell:forRowAtIndexPath:)]) [_delegate tableView:tableView initCell:cell forRowAtIndexPath:indexPath];

			if (!cell) cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DefaultCell"] autorelease];
		}
		else
		{
			if ([_delegate respondsToSelector:@selector(tableView:initCell:forRowAtIndexPath:)]) [_delegate tableView:tableView initCell:cell forRowAtIndexPath:indexPath];
		}
		return cell;
	}

	if ([rowDictionary objectForKey:kRowCellClassNameKey])
	{
		if (!cellID) cellID = [rowDictionary objectForKey:kRowCellClassNameKey];
		
		cell = [tableView dequeueReusableCellWithIdentifier:cellID];

		if (!cell)
		{
			cell = [[[NSClassFromString([rowDictionary objectForKey:kRowCellClassNameKey]) alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];

			if (cell && [_delegate respondsToSelector:@selector(tableView:initCell:forRowAtIndexPath:)]) [_delegate tableView:tableView initCell:cell forRowAtIndexPath:indexPath];

			if (!cell) cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DefaultCell"] autorelease];			
		}
		else
		{
			if ([_delegate respondsToSelector:@selector(tableView:initCell:forRowAtIndexPath:)]) [_delegate tableView:tableView initCell:cell forRowAtIndexPath:indexPath];
		}
		return cell;
	}

	UITableViewCellStyle rowCellStyle = [[rowDictionary valueForKey:kRowCellStyleKey] integerValue];
	if (!rowCellStyle) rowCellStyle = UITableViewCellStyleDefault;

	if (!cellID)

		if (![rowDictionary objectForKey:kRowBackgroundColorKey] &&	![rowDictionary objectForKey:kRowHeightKey] &&
			![rowDictionary objectForKey:kRowLabelFontKey] && ![rowDictionary objectForKey:kRowLabelTextColorKey] &&
			![rowDictionary objectForKey:kRowLabelLineBreakModeKey] && ![rowDictionary objectForKey:kRowLabelTextAlignmentKey] &&
			![rowDictionary objectForKey:kRowDetailLabelFontKey] && ![rowDictionary objectForKey:kRowDetailLabelTextColorKey] &&
			![rowDictionary objectForKey:kRowDetailLabelLineBreakModeKey] && ![rowDictionary objectForKey:kRowDetailLabelTextAlignmentKey])

			cellID = [NSString stringWithFormat:@"CellID%u", rowCellStyle];
	
    if (cellID) [tableView dequeueReusableCellWithIdentifier:cellID];

	if (!cell) cell = [[[UITableViewCell alloc] initWithStyle:rowCellStyle reuseIdentifier:cellID] autorelease];
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

			cell.textLabel.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
			cell.textLabel.textAlignment = TEXTALIGNMENTLEFT;
			break;

			default:
			break;
		}
	}

	cell.selectionStyle = rowFlags & kSelectable ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
	cell.accessoryType = UITableViewCellAccessoryNone;
	cell.showsReorderControl = rowFlags & kMovable ? YES : NO;

	if (rowFlags & kAccessoryDisclosureIndicator) cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	if (rowFlags & kAccessoryDetailDisclosureButton) cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	if (rowFlags & kAccessoryCheckmark) cell.accessoryType = UITableViewCellAccessoryCheckmark;
	
	cell.editingAccessoryType = cell.accessoryType;
	cell.shouldIndentWhileEditing = rowFlags & kEditable ? YES : NO;

	UIImage * image = [rowDictionary valueForKey:kRowImageKey];

	if (image && (NSNull *)image == [NSNull null])
	{
		image = nil;

		if ([_delegate respondsToSelector:@selector(tableView:imageForRowAtIndexPath:)]) image = [_delegate tableView:tableView imageForRowAtIndexPath:indexPath];
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

	UIView * rowRightView = [rowDictionary valueForKey:kRowRightViewKey];

	if (rowRightView)
	{											
		CGFloat rowRightViewWidth = [rowDictionary objectForKey:kRowRightViewWidthKey] ? [[rowDictionary valueForKey:kRowRightViewWidthKey] floatValue] : rowRightView.frame.size.width;
        CGFloat rowRightViewHeight = [rowDictionary objectForKey:kRowRightViewHeightKey] ? [[rowDictionary valueForKey:kRowRightViewHeightKey] floatValue] : rowRightView.frame.size.height;
		CGFloat rowRightViewIndentation = [rowDictionary objectForKey:kRowRightViewIndentationKey] ? [[rowDictionary valueForKey:kRowRightViewIndentationKey] floatValue] : cell.indentationWidth;

		if (rowRightViewWidth > 0)
		{
			if (rowRightViewHeight > 0)
				
				rowRightView.frame = CGRectMake((cell.contentView.frame.size.height >= rowRightViewHeight ? cell.contentView.frame.size.width - rowRightViewWidth - rowRightViewIndentation : 0.0),
												(cell.contentView.frame.size.height >= rowRightViewHeight ? (int)((cell.contentView.frame.size.height - rowRightViewHeight) / 2) : 0.0),
												rowRightViewWidth, rowRightViewHeight);
			else
				
				rowRightView.frame = CGRectMake(cell.contentView.frame.size.width - rowRightViewWidth - rowRightViewIndentation,
												rowRightViewIndentation, rowRightViewWidth, cell.contentView.frame.size.height - rowRightViewIndentation * 2);
		}
		else
			
			if (rowRightViewHeight > 0)
				
				rowRightView.frame = CGRectMake(rowRightViewIndentation, (cell.contentView.frame.size.height >= rowRightViewHeight ? (int)((cell.contentView.frame.size.height - rowRightViewHeight) / 2) : 0.0),
												cell.contentView.frame.size.width - rowRightViewIndentation * 2, rowRightViewHeight);
			else
				
				rowRightView.frame = CGRectMake(rowRightViewIndentation, rowRightViewIndentation, cell.contentView.frame.size.width - rowRightViewIndentation * 2,
												cell.contentView.frame.size.height - rowRightViewIndentation * 2);

		if ([(id)rowRightView respondsToSelector:@selector(setEnabled:)]) [(id)rowRightView setEnabled:(rowFlags & kDisabled ? NO : YES)];

		if ([rowDictionary valueForKey:kRowLabelKey])
		{
			if (image) rowRightViewIndentation += rowRightViewIndentation + image.size.width;
			
			UILabel * rowTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(rowRightViewIndentation, 0.0,
																			   rowRightView.frame.origin.x - rowRightViewIndentation - 5.0,
																			   cell.contentView.frame.size.height - 2.0)];
			rowTextLabel.text = [rowDictionary valueForKey:kRowLabelKey];
			rowTextLabel.textAlignment = rowFlags & TEXTALIGNMENTRIGHT ? TEXTALIGNMENTRIGHT : TEXTALIGNMENTLEFT;
			rowTextLabel.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
			rowTextLabel.textColor = [UIColor blackColor];
			rowTextLabel.highlightedTextColor = [UIColor whiteColor];
			rowTextLabel.backgroundColor = [UIColor clearColor];
			rowTextLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
			rowTextLabel.tag = kRowTextLabelTag;
			rowTextLabel.enabled = rowFlags & kDisabled ? NO : YES;

			[cell.contentView addSubview:rowTextLabel];
			[rowTextLabel release];
		}

		[cell.contentView addSubview:rowRightView];
	}
	else
	if (rowFlags & kButton)
	{
		SEL selector = NSSelectorFromString([rowDictionary valueForKey:kRowSelectorNameKey]);
		if (selector && ![_delegate respondsToSelector:selector]) selector = NULL;

		UIImage * backgroundNormal = [[UIImage imageNamed:[rowDictionary valueForKey:kRowButtonBackgroundNormalKey]] stretchableImageWithLeftCapWidth:6.0 topCapHeight:0.0];
		UIImage * backgroundHighlighted = [[UIImage imageNamed:[rowDictionary valueForKey:kRowButtonBackgroundHighlightedKey]] stretchableImageWithLeftCapWidth:6.0 topCapHeight:0.0];
		UIButton * rowButton = [UIButton buttonWithType:UIButtonTypeCustom];

		rowButton.backgroundColor = [UIColor clearColor];
		rowButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		rowButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
		rowButton.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont buttonFontSize]];
		rowButton.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
		rowButton.frame = CGRectMake(0.0, 0.0, cell.contentView.frame.size.width - cell.indentationWidth * 2, cell.contentView.frame.size.height);
		rowButton.tag = kRowButtonTag;
		rowButton.enabled = rowFlags & kDisabled ? NO : YES;

		[rowButton setTitle:[rowDictionary valueForKey:kRowLabelKey] forState:UIControlStateNormal];
		[rowButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[rowButton setTitleShadowColor:[UIColor colorWithRed:(0.0 / 255.0) green:(0.0 / 255.0) blue:(0.0 / 255.0) alpha:0.7] forState:UIControlStateNormal];
		[rowButton setBackgroundImage:backgroundNormal forState:UIControlStateNormal];
		[rowButton setBackgroundImage:backgroundHighlighted forState:UIControlStateHighlighted];
		[rowButton addTarget:(selector ? _delegate : nil) action:(selector ? selector : nil) forControlEvents:UIControlEventTouchUpInside];

		cell.backgroundView = nil;
		[cell.contentView addSubview:rowButton];
	}
	else
	{
		NSString * labelText = [rowDictionary valueForKey:kRowLabelKey];
		
		if (labelText && (NSNull *)labelText == [NSNull null])
		{
			labelText = nil;
			
			if ([_delegate respondsToSelector:@selector(tableView:textForRowAtIndexPath:)]) labelText = [_delegate tableView:tableView textForRowAtIndexPath:indexPath];
		}
		
		cell.textLabel.text = labelText;
		cell.textLabel.enabled = rowFlags & kDisabled ? NO : YES;

		UIFont * labelFont = [rowDictionary valueForKey:kRowLabelFontKey];
		if (labelFont) cell.textLabel.font = labelFont;
		
		UIColor * labelTextColor = [rowDictionary objectForKey:kRowLabelTextColorKey];
		if (labelTextColor) cell.textLabel.textColor = labelTextColor;

		if ([rowDictionary objectForKey:kRowLabelLineBreakModeKey])	cell.textLabel.lineBreakMode = [[rowDictionary valueForKey:kRowLabelLineBreakModeKey] integerValue];
		if ([rowDictionary objectForKey:kRowLabelTextAlignmentKey])	cell.textLabel.textAlignment = [[rowDictionary valueForKey:kRowLabelTextAlignmentKey] integerValue];

		if (rowFlags & kMultiLineLabel)
		{
			CGFloat textLabelWidth = rowCellStyle == UITableViewCellStyleValue2 ? DETAILTEXTLABEL_POSX : cell.contentView.frame.size.width - cell.indentationWidth * 4;
			CGFloat textHeight = [cell.textLabel.text sizeWithFont:cell.textLabel.font
												 constrainedToSize:CGSizeMake(textLabelWidth, 1024)
													 lineBreakMode:LINEBREAKBYWORDWRAPPING].height;

			cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width, textHeight + cell.indentationWidth * 2);
			cell.textLabel.numberOfLines = 0;
		}

		if (cell.detailTextLabel)
		{
            NSString * detailText = [rowDictionary valueForKey:kRowDetailLabelKey];
            
            if (detailText && (NSNull *)detailText == [NSNull null])
            {
                detailText = nil;
                
                if ([_delegate respondsToSelector:@selector(tableView:detailTextForRowAtIndexPath:)]) detailText = [_delegate tableView:tableView detailTextForRowAtIndexPath:indexPath];
            }
            
			cell.detailTextLabel.text = detailText;
			cell.detailTextLabel.enabled = rowFlags & kDisabled ? NO : YES;

			UIFont * detailLabelFont = [rowDictionary valueForKey:kRowDetailLabelFontKey];
			if (detailLabelFont) cell.detailTextLabel.font = detailLabelFont;
			
			UIColor * detailLabelTextColor = [rowDictionary objectForKey:kRowDetailLabelTextColorKey];
			if (detailLabelTextColor) cell.detailTextLabel.textColor = detailLabelTextColor;

			if ([rowDictionary objectForKey:kRowDetailLabelLineBreakModeKey]) cell.detailTextLabel.lineBreakMode = [[rowDictionary valueForKey:kRowDetailLabelLineBreakModeKey] integerValue];
			if ([rowDictionary objectForKey:kRowDetailLabelTextAlignmentKey]) cell.detailTextLabel.textAlignment = [[rowDictionary valueForKey:kRowDetailLabelTextAlignmentKey] integerValue];

			if (rowFlags & kMultiLineDetailLabel && rowCellStyle == UITableViewCellStyleValue2)
			{
				CGFloat detailTextLabelWidth = cell.contentView.frame.size.width - cell.indentationWidth - ([[UIDevice currentDevice].systemVersion floatValue] >= 5 ? cell.indentationWidth * 2 : 0) - DETAILTEXTLABEL_POSX;
				CGFloat textHeight = [cell.detailTextLabel.text sizeWithFont:cell.detailTextLabel.font
														   constrainedToSize:CGSizeMake(detailTextLabelWidth, 1024)
															   lineBreakMode:LINEBREAKBYWORDWRAPPING].height;				

				cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width, textHeight + cell.indentationWidth * 2);
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
	NSMutableDictionary * rowDictionary = [[self dictionaryForRowAtIndexPath:fromIndexPath] retain];
    [[self rowsArrayForSection:fromIndexPath.section] removeObjectAtIndex:fromIndexPath.row];
    [[self rowsArrayForSection:toIndexPath.section] insertObject:rowDictionary atIndex:toIndexPath.row];
    [rowDictionary release];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_delegate respondsToSelector:@selector(tableView:commitEditingStyle:forRowAtIndexPath:)])

		[_delegate tableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
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
	NSDictionary * rowDictionary = [self dictionaryForRowAtIndexPath:indexPath];
	CGFloat rowHeight = [[rowDictionary valueForKey:kRowHeightKey] floatValue];

	if (!rowHeight && _variableRowHeight) rowHeight = [self tableView:tableView cellForRowAtIndexPath:indexPath].frame.size.height;

	return rowHeight ? rowHeight : tableView.rowHeight;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	UIColor * backgroundColor = [[self dictionaryForRowAtIndexPath:indexPath] objectForKey:kRowBackgroundColorKey];
	if (backgroundColor) cell.backgroundColor = backgroundColor;
	
	if ([_delegate respondsToSelector:@selector(tableView:willDisplayCell:forRowAtIndexPath:)])

		[_delegate tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [self rowSelectableAtIndexPath:indexPath] && [self rowEnabledAtIndexPath:indexPath] ? indexPath : nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([_delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) [_delegate tableView:tableView didSelectRowAtIndexPath:indexPath];

    NSString * viewControllerNibName = [[self dictionaryForRowAtIndexPath:indexPath] valueForKey:kRowViewControllerNibNameKey];

	if (viewControllerNibName)
	{
		Class ViewControllerClass = NSClassFromString(viewControllerNibName);
		UIViewController * tableViewController = (UIViewController *)_delegate;

		if ([tableViewController isKindOfClass:[UIViewController class]] && tableViewController.navigationController &&
			ViewControllerClass && [ViewControllerClass isSubclassOfClass:[UIViewController class]])
		{
			UIViewController * viewController = [[ViewControllerClass alloc] initWithNibName:viewControllerNibName bundle:nil];
			[tableViewController.navigationController pushViewController:viewController animated:YES];
			[viewController release];
		}
	}
	else
	{
		[tableView deselectRowAtIndexPath:indexPath animated:YES];

		NSString * string = [[self dictionaryForRowAtIndexPath:indexPath] valueForKey:kRowSelectorNameKey];
		SEL selector = NSSelectorFromString(string);

		if (selector && [_delegate respondsToSelector:selector])
		{
			if (![string hasSuffix:@":"]) [_delegate performSelector:selector];
			else
			{
				if ([string occurrencesOfString:@":"] == 1) [_delegate performSelector:selector withObject:indexPath];
				else

					[_delegate performSelector:selector
									withObject:indexPath
									withObject:[[self dictionaryForRowAtIndexPath:indexPath] valueForKey:kRowUserInfoKey]];
			}
		}
	}
}

#pragma mark - Memory management

- (void)dealloc
{
	[_dataSource release];
	[super dealloc];
}

@end
