/* =========================================================================
   FILE: 03_analysis_queries.sql
   PURPOSE: KPI queries that feed the Power BI dashboard. Each query maps to
            a specific JD requirement (noted in the comment above it).
   ========================================================================= */

-- =========================================================================
-- KPI 1: MONTHLY INVOICE SUMMARY  (JD: "Generate monthly invoices...")
-- =========================================================================
SELECT
    FORMAT(invoice_date, 'yyyy-MM')        AS invoice_month,
    COUNT(*)                                AS invoice_count,
    SUM(invoice_amount)                     AS total_invoiced,
    SUM(paid_amount)                        AS total_collected,
    SUM(invoice_amount) - SUM(paid_amount)  AS outstanding_amount
FROM invoices
GROUP BY FORMAT(invoice_date, 'yyyy-MM')
ORDER BY invoice_month;

-- =========================================================================
-- KPI 2: DAYS SALES OUTSTANDING (DSO) BY CLIENT (JD: "Transactions/Revenue
-- report understanding", client service quality)
-- =========================================================================
SELECT
    c.client_id,
    cl.client_name,
    ROUND(AVG(DATEDIFF(DAY, i.invoice_date, i.due_date)), 1)      AS avg_credit_terms_days,
    ROUND(AVG(CASE WHEN i.invoice_status = 'Paid'
               THEN DATEDIFF(DAY, i.invoice_date, i.paid_date) END), 1) AS avg_actual_collection_days
FROM invoices i
JOIN contracts c ON i.contract_id = c.contract_id
JOIN clients cl  ON c.client_id  = cl.client_id
GROUP BY c.client_id, cl.client_name
ORDER BY avg_actual_collection_days DESC;

-- =========================================================================
-- KPI 3: INVOICE STATUS / AGING BUCKETS (JD: adhoc reporting for clients)
-- =========================================================================
SELECT
    invoice_status,
    COUNT(*)                                AS invoice_count,
    SUM(invoice_amount)                     AS amount,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM invoices), 1)  AS pct_of_total
FROM invoices
GROUP BY invoice_status
ORDER BY amount DESC;

-- =========================================================================
-- KPI 4: REVENUE RECOGNIZED VS BILLED VS WIP  (JD: "Recognizing revenue as
-- per SOX guidelines", "WIP report")
-- =========================================================================
SELECT
    period,
    SUM(billed_amount)        AS total_billed,
    SUM(recognized_revenue)   AS total_recognized_revenue,
    SUM(wip_amount)           AS total_wip,
    ROUND(100.0 * SUM(recognized_revenue) / NULLIF(SUM(billed_amount),0), 1) AS pct_recognized_of_billed
FROM revenue_wip
GROUP BY period
ORDER BY period;

-- =========================================================================
-- KPI 5: WIP AGING BY CONTRACT (JD: "monthly financial reports... WIP report")
-- =========================================================================
SELECT
    r.contract_id,
    cl.client_name,
    SUM(r.wip_amount)              AS total_wip_outstanding,
    COUNT(DISTINCT r.period)       AS months_in_wip,
    MAX(r.period)                  AS latest_period
FROM revenue_wip r
JOIN contracts c ON r.contract_id = c.contract_id
JOIN clients cl  ON c.client_id  = cl.client_id
GROUP BY r.contract_id, cl.client_name
HAVING SUM(r.wip_amount) > 0
ORDER BY total_wip_outstanding DESC;

-- =========================================================================
-- KPI 6: SOX COMPLIANCE RATE & AUDIT EXCEPTIONS (JD: "Comply with audit or
-- controls to ensure data integrity", "Recognizing revenue as per SOX")
-- =========================================================================
SELECT
    period,
    COUNT(*)                                                      AS total_records,
    SUM(CASE WHEN sox_compliant_flag = 'Y' THEN 1 ELSE 0 END)      AS compliant_records,
    ROUND(100.0 * SUM(CASE WHEN sox_compliant_flag = 'Y' THEN 1 ELSE 0 END) / COUNT(*), 1) AS sox_compliance_pct,
    SUM(CASE WHEN audit_flag = 'Flagged' THEN 1 ELSE 0 END)        AS audit_flags_raised
FROM revenue_wip
GROUP BY period
ORDER BY period;

-- =========================================================================
-- KPI 7: AUDIT FINDINGS & RESOLUTION STATUS (JD: "support internal/external
-- auditors", "meeting targets, calling out potential risk")
-- =========================================================================
SELECT
    finding,
    resolution_status,
    COUNT(*) AS occurrences
FROM audit_log
GROUP BY finding, resolution_status
ORDER BY occurrences DESC;

-- =========================================================================
-- KPI 8: CONTRACT MODIFICATIONS / REVERSALS TRACKER (JD: "Working on contract
-- modifications / reversals in Workday based on client evidence support")
-- =========================================================================
SELECT
    modification_type,
    status,
    COUNT(*)                         AS contract_count,
    SUM(original_value)              AS total_contract_value
FROM contracts
WHERE modification_type <> 'None'
GROUP BY modification_type, status
ORDER BY contract_count DESC;

-- =========================================================================
-- KPI 9: WORKDAY TRANSACTION PROCESSING HEALTH (JD: "Exposure to Workday
-- ERP system")
-- =========================================================================
SELECT
    transaction_type,
    workday_status,
    COUNT(*)                          AS txn_count,
    SUM(amount)                       AS net_amount
FROM transactions
GROUP BY transaction_type, workday_status
ORDER BY transaction_type, workday_status;

-- =========================================================================
-- KPI 10: CLIENT-LEVEL 360 SUMMARY (single view for client service / adhoc
-- requests — combines invoicing, revenue, WIP, and risk in one place)
-- =========================================================================
SELECT
    cl.client_id,
    cl.client_name,
    cl.region,
    COUNT(DISTINCT c.contract_id)                          AS active_contracts,
    SUM(DISTINCT c.original_value)                         AS total_contract_value,
    SUM(i.invoice_amount)                                  AS total_invoiced,
    SUM(i.paid_amount)                                     AS total_collected,
    (SELECT SUM(r.wip_amount) FROM revenue_wip r
      WHERE r.contract_id IN (SELECT contract_id FROM contracts WHERE client_id = cl.client_id)) AS total_wip,
    (SELECT COUNT(*) FROM audit_log a
      WHERE a.contract_id IN (SELECT contract_id FROM contracts WHERE client_id = cl.client_id)) AS audit_findings
FROM clients cl
LEFT JOIN contracts c ON cl.client_id = c.client_id
LEFT JOIN invoices i  ON c.contract_id = i.contract_id
GROUP BY cl.client_id, cl.client_name, cl.region
ORDER BY total_invoiced DESC;
