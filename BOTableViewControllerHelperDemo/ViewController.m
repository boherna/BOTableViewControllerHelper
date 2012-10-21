//
//  ViewController.m
//  BOTableViewControllerHelperDemo
//
//  Created by Bohdan Hernandez Navia on 21/10/2012.
//  Copyright (c) 2012 Bohdan Hernandez Navia. All rights reserved.
//

#import "ViewController.h"
#import "BOTableViewControllerHelper.h"

@interface ViewController () <BOTableViewControllerHelperDelegate, UITextViewDelegate>

@property (retain, nonatomic) BOTableViewControllerHelper * tableViewControllerHelper;
@property (retain, nonatomic) IBOutlet UITableView * tableView;
@property (retain, nonatomic) IBOutlet UIView * captionView;
@property (retain, nonatomic) IBOutlet UITextView * captionTextView;
@property (retain, nonatomic) IBOutlet UILabel * captionLengthLabel;
@property (retain, nonatomic) UISwitch * shareOnFacebookSwitch;
@property (retain, nonatomic) UISwitch * shareOnTwitterSwitch;

@end

@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
	{
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

	NSDictionary * captionSection = [NSDictionary dictionaryWithObjectsAndKeys:
									 [NSArray arrayWithObjects:
									  [NSMutableDictionary dictionaryWithObjectsAndKeys:
									   [NSNumber numberWithFloat:115.0], kRowHeightKey,
									   [NSNumber numberWithUnsignedInteger:(kRightView)], kRowFlagsKey,
									   [NSNumber numberWithFloat:0.0], kRowRightViewWidthKey,
									   [NSNumber numberWithFloat:0.0], kRowRightViewHeightKey,
									   [NSNumber numberWithFloat:5.0], kRowRightViewIndentationKey,
									   self.captionView, kRowRightViewKey,
									   nil],
									  nil], kRowsArrayKey,
									 nil];

	NSDictionary * sharingSection = [NSDictionary dictionaryWithObjectsAndKeys:
									 NSLocalizedString(@"sharingHeaderTitle", @""), kSectionHeaderTitleKey,
									 NSLocalizedString(@"sharingFooterTitle", @""), kSectionFooterTitleKey,
									 [NSArray arrayWithObjects:
									  [NSMutableDictionary dictionaryWithObjectsAndKeys:
									   [NSNumber numberWithUnsignedInteger:(kRightView)], kRowFlagsKey,
									   NSLocalizedString(@"shareOnFacebookRowLabel", @""), kRowLabelKey,
									   [UIImage imageNamed:@"facebook-icon.png"], kRowImageKey,
									   self.shareOnFacebookSwitch, kRowRightViewKey,
									   nil],
									  [NSMutableDictionary dictionaryWithObjectsAndKeys:
									   [NSNumber numberWithUnsignedInteger:(kRightView)], kRowFlagsKey,
									   NSLocalizedString(@"shareOnTwitterRowLabel", @""), kRowLabelKey,
									   [UIImage imageNamed:@"twitter-icon.png"], kRowImageKey,
									   self.shareOnTwitterSwitch, kRowRightViewKey,
									   nil],
									  nil], kRowsArrayKey,
									 nil];

	NSDictionary * logoutSection = [NSDictionary dictionaryWithObjectsAndKeys:									
									[NSArray arrayWithObjects:
									 [NSMutableDictionary dictionaryWithObjectsAndKeys:
									  [NSNumber numberWithUnsignedInteger:(kSelectable | kTextAlignmentCenter)], kRowFlagsKey,
									  NSLocalizedString(@"logoutRowLabel", @""), kRowLabelKey,
									  @"logoutAction", kRowSelectorNameKey,
									  nil],
									 nil], kRowsArrayKey,
									nil];

	self.tableViewControllerHelper = [BOTableViewControllerHelper dataSourceWithArray:[NSMutableArray arrayWithObjects:captionSection, sharingSection, logoutSection, nil]];
	_tableViewControllerHelper.delegate = self;

	_captionTextView.autocapitalizationType = UITextAutocapitalizationTypeSentences;
	_captionTextView.autocorrectionType = UITextAutocorrectionTypeYes;
	_captionTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _captionTextView.backgroundColor = [UIColor clearColor];
	_captionTextView.font = [UIFont systemFontOfSize:15.0];
	_captionTextView.returnKeyType = UIReturnKeyDone;
	_captionTextView.keyboardType = UIKeyboardTypeDefault;
    _captionTextView.autocorrectionType = UITextAutocorrectionTypeNo;
	_captionTextView.scrollEnabled = YES;
    _captionTextView.delegate = self;
	_captionTextView.tag = kRowRightViewTag;
	_captionTextView.text = NSLocalizedString(@"captionPlaceholder", @"");
	_captionTextView.textColor = [UIColor lightGrayColor];
	
	_captionLengthLabel.font = [UIFont systemFontOfSize:10.0];
	[self updateNumberOfChars];

	_shareOnFacebookSwitch.on = YES;
	_shareOnTwitterSwitch.on = NO;
	
	_tableView.dataSource = _tableViewControllerHelper;
	_tableView.delegate = _tableViewControllerHelper;
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.scrollEnabled = YES;
    [_tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return YES;
}

- (BOOL)shouldAutorotate
{
	return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskAll;
}

- (void)switchAction:(id)sender
{
}

- (void)logoutAction
{
	[[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"logoutAlertTitle", @"")
								 message:NSLocalizedString(@"logoutAlertMessage", @"")
								delegate:nil
					   cancelButtonTitle:NSLocalizedString(@"OK", @"")
					   otherButtonTitles:nil] autorelease] show];
}

