\# Day 1: QA Fundamentals



\## 1. The 7 testing principles



1\. \*\*Testing shows the presence of defects, not their absence.\*\*

&#x20;  Testing can find bugs, but it can never prove there are none.

&#x20;  Example: 50 passed tests on saucedemo.com do not mean the shop is bug-free.



2\. \*\*Exhaustive testing is impossible.\*\*

&#x20;  I cannot test every input and every combination.

&#x20;  Example: a text field accepts endless possible inputs, so I choose test values using techniques (equivalence partitioning, boundary values) and risk.



3\. \*\*Early testing saves time and money.\*\*

&#x20;  The earlier a problem is found, the cheaper it is to fix.

&#x20;  Example: spotting an unclear requirement in a review is cheaper than finding the bug after the feature is built.



4\. \*\*Defects cluster together.\*\*

&#x20;  A small number of modules usually contain most of the bugs.

&#x20;  Example: if checkout had many bugs in the last release, I test checkout more carefully this time.



5\. \*\*Beware of the pesticide paradox.\*\*

&#x20;  If I run the same tests again and again, they stop finding new bugs, like insects becoming resistant to the same pesticide.

&#x20;  Example: I update my regression tests and add new cases and exploratory sessions each release.



6\. \*\*Testing is context dependent.\*\*

&#x20;  How I test depends on the product and its risks.

&#x20;  Example: a banking app needs strong security and accuracy testing; a simple game needs more usability and performance testing.



7\. \*\*Absence-of-defects fallacy.\*\*

&#x20;  A product with no found bugs is still a failure if it does not meet what users need.

&#x20;  Example: a perfectly working shop that is too confusing for customers to buy anything.



\## 2. Test types and terms



\- \*\*Smoke test\*\*: a quick check that the new build is stable enough to test further.

&#x20; Example: the login page opens and I can log in.

\- \*\*Sanity test\*\*: a narrow check after a small change or fix.

&#x20; Example: after the cart-badge bug was fixed, I check only that the badge updates correctly.

\- \*\*Regression test\*\*: checking that old features still work after a change.

&#x20; Example: after a fix, I re-run the whole cart and checkout flow.

\- \*\*Retest (confirmation test)\*\*: running the exact test that failed to confirm the bug is fixed.

&#x20; Example: I repeat the failed login test with the same steps and data.

\- \*\*Exploratory testing\*\*: learning the application and testing it at the same time, without fixed scripts.

&#x20; Example: 20 minutes trying unusual inputs in the checkout form.

\- \*\*Functional testing\*\*: checking WHAT the system does, against the requirements.

&#x20; Example: the user can add a product to the cart.

\- \*\*Non-functional testing\*\*: checking HOW WELL the system works (performance, security, usability, compatibility).

&#x20; Example: the page loads in under 3 seconds; it works in Chrome and Firefox.

\- \*\*Black box testing\*\*: testing from the outside, without knowing the code.

&#x20; Example: I use the app like a user and compare the results with the requirements.

\- \*\*White box testing\*\*: testing with knowledge of the internal code structure.

&#x20; Example: a developer writes unit tests so that every branch of a function runs.

\- \*\*Grey box testing\*\*: partial knowledge of the internals.

&#x20; Example: I test an API in Postman and then check the database with SQL.



\## 3. Scrum



\- \*\*What it is:\*\* a framework (a set of rules and roles) where a team builds a product in short cycles called sprints, usually 2 weeks, and delivers a working increment each time. It is not only for QA teams.

\- \*\*Roles:\*\*

&#x20; - Product Owner: decides what is built and in which order (owns the backlog)

&#x20; - Scrum Master: helps the team follow the process and removes blockers

&#x20; - Developers: everyone who builds the product, including testers

\- \*\*Events:\*\* Sprint, Sprint Planning, Daily Scrum (15 minutes), Sprint Review, Sprint Retrospective

\- \*\*Artifacts:\*\* Product Backlog, Sprint Backlog, Increment

\- \*\*Definition of Done:\*\* the team's checklist for when work is truly finished (for example code reviewed and tests passed). Acceptance criteria are the conditions for one specific user story.

\- \*\*Where QA fits:\*\* QA tests inside the sprint, starting early (for example reviewing user stories), and the whole team is responsible for quality.

