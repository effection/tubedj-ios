//
//  JHYoutubeSongCell.m
//  tubedj
//
//  Created by Jordan Hamill on 01/08/2013.
//  Copyright (c) 2013 Jordan Hamill. All rights reserved.
//

#import "JHYoutubeSongCell.h"
#import "JHYoutubeSongCellBackgroundView.h"

@interface JHYoutubeSongCell()
@property (weak, nonatomic) IBOutlet UIImageView *previewImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *ownerLabel;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;

@property (strong, nonatomic) JHYoutubeSongCellBackgroundView *addBackground;

- (void)commonInit;

@end

@implementation JHYoutubeSongCell {
	BOOL hitAddButton;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self commonInit];
    }
    return self;
}


- (void)awakeFromNib
{
	[super awakeFromNib];
	[self commonInit];
}

- (void)commonInit
{
	self.selectionStyle = UITableViewCellSelectionStyleNone;
	self.contentView.backgroundColor = [UIColor app_darkGrey];
	
	self.backgroundColor = [UIColor app_darkGrey];
	self.titleLabel.textColor = [UIColor app_offWhite];
	self.ownerLabel.textColor = [UIColor app_lightGrey];
	self.ageLabel.textColor = [UIColor app_lightGrey];
	self.backView = self.addBackground = [GeneralUI loadViewFromNib:[JHYoutubeSongCellBackgroundView class]];
	
	self.revealDirection = RMSwipeTableViewCellRevealDirectionLeft;
}

- (void)prepareForReuse
{
	[super prepareForReuse];
	hitAddButton = NO;
	self.animationDuration = 0.2;
}

-(BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)panGestureRecognizer
{
	if(hitAddButton) return NO;
	
	return [super gestureRecognizerShouldBegin:panGestureRecognizer];
}

- (void)animateContentViewForPoint:(CGPoint)point velocity:(CGPoint)velocity
{
	[super animateContentViewForPoint:point velocity:velocity];
	float alpha = 0;
	if(self.canDelete) {
		float closeToTick = MAX(0, (-point.x) - 130) ;
		alpha = closeToTick / (195 - 130);
		self.addBackground.addButton.alpha = alpha;

		if(alpha < 1)
			self.addBackground.addButton.titleLabel.textColor = [UIColor app_lightGrey];
		else {
			self.addBackground.addButton.titleLabel.textColor = [UIColor app_red];
			hitAddButton = YES;
			self.animationDuration = 1.0;
		}
		alpha = MIN(1, 1);
	} else {
		float closeToTick = MAX(0, point.x - 152);
		alpha = closeToTick / (195 - 152);
		self.addBackground.addButton.alpha = alpha;
		if(alpha < 1)
			self.addBackground.addButton.titleLabel.textColor = [UIColor app_lightGrey];
		else {
			self.addBackground.addButton.titleLabel.textColor = [UIColor app_green];
			hitAddButton = YES;
			self.animationDuration = 1.0;
		}
		alpha = MIN(1, (point.x - 30) / 320);
	}
	
	self.addBackground.dot1.alpha = MIN(0.4, alpha);
	self.addBackground.dot2.alpha = MIN(0.4, alpha);
	self.addBackground.dot3.alpha = MIN(0.4, alpha);
	self.addBackground.dot4.alpha = MIN(0.4, alpha);
}

- (void)setCanDelete:(BOOL)canDelete
{
	if(_canDelete == canDelete) return;
	
	_canDelete = canDelete;
	if(canDelete)
	{
		self.revealDirection = RMSwipeTableViewCellRevealDirectionRight;
	} else
	{
		self.revealDirection = RMSwipeTableViewCellRevealDirectionLeft;
	}
	self.addBackground.canDelete = canDelete;
}


@end
