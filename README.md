# 🛒 Walmart Sales — Exploratory Data Analysis

> End-to-end data analysis pipeline: Python for data cleaning & transformation, MySQL for business intelligence queries, across **10,000+ real Walmart transactions** from 100 branches across Texas.

![Python](https://img.shields.io/badge/Python-3776AB?style=flat-square&logo=python&logoColor=white)
![Pandas](https://img.shields.io/badge/Pandas-150458?style=flat-square&logo=pandas&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-4479A1?style=flat-square&logo=mysql&logoColor=white)
![Jupyter](https://img.shields.io/badge/Jupyter-F37626?style=flat-square&logo=jupyter&logoColor=white)

---

## 📖 Description

This project performs a full exploratory data analysis (EDA) on a Walmart sales dataset. It follows a real-world analyst workflow — raw CSV in, clean database out, business questions answered with SQL.

**The pipeline has two stages:**

1. **Python (`project.ipynb`)** — Load, inspect, clean, and transform the data, then push it to a MySQL database via SQLAlchemy
2. **SQL (`walmart_EDA.sql`)** — Query the database to answer three business intelligence questions about payments, ratings, and store traffic

---

## 📁 Project Structure

```
📁 walmart-eda/
├── 📓 project.ipynb       ← Jupyter notebook (cleaning + DB load)
├── 📊 Walmart.csv         ← Raw dataset (10,051 rows)
├── 🗄️  walmart_EDA.sql    ← SQL business queries
└── 📄 README.md           ← This file
```

---

## 🗃️ Dataset

| Field | Details |
|---|---|
| **Source** | `Walmart.csv` |
| **Rows** | 10,051 transactions |
| **Branches** | 100 (`WALM001` – `WALM100`) |
| **Cities** | 98 cities across Texas |
| **Date Range** | January – March 2019 |

**Columns:**

| Column | Type | Description |
|---|---|---|
| `invoice_id` | int | Unique transaction ID |
| `Branch` | string | Store branch code (e.g. WALM003) |
| `City` | string | City of the branch |
| `category` | string | Product category (6 types) |
| `unit_price` | float | Price per item (cleaned from `$` string) |
| `quantity` | int | Number of items sold |
| `date` | date | Transaction date (DD/MM/YY) |
| `time` | time | Transaction time |
| `payment_method` | string | Cash / Credit card / Ewallet |
| `rating` | float | Customer rating (1-10) |
| `profit_margin` | float | Margin on the transaction |
| `total_price` | float | **Derived:** `unit_price x quantity` |

**Product Categories:**
`Electronic accessories` · `Fashion accessories` · `Food and beverages` · `Health and beauty` · `Home and lifestyle` · `Sports and travel`

---

## 🐍 Python Pipeline (`project.ipynb`)

### Step 1 — Load & Inspect
```python
df = pd.read_csv('Walmart.csv')
df.describe()
```

### Step 2 — Clean Data
```python
# Remove duplicates and nulls
df.drop_duplicates(inplace=True)
df.dropna(inplace=True)

# Fix unit_price: strip '$' and cast to float
df['unit_price'] = df['unit_price'].str.replace('$', '').astype('float')
```

### Step 3 — Feature Engineering
```python
# Add derived total_price column
df['total_price'] = df['unit_price'] * df['quantity']
```

### Step 4 — Push to MySQL
```python
from sqlalchemy import create_engine
engine = create_engine("mysql+pymysql://root:<password>@127.0.0.1:3306/walmart_db")
df.to_sql('walmart_db', con=engine, if_exists='replace', index=False)
```

---

## 🗄️ SQL Business Queries (`walmart_EDA.sql`)

Three business intelligence questions answered with SQL:

---

### Q1 — Payment Method Breakdown
> *How many transactions and items were sold per payment method?*

```sql
SELECT
  payment_method,
  COUNT(*)      AS no_payments,
  SUM(quantity) AS no_of_qty_sold
FROM walmart_db
GROUP BY payment_method;
```

Answers which of Cash, Credit card, or Ewallet is most popular by transaction volume and units sold.

---

### Q2 — Highest Rated Category per Branch
> *What is the top-rated product category in each store branch?*

```sql
SELECT Branch, Category, avg_rating
FROM (
  SELECT
    Branch, Category,
    AVG(rating) AS avg_rating,
    ROW_NUMBER() OVER (PARTITION BY Branch ORDER BY AVG(rating) DESC) AS rn
  FROM walmart_db
  GROUP BY Branch, Category
) AS t
WHERE rn = 1
ORDER BY Branch;
```

Identifies which product category customers rate highest in each of the 100 branches — useful for stocking and marketing decisions.

---

### Q3 — Busiest Day per Branch
> *Which day of the week sees the most transactions at each branch?*

```sql
WITH branch_transactions AS (
  SELECT
    branch,
    DAYNAME(STR_TO_DATE(`date`, '%d/%m/%y')) AS day_name,
    COUNT(*) AS no_transactions
  FROM walmart_db
  GROUP BY branch, day_name
)
SELECT branch, day_name, no_transactions
FROM (
  SELECT *,
    ROW_NUMBER() OVER (PARTITION BY branch ORDER BY no_transactions DESC) AS rn
  FROM branch_transactions
) ranked
WHERE rn = 1
ORDER BY branch;
```

Finds the single busiest weekday for every branch — useful for staffing and inventory planning.

---

## ⚙️ Setup & Usage

### Prerequisites

```bash
pip install pandas numpy matplotlib sqlalchemy pymysql jupyter
```

MySQL server running locally on port `3306` with a database named `walmart_db`.

### Run the Notebook

```bash
jupyter notebook project.ipynb
```

Execute cells top-to-bottom. The notebook will load and clean `Walmart.csv`, connect to your local MySQL instance, and push the cleaned data as the `walmart_db` table.

### Run the SQL Queries

Open `walmart_EDA.sql` in MySQL Workbench (or any MySQL client) and execute the queries against the `walmart_db` database.

> **Note:** Update the database credentials in Cell 5 of the notebook before running.

---

## 🔍 Key Findings

- **3 payment methods** tracked: Cash, Credit card, and Ewallet
- **6 product categories** across all branches — each branch has a clear top-rated one
- **Busiest day varies by branch** — identified per store for operational planning
- **Data cleaning** removed duplicates and null records; `unit_price` required string-to-float conversion before analysis

---

## 🛠️ Tech Stack

| Tool | Purpose |
|---|---|
| Python 3 | Data loading, cleaning, feature engineering |
| Pandas | DataFrame operations |
| SQLAlchemy + PyMySQL | Python to MySQL connection |
| MySQL | Data storage and SQL querying |
| Jupyter Notebook | Interactive analysis environment |

---

## 📄 License

MIT — free to use for learning and portfolio projects.
