CREATE OR REPLACE FUNCTION max_rental_req_accepted_per_user() RETURNS trigger
AS $$
	usr_id = TD["new"]["ud_id"]
	rt_id = TD["new"]["rental_req_id"]
	print(f"usr_id: {usr_id}, rental_day: {rt_day}")
	qry = f"""
	        SELECT count(r_req.rental_req_id)
	        FROM rental_requests r_req
	        WHERE r_req.ud_id == {usr_id} AND (r_req.stat=='pending' OR r_req.stat=='accepted')
				AND date_trunc('day', r_req.rental_time) > date_trunc('day', CURRENT_TIMESTAMP)
	        GROUP BY (r_req.rental_req_id)
	        """
	plpython3u.prepare(qry)
	try:
		qry_result = plpy.execute(qry)
	except plpy.SPIError:
	    return "something went wrong"
	else:
	    if qry_result[0] > 5:
	        raise plpy.error(f"Max num of requests reached for {usr_id}, rolling back")
		else:
	    	return "OK"
$$ LANGUAGE plpython3u;

CREATE TRIGGER rental_req_stamp BEFORE INSERT OR UPDATE ON rental_request
    FOR EACH STATEMENT EXECUTE FUNCTION max_rental_req_accepted_per_user();
    --- FOR EACH STATEMENT option will call the trigger function only once for each statement, regardless of the number of rows getting modified.

CREATE OR REPLACE FUNCTION rental_req_disj() RETURNS trigger
AS $$

$$ LANGUAGE plpython3u

CREATE TRIGGER rental_req_disj_check BEFORE INSERT OR UPDATE ON rental_request
	FOR EACH STATEMENT EXECUTE FUNCTION rental_req_disj();


CREATE OR REPLACE FUNCTION new_aptBlock RETURN trigger
AS $$
	rq_status_old = TD["old"]["stat"]
	rq_status_new = TD["new"]["stat"]

	ut_id = TD["new"]["ut_id"]
	aptBlock_id = TD["new"]["aptBlockReq_id"]
	addr_aptB = TD["new"]["addr_aptB"]
	city = TD["new"]["city"]
	cap = TD["new"]["cap"]

	if rq_status_old == "pending":
		if rq_status_new == "refused":
			raise plpy.error(f"The request was refused, aborting operation")

		elif rq_status_new == "accpeted":
			qry = f"INSERT INTO aptBlock VALUES({aptBlock_id}, {addr_aptB}, {city}, {cap})"
			plpy.prepare(qry)
			try:
				plpy.execute(qry)
			except plpy.SPIError:
	    		return "something went wrong"

	return "OK"
$$ LANGUAGE plpython3u;

CREATE TRIGGER insert_aptBlock_on_req_accepted AFTER UPDATE ON req_aptBlock_create
	FOR EACH ROW EXECUTE FUNCTION new_aptBlock();


CREATE OR REPLACE FUNCTION define_relative_bulletinBoards RETURN trigger
AS $$
	aptBlock_id = TD["new"]["aptBlock_id"]

	qry_geneal = f"""
			INSERT INTO aptBlock_bulletinBoard (aptBlock_id, bb_name, bb_year)
			VALUES({aptBlock_id}, general, date_part(current_date, 'year'));
			"""
	qry_admin = f"""
			INSERT INTO aptBlock_bulletinBoard (aptBlock_id, bb_name, bb_year)
			VALUES({aptBlock_id}, admin, date_part(current_date, 'year'));
			"""
	plpy.prepare(qry_geneal)
	plpy.prepare(qry_admin)
	try:
		plpy.execute(qry_geneal)
	except plpy.SPIError:
	    		return "something went wrong with the insertion of the general bboard"
	try:
		plpy.execute(qry_admin)
	except plpy.SPIError:
		return "something went wrong with the insertion of the admin bboard"
	return "OK"
$$ LANGUAGE plpython3u;

CREATE TRIGGER insert_bulletinBoard_on_aptBlock_creation AFTER INSERT ON aptBlock
	FOR EACH ROW EXECUTE FUNCTION define_relative_bulletinBoards();


-- TO MODIFY TRIGGERS:
-- DROP TRIGGER rental_req_stamp ON rental_request;
-- DROP FUNCTION max_rental_req_accepted_per_user();



-- TODO: On creation of new instance of aptBlock TRIGGER creations of two new instances 
--   of aptBlock_bulletinBoard: "admin" and "general"