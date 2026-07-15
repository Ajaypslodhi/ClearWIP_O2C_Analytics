# Data Dictionary — O2C Revenue & Billing Analytics

## clients.csv (40 rows)
| Field | Type | Description |
|---|---|---|
| client_id | VARCHAR(10) PK | Unique client identifier |
| client_name | VARCHAR(100) | Client company name |
| industry | VARCHAR(50) | Industry vertical |
| region | VARCHAR(30) | North America / Europe / APAC |
| account_manager | VARCHAR(50) | Internal owner |
| contract_start_date | DATE | First engagement date |

## contracts.csv (106 rows)
| Field | Type | Description |
|---|---|---|
| contract_id | VARCHAR(10) PK | Unique contract identifier |
| client_id | VARCHAR(10) FK | Links to clients |
| contract_type | VARCHAR(20) | New / Renewal / Amendment |
| original_value | DECIMAL | Contract value (USD) |
| currency | VARCHAR(5) | Currency code |
| start_date / end_date | DATE | Contract term |
| status | VARCHAR(25) | Active / Closed / Under Modification / Terminated |
| last_modified_date | DATE | Date of most recent modification |
| modification_type | VARCHAR(30) | Value Change / Term Extension / Scope Change / Rate Revision / Reversal / None |

## invoices.csv (783 rows)
| Field | Type | Description |
|---|---|---|
| invoice_id | VARCHAR(10) PK | Unique invoice identifier |
| contract_id | VARCHAR(10) FK | Links to contracts |
| invoice_date / due_date | DATE | Billing and due dates |
| invoice_amount | DECIMAL | Invoiced amount |
| paid_amount | DECIMAL | Amount collected |
| paid_date | DATE | Date payment received (blank if unpaid) |
| invoice_status | VARCHAR(20) | Paid / Outstanding / Overdue / Disputed |

## transactions.csv (580 rows)
| Field | Type | Description |
|---|---|---|
| transaction_id | VARCHAR(10) PK | Unique transaction identifier |
| contract_id | VARCHAR(10) FK | Links to contracts |
| transaction_date | DATE | Date of transaction |
| transaction_type | VARCHAR(30) | Billing / Adjustment / Reversal / Contract Modification / Write-off |
| amount | DECIMAL | Net transaction amount (can be negative) |
| workday_status | VARCHAR(20) | Processed / Pending / Failed (Workday ERP processing status) |

## revenue_wip.csv (1,272 rows)
| Field | Type | Description |
|---|---|---|
| record_id | VARCHAR(10) PK | Unique record identifier |
| contract_id | VARCHAR(10) FK | Links to contracts |
| period | CHAR(7) | Reporting month, YYYY-MM |
| billed_amount | DECIMAL | Amount billed in period |
| recognized_revenue | DECIMAL | Revenue recognized per SOX guidance |
| wip_amount | DECIMAL | Unbilled/unrecognized work-in-progress |
| sox_compliant_flag | CHAR(1) | Y / N |
| audit_flag | VARCHAR(10) | Clear / Flagged |

## audit_log.csv (25 rows)
| Field | Type | Description |
|---|---|---|
| audit_id | VARCHAR(10) PK | Unique audit record identifier |
| contract_id | VARCHAR(10) FK | Links to contracts |
| audit_date | DATE | Date of audit |
| audit_type | VARCHAR(20) | Internal / External |
| finding | VARCHAR(60) | Revenue Recognition Exception / Missing Evidence / Duplicate Invoice / Late Contract Update / Unauthorized Adjustment |
| resolution_status | VARCHAR(20) | Resolved / In Progress / Escalated |

## Entity Relationship Summary
```
clients (1) ──< contracts (many)
contracts (1) ──< invoices (many)
contracts (1) ──< transactions (many)
contracts (1) ──< revenue_wip (many)
contracts (1) ──< audit_log (many)
```
All joins use `client_id` / `contract_id` as keys. This mirrors a standard
star-schema design ready for direct import into Power BI.
