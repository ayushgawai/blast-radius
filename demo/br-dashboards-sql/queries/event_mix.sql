select event_type, count(*) as events
from events
group by 1
order by 2 desc
