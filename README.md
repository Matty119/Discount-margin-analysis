# Discount Impact & Margin Leakage Analysis
### FMCG Category Performance | SQL · Excel · Power BI

---

## Project Overview

This project analyzes **2.5M+ retail transactions** across 8 FMCG categories to identify discount dependency, margin leakage, and post-promotion demand cannibalization — with actionable recommendations for smarter promotional planning.

The dataset used is the **Dunnhumby "The Complete Journey"** dataset — a real-world retail panel tracking 2,500+ households over 2 years across grocery, meat, produce, personal care, nutrition, and other categories.

---

## Business Questions Answered

1. **Does discount depth actually drive volume?** Or are we just giving margin away?
2. **Which categories are discount-dependent?** Where do customers only buy on promotion?
3. **Where is margin leaking the most?** Which departments surrender the highest % of revenue as discounts?
4. **Is post-promotion demand dip real?** Are we cannibalizing future demand by running heavy promotions?

---

## Key Findings

### 1. Discount Dependency
| Category | Discount Dependency |
|----------|-------------------|
| GROCERY | 83.78% |
| MEAT-PCKGD | 72.33% |
| MEAT | 63.77% |
| DELI | 53.69% |
| NUTRITION | 50.15% |
| PRODUCE | 46.95% |
| DRUG GM | 42.89% |
| PASTRY | 37.89% |

**84% of grocery transactions happen only when a discount is applied** — customers are conditioned to wait for deals before buying staples.

### 2. Margin Leakage by Category
| Category | Discount as % of Revenue |
|----------|------------------------|
| MEAT | 32.20% |
| MEAT-PCKGD | 28.96% |
| GROCERY | 19.97% |
| PASTRY | 14.44% |
| NUTRITION | 12.49% |
| PRODUCE | 12.27% |
| DRUG GM | 9.93% |
| DELI | 8.62% |

**MEAT surrenders 32% of revenue as discounts** — nearly 1 in every 3 rupees of meat revenue is given away. DRUG GM at 9.93% suggests blanket discounting on personal care is unnecessary.

### 3. Post-Promotion Demand Cannibalization
- **Week 92** — promotion spike: 3,362 transactions, $113K in sales
- **Week 93** — immediate crash: 2,547 transactions, $80.8K in sales
- **Result: 24% drop in transactions** the week after a heavy promotion — confirming demand was pulled forward, not genuinely grown

---

## Recommendations

| Category | Recommendation |
|----------|---------------|
| GROCERY | Shift from blanket discounts to loyalty-based promotions — protect margin on staples |
| MEAT | Cap discount depth at 15% — volume lift beyond that doesn't justify margin cost |
| DRUG GM | Reduce unnecessary discounting — demand is largely inelastic |
| All Categories | Stagger promotional calendars — introduce soft-landing weeks to prevent post-promo demand dips |
| PASTRY | Maintain current approach — impulse-driven category, discounts not required to drive volume |

---

## Data Note
Weeks 1–16 were excluded from weekly trend analysis due to a household enrollment ramp-up period in the study panel — transactions in that window reflect data collection growth, not organic demand trends.

---

## Repository Structure

```
discount-margin-analysis/
│
├── pricing_analysis.sql     # All SQL queries with comments
│
├── results/
│   ├── Query1.csv        # Discount band vs sales volume
│   ├── Query2.csv        # Weekly sales & discount trend
│   ├── Query3.csv        # Margin leakage by category
│   └── Query4.csv        # Discount dependency score
│
└── README.md
```

---

## Tools Used
- **PostgreSQL** — data storage and querying
- **pgAdmin 4** — query execution and data exploration
- **Excel** — pivot analysis and data validation
- **Power BI** — interactive dashboard (in progress)

---

## Author
**Kamil Khan Pathan**  
[LinkedIn](https://www.linkedin.com/in/kamil-khan-pathan-4a9a3b251) | kamilkhan1906@gmail.com
