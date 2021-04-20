
use sqlympics;

go 
CREATE OR ALTER PROCEDURE gen_rounds 
    @rounds varchar(20) 
    ,@seats int 
AS      

SET NOCOUNT ON;

--exec gen_rounds @rounds = 100, @seats = 4
--for testing:
--declare @rounds varchar(10) = '5', @seats int = 10


/*
    Generate the number of rounds to be run
*/
declare @run int;
select @run = isnull(max(id),0) + 1 from runs;
insert into runs(id) values(@run)

declare @sql nvarchar(max) 
--    ,@rounds varchar(20)
set @sql = 
N'insert into rounds(run_id)
select top ' + @rounds + ' @run 
    FROM sys.columns s1       
    CROSS JOIN sys.columns s2 
    cross join sys.columns s3
    cross join sys.columns s4
'

EXECUTE sp_executesql
@sql
,N'@run int'
, @run = @run



IF OBJECT_ID('tempdb..#shuffle') IS NULL 
begin
create table #shuffle
    (id int identity
    ,card_id int
    )
end 

IF OBJECT_ID('tempdb..#hands') IS NULL 
begin
create table #hands
    (seat_id int
    ,card_id int
    ,round_id int
    )
end 

IF OBJECT_ID('tempdb..#cards_used') IS NULL 
begin
create table #cards_used
    (seat_id int
    ,card_id int
    ,round_id int
    )
end 

declare  @curround int
        ,@maxround int
select @curround = min(id) from rounds r where r.run_id = @run
select @maxround = max(id) from rounds r where r.run_id = @run

while @curround <= @maxround
BEGIN

    TRUNCATE table #shuffle;
    TRUNCATE table #hands
    TRUNCATE table #cards_used;

    insert into #shuffle(card_id)
    select id from cards 
    order by NEWID()

    insert into #cards_used(seat_id,card_id,round_id)
    SELECT 
         ((ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) -1) / 2) + 1 AS seat_id 
        ,card_id
        ,@curround
    from #shuffle

    delete from #cards_used
    where seat_id > @seats

    insert into deal(seat_id,card_id,round_id)
    select seat_id,card_id,round_id from #cards_used

    insert into community_cards(card_id,round_id)
    SELECT top 8 
        c.id as card_id
        , @curround as round_id
    from 
    cards c
    where not exists (select card_id from #cards_used cu where cu.card_id = c.id)
    order by NEWID()

    set @curround = @curround + 1
END 

GO

