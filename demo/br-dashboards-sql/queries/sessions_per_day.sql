select date_trunc('day', event_ts) as day, count(distinct session_id) as sessions
from events
group by 1
order by 1
