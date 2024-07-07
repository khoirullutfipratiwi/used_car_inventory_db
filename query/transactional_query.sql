-------------------------
-- Transactional Query --
-------------------------

----------------------------------------------------------------------------------------------------------------------------------
-- 1. Mencari mobil keluaran 2015 ke atas.

SELECT 	
	car_id,
	brand,
	model,
	year,
	price
FROM cars
WHERE year >= 2015
ORDER BY year;

SELECT * FROM users


	
----------------------------------------------------------------------------------------------------------------------------------
-- 2. Menambahkan satu data bid produk baru.
	
INSERT INTO bids(bid_id, user_id, advertisement_id, bid_price)
	VALUES(101, 5, 30, 185500000 );

INSERT INTO bid_status_log(bid_detail_id, bid_id, label, created_at)
	VALUES(240, 101, 'Sent', '2024-06-18 00:01:10');



----------------------------------------------------------------------------------------------------------------------------------
-- 3. Melihat semua mobil yg dijual 1 akun dari yg paling baru

SELECT user_id, 
  name,
  brand,
  model
FROM advertisements
JOIN cars USING(car_id)
JOIN users USING(user_id)
GROUP BY user_id, name, brand, model
ORDER BY user_id DESC
LIMIT 1;


----------------------------------------------------------------------------------------------------------------------------------
-- 4. Mencari mobil bekas yang termurah berdasarkan keyword

SELECT	
	car_id,
	brand,
	model,
	year,
	price
FROM product
WHERE model ILIKE '%Toyota%'
ORDER BY price ASC
LIMIT 1;



----------------------------------------------------------------------------------------------------------------------------------
-- 5. Mencari mobil bekas yang terdekat berdasarkan sebuah id kota, 
-- jarak terdekat dihitung berdasarkan latitude longitude. 
-- Perhitungan jarak dapat dihitung menggunakan rumus jarak euclidean berdasarkan latitude dan longitude. 

CREATE FUNCTION haversine_distance(point1 POINT, point2 POINT)
RETURNS float AS $$
DECLARE
	lon1 float := radians(point1[0]); 
	lat1 float := radians(point1[1]); 
	lon2 float := radians(point2[0]); 
	lat2 float:= radians(point2[1]);
	
	dlon float:= lon2 - lon1; 
	dlat float:= lat2 - lat1;
	a float; 
	c float;
	r float := 6371; 
	jarak float;
BEGIN
	-- haversine formula
	a := sin(dlat/2) ^2 + cos(lat1) * cos(lat2) * sin(dlon/2)^2;
	c := 2 * asin(sqrt(a));
	jarak := r * c;
	RETURN jarak;
END;
$$ LANGUAGE plpgsql;

-- mobil bekas yang terdekat berdasarkan sebuah id kota
SELECT 
    	m.car_id,
    	m.brand,
    	m.model,
		m.year,
		m.price,
		c.location AS city_location,
		haversine_distance((SELECT location from cities where city_id = 3471), c.location) AS distance
FROM cars AS m 
JOIN users AS u USING(user_id)
JOIN cities AS c USING(city_id)
ORDER BY distance ASC
LIMIT 1;

