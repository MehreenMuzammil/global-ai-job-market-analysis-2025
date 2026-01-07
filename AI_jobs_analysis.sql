--Salary Competitiveness Index per Role and Industry
SELECT job_title, industry,
    ROUND(AVG(salary_usd), 2) AS avg_salary,
    ROUND(AVG(salary_usd) - AVG(AVG(salary_usd)) OVER (PARTITION BY industry), 2) AS salary_diff_from_industry
FROM ai_job_market
GROUP BY job_title, industry
ORDER BY salary_diff_from_industry DESC;

--Cost Efficiency: Salary vs. Experience Level
SELECT
    experience_level,
    ROUND(AVG(salary_usd), 2) AS avg_salary,
    ROUND(AVG(years_experience), 1) AS avg_years,
    ROUND(AVG(salary_usd) / NULLIF(AVG(years_experience), 0), 2) AS salary_per_experience
FROM ai_job_market
GROUP BY experience_level
ORDER BY salary_per_experience DESC;

--Remote Work Salary Advantage by Country
SELECT
    company_location,
    CASE
        WHEN remote_ratio = 100 THEN 'Remote'
        WHEN remote_ratio BETWEEN 1 AND 99 THEN 'Hybrid'
        ELSE 'Onsite'
    END AS work_type,
    ROUND(AVG(salary_usd), 2) AS avg_salary
FROM ai_job_market
GROUP BY company_location, work_type
HAVING COUNT(*) > 10
ORDER BY company_location, avg_salary DESC;

--Skill Premium Analysis
WITH skill_data AS (
    SELECT TRIM(UNNEST(STRING_TO_ARRAY(LOWER(required_skills), ','))) AS skill,
           salary_usd
    FROM ai_job_market
)
SELECT
    skill,
    COUNT(*) AS demand_count,
    ROUND(AVG(salary_usd), 2) AS avg_salary
FROM skill_data
GROUP BY skill
HAVING COUNT(*) > 20
ORDER BY avg_salary DESC
LIMIT 20;

--Company Growth Potential via Job Posting Cadence
SELECT
    company_name,
    COUNT(*) AS total_postings,
    DATE_TRUNC('month', posting_date) AS month,
    COUNT(*) FILTER (WHERE posting_date >= NOW() - INTERVAL '90 days') AS recent_postings
FROM ai_job_market
GROUP BY company_name, month
ORDER BY recent_postings DESC
LIMIT 15;

--Time-to-Hire Efficiency by Industry
SELECT
    industry,
    ROUND(AVG(EXTRACT(DAY FROM AGE(application_deadline, posting_date))), 1) AS avg_open_days,
    COUNT(*) AS openings
FROM ai_job_market
GROUP BY industry
ORDER BY avg_open_days ASC;

--Salary vs. Benefits Correlation
SELECT
    ROUND(CORR(salary_usd, benefits_score)::numeric, 3) AS corr_salary_benefits
FROM ai_job_market;

--Education ROI — Salary per Education Level per Experience Year
SELECT
    education_required,
    ROUND(AVG(salary_usd / NULLIF(years_experience, 0)), 2) AS avg_salary_per_year,
    COUNT(*) AS job_count
FROM ai_job_market
GROUP BY education_required
ORDER BY avg_salary_per_year DESC;

--Emerging AI Roles Trend Analysis
SELECT
    job_title,
    DATE_TRUNC('quarter', posting_date) AS quarter,
    COUNT(*) AS posting_count
FROM ai_job_market
GROUP BY job_title, quarter
HAVING COUNT(*) > 5
ORDER BY quarter DESC, posting_count DESC;

--Global Pay Equity Check — Residence vs Company Location
SELECT
    CASE WHEN company_location = employee_residence THEN 'Same Country' ELSE 'Different Country' END AS mobility_type,
    ROUND(AVG(salary_usd), 2) AS avg_salary,
    COUNT(*) AS total_roles
FROM ai_job_market
GROUP BY mobility_type;

--Multi-Dimensional Business KPI View
SELECT
    industry,
    experience_level,
    company_size,
    ROUND(AVG(salary_usd), 2) AS avg_salary,
    ROUND(AVG(benefits_score), 2) AS avg_benefits,
    COUNT(*) AS total_roles,
    ROUND(AVG(EXTRACT(DAY FROM AGE(application_deadline, posting_date))), 1) AS avg_open_days
FROM ai_job_market
GROUP BY industry, experience_level, company_size
ORDER BY avg_salary DESC;