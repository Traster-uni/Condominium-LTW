CREATE OR REPLACE FUNCTION max_rental_req_accepted_per_user() RETURNS trigger
AS $$
	owner_id = TD["new"]["ut_owner_id"]
	rt_id	 = TD["new"]["rental_req_id"]
	qry = f"""
			SELECT r_req.ut_owner_id, count(r_req.rental_req_id) as num_req
			FROM rental_request r_req
			WHERE r_req.ut_owner_id = {owner_id}
				AND	(r_req.stat ='pending' OR r_req.stat = 'accepted')
				AND r_req.rental_datetime_start BETWEEN date_trunc('day', current_timestamp) AND date_trunc('day', current_timestamp) + INTERVAL '30 days'
			GROUP BY (r_req.ut_owner_id)
			"""
	qry2 =	f"""
			SELECT r_req.ut_owner_id, count(r_req.rental_req_id) as conum_requnt
			FROM rental_request r_req
			WHERE r_req.ut_owner_id = {owner_id}
				AND	(r_req.stat ='pending' OR r_req.stat = 'accepted')
				AND date_part('month', r_req.rental_datetime_start) = date_part('month', current_timestamp)
			GROUP BY (r_req.ut_owner_id)
			"""
	plpy.prepare(qry)
	try:
		qry_result = plpy.execute(qry)
	except plpy.SPIError:
		return "something went wrong"
	else:
		if len(qry_result) == 0:
			return "OK"
		if qry_result[0]["num_req"] > 5:
			raise plpy.error(f"Max num of requests reached for owner {owner_id}, rolling back")
			return "ERROR"
		else:
			return "OK"
$$ LANGUAGE plpython3u;


CREATE OR REPLACE TRIGGER max_rental_req_accepted_per_user 
	BEFORE INSERT OR UPDATE ON rental_request
    FOR EACH ROW EXECUTE FUNCTION max_rental_req_accepted_per_user();


CREATE OR REPLACE FUNCTION rental_req_disj() RETURNS trigger
AS $$
	owner_id 	= TD["new"]["ut_owner_id"]
	rt_id		= TD["new"]["rental_req_id"]
	rt_dt_s		= TD["new"]["rental_datetime_start"]
	rt_dt_e		= TD["new"]["rental_datetime_end"]
	rt_cs_id = TD["new"]["cs_id"]
	
	qry_disj = f"""
		SELECT EXISTS(
			SELECT rr.rental_req_id 
			FROM rental_request rr
			WHERE (
			date_part('day', timestamp '{rt_dt_s}') BETWEEN date_part('day', rr.rental_datetime_start) AND date_part('day', rr.rental_datetime_end)
			OR 
			date_part('day', timestamp '{rt_dt_e}') BETWEEN date_part('day', rr.rental_datetime_start) AND date_part('day', rr.rental_datetime_end)
			)AND(
			date_part('hour', timestamp '{rt_dt_s}') BETWEEN date_part('hour', rr.rental_datetime_start) AND date_part('hour', rr.rental_datetime_end)	
			OR
			date_part('hour', timestamp '{rt_dt_e}') BETWEEN date_part('hour', rr.rental_datetime_start) AND date_part('hour', rr.rental_datetime_end)
			)
			AND rr.stat = 'accepted' AND rr.cs_id = {rt_cs_id}
		) as disj
		"""

	plpy.prepare(qry_disj)
	try:
		qry_res = plpy.execute(qry_disj)
	except plpy.SPIError as e:
		plpy.error(f"Error rental requests overlapping")
		return "ERROR"
	if qry_res[0]["disj"] == True:
		raise plpy.error("A rental request in the same time period already exists")
		return "ERROR"
	else:
		return "OK"
$$ LANGUAGE plpython3u;

CREATE OR REPLACE TRIGGER rental_req_disj_check 
	BEFORE INSERT ON rental_request
	FOR EACH ROW EXECUTE FUNCTION rental_req_disj();


CREATE OR REPLACE FUNCTION rental_req_del_on_accepted() RETURNS trigger
AS $$
	rt_dt_s	= TD["new"]["rental_datetime_start"]
	rt_dt_e	= TD["new"]["rental_datetime_end"]
	rt_status_new = TD["new"]["stat"]
	rt_status_old = TD["old"]["stat"]
	rt_cs_id = TD["new"]["cs_id"]
	
	qry_day_join = f"""
			SELECT rr.rental_req_id 
			FROM rental_request rr
			WHERE (
			date_part('day', timestamp '{rt_dt_s}') BETWEEN date_part('day', rr.rental_datetime_start) AND date_part('day', rr.rental_datetime_end)
			OR 
			date_part('day', timestamp '{rt_dt_e}') BETWEEN date_part('day', rr.rental_datetime_start) AND date_part('day', rr.rental_datetime_end)
			)AND(
			date_part('hour', timestamp '{rt_dt_s}') BETWEEN date_part('hour', rr.rental_datetime_start) AND date_part('hour', rr.rental_datetime_end)	
			OR
			date_part('hour', timestamp '{rt_dt_e}') BETWEEN date_part('hour', rr.rental_datetime_start) AND date_part('hour', rr.rental_datetime_end)
			)
			AND rr.stat = 'pending' AND rr.cs_id = {rt_cs_id}
			"""
	
	
	plpy.prepare(qry_day_join)
	
	if rt_status_old == 'pending' and rt_status_new == 'accepted':
		try:
			qry_day_res = plpy.execute(qry_day_join)

		except plpy.SPIError as e:
			plpy.error("Error while executing queries")
			return "ERROR"
		
		
		for i in range(len(qry_day_res)):
			q = f"UPDATE rental_request SET stat = 'refused' where rental_request.rental_req_id = {qry_day_res[i]['rental_req_id']}"
			plpy.prepare(q)

			try:
				plpy.execute(q)

			except plpy.SPIError as e:
				plpy.error("Error while executing queries")
				return "ERROR"

