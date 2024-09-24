/*1 team which won the maximum gold medals over the years*/

with cte1 as (
select a.team, ae.year, ae.event
from athlete_events ae
left join athletes a
on ae.athlete_id = a.id
where ae.medal = 'gold'
group by a.team, ae.year, ae.event
)

select top 1 team, count(1) as total_won
from cte1
group by team
order by 2 desc

/*2 for each team total silver medals and year in which they won maximum silver medal..output 3 columns
team,total_silver_medals, year_of_max_silver*/

with cte1 as(
select team, medal, year, count(distinct event) as silver_won
from athlete_events ae
left join athletes a
on ae.athlete_id = a.id
where ae.medal = 'silver'
group by team, medal, year
)

select top 10 team, total_silver_medals, year as year_of_max_silver
from
(select *,
sum(silver_won) over(partition by team) as total_silver_medals,
row_number() over(partition by team order by silver_won desc, year desc) as rn
from cte1) a
where rn = 1
order by 2 desc

/*3 player which has won maximum gold medals amongst the players 
which have won only gold medal (never won silver or bronze) over the years*/

with cte1 as
(select a.name, ae.medal
from athlete_events ae
left join athletes a
on ae.athlete_id = a.id)

select top 10 name, count(1) as total_gold from cte1 where medal = 'gold' and name not in 
(select distinct name from cte1 where medal in ('silver', 'bronze'))
group by name
order by 2 desc

/*4 in each year player which has won maximum gold medal. query to print year,player name 
and no of golds won in that year . In case of a tie print comma separated player names*/

with cte1 as(
select ae.year, a.name, count(1) as medal_won
from athlete_events ae
left join athletes a
on ae.athlete_id = a.id
where ae.medal = 'gold'
group by ae.year, ae.medal, a.name
),

cte2 as(
select year, name, medal_won, total_gold_in_that_year from
(select *,
rank() over(partition by year order by medal_won desc) as rn,
sum(medal_won) over(partition by year) as total_gold_in_that_year
from cte1)a
where rn = 1
)

select top 10 year, string_agg(name, ', ') as players_name, medal_won, total_gold_in_that_year
from cte2
group by year, medal_won, total_gold_in_that_year
order by 1 desc

/*5 event and year in which India has won its first gold medal,first silver medal and first bronze medal
print 3 columns medal,year,sport*/

with cte1 as (
select ae.year, ae.medal, ae.sport
from athlete_events ae
left join athletes a
on ae.athlete_id = a.id
where a.team = 'india' and
ae.medal in ('gold', 'silver', 'bronze')
)

select year, medal, sport from
(select *,
row_number() over(partition by medal order by year) as rn
from cte1)a
where rn = 1
order by 1

/*6 players who won gold medal in summer and winter olympics both*/

select distinct a.name
from athlete_events ae
left join athletes a
on ae.athlete_id = a.id
where ae.medal = 'gold'
group by a.name
having count(distinct season) = 2

/*7 players who won gold, silver and bronze medal in a single olympics. print player name along with year*/

with cte1 as
(select distinct a.name, ae.year
from athlete_events ae
left join athletes a
on ae.athlete_id = a.id
where ae.medal in ('gold', 'silver', 'bronze')
group by a.name, ae.year
having count(distinct ae.medal) = 3)

select top 10 * from cte1
order by 2 desc

/*8 players who have won gold medals in consecutive 3 summer olympics in the same event. Considering only olympics 2000 onwards. 
Assume summer olympics happens every 4 year starting 2000. print player name and event name*/

with cte1 as
(select a.name, ae.year, ae.event
from athlete_events ae
left join athletes a
on ae.athlete_id = a.id
where ae.year >= 2000 and ae.medal = 'gold' and ae.season = 'summer')

select top 10 * from 
(select *,
lag(year,1) over(partition by name, event order by year) as previous_year,
lead(year,1) over(partition by name, event order by year) as next_year
from cte1)a
where year = previous_year+4 and year = next_year-4
order by 2 desc
