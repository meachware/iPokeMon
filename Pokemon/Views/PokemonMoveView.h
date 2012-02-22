//
//  PokemonMoveView.h
//  Pokemon
//
//  Created by Kaijie Yu on 2/22/12.
//  Copyright (c) 2012 Kjuly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PokemonMoveView : UIView
{
  UILabel * type1_;
  UILabel * type2_;
  UILabel * name_;
  UILabel * pp_;
}

@property (nonatomic, retain) UILabel * type1;
@property (nonatomic, retain) UILabel * type2;
@property (nonatomic, retain) UILabel * name;
@property (nonatomic, retain) UILabel * pp;

@end