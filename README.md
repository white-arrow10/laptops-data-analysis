# Laptop Data Analysis with SQL

## Overview
This project demonstrates the complete SQL workflow for managing and analyzing a laptop dataset. It begins with creating a backup of the raw data, proceeds through data cleaning and transformation, and culminates in exploratory data analysis to uncover insights.

The primary goal is to show practical SQL techniques for data preparation and analytical querying on a real-world dataset.

---

## Dataset
- The raw dataset (`laptopData.csv`) includes detailed laptop specifications such as brand, model, processor, RAM, storage, price, and other features.
- Initial backup of this dataset ensured data safety before transformations.

---

## SQL Scripts and Workflow

1. **Backup (`file1.sql`):** 
   - Creates a backup copy of the original laptop data table to preserve the raw dataset before any modifications.

2. **Data Cleaning (`cleaning.sql`):**
   - Performs cleaning operations such as removing duplicates, correcting inconsistent or missing values, standardizing data formats, and preparing tables for analysis.

3. **Exploratory Data Analysis (`eda.sql`):**
   - Contains queries for aggregations, grouping, trend analysis, and summarizing dataset features to extract business-meaningful insights.

---

## Tools and Environment

- SQL (compatible with MySQL, PostgreSQL, and similar relational databases)
- Data import from CSV format into SQL database
- Query execution via database clients or command line interfaces

---

## Key Outcomes

- Secure backup of raw data before processing.
- Comprehensive cleaning ensuring high-quality, consistent dataset ready for analysis.
- Analytical queries yielding insights such as brand pricing trends, popular specifications, and price distributions.

---

## Usage Instructions

1. Import `laptopData.csv` into your SQL database.
2. Execute `file1.sql` to create a backup of the original dataset.
3. Run `cleaning.sql` to clean and transform the data.
4. Execute `eda.sql` to perform exploratory analysis and generate insights.

---
