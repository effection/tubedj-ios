//
//  JHYoutubeSongCell.m
//  tubedj
//
//  Created by Jordan Hamill on 01/08/2013.
//  Copyright (c) 2013 Jordan Hamill. All rights reserved.
//

#import "JHYoutubeSongCell.h"
#import "JHYoutubeSongCellBackgroundView.h"
#import "JHYoutubeClient.h"

@interface JHYoutubeSongCell()

@property (strong, nonatomic) UIImageView *playIndicator;
@property (strong, nonatomic) JHYoutubeSongCellBackgroundView *addBackground;

- (void)commonInit;

@end

@implementation JHYoutubeSongCell {
	

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
	self.contentView.clipsToBounds = YES;
	
	self.backgroundColor = [UIColor app_darkGrey];
	self.titleLabel.textColor = [UIColor app_offWhite];
	self.ownerLabel.textColor = [UIColor app_lightGrey];
	self.ageLabel.textColor = [UIColor app_lightGrey];
	self.backView = self.addBackground = [GeneralUI loadViewFromNib:[JHYoutubeSongCellBackgroundView class]];
	
	self.revealDirection = RMSwipeTableViewCellRevealDirectionLeft;
	self.actionSuccessful = NO;
	
	self.playIndicator = [[UIImageView alloc] initWithFrame:CGRectMake(273, 35, 47, 47)];
	self.playIndicator.image = [UIImage imageNamed:@"play-indicator"];
	self.playIndicator.alpha = 0.4;
	self.playIndicator.contentMode = UIViewContentModeTopLeft;
	self.playIndicator.clipsToBounds = YES;
	[self.contentView addSubview:self.playIndicator];
	self.playIndicator.hidden = YES;
	self.canDelete = NO;
	
}

- (void)prepareForReuse
{
	[super prepareForReuse];
	self.actionSuccessful = NO;
	self.isPlaying = NO;
	self.isPerformingAction = NO;
	self.animationDuration = 0.2;
}

-(BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)panGestureRecognizer
{
	if(self.actionSuccessful) return NO;
	
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
			self.actionSuccessful = YES;
			
			self.addBackground.addButton.titleLabel.textColor = [UIColor app_red];
			self.animationDuration = 0.6;
			
			if([self.actionDelegate respondsToSelector:@selector(songCellTriggeredDeleteAction:)])
				[self.actionDelegate songCellTriggeredDeleteAction:self];
		}
		alpha = MIN(1, 1);
	} else {
		float closeToTick = MAX(0, point.x - 152);
		alpha = closeToTick / (195 - 152);
		self.addBackground.addButton.alpha = alpha;
		if(alpha < 1)
			self.addBackground.addButton.titleLabel.textColor = [UIColor app_lightGrey];
		else {
			self.actionSuccessful = YES;
			
			self.addBackground.addButton.titleLabel.textColor = [UIColor app_green];
			self.animationDuration = 0.6;
			
			if([self.actionDelegate respondsToSelector:@selector(songCellTriggeredAddAction:)])
				[self.actionDelegate songCellTriggeredAddAction:self];
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

- (void)setIsPlaying:(BOOL)isPlaying
{
	_isPlaying = isPlaying;
	self.playIndicator.hidden = !_isPlaying;
}

- (void)setActionSuccessful:(BOOL)actionSuccessful
{
	_actionSuccessful = actionSuccessful;
	[UIView animateWithDuration:0.3f
					 animations:^{
						 float alpha = (!actionSuccessful ? 1.0f : 0.4f);
						 self.previewImage.alpha = alpha;
						 self.titleLabel.alpha = alpha;
						 self.ownerLabel.alpha = alpha;
						 self.ageLabel.alpha = alpha;
						 self.titleLabel.textColor = (!actionSuccessful ? [UIColor app_offWhite] : (self.canDelete ? [UIColor app_red] : [UIColor app_green]));
					 }];
}


@end
