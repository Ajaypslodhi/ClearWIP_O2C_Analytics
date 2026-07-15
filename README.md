# ClearWIP: Revenue Assurance & Billing Intelligence for Contract Accounting Operations

An end-to-end Order-to-Cash (O2C) analytics project built with **SQL** and **Power BI**.
Models the full contract-to-cash lifecycle — client and contract data, invoicing,
revenue recognition, work-in-progress (WIP), Workday-style transactions, and audit
findings — and turns it into a decision-ready dashboard for a Contract Accounting
Operations team.

## What's inside
- `/data` — 6 relational CSV tables (clients, contracts, invoices, transactions,
  revenue_wip, audit_log) — ~2,800 rows of representative O2C data
- `/sql` — schema, data load, and 10 production-style analysis queries covering
  invoice status, DSO, revenue recognized vs. billed, WIP aging, SOX compliance,
  contract modification tracking, and audit resolution
- `/docs` — data dictionary, Power BI build guide (data model + DAX measures),
  and a full project report with findings and recommendations

## Stack
SQL (T-SQL) · Power BI · relational data modeling

## Key KPIs covered
Invoicing & collections · DSO · Revenue recognition vs. WIP · SOX compliance rate ·
Contract modification/reversal tracking · Workday transaction health · Audit
findings & resolution
