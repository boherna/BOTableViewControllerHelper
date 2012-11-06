//
//  CustomCell.m
//  BOTableViewControllerHelperDemo
//
//  Created by Bohdan Hernandez Navia on 02/11/2012.
//  Copyright (c) 2012 Bohdan Hernandez Navia. All rights reserved.
//

#import "CustomCell.h"

@implementation CustomCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]))
	{
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
	[super awakeFromNib];

	// Additional set up for objects
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
