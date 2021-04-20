use sqlympics;

TRUNCATE TABLE winners;
declare @loopcount int

--straight flush
drop table if exists #straightflush
create table #straightflush(
    winner_type_id int 
    ,bitwise bigint
    ,c1_value int
    ,c2_value int
    ,c3_value int
    ,c4_value int
    ,c5_value int
    );


IF NOT EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[set_seq]') AND type = 'SO')
--drop sequence set_seq
CREATE SEQUENCE set_seq  
    START WITH 1  
    INCREMENT BY 1 
    ;  


declare 
     @set1 int
    ,@set2 int
    ,@set3 int
    ,@set4 int
    ,@set5 int 
    ,@sql nvarchar(max)
    ,@suitloop int  

    set @loopcount = 1
    while @loopcount <= 11
    BEGIN

        set @sql = 'ALTER SEQUENCE set_seq restart with ' + cast(@loopcount as nvarchar(10)) 
        exec sp_executesql @sql

        select @set1 = next value for set_seq
        select @set2 = next value for set_seq
        select @set3 = next value for set_seq
        select @set4 = next value for set_seq
        select @set5 = next value for set_seq

        -- change to 1 for the final pass
        if @set5 = 14 set @set5 = 1

    insert into #straightflush(
        winner_type_id  
        ,bitwise 
        ,c1_value
        ,c2_value
        ,c3_value
        ,c4_value
        ,c5_value
    )
    select 
        wt.id
        ,c1.bitwise | c2.bitwise | c3.bitwise | c4.bitwise | c5.bitwise as bitwise
        ,c1.[value],c2.[value],c3.[value],c4.[value],c5.[value]
        from cards c1 
        cross join cards c2
        cross join cards c3
        cross join cards c4
        cross join cards c5
        cross join winner_types wt
        where c1.value  = @set1
        and c2.value = @set2
        and c3.value = @set3
        and c4.value = @set4
        and c5.value = @set5
        and c1.suit_id = c2.suit_id
        and c1.suit_id = c3.suit_id
        and c1.suit_id = c4.suit_id
        and c1.suit_id = c5.suit_id
        and c2.suit_id = c3.suit_id
        and c2.suit_id = c4.suit_id
        and c2.suit_id = c5.suit_id
        and c3.suit_id = c4.suit_id
        and c3.suit_id = c5.suit_id
        and c4.suit_id = c5.suit_id
        and wt.name = 'Straight flush'
        SET @loopcount = @loopcount + 1
END

    insert into winners (
        winner_type_id
        ,bitwise
        ,card_1_value
        ,card_2_value
        ,card_3_value
        ,card_4_value
        ,card_5_value)
    select 
        winner_type_id  
        ,bitwise 
        ,c1_value
        ,c2_value
        ,c3_value
        ,c4_value
        ,c5_value 
    from #straightflush


--straight--

drop table if exists #straight
create table #straight(
    winner_type_id int 
    ,bitwise bigint
    ,c1_value int
    ,c2_value int
    ,c3_value int
    ,c4_value int
    ,c5_value int
    );


-- sequence is used in loop to increment set numbers
IF NOT EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[set_seq]') AND type = 'SO')
CREATE SEQUENCE set_seq  
    START WITH 1  
    INCREMENT BY 1 
    ;  

set @loopcount = 1
while @loopcount <= 11

