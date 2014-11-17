p4-chips
=======

Provide virtual game chips, handle game and players chips balances, gains and losses

## Chips

Without chips player can not play games. Player can buy chips, sell them, win and lose in games.

## Interface

### Checking chips balances

    player1.balance.chips    # 1200
    player2.balance.chips    # 400

### Reserving chips as player's stack in a game

Before a game starts players should bring an initial stack (certain number of chips) on the table. These chips are become reserved for certain game.

    player1.balance.chips.for_game_id(324565).reserve(200)
    player2.balance.chips.for_game_id(324565).reserve(200)
    player1.balance.chips    # 1000
    player2.balance.chips    # 200

If player tries to reserve more chips than he has, `P4::BALANCE::INSUFFICIENT_FUNDS` exception is being raised.

The reservation could be persisted in a database one by one, e.g. when pleayer joins the game.

    player1.balance.chips.for_game_id(324565).reserve(200).persist
    # or 
    reservation = player1.balance.chips.for_game_id(324565).reserve(200)
    reservation.persist
    
### Reservation cancellation

When player1 decides not to wait the game gets required players number, he could leave the game if the game has not being started yet.

    player1.balance.chips.for_game_id(324565).cancel
    # or
    reservation = player1.balance.chips.for_game_id(324565).reserve(200)
    reservation.cancel
    
In that case if reservation has being persisted, the cancellation could be persisted too.

    reservation.cancel.persist
    #or
    reservation.persist

If entire game should be canceled

    Balance.chips.for_game_id(324565).cancel

If entire game should be canceled and persisted

    Balance.chips.for_game_id(324565).cancel.persist

### Win/lose game results fixing

When the game ends. One player (or some of them) win chips, others lose.
    
    player1.balance.chips.for_game_id(324565).gain(200)
    player2.balance.chips.for_game_id(324565).lose(200)
    
These gains and losses could be persisted in a database all at once.

    Balance.chips.for_game_id(324565).persist
