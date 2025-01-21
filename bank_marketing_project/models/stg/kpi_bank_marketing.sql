{{ config(materialized='table') }}

-- CTE for conversion metrics
with general_metrics as (
    select
        -- Total contacts
        count(1) as total_contacts,

        -- Successful conversions
        countif(is_converted) as successful_conversions,

        -- Conversion rate
        round(
            100.0 * countif(is_converted) / count(1),
            2
        ) as conversion_rate_percentage,

        -- Campaign performance metrics
        avg(account_balance) as avg_segment_balance,
        avg(call_duration_seconds) as avg_call_duration_seconds,
        avg(current_campaign_contacts) as avg_campaign_contacts,

        -- Trend analysis
        countif(previous_campaign_outcome = 'success') as previous_success_count,

        -- Value indicators
        countif(income_potential = 'High' and is_converted) as high_value_conversions
    from {{ ref('staging_bank_marketing') }}
),

-- CTE for call duration categories
call_duration_metrics as (
    select
        call_duration,
        avg(b.call_duration_seconds) as avg_call_duration,
        count(1) as total_calls,
        count(1) / m.total_contacts as call_ratio

    from {{ ref('staging_bank_marketing') }} b
    cross join general_metrics m
    group by call_duration
),

-- CTR for age groups
age_group_metrics as (
    select
        age_group,
        avg(age) as avg_age_group,
    from {{ ref('staging_bank_marketing') }}
    group by age_group
),

-- CTE for customer segmentation
customer_segments as (
    select
        age_group,
        job,
        marital_status,
        education,
        income_potential,
        campaign_success,
        call_duration,

        -- Additional segment insights
        avg(account_balance) as avg_segment_balance,
        avg(age) as avg_segment_age
    from {{ ref('staging_bank_marketing') }}
    group by
        age_group,
        job,
        marital_status,
        education,
        income_potential,
        campaign_success,
        call_duration
),

-- Final KPI staging transformation
staging_bank_marketing_kpi as (
    select
        gm.*,
        cdm.*,
        agm.*,
        cs.age_group,
        cs.job,
        cs.marital_status,
        cs.education,
        cs.income_potential,
        cs.campaign_success,
        cs.avg_segment_balance,
        cs.avg_segment_age
    from customer_segments cs
    inner join call_duration_metrics cdm on cs.call_duration = cdm.call_duration
    inner join age_group_metrics agm on cs.age_group = agm.age_group
    cross join general_metrics gm
)

select * from staging_bank_marketing_kpi