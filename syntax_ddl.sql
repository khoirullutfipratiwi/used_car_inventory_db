-------------------
-- Create Tables --
-------------------


CREATE TABLE cities(
	city_id INTEGER PRIMARY KEY,
	city_name VARCHAR(255) UNIQUE NOT NULL,
	location POINT NOT NULL
);

CREATE TABLE users(
	user_id SERIAL PRIMARY KEY,
	city_id INTEGER NOT NULL,
	name VARCHAR(255) UNIQUE NOT NULL,
	email VARCHAR(255) UNIQUE NOT NULL,
	phone_number VARCHAR(20) NOT NULL,
	address TEXT,
	CONSTRAINT fk_city_user
		FOREIGN KEY(city_id)
		REFERENCES cities(city_id)
);

CREATE TABLE cars(
	car_id SERIAL PRIMARY KEY,
	user_id INTEGER NOT NULL,
	brand VARCHAR(100) NOT NULL,
	model VARCHAR(100) NOT NULL,
	body_type VARCHAR(50) NOT NULL,
	car_type VARCHAR(25) NOT NULL,
	year INTEGER NOT NULL,
	price INTEGER NOT NULL CHECK (price > 0),
	photo TEXT NOT NULL,
	CONSTRAINT fk_user_product
		FOREIGN KEY(user_id)
		REFERENCES users(user_id)
);

CREATE TABLE advertisements(
	advertisement_id SERIAL PRIMARY KEY,
	car_id INTEGER NOT NULL,
	title TEXT NOT NULL,
	description TEXT NOT NULL,
	bid_feature BOOLEAN NOT NULL,
	CONSTRAINT fk_product_advertisement
		FOREIGN KEY(car_id)
		REFERENCES cars(car_id)
);

CREATE TABLE bids(
	bid_id SERIAL PRIMARY KEY,
	advertisement_id INTEGER NOT NULL,
	user_id INTEGER NOT NULL,
	bid_price INTEGER NOT NULL CHECK (bid_price > 0),
	CONSTRAINT fk_user_bid
		FOREIGN KEY(user_id)
		REFERENCES users(user_id),
	CONSTRAINT fk_advertisement_bid
		FOREIGN KEY(advertisement_id)
		REFERENCES advertisements(advertisement_id)
);

CREATE TABLE bid_details(
	bid_detail_id SERIAL PRIMARY KEY,
	bid_id INTEGER NOT NULL,
	label VARCHAR(50) NOT NULL DEFAULT 'Sent',
	created_at TIMESTAMP NOT NULL,
	CONSTRAINT fk_bids_biddetails
		FOREIGN KEY(bid_id)
		REFERENCES bids(bid_id)
);



COPY cities
FROM 'C:\Users\Public\cities.csv'
CSV
HEADER;

COPY users
FROM 'C:\Users\Public\users.csv'
CSV
HEADER;

COPY cars
FROM 'C:\Users\Public\cars_table.csv'
CSV
HEADER;

COPY advertisements
FROM 'C:\Users\Public\advertisements.csv'
CSV
HEADER;

COPY bids
FROM 'C:\Users\Public\bids.csv'
CSV
HEADER;

COPY bid_details
FROM 'C:\Users\Public\bid_details.csv'
CSV
HEADER;

SELECT * FROM cities;
SELECT * FROM users;
SELECT * FROM cars;
SELECT * FROM advertisements;
SELECT * FROM bids;
SELECT * FROM bid_details;