BEGIN

    set @sql = 'ALTER SEQUENCE set_seq restart with ' + cast(@loopcount as nvarchar(10)) 
    exec sp_executesql @sql

    select @set1 = next value for set_seq
    select @set2 = next value for set_seq
    select @set3 = next value for set_seq
    select @set4 = next value for set_seq
    select @set5 = next value for set_seq
    
    -- change to 1 for the final pass
    if @set5 = 14 set @set5 = 1


    insert into #straight(
        winner_type_id  
        ,bitwise 
        ,c1_value
        ,c2_value
        ,c3_value
        ,c4_value
        ,c5_value
    )
    select 
        wt.id
        ,c1.bitwise | c2.bitwise | c3.bitwise | c4.bitwise | c5.bitwise
        ,c1.[value],c2.[value],c3.[value],c4.[value],c5.[value]
    from cards c1 
    cross join cards c2
    cross join cards c3
    cross join cards c4
    cross join cards c5
    cross join winner_types wt
    where c1.value  = @set1
    and c2.value = @set2
    and c3.value = @set3
    and c4.value = @set4
    and c5.value = @set5
    and wt.name = 'Straight'
    and c1.bitwise | c2.bitwise | c3.bitwise | c4.bitwise | c5.bitwise not in 
        (select bitwise from #straightflush)
    SET @loopcount = @loopcount + 1

END


insert into winners (
    winner_type_id
    ,bitwise
    ,card_1_value
    ,card_2_value
    ,card_3_value
    ,card_4_value
    ,card_5_value)
select 
    winner_type_id  
    ,bitwise 
    ,c1_value
    ,c2_value
    ,c3_value
    ,c4_value
    ,c5_value 
from #straight

create index ix_straight_bitwise on #straight(bitwise)



--flush 

insert into winners (
    winner_type_id
    ,bitwise
    ,card_1_value
    ,card_2_value
    ,card_3_value
    ,card_4_value
    ,card_5_value)   
select 
    wt.id
    ,c1.bitwise | c2.bitwise | c3.bitwise | c4.bitwise | c5.bitwise bitwise
    ,c1.[value],c2.[value],c3.[value],c4.[value],c5.[value]
from cards c1 
cross join cards c2 
cross join cards c3 
cross join cards c4 
cross join cards c5 
cross join winner_types wt
where (c1.value < c2.value OR c2.value IS NULL)
AND (c2.value < c3.value OR c3.value IS NULL)
AND (c3.value < c4.value OR c4.value IS NULL)
AND (c4.value < c5.value OR c5.value IS NULL)
and c1.suit_id = c2.suit_id
and c1.suit_id = c3.suit_id
and c1.suit_id = c4.suit_id
and c1.suit_id = c5.suit_id
and c2.suit_id = c3.suit_id
and c2.suit_id = c4.suit_id
and c2.suit_id = c5.suit_id
and c3.suit_id = c4.suit_id
and c3.suit_id = c5.suit_id
and c4.suit_id = c5.suit_id
and wt.name = 'Flush'
and c1.bitwise | c2.bitwise | c3.bitwise | c4.bitwise | c5.bitwise not in 
    (select bitwise from #straightflush
    union all
    select bitwise from #straight
    )
order by c1.bitwise | c2.bitwise | c3.bitwise | c4.bitwise | c5.bitwise



--Four of a kind. 

;with four as(
select 
    wt.id as winner_type_id
    ,ROW_NUMBER() over(partition by c1.bitwise | c2.bitwise | c3.bitwise | c4.bitwise order by c1.id) as rownum
    ,c1.bitwise | c2.bitwise | c3.bitwise | c4.bitwise as bitwise
    ,-1 c1_value
    ,c1.[value] c2_value
    ,c2.[value] c3_value
    ,c3.[value] c4_value
    ,c4.[value] c5_value
from cards c1 
cross join cards c2
cross join cards c3
cross join cards c4
cross join winner_types wt
where c1.[value] = c2. [value]
and c2.[value] = c3.[value]
and c3.[value] = c4.[value]
and c1.suit_id <> c2.suit_id
and c1.suit_id <> c3.suit_id
and c1.suit_id <> c4.suit_id
and c2.suit_id <> c4.suit_id
and c3.suit_id <> c4.suit_id
and c2.suit_id <> c3.suit_id
and wt.name = 'Four of a kind') 
insert into winners(
     winner_type_id
    ,bitwise
    ,card_1_value
    ,card_2_value
    ,card_3_value
    ,card_4_value
    ,card_5_value)
select winner_type_id
    ,bitwise
    ,-1 c1_value
    ,c2_value
    ,c3_value
    ,c4_value
    ,c5_value
    from four
where rownum = 1



--three of a kind 
drop table if exists #three_of_a_kind
create table #three_of_a_kind(
    winner_type_id int 
    ,bitwise bigint
    ,c1_value int
    ,c2_value int
    ,c3_value int
    ,c4_value int
    ,c5_value int
    );

    with three as (
    select
    wt.id as winner_type_id
    ,ROW_NUMBER() over(partition by c1.bitwise | c2.bitwise | c3.bitwise order by c1.id) as rownum
    ,c1.bitwise | c2.bitwise | c3.bitwise as bitwise
    ,-1 c1_value
    ,-1 c2_value
    ,c1.[value] c3_value
    ,c2.[value] c4_value
    ,c3.[value] c5_value
    from cards c1 
    cross join cards c2
    cross join cards c3
    cross join winner_types wt
    where c1.[value] = c2. [value]
    and c2.[value] = c3.[value]
    and c1.suit_id <> c2.suit_id
    and c2.suit_id <> c3.suit_id
    and c1.suit_id <> c3.suit_id
    and wt.name = 'Three of a Kind')

    insert into #three_of_a_kind(
        winner_type_id  
        ,bitwise 
        ,c1_value
        ,c2_value
        ,c3_value
        ,c4_value
        ,c5_value
    )
    select winner_type_id
        ,bitwise
        ,c1_value
        ,c2_value
        ,c3_value
        ,c4_value
        ,c5_value
        from three
    where rownum = 1