$$ LANGUAGE plpython3u;

CREATE OR REPLACE TRIGGER rental_req_del_on_accepted
	AFTER UPDATE ON rental_request
	FOR EACH ROW EXECUTE FUNCTION rental_req_del_on_accepted();

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
			qry = f"""INSERT INTO aptBlock(aptBlock_id, addr_aptb, city, cap)
					VALUES({aptBlock_id}, '{addr_aptB}', '{city}', '{cap}');"""
			plpy.prepare(qry)
			try:
				plpy.execute(qry)
			except plpy.SPIError as e:
				raise plpy.error(f"Something went wrong, aborting operation: ({aptBlock_id}, '{addr_aptB}', '{city}', '{cap}')")
				return "ERROR"
	return "OK"
$$ LANGUAGE plpython3u;

CREATE OR REPLACE TRIGGER insert_aptBlock_on_req_accepted 
	AFTER UPDATE ON req_aptBlock_create
	FOR EACH ROW EXECUTE FUNCTION new_aptBlock();



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
	except plpy.SPIError as e:
		raise plpy.error("something went wrong with the insertion of the general bboard")
	try:
		plpy.execute(qry_admin)
	except plpy.SPIError as e:
		raise plpy.error(f"Error creating bullettin board")
		return "ERROR"
	return "OK"
$$ LANGUAGE plpython3u;

CREATE OR REPLACE TRIGGER insert_bulletinBoard_on_aptBlock_creation 
	AFTER INSERT ON aptBlock
	FOR EACH ROW EXECUTE FUNCTION define_relative_bulletinBoards();


CREATE OR REPLACE FUNCTION timestamp_update_on_update_ticket() RETURNS trigger
AS $$ 
	t_name = TD["table_name"]
	tick_id = TD["new"]["ticket_id"]
	t_status_new = TD["new"]["status"]
	t_status_old = TD["old"]["status"]
	qry = f"""
			UPDATE {t_name}
			SET time_mod = NOW()::timestamp
			WHERE {t_name}.ticket_id = {tick_id}
			"""

	if t_status_old == 'open':
		if t_status_new == 'closed':
			try:
				plpy.prepare(qry)
				plpy.execute(qry)

			except plpy.SPIError as e:
				raise plpy.error(f"Error updating timestamp")
				return "ERROR"
				
	return "OK"
$$ LANGUAGE plpython3u;

CREATE OR REPLACE TRIGGER timestamp_update_on_update_ticket
	AFTER UPDATE ON tickets
	FOR EACH ROW EXECUTE FUNCTION timestamp_update_on_update_ticket();

CREATE OR REPLACE FUNCTION timestamp_update_on_update_req_ut_access() RETURNS trigger
AS $$ 
	t_name = TD["table_name"]
	req_id = TD["new"]["utreq_id"]
	status_old = TD["old"]["status"]
	status_new = TD["new"]["status"]
	qry = f"""
			UPDATE {t_name}
			SET time_mod = NOW()::timestamp
			WHERE {t_name}.utreq_id = {req_id}
			"""

	if status_old == "pending":
		if status_new == "accepted" or status_new == 'refused':
			try:
				plpy.prepare(qry)
				plpy.execute(qry)

			except plpy.SPIError as e:
				raise plpy.error(f"Error updating timestamp")
				return "ERROR"

	return "OK"
$$ LANGUAGE plpython3u;

CREATE OR REPLACE TRIGGER timestamp_update_on_update_req_ut_access
	AFTER UPDATE ON req_ut_access
	FOR EACH ROW EXECUTE FUNCTION timestamp_update_on_update_req_ut_access();

CREATE OR REPLACE FUNCTION ut_owner_on_accepted_req() RETURNS trigger
AS $$
	rq_status_old = TD["old"]["status"]
	rq_status_new = TD["new"]["status"]

	rq_id = TD['old']['utreq_id']
	rq_img_dir = TD['old']['img_dir']

	if rq_status_old == "pending":
		if rq_status_new == "refused":
			return "OK"

		elif rq_status_new == "aborted":
			return "OK"

		elif rq_status_new == "accepted":
			qry = f"""INSERT INTO ut_owner(utreq_id, ut_ownership_doc_fname) 
					VALUES({rq_id}, '{rq_img_dir}')"""
			plpy.prepare(qry)
			try:
				plpy.execute(qry)
			except plpy.SPIError as e:
				raise plpy.error(f"Something went wrong, aborting operation: ({rq_id})")
				return "ERROR"

	return "OK"	
$$ LANGUAGE plpython3u;

CREATE OR REPLACE TRIGGER ut_owner_on_accepted_req 
	AFTER UPDATE ON req_ut_access
	FOR EACH ROW EXECUTE FUNCTION ut_owner_on_accepted_req();

