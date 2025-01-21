
{{ config(materialized='table') }}

-- CTE for cleaning and normalizing data
with cleaned_data as (
    select
        -- Basic data cleaning
        b.age as age,
        case
            when b.job = 'admin.' then 'admin'
            else trim(b.job)
        end as job,
        trim(b.marital) as marital_status,
        trim(b.education) as education,
        trim(b.default) as default_credit,
        b.balance as account_balance,
        trim(b.housing) as housing_loan,
        trim(b.loan) as personal_loan,
        trim(b.contact) as contact_type,
        b.day as contact_day,
        trim(b.month) as contact_month,
        b.duration as call_duration_seconds,
        b.campaign as current_campaign_contacts,
        b.pdays as days_since_last_contact,
        b.previous as previous_campaign_contacts,
        trim(b.poutcome) as previous_campaign_outcome,
        trim(b.y) as term_deposit_subscription,

    from {{ source('staging', 'stg_bank') }} b
),

-- CTE for filtering relevant records
filtered_data as (
    select * from cleaned_data
    where
        -- Filter out records with unknown or missing critical information
        age is not null
        and job is not null
        and marital_status is not null
        and education is not null
        and contact_type is not null
),

-- CTE for enhancing data quality
enhanced_data as (
    select
        *,

        -- Create age groups
        case
            when cast(age as int) < 25 then 'Young Adult'
            when cast(age as int) between 25 and 40 then 'Adult'
            when cast(age as int) between 41 and 60 then 'Middle-Aged'
            else 'Senior'
        end as age_group,

        -- Create income potential indicator
        case
            when cast(balance as numeric) > 10000 then 'High'
            when cast(balance as numeric) between 5000 and 10000 then 'Medium'
            else 'Low'
        end as income_potential

        -- Create campaign success indicator
        case
            when current_campaign_contacts = 0 then 'No'
            when current_campaign_contacts = 1 then 'Single'
            when current_campaign_contacts between 2 and 5 then 'Multiple'
            else 'Many'
        end as campaign_success

        -- Create call duration category
        case
            when call_duration_seconds < 10 then 'Very Short'
            when call_duration_seconds between 10 and 60 then 'Short'
            when call_duration_seconds between 61 and 120 then 'Medium'
            when call_duration_seconds between 121 and 240 then 'Long'
            else 'Very Long'
        end as call_duration

    from filtered_data
),

-- Final staging transformation
staging_bank_marketing as (
    select
        *,
        -- Additional derived columns for analysis
        case
            when term_deposit_subscription = 'yes' then 1
            else 0
        end as is_converted,

        case
            when previous_campaign_outcome = 'success' then 1
            else 0
        end as previous_campaign_success

    from enhanced_data
)

select * from staging_bank_marketing