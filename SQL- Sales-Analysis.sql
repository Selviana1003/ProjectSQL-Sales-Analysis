-- 1. Selama transaksi yang terjadi selama 2021, pada bulan apa total nilai transaksi
-- (after_discount) paling besar? Gunakan is_valid = 1 untuk memfilter data transaksi.
SELECT
	EXTRACT(month FROM order_date) Bulan,
	SUM(after_discount) AS total_nilai_transaksi
FROM
	order_detail
 WHERE
 	EXTRACT(year from order_date) = 2021
    AND is_valid = 1
 GROUP BY
 	Bulan
 ORDER BY
 	total_nilai_transaksi DESC LIMIT 1;

-- 2. Selama transaksi pada tahun 2022, kategori apa yang menghasilkan nilai transaksi paling
-- besar? Gunakan is_valid = 1 untuk memfilter data transaksi.
SELECT 
	year(order_date) AS Tahun,
    s.category,
    ROUND(SUM(after_discount)) AS total_transaksi_terbesar
FROM
	order_detail AS o
LEFT JOIN sku_detail AS s on o.sku_id = s.id
WHERE
	EXTRACT(year FROM o.order_date) = 2022
    AND is_valid = 1
GROUP BY
	s.category,
    Tahun
ORDER BY
	total_transaksi_terbesar DESC
LIMIT 1;

-- 3. Bandingkan nilai transaksi dari masing-masing kategori pada tahun 2021 dengan 2022.
-- Sebutkan kategori apa saja yang mengalami peningkatan dan kategori apa yang mengalami
-- penurunan nilai transaksi dari tahun 2021 ke 2022. Gunakan is_valid = 1 untuk memfilter data
-- transaksi.
WITH transaksi2021 AS (
SELECT
	YEAR (od.order_date) AS Tahun,
    category,
    ROUND(SUM(after_discount)) total_transaksi2021
FROM
	order_detail AS od
LEFT JOIN
	sku_detail AS sd on od.sku_id = sd.id
WHERE
	YEAR(order_date) = 2021
    AND is_valid = 1
GROUP BY
	category,
    Tahun
ORDER BY
	total_transaksi2021
 )
, transaksi2022 AS (
SELECT
	YEAR(od.order_date) AS Tahun,
    category,
    ROUND(SUM(after_discount)) total_transaksi2022
FROM
	order_detail AS od
LEFT JOIN
	sku_detail AS sd on od.sku_id = sd.id
WHERE
	YEAR(order_date) = 2022
    AND is_valid = 1
GROUP BY
	category,
    Tahun
ORDER BY
	total_transaksi2022
)
SELECT
	transaksi2021.category,
    total_transaksi2021,
    total_transaksi2022,
    ROUND(((total_transaksi2022 - total_transaksi2021)/total_transaksi2021)*100) AS Peningkatan,
		CASE
			WHEN (total_transaksi2022 > total_transaksi2021) THEN "INCREASE"
            WHEN (total_transaksi2022 < total_transaksi2021) THEN "DECREASE"
		END AS Keterangan
    FROM
		transaksi2021
	LEFT JOIN transaksi2022 on transaksi2022.category = transaksi2021.category
    ORDER BY
		Peningkatan DESC;
-- 4. Tampilkan top 5 metode pembayaran yang paling populer digunakan selama 2022
-- (berdasarkan total unique order). Gunakan is_valid = 1 untuk memfilter data transaksi.
SELECT
	payment_method,
    COUNT(DISTINCT id) AS total_payment
FROM (
  SELECT
  	order_detail.id,
  	payment_detail.payment_method
  FROM 
  	order_detail
  LEFT JOIN
  	payment_detail on order_detail.payment_id = payment_detail.id
  WHERE
  	order_detail.is_valid = 1
  	AND EXTRACT(YEAR FROM order_detail.order_date)= 2022) AS Orderspayments
 GROUP BY
 	payment_method
 ORDER BY
 	total_payment DESC
 LIMIT 5;

-- 5.  Urutkan dari ke-5 produk ini berdasarkan nilai transaksinya.
-- 01. Samsung
-- 02. Apple
-- 03. Sony
-- 04. Huawei
-- 05. Lenovo
-- Gunakan is_valid = 1 untuk memfilter data transaksi.
with ProductSales AS (
    SELECT
        CASE
            WHEN LOWER(sd.sku_name) LIKE '%samsung%' THEN 'Samsung'
            WHEN LOWER(sd.sku_name) LIKE '%apple%' or
            	 LOWER(sd.sku_name) LIKE '%iphone%' or
            	 LOWER(sd.sku_name) LIKE '%macbook%' or
            	 LOWER(sd.sku_name) LIKE '%ipad%' THEN 'Apple'
            WHEN LOWER(sd.sku_name) LIKE '%sony%' THEN 'Sony'
            WHEN LOWER(sd.sku_name) LIKE '%huawei%' THEN 'Huawei'
            WHEN LOWER(sd.sku_name) LIKE '%lenovo%' THEN 'Lenovo'
        END AS product_category,
        ROUND(SUM(od.after_discount)) AS total_sales
    FROM
        order_detail od
    JOIN
        sku_detail sd ON od.sku_id = sd.id
    WHERE
        od.is_valid = 1
    GROUP BY
        product_category
)
SELECT
    product_category,
    total_sales
	FROM
    	ProductSales
    where product_category is not null
    GROUP BY
		product_category
	ORDER BY
    	total_sales DESC;