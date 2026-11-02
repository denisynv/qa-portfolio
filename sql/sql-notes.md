# SQL notes (SQLBolt lessons 1 to 12)

Why a QA needs SQL: after a UI action or an API call, I check in the database that the data really changed. Mostly I use SELECT.

## 1. Basic SELECT (lessons 1 to 4)

| Clause | What it does | Example |
|---|---|---|
| SELECT col, col2 | Choose the columns | SELECT name, email |
| SELECT * | All columns | SELECT * |
| FROM | Which table | FROM customers |
| WHERE | Keep only the rows that match a condition | WHERE status = 'ACTIVE' |
| AND / OR | Combine conditions | WHERE a = 1 AND b > 5 |
| DISTINCT | Remove duplicate rows from the result | SELECT DISTINCT plan |
| ORDER BY | Sort, ASC (default) or DESC | ORDER BY created_at DESC |
| LIMIT / OFFSET | How many rows to return / where to start | LIMIT 5 OFFSET 10 |

### Filters for numbers
| Operator | Meaning |
|---|---|
| =, !=, <, <=, >, >= | Normal comparison |
| BETWEEN a AND b | In the range, both ends included |
| NOT BETWEEN a AND b | Outside the range |
| IN (2, 4, 6) / NOT IN (...) | In / not in a list |

### Filters for text
| Operator | Meaning |
|---|---|
| = , != (or <>) | Exact comparison. In SQLBolt it is case sensitive |
| LIKE / NOT LIKE | Pattern comparison, case insensitive in SQLBolt |
| % | Any number of characters (including none), only with LIKE: LIKE '%@a1.bg' |
| _ | Exactly one character, only with LIKE: LIKE 'AN_' matches AND, not AN |
| IN ('A','B') / NOT IN (...) | In / not in a list |

- Text must be written in quotes. Without quotes the database reads the word as a keyword or a column name.
- Case sensitivity of = and LIKE depends on the database (SQLite, MySQL and PostgreSQL differ). I check it before I trust a result.

Full shape of a simple query:

    SELECT column, another_column
    FROM mytable
    WHERE condition
    ORDER BY column ASC/DESC
    LIMIT num_limit OFFSET num_offset;

## 2. Joins (lessons 6 and 7)

A join combines rows of two tables using a key (customers.id = subscriptions.customer_id).

| Join | Returns |
|---|---|
| INNER JOIN | Only rows that have a match in both tables |
| LEFT JOIN | All rows from the left table; matching right rows, or NULL when there is no match |
| RIGHT JOIN | Same as LEFT, from the other side |
| FULL JOIN | All rows from both tables (not available in every database, for example not in MySQL) |

    SELECT c.name, s.plan
    FROM customers c
    INNER JOIN subscriptions s ON s.customer_id = c.id
    WHERE s.status = 'ACTIVE';

### Small example (3 customers)
- customers: 1 Ivan, 2 Maria, 3 Desi. subscriptions: customer 1 Basic, customer 1 Premium, customer 2 Basic.
- INNER JOIN gives 3 rows, and Desi is missing.
- LEFT JOIN gives 4 rows, and Desi appears with NULL in plan.

### Customers WITHOUT an active subscription (anti-join)

    SELECT c.id, c.name
    FROM customers c
    LEFT JOIN subscriptions s
      ON s.customer_id = c.id AND s.status = 'ACTIVE'
    WHERE s.id IS NULL;

Pitfall: the status condition must be in ON, not in WHERE. In WHERE it removes the NULL rows and the LEFT JOIN silently behaves like an INNER JOIN.

## 3. NULL (lesson 8)

- NULL means "no value / unknown". It is not zero and not an empty string.
- Outer joins create NULLs when there is no matching row.
- Test it with IS NULL / IS NOT NULL. "= NULL" never matches, because a comparison with NULL is never true.
- COUNT(*) counts rows. COUNT(column) skips the rows where that column is NULL.

## 4. Expressions and aliases (lesson 9)

- I can calculate inside a query: SELECT price * 1.2 AS price_with_vat.
- AS gives a readable name to a column or table. Short table aliases (c, s) keep joins readable.
- Aliases from SELECT cannot be used in WHERE or HAVING in most databases, but they can be used in ORDER BY (see order of execution).

## 5. Aggregates, GROUP BY, HAVING (lessons 10 and 11)

| Function | Meaning |
|---|---|
| COUNT(*) / COUNT(col) | Number of rows / number of non-NULL values |
| MIN(col), MAX(col) | Smallest / largest value |
| AVG(col) | Average |
| SUM(col) | Sum |

    SELECT plan, COUNT(*) AS total
    FROM subscriptions
    WHERE status = 'ACTIVE'
    GROUP BY plan
    HAVING COUNT(*) > 3;

### WHERE vs HAVING
| | WHERE | HAVING |
|---|---|---|
| Filters | Single rows | Groups |
| Applied | Before grouping | After GROUP BY |
| Can use aggregates like COUNT? | No | Yes |

Duplicate check (a classic data-quality test):

    SELECT email, COUNT(*) FROM customers GROUP BY email HAVING COUNT(*) > 1;

## 6. Order of execution (lesson 12)

| Step | Clause | What happens |
|---|---|---|
| 1 | FROM and JOINs | Build the full working set of rows |
| 2 | WHERE | Discard single rows that do not match |
| 3 | GROUP BY | Group the remaining rows |
| 4 | HAVING | Discard groups that do not match |
| 5 | SELECT | Calculate the expressions and aliases |
| 6 | DISTINCT | Remove duplicate rows |
| 7 | ORDER BY | Sort (aliases can be used here) |
| 8 | LIMIT / OFFSET | Cut the result |

This explains two things: WHERE cannot use aggregates (the groups do not exist yet), and WHERE cannot use SELECT aliases (SELECT has not run yet).

## 7. Other things interviewers ask (from my handbook, not SQLBolt)

| Question | Answer |
|---|---|
| DELETE vs TRUNCATE vs DROP | DELETE removes rows (can use WHERE). TRUNCATE empties the whole table quickly. DROP removes the table itself |
| UNION vs UNION ALL | UNION removes duplicates, UNION ALL keeps them |
| Primary key / foreign key | Primary key identifies a row. Foreign key points to the key of another table |
| Safety rule | Never run UPDATE or DELETE without WHERE, and never on production |

## 8. How I use SQL as a tester

After POST /booking returned a success status in Postman, I run a SELECT with a WHERE on a unique value to check that exactly one new row exists with the right values. I also check for duplicates and for orphan rows.

## 9. Progress

- [x] Lessons 1 to 12 (SELECT, constraints, sorting, review, joins, outer joins, NULL, expressions, aggregates, order of execution)
- [ ] Lessons 13 to 15 (INSERT, UPDATE, DELETE): skipped on purpose, optional bonus
- [ ] Lessons 16 to 18 (create, alter, drop tables): skipped, database administration
- [ ] Practice: write the 10 queries on my own customers/subscriptions database