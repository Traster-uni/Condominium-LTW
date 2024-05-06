
-- create
CREATE TYPE request_status AS ENUM ('accepted', 'pending', 'refused');

CREATE TABLE rental_request(
	rental_req_id serial,
	ut_id integer,
	adm_id integer,
	rental_datatime_start timestamp NOT NULL,
	rental_datatime_end timestamp NOT NULL CHECK(rental_datatime_end > rental_datatime_start),
	submit_time timestamp NOT NULL,
	stat request_status NOT NULL
);

-- insert
INSERT INTO rental_request 
  VALUES (1, 1, 1, '2024-05-04 12:00:00', '2024-05-05 07:30:0', CURRENT_TIMESTAMP, 'accepted');
INSERT INTO rental_request 
  VALUES (2, 1, 1, '2024-05-06 11:00:00', '2024-05-06 12:30:00', CURRENT_TIMESTAMP, 'pending');
INSERT INTO rental_request 
    VALUES (3, 1, 1, '2024-05-07 12:00:00', '2024-05-14 12:30:00', CURRENT_TIMESTAMP, 'accepted');
INSERT INTO rental_request 
  VALUES (4, 1, 1, '2024-05-15 12:00:00', '2024-05-15 20:30:00', CURRENT_TIMESTAMP, 'pending');

-- fetch 
SELECT r_req.ut_id, count(r_req.rental_req_id)
FROM rental_request r_req
WHERE r_req.ut_id = 1
	AND	r_req.stat ='pending'
	AND r_req.rental_datatime_start BETWEEN date_trunc('day', current_timestamp) AND date_trunc('day', current_timestamp) + INTERVAL '30 days'
GROUP BY (r_req.ut_id)

INSERT INTO rental_request
  VALUES (5, 1, 1, '2024-05-19 12:00:00', '2024-05-20 20:30:00', CURRENT_TIMESTAMP, 'pending');