select
    user_id,
    min(event_ts) as first_seen,
    max(event_ts) as last_seen,
    count(distinct session_id) as sessions,
    sum(revenue_usd) as lifetime_revenue_usd
from {{ ref('stg_events') }}
group by user_id
