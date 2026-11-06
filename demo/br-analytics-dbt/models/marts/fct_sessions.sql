select
    session_id,
    user_id,
    min(event_ts) as session_start,
    max(event_ts) as session_end,
    count(*) as events,
    sum(revenue_usd) as revenue_usd
from {{ ref('stg_events') }}
group by session_id, user_id
