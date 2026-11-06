select date_trunc('day', event_ts) as day, count(distinct user_id) as active_users
from events
group by 1
order by 1
