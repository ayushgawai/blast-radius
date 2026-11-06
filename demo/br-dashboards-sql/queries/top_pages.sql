select page, count(*) as views
from events
where event_type = 'page_view'
group by 1
order by 2 desc
limit 10
