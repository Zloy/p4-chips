[![Build Status](https://travis-ci.org/Zloy/p4-chips.png)](https://travis-ci.org/Zloy/p4-chips)
[![Coverage Status](https://coveralls.io/repos/Zloy/p4-chips/badge.png)](https://coveralls.io/r/Zloy/p4-chips)

p4-chips
=======

Provide game virtual chips, handle game and players chips balances, gains and losses.

## Testing

    cd <gem root directory>
    bundle exec rake

## Chips

Without chips player cannot play game. Player can buy chips, sell them, win and lose in games.

Chips are measured in natural numbers.

## Interface

### Setting up

This gem should be informed of Player class and Player object method which returns player identifier. 
The Player object identifier should be an Integer. It also needs api entry point name. 

Here `User` object has `:id` method and is to be granted `:balance` entry method

    P4::Chips.configure User, :id, :balance
    
and here `P4::Chips::TestUser` object has `:id` method and is to be granted `:chips` entry method

    P4::Chips.configure P4::Chips::TestUser, :id, :chips

### Buying, selling chips

To get chips a player should buy them. DB transaction takes place in a block.

    player1.chips.buy(2800) do |chips|
      # withdraw player1 money here
    end

A player can sell chips. DB transaction takes place in a block.

    player1.chips.sell(1600) do |chips|
      # deposit player1 money here
    end

If player1 has less free chips than to be sold, `P4::BALANCE::INSUFFICIENT_FUNDS` exception is being raised.

### Checking chips balances

Player chips could be either free (available to join a game), or reserved if the player has already joined game(s).

    player1.chips.free         # 1200 chips are available to perform reservation for a game
    player1.chips.reserved     #   [] chips are reserved for certain game(s) or empty array

### Reserving chips as player's stack in a game

Before a game starts players should reserve some chips for it - bring an initial stack (certain number of chips) on the table. 

These chips become reserved for certain game.

    player1.chips.reserve_game(200, 324565) # chips, game_id
    player1.chips.free         # 1000 chips are available to perform reservation for a game
    player1.chips.reserved     # [{game_id: 324565, chips: 200}] chips are reserved for certain game

If player tries to reserve more chips than he has, `P4::BALANCE::INSUFFICIENT_FUNDS` exception is being raised.

### Reservation cancellation

When player1 decides not to wait the game to be started, which occures when certain number of players joined the game, he could leave the game if the game has not being started yet.

    player1.chips.free_game(324565) # game_id
    
Entire game could be canceled

    Chips.free_game(324565) # game_id

### Win, lose game results fix

When the game ends one player (or some of them) win chips, others lose.

The game could fix the final result at once
    
    Chips.fix_game(324565) do # game_id
      player1.chips.gain(200)
      player2.chips.lose(200)
    end

or could perform a series of intermediate results fixes: 

    Chips.fix_game(324565) do # game_id
      player1.chips.gain(20)
      player2.chips.lose(20)
    end
    ...
    Chips.fix_game(324565) do # game_id
      player1.chips.gain(180)
      player2.chips.lose(180)
    end

If the game tries to fix more chips than left reserved to it, `P4::BALANCE::INSUFFICIENT_FUNDS` exception is being raised.
