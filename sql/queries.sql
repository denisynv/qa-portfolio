-- Practice queries on the customers / subscriptions database (see setup.sql)
-- Expected result in brackets.

-- 1. Customers created this year, newest first, top 5 (ids 8, 7, 6, 4, 3)
SELECT * FROM customers
WHERE created_at >= '2026-01-01'
ORDER BY created_at DESC
LIMIT 5;

-- 2. Customers whose email ends with @a1.bg (ids 1, 3, 6, 7)
SELECT * FROM customers
WHERE email LIKE '%@a1.bg';

-- 3. Active subscriptions with customer name and plan, INNER JOIN (7 rows)
SELECT c.name, s.plan
FROM subscriptions s
INNER JOIN customers c ON c.id = s.customer_id
WHERE s.status = 'ACTIVE';

-- 4. All customers with their subscriptions, LEFT JOIN (10 rows, customer 7 with NULLs)
SELECT c.id, c.name, s.plan, s.status
FROM customers c
LEFT JOIN subscriptions s ON s.customer_id = c.id;

-- 5. Customers with NO active subscription (ids 4, 5, 7)
-- The status condition is in ON, not in WHERE. In WHERE it would remove the NULL rows
-- and turn the LEFT JOIN into an INNER JOIN.
SELECT c.id, c.name
FROM customers c
LEFT JOIN subscriptions s
  ON s.customer_id = c.id AND s.status = 'ACTIVE'
WHERE s.id IS NULL;

-- 6. Number of active subscriptions per plan (Basic 4, Premium 1, Unlimited 3)
SELECT plan, COUNT(*) AS total
FROM subscriptions
WHERE status = 'ACTIVE'
GROUP BY plan;

-- 7. Plans with more than 3 active subscriptions (Basic)
SELECT plan, COUNT(*) AS total
FROM subscriptions
WHERE status = 'ACTIVE'
GROUP BY plan
HAVING COUNT(*) > 3;

-- 8. Duplicate emails (ivan@a1.bg, count 2)
SELECT email, COUNT(*) AS total
FROM customers
GROUP BY email
HAVING COUNT(*) > 1;

-- 9. Subscriptions where ended_at is before started_at (subscription 9)
SELECT * FROM subscriptions
WHERE ended_at < started_at;

-- 10. Subscriptions with no matching customer (subscription 10)
SELECT s.id, s.customer_id
FROM subscriptions s
LEFT JOIN customers c ON c.id = s.customer_id
WHERE c.id IS NULL;