insert into winners (
    winner_type_id
    ,bitwise
    ,card_1_value
    ,card_2_value
    ,card_3_value
    ,card_4_value
    ,card_5_value)
select winner_type_id,bitwise,c1_value,c2_value,c3_value,c4_value,c5_value
from #three_of_a_kind


--pair 
drop table if exists #pair;
create table #pair(winner_type_id int 
    ,bitwise bigint
    ,c1_value int
    ,c2_value int
    ,c3_value int
    ,c4_value int
    ,c5_value int
    );

    with pair as (
    select
    wt.id as winner_type_id
    ,ROW_NUMBER() over(partition by c1.bitwise | c2.bitwise order by c1.id) as rownum
    ,c1.bitwise | c2.bitwise as bitwise
    ,-1 c1_value
    ,-1 c2_value
    ,-1 c3_value
    ,c1.[value] c4_value
    ,c2.[value] c5_value
    from cards c1 
    cross join cards c2
    cross join winner_types wt
    where c1.[value] = c2. [value]
    and c1.suit_id <> c2.suit_id
    and wt.name = 'One Pair')

    insert into #pair(
        winner_type_id  
        ,bitwise 
        ,c1_value
        ,c2_value
        ,c3_value
        ,c4_value
        ,c5_value
    )
    select winner_type_id
        ,bitwise
        ,c1_value
        ,c2_value
        ,c3_value
        ,c4_value
        ,c5_value
        from pair
    where rownum = 1

insert into winners (
    winner_type_id
    ,bitwise
    ,card_1_value
    ,card_2_value
    ,card_3_value
    ,card_4_value
    ,card_5_value)
select winner_type_id,bitwise,c1_value,c2_value,c3_value,c4_value,c5_value
from #pair


--Full house. Three of a kind with a pair.
drop table if exists #fullhouse

    select distinct
    wt.id as winner_type_id
    ,t.bitwise | p.bitwise as bitwise
    ,t.c3_value three_1
    ,t.c4_value three_2
    ,t.c5_value three_3
    ,p.c5_value pair_1
    ,p.c4_value pair_2
    into #fullhouse
    from #three_of_a_kind t
    cross join #pair p
    cross join winner_types wt
    where wt.name = 'Full House'
    and t.c4_value<p.c4_value;


insert into winners (
    winner_type_id
    ,bitwise
    ,card_1_value
    ,card_2_value
    ,card_3_value
    ,card_4_value
    ,card_5_value)
    select 
        winner_type_id
        ,bitwise
        ,pair_1
        ,pair_2
        ,three_1
        ,three_2
        ,three_3
    from #fullhouse

--two pair
drop table if exists #twopair
   
select 
wt.id winner_type_id
,p1.bitwise | p2.bitwise as bitwise
,p1.c4_value first_1
,p1.c5_value first_2
,p2.c4_value second_1
,p2.c5_value second_2
into #twopair
from #pair p1
cross join #pair p2
cross join winner_types wt
where wt.name = 'Two Pair'
and p1.bitwise <> p2.bitwise
and p2.c4_value > p1.c4_value
and p2.c5_value > p1.c5_value
and p1.c4_value > 1
union
select 
wt.id winner_type_id
,p1.bitwise | p2.bitwise as bitwise
,p1.c4_value first_1
,p1.c5_value first_2
,p2.c4_value second_1
,p2.c5_value second_2
from #pair p1
cross join #pair p2
cross join winner_types wt
where wt.name = 'Two Pair'
and p1.bitwise <> p2.bitwise
and p2.c4_value = 1
and p1.c4_value <> 1
;


insert into winners (
    winner_type_id
    ,bitwise
    ,card_1_value
    ,card_2_value
    ,card_3_value
    ,card_4_value
    ,card_5_value)
select 
    winner_type_id
    ,bitwise
    ,-1
    ,first_1
    ,first_2
    ,second_1
    ,second_2
from #twopair


--high card
insert into winners (
    winner_type_id
    ,bitwise
    ,card_1_value
    ,card_2_value
    ,card_3_value
    ,card_4_value
    ,card_5_value)
select 
    wt.id as winner_type_id
    ,c1.bitwise
    ,-1 c1_value
    ,-1 c2_value
    ,-1 c3_value
    ,-1 c4_value
    ,c1.[value] c5_value
from cards c1
cross join winner_types wt
where wt.name = 'High'

