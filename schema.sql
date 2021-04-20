use master;

go 

DROP DATABASE IF EXISTS sqlympics;
CREATE DATABASE sqlympics;

go 

USE sqlympics;

create table suits(
    id int IDENTITY
    ,suit varchar(50)
    ,PRIMARY KEY (id)
) 

create table cards(
    id int IDENTITY
    ,card varchar(50)
    ,suit_id int
    ,value int
    ,bitwise as cast(power(cast(2 as bigint),cast(id as bigint)-1) as bigint)
    ,PRIMARY KEY (id)
    ,CONSTRAINT fk_cards_suits FOREIGN KEY (suit_id) REFERENCES suits(id)
)

create table seats(
    id int IDENTITY
    ,name varchar(50)
    ,PRIMARY KEY (id)
)

create table runs(
    id int 
    ,PRIMARY KEY (id)
);

create table rounds(
    id int IDENTITY
    ,run_id int
    ,analyzed bit DEFAULT 0
    ,PRIMARY KEY (id)
    ,CONSTRAINT fk_runs_rounds FOREIGN KEY (run_id) REFERENCES runs(id)
)

create table deal (
    id int IDENTITY
    ,seat_id int
    ,card_id int
    ,round_id int 
    ,PRIMARY KEY (id)
    ,CONSTRAINT fk_seats_hands FOREIGN KEY (seat_id) REFERENCES seats(id)
    ,CONSTRAINT fk_cards_hands_cards FOREIGN KEY (card_id) REFERENCES cards(id)
    ,CONSTRAINT fk_rounds_hands FOREIGN KEY (round_id) REFERENCES rounds(id)
)

create table community_cards(
    id int IDENTITY
    ,card_id int
    ,round_id int
    ,PRIMARY KEY (id)
    ,CONSTRAINT fk_cards_community_cards FOREIGN KEY (card_id) REFERENCES cards(id)
    ,CONSTRAINT fk_rounds_community_cards FOREIGN KEY (round_id) REFERENCES rounds(id)
)

create table winner_types(
    id int IDENTITY
    ,name varchar(20)
    ,PRIMARY KEY(id)
)

create table winners(
    id int IDENTITY
    ,winner_type_id int
    ,bitwise bigint 
    ,card_1_value INT
    ,card_2_value INT
    ,card_3_value INT
    ,card_4_value INT
    ,card_5_value INT
    ,PRIMARY KEY (id)
    ,CONSTRAINT fk_winners_winner_types FOREIGN KEY (winner_type_id) REFERENCES winner_types(id)
)

CREATE TABLE summary_results(
    id int IDENTITY 
    ,generic_hand_type varchar(50)
    ,num_players int
    ,num_deals int
    ,wins int 
    ,ties int 
    ,tie_pct as cast(ties as numeric(10,2))/cast(num_deals as numeric(10,2)) 
    ,win_pct_excl_ties as cast(wins as numeric(10,2))/cast(num_deals as numeric(10,2)) 
    ,win_pct_incl_ties as (cast(wins as numeric(10,2)) + cast(ties as numeric(10,2)))/cast(num_deals as numeric(10,2))      
    ,PRIMARY KEY (id)
)

insert into suits(suit) VALUES('Spades');
insert into suits(suit) VALUES('Clubs');
insert into suits(suit) VALUES('Diamonds');
insert into suits(suit) VALUES('Hearts');

declare @spades int, @clubs int, @diamonds int, @hearts int
select @spades = id from suits where suit = 'spades'
select @spades = id from suits where suit = 'spades'
select @spades = id from suits where suit = 'spades'

INSERT INTO cards (card,suit_id,value)
VALUES('Ace of Hearts',4,1)
,('Ace of Diamonds',3,1)
,('Ace of Clubs',2,1)
,('Ace of Spades',1,1)
,('2 of Hearts',4,2)
,('2 of Diamonds',3,2)
,('2 of Clubs',2,2)
,('2 of Spades',1,2)
,('3 of Hearts',4,3)
,('3 of Diamonds',3,3)
,('3 of Clubs',2,3)
,('3 of Spades',1,3)
,('4 of Hearts',4,4)
,('4 of Diamonds',3,4)
,('4 of Clubs',2,4)
,('4 of Spades',1,4)
,('5 of Hearts',4,5)
,('5 of Diamonds',3,5)
,('5 of Clubs',2,5)
,('5 of Spades',1,5)
,('6 of Hearts',4,6)
,('6 of Diamonds',3,6)
,('6 of Clubs',2,6)
,('6 of Spades',1,6)
,('7 of Hearts',4,7)
,('7 of Diamonds',3,7)
,('7 of Clubs',2,7)
,('7 of Spades',1,7)
,('8 of Hearts',4,8)
,('8 of Diamonds',3,8)
,('8 of Clubs',2,8)
,('8 of Spades',1,8)
,('9 of Hearts',4,9)
,('9 of Diamonds',3,9)
,('9 of Clubs',2,9)
,('9 of Spades',1,9)
,('10 of Hearts',4,10)
,('10 of Diamonds',3,10)
,('10 of Clubs',2,10)
,('10 of Spades',1,10)
,('Jack of Hearts',4,11)
,('Jack of Diamonds',3,11)
,('Jack of Clubs',2,11)
,('Jack of Spades',1,11)
,('Queen of Hearts',4,12)
,('Queen of Diamonds',3,12)
,('Queen of Clubs',2,12)
,('Queen of Spades',1,12)
,('King of Hearts',4,13)
,('King of Diamonds',3,13)
,('King of Clubs',2,13)
,('King of Spades',1,13);


insert into seats(name)
VALUES
     (1)
    ,(2)
    ,(3)
    ,(4)
    ,(5)
    ,(6)
    ,(7)
    ,(8)
    ,(9)
    ,(10);

insert into winner_types(name)
VALUES
     ('Straight flush')
    ,('Four of a kind')
    ,('Full house')
    ,('Flush')
    ,('Straight')
    ,('Three of a kind')	
    ,('Two pair')
    ,('One pair')
    ,('High');
