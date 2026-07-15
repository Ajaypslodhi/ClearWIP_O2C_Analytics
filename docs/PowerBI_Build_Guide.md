# Power BI Build Guide — O2C Revenue & Billing Analytics

This guide takes you from the 6 CSVs (or SQL tables) to a finished 6-page
Power BI dashboard mapped to the Alight Solutions Jr. Analyst JD.

## 1. Get Data & Data Model

1. **Get Data → SQL Server** (or **Text/CSV** if using the flat files) and
   import: `clients`, `contracts`, `invoices`, `transactions`,
   `revenue_wip`, `audit_log`.
2. **Create a Date table** (Model view → New Table):
   ```DAX
   DateTable = CALENDAR(DATE(2023,1,1), DATE(2026,12,31))
   ```
   Mark it as a Date Table (Table tools → Mark as Date Table), and add:
   ```DAX
   Month = FORMAT([Date], "YYYY-MM")
   MonthName = FORMAT([Date], "MMM YYYY")
   Year = YEAR([Date])
   ```
3. **Relationships** (Model view — all 1‑to‑many, single direction unless noted):
   - `clients[client_id]` → `contracts[client_id]`
   - `contracts[contract_id]` → `invoices[contract_id]`
   - `contracts[contract_id]` → `transactions[contract_id]`
   - `contracts[contract_id]` → `revenue_wip[contract_id]`
   - `contracts[contract_id]` → `audit_log[contract_id]`
   - `DateTable[Date]` → `invoices[invoice_date]`
   - `DateTable[Date]` → `transactions[transaction_date]` (inactive; activate
     with `USERELATIONSHIP` where needed)
   - `revenue_wip[period]` (text `YYYY-MM`) → build a calculated column
     `PeriodDate = DATEVALUE(revenue_wip[period] & "-01")` and relate that to
     `DateTable[Date]`.

## 2. Core DAX Measures

```DAX
-- Invoicing
Total Invoiced        = SUM(invoices[invoice_amount])
Total Collected        = SUM(invoices[paid_amount])
Outstanding Amount      = [Total Invoiced] - [Total Collected]
Overdue Amount           = CALCULATE([Outstanding Amount], invoices[invoice_status] = "Overdue")
Collection Rate %        = DIVIDE([Total Collected], [Total Invoiced])

-- DSO
Avg DSO (Days) = AVERAGEX(
    FILTER(invoices, invoices[invoice_status] = "Paid"),
    DATEDIFF(invoices[invoice_date], invoices[paid_date], DAY)
)

-- Revenue Recognition / WIP
Total Billed            = SUM(revenue_wip[billed_amount])
Total Recognized Revenue = SUM(revenue_wip[recognized_revenue])
Total WIP                = SUM(revenue_wip[wip_amount])
Recognition Rate %       = DIVIDE([Total Recognized Revenue], [Total Billed])

-- SOX / Audit
SOX Compliant Records   = CALCULATE(COUNTROWS(revenue_wip), revenue_wip[sox_compliant_flag]="Y")
SOX Compliance %        = DIVIDE([SOX Compliant Records], COUNTROWS(revenue_wip))
Audit Flags Raised      = CALCULATE(COUNTROWS(revenue_wip), revenue_wip[audit_flag]="Flagged")
Open Audit Findings     = CALCULATE(COUNTROWS(audit_log), audit_log[resolution_status] <> "Resolved")

-- Contracts
Active Contracts        = CALCULATE(DISTINCTCOUNT(contracts[contract_id]), contracts[status]="Active")
Contracts Modified       = CALCULATE(DISTINCTCOUNT(contracts[contract_id]), contracts[modification_type]<>"None")

-- Workday Transactions
Failed Txn %             = DIVIDE(
    CALCULATE(COUNTROWS(transactions), transactions[workday_status]="Failed"),
    COUNTROWS(transactions)
)

-- Risk Flag (client-level, used on Client 360 / Audit page)
At Risk Client = IF(
    [Overdue Amount] > 20000 || [Open Audit Findings] > 2,
    "⚠ At Risk", "OK"
)
```

## 3. Dashboard Pages

### Page 1 — Executive Summary
- KPI cards: Total Invoiced, Total Collected, Outstanding Amount, Recognition
  Rate %, SOX Compliance %, Audit Flags Raised.
- Line chart: Total Invoiced vs Total Collected vs Total Recognized Revenue
  by Month (`DateTable[MonthName]` on axis).
- Slicers: Region, Industry, Account Manager.

### Page 2 — Invoicing & Collections
- Donut chart: Invoice count by `invoice_status`.
- Clustered bar: Avg DSO by client (top 15).
- Aging bucket table (create calculated column
  `AgingBucket = SWITCH(TRUE(), DATEDIFF(due_date,TODAY(),DAY)<=0,"Current", ... )`).
- Drill-through page: Invoice-level detail table filtered by client/contract.

### Page 3 — Revenue Recognition & WIP
- Stacked column: Billed vs Recognized vs WIP by month.
- Line: SOX Compliance % trend.
- Table: WIP aging by contract (contract_id, client_name, Total WIP,
  months in WIP) sorted descending — mirrors SQL KPI 5.

### Page 4 — Contract Modifications & Workday
- Matrix: `modification_type` × `status`, values = contract count & total
  value.
- Stacked bar: Transaction count by `transaction_type` and `workday_status`.

### Page 5 — Audit & Risk
- Bar chart: Findings by type, colored by resolution status.
- Table: At-risk clients (uses `[At Risk Client]` measure) combining
  overdue amount + open audit findings + WIP.

### Page 6 — Client 360
- Single-client drill page: contract list, invoice list, WIP trend, audit
  history — designed to be screen-shared on a client call, directly
  supporting the JD's client-service and adhoc-reporting requirements.

## 4. Formatting & Delivery Notes
- Use a consistent color theme (e.g., navy/blue for revenue, amber for
  WIP/risk, red for overdue/flagged).
- Add a report-level tooltip page showing invoice/contract details on
  hover.
- Publish to Power BI Service; schedule a daily refresh if connected live
  to SQL Server, to mirror the JD's "daily/monthly financial reports"
  requirement.