- (NSString *)actualCaptionText
{
	return !_captionTextView.text || [_captionTextView.text isEqualToString:NSLocalizedString(@"captionPlaceholder", @"")] ? @"" : _captionTextView.text;
}

- (void)updateNumberOfChars
{
	NSString * text = [self actualCaptionText];
	_captionLengthLabel.hidden = text.length ? NO : YES;
	_captionLengthLabel.text = [NSString stringWithFormat:NSLocalizedString(@"numberOfChars", @""), 140 - text.length];
	_captionLengthLabel.textColor = text.length > 140 ? [UIColor colorWithRed:255.0/255.0 green:70.0/255.0 blue:70.0/255.0 alpha:1.0] : [UIColor lightGrayColor];
}

#pragma mark - Memory management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
	[_tableView release];
	[_tableViewControllerHelper release];
	[_captionView release];
	[_captionTextView release];
	[_captionLengthLabel release];
	[_shareOnFacebookSwitch release];
	[_shareOnTwitterSwitch release];
	[super dealloc];
}

- (void)viewDidUnload
{
	[self setTableView:nil];
	[self setCaptionView:nil];
	[self setCaptionTextView:nil];
	[self setCaptionLengthLabel:nil];
	self.shareOnFacebookSwitch = nil;
	self.shareOnTwitterSwitch = nil;
	[super viewDidUnload];
}

#pragma mark - Lazy creation of controls

- (UISwitch *)createSwitch
{
	UISwitch * switchControl = [[[UISwitch alloc] initWithFrame:CGRectZero] autorelease];
	[switchControl addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
	switchControl.backgroundColor = [UIColor clearColor];
	switchControl.tag = kRowRightViewTag;
	switchControl.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    return switchControl;
}

- (UISwitch *)shareOnFacebookSwitch
{
	return _shareOnFacebookSwitch ? _shareOnFacebookSwitch : (self.shareOnFacebookSwitch = [self createSwitch]);
}

- (UISwitch *)shareOnTwitterSwitch
{
	return _shareOnTwitterSwitch ? _shareOnTwitterSwitch : (self.shareOnTwitterSwitch = [self createSwitch]);
}

#pragma mark - UITextView delegate methods

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
	if ([textView.text isEqualToString:NSLocalizedString(@"captionPlaceholder", @"")])
	{
		_captionTextView.textColor = [UIColor blackColor];
		_captionTextView.text = nil;
	}
	return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
	if (!textView.text || !textView.text.length)
	{
		_captionTextView.textColor = [UIColor lightGrayColor];
		_captionTextView.text = NSLocalizedString(@"captionPlaceholder", @"");
	}
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
	{
        [textView resignFirstResponder];
        return FALSE;
    }

	[self performSelector:@selector(updateNumberOfChars) withObject:nil afterDelay:0.1];
    return TRUE;
}
@end
