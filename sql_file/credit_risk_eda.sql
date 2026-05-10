use credit_risk_db;
-- Basic Aggregation:

-- 1. What is the total number of loans by loan intent?
select loan_intent,
count(*) as total_loan
from credit_risk
group by loan_intent
order by 2 desc;

-- 2. What is the overall default rate as a percentage?
select round(avg(loan_status)*100,2) as default_percentage
from credit_risk;


-- 3. What is the average interest rate by loan grade?
select loan_grade, 
round(avg(interest_rate),2) as avg_interest
from credit_risk
group by loan_grade
order by loan_grade;


-- 4. Which home ownership type has the highest average loan amount?
select home_ownership,
round(avg(loan_amount),2) as avg_loan
from credit_risk 
group by home_ownership
order by 2 desc
limit 1;

-- 5. What is the average income by loan status?
select loan_status_label, 
round(avg(income),2) as average_income
from credit_risk 
group by loan_status_label;




-- GROUP BY + HAVING:

-- 6. Which loan grade has a default rate greater than 50%?
select loan_grade,
round(avg(loan_status)*100,2) as loan_rate
from credit_risk
group by loan_grade
having loan_rate > 50;


-- 7. Which loan intent has more than 1000 defaulted loans?
select loan_intent,
count(*) as defaulted_loans
from credit_risk 
where loan_status_label = 'Default'
group by loan_intent
having defaulted_loans > 1000


-- Subquery:

-- 8. What is the default rate of applicants whose income is above the overall average income?
select round(avg(loan_status)*100,2) as default_rate
from credit_risk
where income > (select avg(income)
				from credit_risk)



-- 9. Which loan grade has a higher default rate than the overall average default rate?
select loan_grade, avg(loan_status)*100 as avg_default
from credit_risk
group by loan_grade
having avg_default > (select avg(loan_status)*100
from credit_risk)
-- or
with overall_stats as (select avg(loan_status)*100 as global_avg
						from credit_risk)
select loan_grade, avg(loan_status)*100 as avg_default
from credit_risk, overall_stats
group by loan_grade,global_avg
having avg_default>global_avg



-- 10. What is the average loan amount for applicants who have previously defaulted?
select avg(loan_amount)  as loan_avg
from credit_risk
where prev_default = 'Yes'


-- Window Function:


-- 11. Rank loan grades by default rate from highest to lowest.
select loan_grade,
avg(loan_status)*100, 
rank() over(order by avg(loan_status) desc)
from credit_risk
group by loan_grade


-- 12. For each home ownership type, show each applicant's loan amount and the average loan amount of their group side by side.
select home_ownership,
loan_amount,
round(avg(loan_amount) over(partition by home_ownership),2) as group_avg_amount
from credit_risk

-- 13. Compare each loan intent's default rate against the overall default rate.
select loan_intent,
round(avg(loan_status)*100,2) as intent_default_rate,
round(avg(avg(loan_status)*100) over(),2) as overfall_default_rate
from credit_risk
group by loan_intent


-- 14. Calculate the cumulative default rate by loan grade ordered from A to G.
select loan_grade, default_rate,
sum(default_rate) over(order by loan_grade) as cumulative
from(select loan_grade,avg(loan_status)*100 as default_rate
from credit_risk
group by loan_grade)
as sub



-- Combined:


-- 15. For each loan grade, show default rate and its difference from the overall average default rate.
select loan_grade, default_rate,
overall_default - default_rate as default_difference
from (
select loan_grade,
avg(loan_status)*100 as default_rate,
(select avg(loan_status)*100 from credit_risk) as overall_default
from credit_risk
group by loan_grade
) as sub



































