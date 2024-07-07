----------------------
-- Analytical Query --
----------------------

----------------------------------------------------------------------------------------------------------------------------------
-- 1. Ranking popularitas model mobil berdasarkan jumlah bid
SELECT *
FROM bids
JOIN advertisements USING (advertisement_id)
JOIN cars USING (car_id);

SELECT 	
	model,
	COUNT(bid_id) AS count_bid
FROM bids
JOIN advertisements USING (advertisement_id)
JOIN cars USING (car_id)
GROUP BY brand, model
ORDER BY count_bid DESC;



----------------------------------------------------------------------------------------------------------------------------------
-- 2. Membandingkan harga mobil berdasarkan harga rata-rata per kota.
SELECT 	
	city_name,
   	brand,
   	model,
   	year,
   	price,
   	TRUNC(AVG(price) OVER(PARTITION BY city_name)) AS avg_car_city
FROM cars
JOIN users USING(user_id)
JOIN cities USING(city_id)
GROUP BY 1,2,3,4,5;



----------------------------------------------------------------------------------------------------------------------------------
-- 3. Dari penawaran suatu model mobil, cari perbandingan tanggal user melakukan bid 
-- dengan bid selanjutnya beserta harga tawar yang diberikan.
-- Contoh: Bid untuk model mobil: Toyota Yaris.

SELECT 	c.model,
        b.user_id,
        bd.created_at AS first_bid_date,
        b.bid_price AS first_bid_price,
        LEAD(b.bid_price) OVER (PARTITION BY c.model ORDER BY bd.created_at) AS next_bid_price
FROM bid_details bd
JOIN bids b USING (bid_id)
JOIN advertisements a USING (advertisement_id)
JOIN cars c USING (car_id)
WHERE c.model = 'Toyota Yaris'



----------------------------------------------------------------------------------------------------------------------------------
-- 4. Membandingkan persentase perbedaan rata-rata harga mobil 
-- berdasarkan modelnya dan rata-rata harga bid yang ditawarkan oleh customer pada 6 bulan terakhir (4% bobot)
-- >  Difference adalah selisih antara rata-rata harga model mobil(avg_price) dengan rata-rata harga bid yang ditawarkan terhadap model tersebut(avg_bid_6month)
-- >  Difference dapat bernilai negatif atau positif
-- >  Difference_percent adalah persentase dari selisih yang telah dihitung, yaitu dengan cara difference dibagi rata-rata harga model mobil(avg_price) dikali 100%
-- >  Difference_percent dapat bernilai negatif atau positif
	
SELECT 
    model,
    ROUND(AVG(c.price), 2) AS avg_price,
    ROUND(AVG(CASE WHEN EXTRACT(MONTH FROM bd.created_at) >= EXTRACT(MONTH FROM CURRENT_DATE) - 6 THEN b.bid_price END), 2) AS avg_bid_6month,
    ROUND((AVG(c.price) - AVG(CASE WHEN EXTRACT(MONTH FROM bd.created_at) >= EXTRACT(MONTH FROM CURRENT_DATE) - 6 THEN b.bid_price END)), 2) AS difference,
    ROUND(((AVG(c.price) - AVG(CASE WHEN EXTRACT(MONTH FROM bd.created_at) >= EXTRACT(MONTH FROM CURRENT_DATE) - 6 THEN b.bid_price END)) / AVG(c.price)) * 100, 2) AS difference_percent
FROM  bid_details bd
JOIN  bids b USING(bid_id)
JOIN  advertisements a USING(advertisement_id)
JOIN  cars c USING(car_id)
WHERE c.brand = 'Daihatsu' AND c.model = 'Daihatsu Ayla'
GROUP BY brand, model;



----------------------------------------------------------------------------------------------------------------------------------
-- 5. Membuat window function rata-rata harga bid sebuah merk dan model mobil selama 6 bulan terakhir
-- Contoh: Mobil Toyota Yaris selama 6 bulan terakhir

WITH avg_brand_cars AS(
    SELECT
        brand,
        model,
        bd.created_at,
        EXTRACT(MONTH FROM bd.created_at) AS bid_month,
        AVG(b.bid_price) OVER(PARTITION BY brand, model ORDER BY bd.created_at) AS avg_bid
	FROM bid_details bd
	JOIN bids b USING(bid_id) 
	JOIN advertisements a USING(advertisement_id)
	JOIN cars c USING(car_id)
	WHERE c.brand = 'Toyota' AND c.model = 'Toyota Yaris'
	ORDER BY 4
)
SELECT
   brand,
   model,
   AVG(CASE WHEN bid_month = 4 THEN avg_bid ELSE NULL END) AS m_min_1,
   AVG(CASE WHEN bid_month = 3 THEN avg_bid ELSE NULL END) AS m_min_2,
   AVG(CASE WHEN bid_month = 2 THEN avg_bid ELSE NULL END) AS m_min_3,
   AVG(CASE WHEN bid_month = 1 THEN avg_bid ELSE NULL END) AS m_min_4,
   AVG(CASE WHEN bid_month = 12 THEN avg_bid ELSE NULL END) AS m_min_5,
   AVG(CASE WHEN bid_month = 11 THEN avg_bid ELSE NULL END) AS m_min_6
FROM avg_brand_cars
GROUP BY 1,2;