//
//  PokemonInfoViewController.h
//  Pokemon
//
//  Created by Kaijie Yu on 2/6/12.
//  Copyright (c) 2012 Kjuly. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TrainerTamedPokemon;

@interface SixPokemonsDetailViewController : UIViewController
{
  TrainerTamedPokemon * pokemon_;
}

@property (nonatomic, retain) TrainerTamedPokemon * pokemon;

- (id)initWithPokemon:(TrainerTamedPokemon *)pokemon;

@end