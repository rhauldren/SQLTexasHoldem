SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER   PROCEDURE [dbo].[winner_winner_chicken_dinner] 

as


SET NOCOUNT ON;

-- Flatten Deal Table to get each players hand

drop table if exists #hands
select 
    h.id as run
    ,h.round_id
    ,p.num_players
    ,h.seat_id  
    ,case   
            when d1.value = d2.value then 'Pocket ' + left(d1.card,charindex(' ',d1.card) - 1) +'''s'
            when d1.value = 1 and d1.suit_id <> d2.suit_id then left(d1.card,charindex(' ',d1.card) - 1) + ', ' +  left(d2.card,charindex(' ',d2.card) - 1) + ' unsuited' 
            when d1.value = 1 and d1.suit_id = d2.suit_id then left(d1.card,charindex(' ',d1.card) - 1) + ', ' +  left(d2.card,charindex(' ',d2.card) - 1) + ' suited' 
            when d1.suit_id <> d2.suit_id then left(d2.card,charindex(' ',d2.card) - 1) + ', ' +  left(d1.card,charindex(' ',d1.card) - 1) + ' unsuited' 
            else left(d2.card,charindex(' ',d2.card) - 1) + ', ' +  left(d1.card,charindex(' ',d1.card) - 1) + ' suited' 
            end as generic_hand_type
    ,case 
        when d1.value = 1 and d2.value <> 1 then d2.VALUE
        when (d1.[value] = 1 and d2.value = 1) then 14 
        when d1.value = 1 then 14 else d1.value 
        end as deal_1_value
    ,case 
        when d1.value = 1 and d2.value <> 1 then 14 
        when d1.value = 1 and d2.value = 1 then 14 
        when d2.value = 1 then 14
        else d2.value 
        end as deal_2_value
    ,d1.card as deal_1
    ,d2.card as deal_2
    ,c1.card as flop_1
    ,c2.card as flop_2
    ,c3.card as flop_3
    ,c4.card as river
    ,c5.card as turn
    ,d1.bitwise | d2.bitwise | c1.bitwise | c2.bitwise | c3.bitwise | c4.bitwise | c5.bitwise as hand_bits
into #hands
from 
(
    select distinct 
    r.id
    ,d.round_id
    ,d.seat_id
    ,ro.analyzed
    from deal d
    join rounds ro 
        on ro.id=d.round_id
    join runs r
        on r.id=ro.run_id
    where isnull(ro.analyzed,0)=0
) h
join (
    select 
        r.id
        ,d.round_id
        ,d.seat_id
        ,d.card_id
        ,c.bitwise
        ,c.card
        ,c.[value]
        ,c.suit_id
        ,rank() over(partition by d.seat_id,d.round_id order by c.id desc) as rank
    from deal d
    join rounds ro on ro.id=d.round_id
    join runs r on ro.run_id=r.id
    join cards c on d.card_id=c.id
) d1 on d1.round_id=h.round_id and d1.seat_id=h.seat_id and h.id=d1.id and d1.rank = 2
join (
    select 
        r.id
        ,d.round_id
        ,d.seat_id
        ,d.card_id
        ,c.bitwise
        ,c.card
        ,c.[value]
        ,c.suit_id
        ,rank() over(partition by d.seat_id,d.round_id order by c.id desc) as rank
    from deal d
    join rounds ro on ro.id=d.round_id
    join runs r on ro.run_id=r.id
    join cards c on d.card_id=c.id
) d2 on d2.round_id=h.round_id and d2.seat_id=h.seat_id and h.id=d2.id and d2.rank = 1
join (
    select 
        r.id
        ,cc.round_id
        ,cc.card_id
        ,c.bitwise
        ,c.card
        ,rank() over(partition by cc.round_id order by cc.id desc) as rank
    from community_cards cc
    join rounds ro on ro.id=cc.round_id
    join runs r on ro.run_id=r.id
    join cards c on cc.card_id=c.id
) c1 on c1.round_id=h.round_id and h.id=c1.id and c1.rank = 2
join (
    select 
        r.id
        ,cc.round_id
        ,cc.card_id
        ,c.bitwise
        ,c.card
        ,rank() over(partition by cc.round_id order by cc.id desc) as rank
    from community_cards cc
    join rounds ro on ro.id=cc.round_id
    join runs r on ro.run_id=r.id
    join cards c on cc.card_id=c.id
) c2 on c2.round_id=h.round_id and h.id=c2.id and c2.rank = 3
join (
    select 
        r.id
        ,cc.round_id
        ,cc.card_id
        ,c.bitwise
        ,c.card
        ,rank() over(partition by cc.round_id order by cc.id desc) as rank
    from community_cards cc
    join rounds ro on ro.id=cc.round_id
    join runs r on ro.run_id=r.id
    join cards c on cc.card_id=c.id
) c3 on c3.round_id=h.round_id and h.id=c3.id and c3.rank = 4
join (
    select 
        r.id
        ,cc.round_id
        ,cc.card_id
        ,c.bitwise
        ,c.card
        ,rank() over(partition by cc.round_id order by cc.id desc) as rank
    from community_cards cc
    join rounds ro on ro.id=cc.round_id
    join runs r on ro.run_id=r.id
    join cards c on cc.card_id=c.id
) c4 on c4.round_id=h.round_id and h.id=c4.id and c4.rank = 6
join (
    select 
        r.id
        ,cc.round_id
        ,cc.card_id
        ,c.bitwise
        ,c.card
        ,rank() over(partition by cc.round_id order by cc.id desc) as rank
    from community_cards cc
    join rounds ro on ro.id=cc.round_id
    join runs r on ro.run_id=r.id
    join cards c on cc.card_id=c.id
) c5 on c5.round_id=h.round_id and h.id=c5.id and c5.rank = 8
join (
    select  
    r.id
    ,d.round_id
    ,max(d.seat_id) as num_players
    from deal d
    join rounds ro 
        on ro.id=d.round_id
    join runs r
        on ro.run_id=r.id
    group by r.id,d.round_id
) p on h.round_id=p.round_id


--CREATE INDEX ix_hand on #hands(hand_bits)

-- Join hands to winnning_hands table to get all winning_hand_types
drop table if exists #matched
select 
    h.round_id,
    h.num_players,
    h.seat_id,
    h.generic_hand_type,
    h.deal_1_value,
    h.deal_2_value,
    h.deal_1,
    h.deal_2,
    h.flop_1,
    h.flop_2,
    h.flop_3,
    h.turn,
    h.river,
    w1.winner_type_id,
    case when wt1.name = 'Straight Flush' and w1.card_5_value = 1 then 'Royal Flush' else wt1.name end as hand_winning_type,
    w1.card_1_value as wc_1,
    case when w1.card_2_value = 1 then 14 else w1.card_2_value end as wc_2,
    case when w1.card_3_value = 1 then 14 else w1.card_3_value end as wc_3,
    case when w1.card_4_value = 1 then 14 else w1.card_4_value end as wc_4,
    case when w1.card_5_value = 1 then 14 else w1.card_5_value end as wc_5
into #matched
from #hands h
join winners w1 on w1.bitwise=(h.hand_bits & w1.bitwise)
join winner_types wt1 on w1.winner_type_id=wt1.id 


--CREATE INDEX ix_winners_bitwise on winners(bitwise) 

--Order winning hand types by winning type id and then descending for each card in the 5-card set starting at card5 (highest value) 
drop table if exists #ranked
select *, 
    case 
    when hand_winning_type in ('Straight', 'Flush','Straight Flush','Full House') then dense_rank() over (partition by round_id order by winner_type_id asc, wc_5 desc, wc_4 desc,  wc_3 desc, wc_2 desc, wc_1 desc) --if winning hand type has 5 cards, only look at those values
    else dense_rank() over (partition by round_id order by winner_type_id asc, wc_5 desc, wc_4 desc,  wc_3 desc, wc_2 desc, wc_1 desc, deal_2_value desc, deal_1_value desc) end as rank --only look at deal values if winning hand type is less than 5 cards
into #ranked
from #matched

--Idenify cases where a player has two hands of identifical rank
drop table if exists #no_dupes
select 
    *, 
    row_number() over (partition by round_id,seat_id order by rank desc) as player_hands
into #no_dupes
from #ranked
where rank = 1

--Identify rounds where pot is split or there is an outright winner
drop table if exists #no_ties
select 
    *
    ,case when count(hand_winning_type) over (partition by round_id) > 1 then 1 else 0 end as tie -- count ties
    ,case when count(hand_winning_type) over (partition by round_id) = 1 then 1 else 0 end as win -- count wins
into #no_ties
from #no_dupes
where player_hands = 1 --only include one winning hand per player

update r
set analyzed = 1
from rounds r
where id in (select round_id from #no_ties)


--staging table for results
drop table if exists #summary
 select  
        nt.generic_hand_type
        ,nt.num_players 
        ,n.num_deals 
        ,sum(nt.win) as wins
        ,sum(nt.tie) as ties
        ,cast(sum(nt.tie) as numeric(10,2))/cast(n.num_deals as numeric(10,2)) as tie_pct
        ,cast(sum(nt.win) as numeric(10,2))/cast(n.num_deals as numeric(10,2)) as win_pct_excl_ties
        ,(cast(sum(nt.win) as numeric(10,2)) + cast(sum(nt.tie) as numeric(10,2)))/cast(n.num_deals as numeric(10,2)) as win_pct_incl_ties
    into #summary
    from #no_ties nt
    join (
        select 
            generic_hand_type
            ,num_players
            ,count(seat_id) as num_deals
        from #hands
        group by 
            generic_hand_type
            ,num_players
    ) n on n.generic_hand_type=nt.generic_hand_type and n.num_players=nt.num_players
    group by
        nt.generic_hand_type
        ,nt.num_players
        ,n.num_deals



        merge summary_results as target
        using #summary as source
        on
        (
            target.generic_hand_type                            =           source.generic_hand_type
           and target.num_players                              =           source.num_players
        )
        when matched then
        update set
            target.num_deals                                   =           target.num_deals + source.num_deals,
            target.wins                                        =           target.wins + source.wins,
            target.ties                                        =           target.ties + source.ties
        when not matched by target then
        insert
        (
            generic_hand_type
            ,num_players
            ,num_deals
            ,wins
            ,ties
        )
        values
        (
            source.generic_hand_type
            ,source.num_players
            ,source.num_deals
            ,source.wins
            ,source.ties
        );
    


print('cha-ching!')

select distinct
    count(seat_id) as hands_analyzed
from #hands

select 'cha-chig' as money_money_money


GO
