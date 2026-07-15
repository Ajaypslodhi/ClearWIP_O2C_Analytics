/* =========================================================================
   PROJECT: O2C Revenue & Billing Analytics (CA Operations)
   FILE   : 01_schema.sql
   PURPOSE: Creates the relational schema for the O2C dataset.
            Compatible with SQL Server / MySQL / PostgreSQL (minor tweaks
            noted inline for engine-specific data types).
   ========================================================================= */

DROP TABLE IF EXISTS audit_log;
DROP TABLE IF EXISTS revenue_wip;
DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS invoices;
DROP TABLE IF EXISTS contracts;
DROP TABLE IF EXISTS clients;

CREATE TABLE clients (
    client_id             VARCHAR(10)   PRIMARY KEY,
    client_name           VARCHAR(100)  NOT NULL,
    industry              VARCHAR(50),
    region                VARCHAR(30),
    account_manager       VARCHAR(50),
    contract_start_date   DATE
);

CREATE TABLE contracts (
    contract_id           VARCHAR(10)   PRIMARY KEY,
    client_id             VARCHAR(10)   NOT NULL,
    contract_type         VARCHAR(20),          -- New / Renewal / Amendment
    original_value        DECIMAL(14,2),
    currency              VARCHAR(5),
    start_date            DATE,
    end_date              DATE,
    status                VARCHAR(25),           -- Active/Closed/Under Modification/Terminated
    last_modified_date    DATE,
    modification_type     VARCHAR(30),           -- Value Change/Term Extension/Scope Change/Rate Revision/Reversal/None
    FOREIGN KEY (client_id) REFERENCES clients(client_id)
);

CREATE TABLE invoices (
    invoice_id            VARCHAR(10)   PRIMARY KEY,
    contract_id           VARCHAR(10)   NOT NULL,
    invoice_date          DATE,
    due_date              DATE,
    invoice_amount        DECIMAL(14,2),
    paid_amount           DECIMAL(14,2),
    paid_date             DATE,
    invoice_status        VARCHAR(20),           -- Paid/Outstanding/Overdue/Disputed
    FOREIGN KEY (contract_id) REFERENCES contracts(contract_id)
);

CREATE TABLE transactions (
    transaction_id        VARCHAR(10)   PRIMARY KEY,
    contract_id           VARCHAR(10)   NOT NULL,
    transaction_date      DATE,
    transaction_type      VARCHAR(30),           -- Billing/Adjustment/Reversal/Contract Modification/Write-off
    amount                DECIMAL(14,2),
    workday_status        VARCHAR(20),           -- Processed/Pending/Failed
    FOREIGN KEY (contract_id) REFERENCES contracts(contract_id)
);

CREATE TABLE revenue_wip (
    record_id             VARCHAR(10)   PRIMARY KEY,
    contract_id           VARCHAR(10)   NOT NULL,
    period                CHAR(7),               -- YYYY-MM
    billed_amount         DECIMAL(14,2),
    recognized_revenue    DECIMAL(14,2),
    wip_amount            DECIMAL(14,2),
    sox_compliant_flag    CHAR(1),               -- Y/N
    audit_flag            VARCHAR(10),           -- Clear/Flagged
    FOREIGN KEY (contract_id) REFERENCES contracts(contract_id)
);

CREATE TABLE audit_log (
    audit_id              VARCHAR(10)   PRIMARY KEY,
    contract_id           VARCHAR(10)   NOT NULL,
    audit_date             DATE,
    audit_type             VARCHAR(20),          -- Internal/External
    finding                VARCHAR(60),
    resolution_status      VARCHAR(20),          -- Resolved/In Progress/Escalated
    FOREIGN KEY (contract_id) REFERENCES contracts(contract_id)
);

/* ---------- Helpful indexes for reporting joins ---------- */
CREATE INDEX idx_contracts_client   ON contracts(client_id);
CREATE INDEX idx_invoices_contract  ON invoices(contract_id);
CREATE INDEX idx_txn_contract       ON transactions(contract_id);
CREATE INDEX idx_wip_contract       ON revenue_wip(contract_id);
CREATE INDEX idx_audit_contract     ON audit_log(contract_id);
