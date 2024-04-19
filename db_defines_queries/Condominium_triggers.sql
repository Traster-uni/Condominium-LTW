CREATE OR REPLACE FUNCTION max_rental_req_accepted_per_user() RETURNS trigger
AS $$
	print(TD)
	usr_id = TD["new"]
	rt_day = TD["new"]
	qry = f"""
	        SELECT r_req.ud_id, COUNT() as c
	        FROM rental_requests r_req
	        WHERE r_req.ud_id == {usr_id} AND r_req stat=='pending' AND
	             date_part(current_date, 'day') - date_part({rt_day}, 'day') <= 30
	        GROUP BY (r_req.ud_id)
	        """
	try:
		qry_result = plpy.execute(qry)
	except plpy.SPIError:
	    return "something went wrong"
	else:
	    if qry_result[0][c] > 5:
	        raise plpy.error(f"Max num of requests reached for {usr_id}")
	    return "OK"
$$ LANGUAGE plpython3u;

CREATE TRIGGER rental_req_stamp BEFORE INSERT OR UPDATE ON rental_request
    FOR EACH STATEMENT EXECUTE FUNCTION max_rental_req_accepted_per_user();
    --- FOR EACH STATEMENT option will call the trigger function only once for each statement, regardless of the number of rows getting modified.

-- TO MODIFY TRIGGERS:
-- DROP TRIGGER rental_req_stamp ON rental_request;
-- DROP FUNCTION max_rental_req_accepted_per_user();

INSERT INTO rental_request VALUES
    (1, 43, 105, CURRENT_TIME(1)::time, CURRENT_DATE+INTERVAL '2 days', 2, CURRENT_TIMESTAMP, 'pending');