# FinTech Credit Risk Analytics & Underwriting Dashboard

## 📌 Executive Summary
This project analyzes consumer finance data to predict loan default risks for the "unbanked" population (individuals with insufficient or non-existent traditional credit histories). By engineering a data pipeline across 1.9 million+ records, this project identifies high-risk demographic and historical applicant profiles and delivers an automated Underwriting Risk Matrix via Power BI.

## 🏢 Business Problem
Consumer finance providers face high vulnerability to loan defaults when lending to individuals without traditional credit scores. The objective of this project was to analyze current application data alongside historical loan data to:
1. Establish baseline default rates across the portfolio.
2. Identify demographic and financial indicators of high risk.
3. Provide the underwriting team with a data-driven dashboard to evaluate new applications.

## 🛠️ Tech Stack & Methodology
* **Database Management:** MySQL (Optimized bulk ingestion, CTEs, Relational Joins)
* **Data Manipulation & EDA:** Python (Pandas, NumPy)
* **Data Visualization & BI:** Power BI (DAX, Conditional Formatting, Interactive Slicers)

## 📂 Data Pipeline Architecture
1. **SQL ETL Phase:** 
   * Bypassed standard GUI imports to write a high-performance `LOAD DATA INFILE` script, disabling `autocommit` and foreign key checks to ingest 300K+ current applications and 1.6M+ previous applications.
   * Utilized Common Table Expressions (CTEs) to aggregate the one-to-many historical records into a single risk profile per applicant *before* executing a `LEFT JOIN`, preventing data duplication.
2. **Python EDA Phase:**
   * Handled critical data anomalies (e.g., isolating `365243` placeholder values in employment days).
   * Converted raw negative day counts into actionable cohorts (Age Groups, Years Employed).
3. **Power BI Dashboarding:**
   * Built a dynamic risk dashboard featuring static portfolio baselines (8.07%) for instant visual comparison.
   * Created a conditional "Underwriting Risk Summary" matrix to automate approval recommendations.

## 📊 Key Insights & Business Recommendations

* **Baseline Risk:** The overall portfolio default rate is **8.07%**.
* **High-Risk Demographics:** Applicants **under 30** have an 11.46% default rate (+3.38 pp above baseline). **Unemployed** applicants carry a severe 36.36% default rate.
* **Historical Predictive Power:** Applicants with **1 or more previous loan rejections** have a 10.32% default rate, a ~48% relative increase in risk compared to those with zero previous rejections.
* **Product Risk:** Cash loans (8.35%) carry a noticeably higher risk than Revolving loans (5.48%).

**Underwriting Action Plan:**
Based on the dashboard matrix, the following rules were established:
* **Additional Verification Required:** Any applicant Under 30 or Unemployed.
* **Enhanced Affordability Checks:** Any applicant utilizing a Cash Loan or possessing 1+ previous loan rejections.
* **Standard Review:** Revolving loans and applicants with 0 previous rejections.

## 🚀 How to Run the Project
1. **SQL Database:** Run `etl_pipeline.sql` in MySQL to build the schema and load the raw Kaggle data.
2. **Python Analysis:** Run `credit_risk_eda.ipynb` to view the data cleaning and demographic cohort analysis.
3. **Dashboard:** Open `Home_Credit_Risk.pbix` in Power BI Desktop to interact with the final dashboard.