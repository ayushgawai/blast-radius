select user_id, sum(revenue_usd) as revenue_usd
from events
where event_type = 'purchase'
group by 1
order by 2 desc
