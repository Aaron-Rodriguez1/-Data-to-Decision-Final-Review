WITH actual AS (
 SELECT department_id, account_id,
        SUM(CASE WHEN account_id IN (4000, 4100) THEN -amount ELSE amount END) AS actual
 FROM general_ledger
 WHERE txn_date >= '2026-01-01' AND txn_date < '2026-08-01'
 GROUP BY department_id, account_id
),
budget AS (
 SELECT department_id, account_id, SUM(budget_amount) AS budget
 FROM monthly_budget
 WHERE budget_month >= '2026-01' AND budget_month < '2026-08'
 GROUP BY department_id, account_id
)
SELECT d.department_name, c.account_category,
 ROUND(SUM(COALESCE(a.actual, 0)), 2) AS actual,
 ROUND(SUM(b.budget), 2) AS budget,
 ROUND(SUM(COALESCE(a.actual, 0) - b.budget), 2) AS dollar_variance,
 ROUND(100.0 * SUM(COALESCE(a.actual, 0) - b.budget)
       / NULLIF(ABS(SUM(b.budget)), 0), 2) AS percent_variance
FROM budget b
LEFT JOIN actual a USING (department_id, account_id)
JOIN department_master d USING (department_id)
JOIN chart_of_accounts c USING (account_id)
GROUP BY d.department_name, c.account_category
ORDER BY d.department_name, c.account_category;