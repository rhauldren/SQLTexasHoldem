# sqlympics

<img src='images/schema.png'></img>


## Instructions

1. To run the code on sql server in a docker container execute `./build_docker_containter.sh`.  (Connection instructions will be printed in the termainal output.)
2. In sql server execute 
   - schema.sql
   - gen_winners.sql
   - gen_rounds.sql
   - winner_winner_chicken_dinner.sql
   
### Sample Run
```
use sqlympics
exec gen_rounds @rounds = 1000, @seats = 10
exec gen_rounds @rounds = 1000, @seats = 9
exec gen_rounds @rounds = 1000, @seats = 8
exec gen_rounds @rounds = 1000, @seats = 7
exec gen_rounds @rounds = 1000, @seats = 6
exec gen_rounds @rounds = 1000, @seats = 5
exec gen_rounds @rounds = 1000, @seats = 4
exec gen_rounds @rounds = 1000, @seats = 3
exec gen_rounds @rounds = 1000, @seats = 2

exec winner_winner_chicken_dinner

select * 
from summary_results 
where num_players = 6 
order by num_players, win_pct_incl_ties desc
```


## The Gist
The main feature of our poker solution is a bitwise lookup table. This allows our model to identify each 5-card poker hand in each 7-card set. using the results of our simulations, we build aggregate statistics on win % of each 169 unique generic hands for n players at the table. 

## Summary of each file
1. schema
   - The schema consists of the typical poker components: cards, suits, community cards, deals, seats and rounds
   - Our card table consists of a bitwise column that converts each card to a unique bit value
   - Additionally, there is a table (winners) for each winning hand and type (e.g. straight flush, flush, two pair) represented as a singular bitwise value
   - Lastly, a table holding the statistical summary of the simulation is what drive our analysis portion
   
2. gen_winners
   - Seperate functions are used to generate every possible combination of each winning hand type, from straight flush to high card
   - Populates 'Winners' table
   
3. gen_rounds
   - This procedure is our "dealer" 
   - Given a number of rounds and seats, this procedure will deal each pair of hole cards, community cards and burn cards

4. winner_winner_chicken_dinner
   - cha-ching!
   - This proc starts by flattening out each hand that has not been analyzed
   - It perfroms a bitwise OR operation on all 7 available cards to construct a unique value for the hand
   - By joining these hands onto the Winners table with a Bitwise & operator, we return each possible winning hand within the 7 card set
   - Through a series of window funtions, we are able to select the best winning hand within the round and crown a winner or call it a draw
   - The final results are merged into our summary_results table and the rounds are marked analyzed
   
   
   Example: 
   - Player 1 has these 7 cards available: 
     
     Deal:3H,4H  
      Community 4S,5H,6H,7H,3D
      
   - The bitwise & join onto winners will return the following results: straight flush, flush,straight, two pair, one pair (3), one pair(4), high card(7), high card(6), high card (5), high card(4) and high card(3)
   - With a partitioning over winner_type_id and the cards contained in the winning hand, we can select the highest ranked matched hand which would be the straight flush
   
   - Player 2 has these 7 cards available: 
       Deal:8H,JH  
      Community 4S,5H,6H,7H,3D
      
    - This bitwise join returns the following: straight flush, flush, straight, high card for each card
    
  - When winner winner steps through this, it compares each card from highest to lowest. The tie would be broken on the high card of 8H and Player 2 would be crowned winner. 
   
   
   
   

