WITH Base_Data AS (
  SELECT 
    CAST(Date AS DATE) as Market_Date,
    GLD as Gold_USD,
    SLV as Silver_USD,
    SPX as Sp500_index,
    USO as Oil_USD,
    `EUR USD` as EUR_USD_Rate
  FROM `pp26-488519.gld_price.gold`
),
Returns AS (
  SELECT *,
    LN(Gold_USD / NULLIF(LAG(Gold_USD) OVER(ORDER BY Market_Date), 0)) as Gold_Log_Return,
    LN(Sp500_index / NULLIF(LAG(Sp500_index) OVER(ORDER BY Market_Date), 0)) as SPX_Log_Return
  FROM Base_Data
),
Calculations AS (
  SELECT *,
    ROUND(Gold_USD / NULLIF(Silver_USD, 0), 2) as Gold_Silver_Ratio,
    ROUND(STDDEV(Gold_Log_Return) OVER(ORDER BY Market_Date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW), 4) as Gold_30d_Vol,
    CASE
      WHEN Gold_Log_Return > 0 AND SPX_Log_Return < 0 THEN 'Hedge Behavior'
      WHEN SPX_Log_Return < -0.02 THEN 'Equity Stress'
      ELSE 'Normal'
    END as Market_Regime
  FROM Returns
)
SELECT * FROM Calculations 
WHERE Gold_Log_Return IS NOT NULL
;