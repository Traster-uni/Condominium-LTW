-- py log table
CREATE TABLE python_log (
    id SERIAL PRIMARY KEY,
    log_message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- py log print
SELECT * FROM python_log;

-- INSERT INTO python_log (log_message) 
-- VALUES ({'name': 'rental_req_disj_check', 'relid': '17642', 'table_name': 'rental_request', 'table_schema': 'public', 'when': 'BEFORE', 'level': 'ROW', 'old': None, 
-- 'new': {'rental_req_id': 5, 'ut_id': 1, 'adm_id': 1, 'rental_datatime_start': '2024-05-27 12:00:00', 'rental_datatime_end': '2024-05-27 20:30:00', 'submit_time': '2024-05-03 13:15:06.454797', 'stat': 'pending'}, 
-- 'event': 'INSERT', 'args': None})

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
SELECT * FROM req_aptBlock_create

-- insert
INSERT INTO rental_request 
  VALUES (1, 1, 1, '2024-05-04 12:00:00', '2024-05-05 07:30:0', CURRENT_TIMESTAMP, 'accepted');
INSERT INTO rental_request 
  VALUES (2, 1, 1, '2024-05-06 11:00:00', '2024-05-06 12:30:00', CURRENT_TIMESTAMP, 'pending');
INSERT INTO rental_request 
    VALUES (3, 1, 1, '2024-05-07 12:00:00', '2024-05-14 12:30:00', CURRENT_TIMESTAMP, 'accepted');
INSERT INTO rental_request 
  VALUES (4, 1, 1, '2024-05-15 12:00:00', '2024-05-15 20:30:00', CURRENT_TIMESTAMP, 'pending');
INSERT INTO rental_request(ut_id, adm_id, rental_datetime_start, rental_datetime_end, submit_time, stat)
  VALUES (1, 1, '2024-05-28 15:00:00', '2024-05-28 20:30:00', CURRENT_TIMESTAMP, 'pending');

INSERT INTO req_aptblock_create(ut_id, stat, addr_aptb, city, cap)
	VALUES (7, 'accepted', 'Via Roma, 1', 'Milano', '00122' )
----------------------------------------------------------
UPDATE req_aptBlock_create
	SET time_mod = CURRENT_TIMESTAMP, stat = 'accepted'
	WHERE aptblockreq_id = 3

-- trigger error:
--	ERROR:  KeyError: 'aptBlockReq_id'
--CONTEXT:  Traceback (most recent call last):
--  PL/Python function "new_aptblock", line 6, in <module>
--    aptBlock_id = TD["new"]["aptBlockReq_id"]
--PL/Python function "new_aptblock" 

--SQL state: 38000
-------------------------------------------------------
-- fetch 
SELECT r_req.ut_id, count(r_req.rental_req_id)
FROM rental_request r_req
WHERE r_req.ut_id = 1
	AND	r_req.stat ='pending'
	AND r_req.rental_datatime_start BETWEEN date_trunc('day', current_timestamp) AND date_trunc('day', current_timestamp) + INTERVAL '30 days'
GROUP BY (r_req.ut_id))

INSERT INTO rental_request
  VALUES (5, 1, 1, '2024-05-19 12:00:00', '2024-05-20 20:30:00', CURRENT_TIMESTAMP, 'pending');
