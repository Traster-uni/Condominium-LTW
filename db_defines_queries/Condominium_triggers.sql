CREATE OR REPLACE FUNCTION max_rental_req_accepted_per_user() RETURNS trigger
AS $$
	usr_id 	= TD["new"]["ut_id"]
	rt_id	= TD["new"]["rental_req_id"]
	qry = f"""
			SELECT r_req.ut_id, count(r_req.rental_req_id) as num_req
			FROM rental_request r_req
			WHERE r_req.ut_id = {usr_id}
				AND	(r_req.stat ='pending' OR r_req.stat = 'accepted')
				AND r_req.rental_datetime_start BETWEEN date_trunc('day', current_timestamp) AND date_trunc('day', current_timestamp) + INTERVAL '30 days'
			GROUP BY (r_req.ut_id)
			"""
	qry2 =	f"""
			SELECT r_req.ut_id, count(r_req.rental_req_id) as conum_requnt
			FROM rental_request r_req
			WHERE r_req.ut_id = {usr_id}
				AND	(r_req.stat ='pending' OR r_req.stat = 'accepted')
				AND date_part('month', r_req.rental_datetime_start) = date_part('month', current_timestamp)
			GROUP BY (r_req.ut_id)
			"""
	plpy.prepare(qry)
	try:
		qry_result = plpy.execute(qry)
	except plpy.SPIError:
		return "something went wrong"
	else:
		if qry_result[0]["num_req"] > 5:
			raise plpy.error(f"Max num of requests reached for {usr_id}, rolling back")
		else:
			return "OK"
$$ LANGUAGE plpython3u;


CREATE OR REPLACE TRIGGER max_rental_req_accepted_per_user BEFORE INSERT OR UPDATE ON rental_request
    FOR EACH ROW EXECUTE FUNCTION max_rental_req_accepted_per_user();

CREATE OR REPLACE FUNCTION rental_req_disj() RETURNS trigger
AS $$
	usr_id		= TD["new"]["ut_id"]
	rt_id		= TD["new"]["rental_req_id"]
	rt_dt_s		= TD["new"]["rental_datetime_start"]
	rt_dt_e		= TD["new"]["rental_datetime_end"]
	
	qry = f"""
		SELECT EXISTS(
			SELECT rr.rental_req_id 
			FROM rental_request rr
			WHERE date_part('day', timestamp '{rt_dt_s}') 
				BETWEEN date_part('day', rr.rental_datetime_start) AND date_part('day', rr.rental_datetime_end)
			AND date_part('day', timestamp '{rt_dt_e}') 
				BETWEEN date_part('day', rr.rental_datetime_start) AND date_part('day', rr.rental_datetime_end)
		) as disj
		"""
	plpy.prepare(qry)
	try:
		qry_result = plpy.execute(qry)

	except plpy.SPIError:
		td = TD["new"]
		ins_print = f"INSERT INTO python_log (log_message) VALUES ('{td}')"
		plpy.prepare(ins_print)
		plpy.execute(qry)
		return "something went wrong"
	if qry_result[0]["disj"] == True:
		raise plpy.error("A rental request in the same time period already exists")
	else:
		return "OK"
$$ LANGUAGE plpython3u;

CREATE OR REPLACE TRIGGER rental_req_disj_check BEFORE INSERT OR UPDATE ON rental_request
	FOR EACH ROW EXECUTE FUNCTION rental_req_disj();

DROP TRIGGER rental_req_disj_check ON rental_request

CREATE OR REPLACE FUNCTION new_aptBlock() RETURNS trigger
AS $$
	rq_status_old = TD["old"]["stat"]
	rq_status_new = TD["new"]["stat"]

	ut_id 		= TD["new"]["ut_id"]
	aptBlock_id = TD["new"]["aptblockreq_id"]
	addr_aptB 	= TD["new"]["addr_aptb"]
	city 		= TD["new"]["city"]
	cap 		= TD["new"]["cap"]

	if rq_status_old == "pending":
		if rq_status_new == "refused":
			raise plpy.error(f"The request was refused, aborting operation")

		elif rq_status_new == "accepted":
			qry = f"INSERT INTO aptBlock VALUES({aptBlock_id}, '{addr_aptB}', '{city}', '{cap}', null)"
			plpy.prepare(qry)
			try:
				plpy.execute(qry)
			except plpy.SPIError:
				raise plpy.error(f"Something went wrong, aborting operation: ({aptBlock_id}, '{addr_aptB}', '{city}', '{cap}')")
	return "OK"
$$ LANGUAGE plpython3u;

CREATE OR REPLACE TRIGGER insert_aptBlock_on_req_accepted AFTER UPDATE ON req_aptBlock_create
	FOR EACH ROW EXECUTE FUNCTION new_aptBlock();

DROP TRIGGER insert_aptBlock_on_req_accepted on req_aptBlock_create

CREATE OR REPLACE FUNCTION define_relative_bulletinBoards() RETURNS trigger
AS $$
	aptBlock_id = TD["new"]["aptblock_id"]

	qry_geneal = f"""
			INSERT INTO aptBlock_bulletinBoard (aptBlock_id, bb_name, bb_year)
			VALUES({aptBlock_id}, 'general', date_part('year', current_date));
			"""
	qry_admin = f"""
			INSERT INTO aptBlock_bulletinBoard (aptBlock_id, bb_name, bb_year)
			VALUES({aptBlock_id}, 'admin', date_part('year', current_date));
			"""
	plpy.prepare(qry_geneal)
	plpy.prepare(qry_admin)
	try:
		plpy.execute(qry_geneal)
	except plpython3u.SPIError:
				return "something went wrong with the insertion of the general bboard"
	try:
		plpy.execute(qry_admin)
	except plpy.SPIError:
		return "something went wrong with the insertion of the admin bboard"
	return "OK"
$$ LANGUAGE plpython3u;

CREATE OR REPLACE TRIGGER insert_bulletinBoard_on_aptBlock_creation AFTER INSERT ON aptBlock
	FOR EACH ROW EXECUTE FUNCTION define_relative_bulletinBoards();
-- Triggers insertion of admin and general board once a new aptBlock has been defined.

DROP TRIGGER insert_bulletinBoard_on_aptBlock_creation ON aptBlock
-- TO MODIFY TRIGGERS:
-- DROP TRIGGER rental_req_stamp ON rental_request;
-- DROP FUNCTION max_rental_req_accepted_per_user();
