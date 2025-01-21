# Bank Marketing Data Transformation Project

## Overview
This project transforms raw bank marketing campaign data into actionable insights using dbt (data build tool) and BigQuery.

## Dataset Source

The data is related with direct marketing campaigns (phone calls) of a Portuguese banking institution. The classification goal is to predict if the client will subscribe a term deposit (variable y).

* ***Dataset Characteristics:*** Multivariate

* ***Subject Area:*** Business

* ***Associated Tasks:*** Classification

* ***Feature Type:*** Categorical, Integer

* ***# Instances:*** 45211

* ***# Features:*** 16

### Dataset Information

The data is related with direct marketing campaigns of a Portuguese banking institution. The marketing campaigns were based on phone calls. Often, more than one contact to the same client was required, in order to access if the product (bank term deposit) would be ('yes') or not ('no') subscribed.

There are four datasets:
1) bank-additional-full.csv with all examples (41188) and 20 inputs, ordered by date (from May 2008 to November 2010), very close to the data analyzed in [Moro et al., 2014]
2) bank-additional.csv with 10% of the examples (4119), randomly selected from 1), and 20 inputs.
3) bank-full.csv with all examples and 17 inputs, ordered by date (older version of this dataset with less inputs).
4) bank.csv with 10% of the examples and 17 inputs, randomly selected from 3 (older version of this dataset with less inputs).
The smallest datasets are provided to test more computationally demanding machine learning algorithms (e.g., SVM).

The classification goal is to predict if the client will subscribe (yes/no) a term deposit (variable y).



## Project Structure

### 1. Data Staging: `staging_bank_marketing.sql`
#### Data Cleaning and Normalization
- Standardizes column names and formats
- Handles job title variations (e.g., 'admin.' → 'admin')
- Removes irrelevant or incomplete records

#### Data Enrichment
- Creates derived columns:
  - `age_group`: Categorizes customers by age
  - `income_potential`: Segments customers by account balance
  - `campaign_success`: Categorizes campaign contact frequency
  - `call_duration`: Classifies call duration
  - `is_converted`: Binary conversion indicator
  - `previous_campaign_success`: Previous campaign performance

### 2. KPI Staging: `staging_bank_marketing_kpi.sql`
#### Conversion Metrics
- Total contacts
- Successful conversions
- Overall conversion rate
- Average campaign contacts
- Average call duration

#### Customer Segmentation
Segments customers across multiple dimensions:
- Age group
- Job
- Marital status
- Education
- Income potential
- Campaign success

#### Segment-Level Insights
- Segment total contacts
- Segment conversions
- Segment conversion rate
- Average segment account balance
- Average segment age

## Data Transformation Process

### Cleaning Steps
1. Remove records with missing critical information
2. Standardize categorical variables
3. Create meaningful derived columns
4. Calculate conversion metrics

### Segmentation Strategy
- Multi-dimensional customer segmentation
- Granular performance tracking
- Enables targeted marketing analysis

## Prerequisites
- dbt
- BigQuery
- Python 3.12+

## Installation
```bash
# Clone the repository
git clone https://github.com/JuanS3/test-analytics-engineering.git

# Install dependencies
pip install dbt-bigquery

# Set up BigQuery credentials
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/credentials.json
```

## Running the Project
```bash
# Initialize dbt
dbt init

# Run models
dbt run

# Test models
dbt test
```

