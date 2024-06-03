--
-- PostgreSQL database dump
--

-- Dumped from database version 16.2 (Ubuntu 16.2-1.pgdg22.04+1)
-- Dumped by pg_dump version 16.2

-- Started on 2024-06-03 11:02:23

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

DROP DATABASE IF EXISTS condominium_ltw;
--
-- TOC entry 3720 (class 1262 OID 16389)
-- Name: condominium_ltw; Type: DATABASE; Schema: -; Owner: admin
--

CREATE DATABASE condominium_ltw WITH TEMPLATE = template0 ENCODING = 'LATIN1' LOCALE_PROVIDER = libc LOCALE = 'en_US';


ALTER DATABASE condominium_ltw OWNER TO admin;

\connect condominium_ltw

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 6 (class 2615 OID 17181)
-- Name: public; Type: SCHEMA; Schema: -; Owner: admin
--

CREATE SCHEMA public;


ALTER SCHEMA public OWNER TO admin;

--
-- TOC entry 971 (class 1247 OID 17783)
-- Name: bb_type; Type: TYPE; Schema: public; Owner: admin
--

CREATE TYPE public.bb_type AS ENUM (
    'general',
    'admin'
);


ALTER TYPE public.bb_type OWNER TO admin;

--
-- TOC entry 909 (class 1247 OID 17253)
-- Name: fiscalcode; Type: DOMAIN; Schema: public; Owner: admin
--

CREATE DOMAIN public.fiscalcode AS character varying(16)
	CONSTRAINT fiscalcode_check CHECK (((VALUE)::text ~ '^[A-Za-z]{6}[0-9]{2}[A-Za-z]{1}[0-9]{2}[A-Za-z]{1}[0-9]{3}[A-Za-z]{1}$'::text));


ALTER DOMAIN public.fiscalcode OWNER TO admin;

--
-- TOC entry 916 (class 1247 OID 17291)
-- Name: postalcode; Type: DOMAIN; Schema: public; Owner: admin
--

CREATE DOMAIN public.postalcode AS character varying(5)
	CONSTRAINT postalcode_check CHECK (((VALUE)::text ~ '^\d{5}$'::text));


ALTER DOMAIN public.postalcode OWNER TO admin;

--
-- TOC entry 891 (class 1247 OID 17190)
-- Name: request_status; Type: TYPE; Schema: public; Owner: admin
--

CREATE TYPE public.request_status AS ENUM (
    'accepted',
    'pending',
    'refused'
);


ALTER TYPE public.request_status OWNER TO admin;

--
-- TOC entry 962 (class 1247 OID 17689)
-- Name: ticket_status; Type: TYPE; Schema: public; Owner: admin
--

CREATE TYPE public.ticket_status AS ENUM (
    'open',
    'closed'
);


ALTER TYPE public.ticket_status OWNER TO admin;

--
-- TOC entry 968 (class 1247 OID 17737)
-- Name: ut_request_stat; Type: TYPE; Schema: public; Owner: admin
--

CREATE TYPE public.ut_request_stat AS ENUM (
    'pending',
    'accepted',
    'refused',
    'aborted',
    'abandoned'
);


ALTER TYPE public.ut_request_stat OWNER TO admin;

--
-- TOC entry 270 (class 1255 OID 17619)
-- Name: define_relative_bulletinboards(); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.define_relative_bulletinboards() RETURNS trigger
    LANGUAGE plpython3u
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
	except plpy.SPIError as e:
		raise plpy.error(f"Error creating bullettin board")
		return "ERROR"
	return "OK"
$$;


ALTER FUNCTION public.define_relative_bulletinboards() OWNER TO admin;

--
-- TOC entry 273 (class 1255 OID 17685)
-- Name: max_rental_req_accepted_per_user(); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.max_rental_req_accepted_per_user() RETURNS trigger
    LANGUAGE plpython3u
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
$$;


ALTER FUNCTION public.max_rental_req_accepted_per_user() OWNER TO admin;

--
-- TOC entry 276 (class 1255 OID 17617)
-- Name: new_aptblock(); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.new_aptblock() RETURNS trigger
    LANGUAGE plpython3u
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
			except plpy.SPIError as e:
				raise plpy.error(f"Something went wrong, aborting operation: ({aptBlock_id}, '{addr_aptB}', '{city}', '{cap}')")
				return "ERROR"
	return "OK"
$$;


ALTER FUNCTION public.new_aptblock() OWNER TO admin;

--
-- TOC entry 277 (class 1255 OID 17888)
-- Name: rental_req_del_on_accepted(); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.rental_req_del_on_accepted() RETURNS trigger
    LANGUAGE plpython3u
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

$$;


ALTER FUNCTION public.rental_req_del_on_accepted() OWNER TO admin;

--
-- TOC entry 275 (class 1255 OID 17614)
-- Name: rental_req_disj(); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.rental_req_disj() RETURNS trigger
    LANGUAGE plpython3u
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
			AND rr.stat = 'pending' AND rr.cs_id = {rt_cs_id}
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
$$;


ALTER FUNCTION public.rental_req_disj() OWNER TO admin;

--
-- TOC entry 271 (class 1255 OID 17838)
-- Name: timestamp_update_on_update_req_ut_access(); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.timestamp_update_on_update_req_ut_access() RETURNS trigger
    LANGUAGE plpython3u
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
$$;


ALTER FUNCTION public.timestamp_update_on_update_req_ut_access() OWNER TO admin;

--
-- TOC entry 274 (class 1255 OID 17840)
-- Name: timestamp_update_on_update_ticket(); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.timestamp_update_on_update_ticket() RETURNS trigger
    LANGUAGE plpython3u
    AS $$ 
	t_name = TD["table_name"]
	p_id = TD["new"]["post_id"]
	t_status_new = TD["new"]["status"]
	t_status_old = TD["old"]["status"]
	qry = f"""
			UPDATE {t_name}
			SET time_mod = NOW()::timestamp
			WHERE {t_name}.post_id = {p_id}
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
$$;


ALTER FUNCTION public.timestamp_update_on_update_ticket() OWNER TO admin;

--
-- TOC entry 272 (class 1255 OID 17811)
-- Name: ut_owner_on_accepted_req(); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.ut_owner_on_accepted_req() RETURNS trigger
    LANGUAGE plpython3u
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
$$;


ALTER FUNCTION public.ut_owner_on_accepted_req() OWNER TO admin;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 225 (class 1259 OID 17307)
-- Name: aptblock; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.aptblock (
    aptblock_id integer NOT NULL,
    addr_aptb character varying(50) NOT NULL,
    city character varying(50) NOT NULL,
    cap public.postalcode NOT NULL,
    aptblock_imgs_dir character varying(100)
);


ALTER TABLE public.aptblock OWNER TO admin;

--
-- TOC entry 222 (class 1259 OID 17278)
-- Name: aptblock_admin; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.aptblock_admin (
    ut_id integer NOT NULL,
    pdf_doc_admvalidity_fname character varying(100) NOT NULL,
    adm_telephone character varying(13) NOT NULL
);


ALTER TABLE public.aptblock_admin OWNER TO admin;

--
-- TOC entry 247 (class 1259 OID 17788)
-- Name: aptblock_bulletinboard; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.aptblock_bulletinboard (
    aptblock_id integer NOT NULL,
    bb_id integer NOT NULL,
    bb_year integer NOT NULL,
    bb_name public.bb_type
);


ALTER TABLE public.aptblock_bulletinboard OWNER TO admin;

--
-- TOC entry 246 (class 1259 OID 17787)
-- Name: aptblock_bulletinboard_bb_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.aptblock_bulletinboard_bb_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.aptblock_bulletinboard_bb_id_seq OWNER TO admin;

--
-- TOC entry 3728 (class 0 OID 0)
-- Dependencies: 246
-- Name: aptblock_bulletinboard_bb_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.aptblock_bulletinboard_bb_id_seq OWNED BY public.aptblock_bulletinboard.bb_id;


--
-- TOC entry 218 (class 1259 OID 17218)
-- Name: city; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.city (
    name character varying(50) NOT NULL,
    region character varying(50),
    provence character varying(2)
);


ALTER TABLE public.city OWNER TO admin;

--
-- TOC entry 245 (class 1259 OID 17715)
-- Name: common_spaces; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.common_spaces (
    cs_id integer NOT NULL,
    common_space_name character varying(50) NOT NULL,
    int_num integer NOT NULL,
    floor_num integer NOT NULL,
    imgs_dir character varying(100),
    aptb_id integer
);


ALTER TABLE public.common_spaces OWNER TO admin;

--
-- TOC entry 244 (class 1259 OID 17714)
-- Name: common_spaces_cs_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.common_spaces_cs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.common_spaces_cs_id_seq OWNER TO admin;

--
-- TOC entry 3731 (class 0 OID 0)
-- Dependencies: 244
-- Name: common_spaces_cs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.common_spaces_cs_id_seq OWNED BY public.common_spaces.cs_id;


--
-- TOC entry 232 (class 1259 OID 17498)
-- Name: post_thread; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.post_thread (
    thread_id integer NOT NULL,
    ut_id integer,
    post_id integer,
    time_born timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    time_lastreplay timestamp without time zone NOT NULL,
    comm_text text
);


ALTER TABLE public.post_thread OWNER TO admin;

--
-- TOC entry 254 (class 1259 OID 17934)
-- Name: post_thread_admin; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.post_thread_admin (
    thread_id integer NOT NULL,
    ut_id integer,
    post_admin_id integer,
    comm_text text,
    time_born timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    time_lastreplay timestamp without time zone NOT NULL
);


ALTER TABLE public.post_thread_admin OWNER TO admin;

--
-- TOC entry 253 (class 1259 OID 17933)
-- Name: post_thread_admin_thread_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.post_thread_admin_thread_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.post_thread_admin_thread_id_seq OWNER TO admin;

--
-- TOC entry 3735 (class 0 OID 0)
-- Dependencies: 253
-- Name: post_thread_admin_thread_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.post_thread_admin_thread_id_seq OWNED BY public.post_thread_admin.thread_id;


--
-- TOC entry 231 (class 1259 OID 17497)
-- Name: post_thread_thread_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.post_thread_thread_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.post_thread_thread_id_seq OWNER TO admin;

--
-- TOC entry 3737 (class 0 OID 0)
-- Dependencies: 231
-- Name: post_thread_thread_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.post_thread_thread_id_seq OWNED BY public.post_thread.thread_id;


--
-- TOC entry 230 (class 1259 OID 17454)
-- Name: posts; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.posts (
    post_id integer NOT NULL,
    bb_id integer,
    ut_owner_id integer,
    title character varying(100) NOT NULL,
    ttext text NOT NULL,
    time_born timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    time_mod timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    data_json json,
    off_comments boolean DEFAULT false,
    time_event timestamp without time zone
);


ALTER TABLE public.posts OWNER TO admin;

--
-- TOC entry 251 (class 1259 OID 17890)
-- Name: posts_admin; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.posts_admin (
    post_id integer NOT NULL,
    bb_id integer,
    aptblockreq_id integer,
    title character varying(100) NOT NULL,
    ttext text NOT NULL,
    time_born timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    time_mod timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    time_event timestamp without time zone,
    data_json json,
    off_comments boolean DEFAULT false
);


ALTER TABLE public.posts_admin OWNER TO admin;

--
-- TOC entry 250 (class 1259 OID 17889)
-- Name: posts_admin_post_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.posts_admin_post_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.posts_admin_post_id_seq OWNER TO admin;

--
-- TOC entry 3741 (class 0 OID 0)
-- Dependencies: 250
-- Name: posts_admin_post_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.posts_admin_post_id_seq OWNED BY public.posts_admin.post_id;


--
-- TOC entry 229 (class 1259 OID 17453)
-- Name: posts_post_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.posts_post_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.posts_post_id_seq OWNER TO admin;

--
-- TOC entry 3743 (class 0 OID 0)
-- Dependencies: 229
-- Name: posts_post_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.posts_post_id_seq OWNED BY public.posts.post_id;


--
-- TOC entry 243 (class 1259 OID 17669)
-- Name: python_log; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.python_log (
    id integer NOT NULL,
    log_message text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.python_log OWNER TO admin;

--
-- TOC entry 242 (class 1259 OID 17668)
-- Name: python_log_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.python_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.python_log_id_seq OWNER TO admin;

--
-- TOC entry 3746 (class 0 OID 0)
-- Dependencies: 242
-- Name: python_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.python_log_id_seq OWNED BY public.python_log.id;


--
-- TOC entry 217 (class 1259 OID 17213)
-- Name: region; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.region (
    name character varying(50) NOT NULL
);


ALTER TABLE public.region OWNER TO admin;

--
-- TOC entry 241 (class 1259 OID 17642)
-- Name: rental_request; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.rental_request (
    rental_req_id integer NOT NULL,
    ut_owner_id integer,
    cs_id integer,
    rental_datetime_start timestamp without time zone NOT NULL,
    rental_datetime_end timestamp without time zone NOT NULL,
    submit_time timestamp without time zone NOT NULL,
    stat public.request_status NOT NULL,
    CONSTRAINT rental_request_check CHECK ((rental_datetime_end > rental_datetime_start))
);


ALTER TABLE public.rental_request OWNER TO admin;

--
-- TOC entry 240 (class 1259 OID 17641)
-- Name: rental_request_rental_req_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.rental_request_rental_req_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.rental_request_rental_req_id_seq OWNER TO admin;

--
-- TOC entry 3749 (class 0 OID 0)
-- Dependencies: 240
-- Name: rental_request_rental_req_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.rental_request_rental_req_id_seq OWNED BY public.rental_request.rental_req_id;


--
-- TOC entry 233 (class 1259 OID 17518)
-- Name: reply_thread; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.reply_thread (
    thread_id integer NOT NULL,
    ud_id integer NOT NULL,
    msg text
);


ALTER TABLE public.reply_thread OWNER TO admin;

--
-- TOC entry 224 (class 1259 OID 17294)
-- Name: req_aptblock_create; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.req_aptblock_create (
    ut_id integer NOT NULL,
    aptblockreq_id integer NOT NULL,
    time_born timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    time_mod timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    stat public.request_status NOT NULL,
    addr_aptb character varying(50) NOT NULL,
    city character varying(50) NOT NULL,
    cap public.postalcode NOT NULL
);


ALTER TABLE public.req_aptblock_create OWNER TO admin;

--
-- TOC entry 223 (class 1259 OID 17293)
-- Name: req_aptblock_create_aptblockreq_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.req_aptblock_create_aptblockreq_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.req_aptblock_create_aptblockreq_id_seq OWNER TO admin;

--
-- TOC entry 3753 (class 0 OID 0)
-- Dependencies: 223
-- Name: req_aptblock_create_aptblockreq_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.req_aptblock_create_aptblockreq_id_seq OWNED BY public.req_aptblock_create.aptblockreq_id;


--
-- TOC entry 227 (class 1259 OID 17327)
-- Name: req_ut_access; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.req_ut_access (
    ut_id integer,
    utreq_id integer NOT NULL,
    aptblock_id integer,
    time_born timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    time_mod timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    status public.ut_request_stat DEFAULT 'pending'::public.ut_request_stat NOT NULL,
    img_dir character varying(300)
);


ALTER TABLE public.req_ut_access OWNER TO admin;

--
-- TOC entry 226 (class 1259 OID 17326)
-- Name: req_ut_access_utreq_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.req_ut_access_utreq_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.req_ut_access_utreq_id_seq OWNER TO admin;

--
-- TOC entry 3756 (class 0 OID 0)
-- Dependencies: 226
-- Name: req_ut_access_utreq_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.req_ut_access_utreq_id_seq OWNED BY public.req_ut_access.utreq_id;


--
-- TOC entry 221 (class 1259 OID 17242)
-- Name: site_personel; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.site_personel (
    ut_id integer NOT NULL
);


ALTER TABLE public.site_personel OWNER TO admin;

--
-- TOC entry 234 (class 1259 OID 17533)
-- Name: tags; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.tags (
    name_tag character varying(20) NOT NULL,
    evento boolean
);


ALTER TABLE public.tags OWNER TO admin;

--
-- TOC entry 235 (class 1259 OID 17538)
-- Name: tags_posts; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.tags_posts (
    name_tag character varying(20) NOT NULL,
    post_id integer NOT NULL
);


ALTER TABLE public.tags_posts OWNER TO admin;

--
-- TOC entry 252 (class 1259 OID 17913)
-- Name: tags_posts_admin; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.tags_posts_admin (
    name_tag character varying(20) NOT NULL,
    post_admin_id integer NOT NULL
);


ALTER TABLE public.tags_posts_admin OWNER TO admin;

--
-- TOC entry 238 (class 1259 OID 17572)
-- Name: tags_tickets; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.tags_tickets (
    name_tag character varying(20) NOT NULL,
    ticket_id integer NOT NULL
);


ALTER TABLE public.tags_tickets OWNER TO admin;

--
-- TOC entry 256 (class 1259 OID 18007)
-- Name: thread_admin_comments; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.thread_admin_comments (
    comment_id integer NOT NULL,
    thread_id integer,
    ut_id integer,
    comm_text text NOT NULL,
    time_born timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.thread_admin_comments OWNER TO admin;

--
-- TOC entry 255 (class 1259 OID 18006)
-- Name: thread_admin_comments_comment_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.thread_admin_comments_comment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.thread_admin_comments_comment_id_seq OWNER TO admin;

--
-- TOC entry 3764 (class 0 OID 0)
-- Dependencies: 255
-- Name: thread_admin_comments_comment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.thread_admin_comments_comment_id_seq OWNED BY public.thread_admin_comments.comment_id;


--
-- TOC entry 258 (class 1259 OID 18027)
-- Name: thread_comments; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.thread_comments (
    comment_id integer NOT NULL,
    thread_id integer,
    ut_id integer,
    comm_text text NOT NULL,
    time_born timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.thread_comments OWNER TO admin;

--
-- TOC entry 257 (class 1259 OID 18026)
-- Name: thread_comments_comment_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.thread_comments_comment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.thread_comments_comment_id_seq OWNER TO admin;

--
-- TOC entry 3767 (class 0 OID 0)
-- Dependencies: 257
-- Name: thread_comments_comment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.thread_comments_comment_id_seq OWNED BY public.thread_comments.comment_id;


--
-- TOC entry 249 (class 1259 OID 17843)
-- Name: ticket_responses; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.ticket_responses (
    response_id integer NOT NULL,
    ticket_id integer,
    response_text text NOT NULL,
    ut_id integer NOT NULL,
    response_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.ticket_responses OWNER TO admin;

--
-- TOC entry 248 (class 1259 OID 17842)
-- Name: ticket_responses_response_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.ticket_responses_response_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.ticket_responses_response_id_seq OWNER TO admin;

--
-- TOC entry 3770 (class 0 OID 0)
-- Dependencies: 248
-- Name: ticket_responses_response_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.ticket_responses_response_id_seq OWNED BY public.ticket_responses.response_id;


--
-- TOC entry 237 (class 1259 OID 17554)
-- Name: tickets; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.tickets (
    ticket_id integer NOT NULL,
    ud_id integer,
    aptblock_admin integer,
    title character varying(50) NOT NULL,
    comm_text text NOT NULL,
    imgs_data bytea[],
    time_born timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    time_lastreplay timestamp without time zone NOT NULL,
    img_fname character varying(100),
    status public.ticket_status NOT NULL
);


ALTER TABLE public.tickets OWNER TO admin;

--
-- TOC entry 236 (class 1259 OID 17553)
-- Name: tickets_ticket_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.tickets_ticket_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tickets_ticket_id_seq OWNER TO admin;

--
-- TOC entry 3772 (class 0 OID 0)
-- Dependencies: 236
-- Name: tickets_ticket_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.tickets_ticket_id_seq OWNED BY public.tickets.ticket_id;


--
-- TOC entry 216 (class 1259 OID 17197)
-- Name: ut_no_reg; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.ut_no_reg (
    cookie integer NOT NULL,
    CONSTRAINT ut_no_reg_cookie_check CHECK ((cookie >= 0))
);


ALTER TABLE public.ut_no_reg OWNER TO admin;

--
-- TOC entry 228 (class 1259 OID 17345)
-- Name: ut_owner; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.ut_owner (
    utreq_id integer NOT NULL,
    ut_ownership_doc_fname character varying(300) NOT NULL
);


ALTER TABLE public.ut_owner OWNER TO admin;

--
-- TOC entry 239 (class 1259 OID 17628)
-- Name: ut_personal_documents; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.ut_personal_documents (
    ut_id integer NOT NULL,
    expr_date_id date NOT NULL,
    img_id_fname character varying(100) NOT NULL,
    ut_fiscalcode public.fiscalcode NOT NULL,
    img_fiscalcode_fname character varying(100) NOT NULL
);


ALTER TABLE public.ut_personal_documents OWNER TO admin;

--
-- TOC entry 220 (class 1259 OID 17229)
-- Name: ut_registered; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.ut_registered (
    ut_id integer NOT NULL,
    nome character varying(50) NOT NULL,
    cognome character varying(50) NOT NULL,
    d_nascita date NOT NULL,
    telefono character varying(13) NOT NULL,
    address character varying(50) NOT NULL,
    citta_residenza character varying(100) NOT NULL,
    ut_email character varying(50) NOT NULL,
    passwd character varying(50) NOT NULL,
    data_iscrizione date DEFAULT CURRENT_DATE NOT NULL
);


ALTER TABLE public.ut_registered OWNER TO admin;

--
-- TOC entry 219 (class 1259 OID 17228)
-- Name: ut_registered_ut_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.ut_registered_ut_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.ut_registered_ut_id_seq OWNER TO admin;

--
-- TOC entry 3778 (class 0 OID 0)
-- Dependencies: 219
-- Name: ut_registered_ut_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.ut_registered_ut_id_seq OWNED BY public.ut_registered.ut_id;


--
-- TOC entry 3395 (class 2604 OID 17791)
-- Name: aptblock_bulletinboard bb_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.aptblock_bulletinboard ALTER COLUMN bb_id SET DEFAULT nextval('public.aptblock_bulletinboard_bb_id_seq'::regclass);


--
-- TOC entry 3394 (class 2604 OID 17718)
-- Name: common_spaces cs_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.common_spaces ALTER COLUMN cs_id SET DEFAULT nextval('public.common_spaces_cs_id_seq'::regclass);


--
-- TOC entry 3387 (class 2604 OID 17501)
-- Name: post_thread thread_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.post_thread ALTER COLUMN thread_id SET DEFAULT nextval('public.post_thread_thread_id_seq'::regclass);


--
-- TOC entry 3402 (class 2604 OID 17937)
-- Name: post_thread_admin thread_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.post_thread_admin ALTER COLUMN thread_id SET DEFAULT nextval('public.post_thread_admin_thread_id_seq'::regclass);


--
-- TOC entry 3383 (class 2604 OID 17457)
-- Name: posts post_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.posts ALTER COLUMN post_id SET DEFAULT nextval('public.posts_post_id_seq'::regclass);


--
-- TOC entry 3398 (class 2604 OID 17893)
-- Name: posts_admin post_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.posts_admin ALTER COLUMN post_id SET DEFAULT nextval('public.posts_admin_post_id_seq'::regclass);


--
-- TOC entry 3392 (class 2604 OID 17672)
-- Name: python_log id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.python_log ALTER COLUMN id SET DEFAULT nextval('public.python_log_id_seq'::regclass);


--
-- TOC entry 3391 (class 2604 OID 17645)
-- Name: rental_request rental_req_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.rental_request ALTER COLUMN rental_req_id SET DEFAULT nextval('public.rental_request_rental_req_id_seq'::regclass);


--
-- TOC entry 3376 (class 2604 OID 17297)
-- Name: req_aptblock_create aptblockreq_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.req_aptblock_create ALTER COLUMN aptblockreq_id SET DEFAULT nextval('public.req_aptblock_create_aptblockreq_id_seq'::regclass);


--
-- TOC entry 3379 (class 2604 OID 17330)
-- Name: req_ut_access utreq_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.req_ut_access ALTER COLUMN utreq_id SET DEFAULT nextval('public.req_ut_access_utreq_id_seq'::regclass);


--
-- TOC entry 3404 (class 2604 OID 18010)
-- Name: thread_admin_comments comment_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.thread_admin_comments ALTER COLUMN comment_id SET DEFAULT nextval('public.thread_admin_comments_comment_id_seq'::regclass);


--
-- TOC entry 3406 (class 2604 OID 18030)
-- Name: thread_comments comment_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.thread_comments ALTER COLUMN comment_id SET DEFAULT nextval('public.thread_comments_comment_id_seq'::regclass);


--
-- TOC entry 3396 (class 2604 OID 17846)
-- Name: ticket_responses response_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.ticket_responses ALTER COLUMN response_id SET DEFAULT nextval('public.ticket_responses_response_id_seq'::regclass);


--
-- TOC entry 3389 (class 2604 OID 17557)
-- Name: tickets ticket_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.tickets ALTER COLUMN ticket_id SET DEFAULT nextval('public.tickets_ticket_id_seq'::regclass);


--
-- TOC entry 3374 (class 2604 OID 17232)
-- Name: ut_registered ut_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.ut_registered ALTER COLUMN ut_id SET DEFAULT nextval('public.ut_registered_ut_id_seq'::regclass);


--
-- TOC entry 3681 (class 0 OID 17307)
-- Dependencies: 225
-- Data for Name: aptblock; Type: TABLE DATA; Schema: public; Owner: admin
--

INSERT INTO public.aptblock (aptblock_id, addr_aptb, city, cap, aptblock_imgs_dir) VALUES (1, 'Via Dante, 1', 'Roma', '00123', NULL);
INSERT INTO public.aptblock (aptblock_id, addr_aptb, city, cap, aptblock_imgs_dir) VALUES (2, 'Via Virgilio, 1', 'Milano', '20131', NULL);
INSERT INTO public.aptblock (aptblock_id, addr_aptb, city, cap, aptblock_imgs_dir) VALUES (3, 'Via Roma, 1', 'Milano', '00122', NULL);


--
-- TOC entry 3678 (class 0 OID 17278)
-- Dependencies: 222
-- Data for Name: aptblock_admin; Type: TABLE DATA; Schema: public; Owner: admin
--

INSERT INTO public.aptblock_admin (ut_id, pdf_doc_admvalidity_fname, adm_telephone) VALUES (1, 'directory', '+390677729958');
INSERT INTO public.aptblock_admin (ut_id, pdf_doc_admvalidity_fname, adm_telephone) VALUES (7, 'directory', '+390677485930');


--
-- TOC entry 3703 (class 0 OID 17788)
-- Dependencies: 247
-- Data for Name: aptblock_bulletinboard; Type: TABLE DATA; Schema: public; Owner: admin
--

INSERT INTO public.aptblock_bulletinboard (aptblock_id, bb_id, bb_year, bb_name) VALUES (1, 1, 2024, 'general');
INSERT INTO public.aptblock_bulletinboard (aptblock_id, bb_id, bb_year, bb_name) VALUES (1, 2, 2024, 'admin');
INSERT INTO public.aptblock_bulletinboard (aptblock_id, bb_id, bb_year, bb_name) VALUES (2, 3, 2024, 'general');
INSERT INTO public.aptblock_bulletinboard (aptblock_id, bb_id, bb_year, bb_name) VALUES (2, 4, 2024, 'admin');


--
-- TOC entry 3674 (class 0 OID 17218)
-- Dependencies: 218
-- Data for Name: city; Type: TABLE DATA; Schema: public; Owner: admin
--

INSERT INTO public.city (name, region, provence) VALUES ('Torino', 'Piemonte', 'TO');
INSERT INTO public.city (name, region, provence) VALUES ('Aosta', 'Valle d Aosta', 'AO');
INSERT INTO public.city (name, region, provence) VALUES ('Milano', 'Lombardia', 'MI');
INSERT INTO public.city (name, region, provence) VALUES ('Trento', 'Trentino Alto-Adige', 'TN');
INSERT INTO public.city (name, region, provence) VALUES ('Venezia', 'Veneto', 'VE');
INSERT INTO public.city (name, region, provence) VALUES ('Trieste', 'Friuli Venezia Giulia', 'TS');
INSERT INTO public.city (name, region, provence) VALUES ('Genova', 'Liguria', 'GE');
INSERT INTO public.city (name, region, provence) VALUES ('Bologna', 'Emilia Romagna', 'BO');
INSERT INTO public.city (name, region, provence) VALUES ('Firenze', 'Toscana', 'FI');
INSERT INTO public.city (name, region, provence) VALUES ('Perugia', 'Umbria', 'PG');
INSERT INTO public.city (name, region, provence) VALUES ('Ancona', 'Marche', 'AN');
INSERT INTO public.city (name, region, provence) VALUES ('Roma', 'Lazio', 'RM');
INSERT INTO public.city (name, region, provence) VALUES ('L Aquila', 'Abruzzo', 'AQ');
INSERT INTO public.city (name, region, provence) VALUES ('Campobasso', 'Molise', 'CB');
INSERT INTO public.city (name, region, provence) VALUES ('Napoli', 'Campania', 'NA');
INSERT INTO public.city (name, region, provence) VALUES ('Bari', 'Puglia', 'BA');
INSERT INTO public.city (name, region, provence) VALUES ('Potenza', 'Basilicata', 'PZ');
INSERT INTO public.city (name, region, provence) VALUES ('Catanzaro', 'Calabria', 'CZ');
INSERT INTO public.city (name, region, provence) VALUES ('Palermo', 'Sicilia', 'PA');
INSERT INTO public.city (name, region, provence) VALUES ('Cagliari', 'Sardegna', 'CA');


--
-- TOC entry 3701 (class 0 OID 17715)
-- Dependencies: 245
-- Data for Name: common_spaces; Type: TABLE DATA; Schema: public; Owner: admin
--

INSERT INTO public.common_spaces (cs_id, common_space_name, int_num, floor_num, imgs_dir, aptb_id) VALUES (1, 'Luogo comune 1', 1, 1, 'LTW-Condominium\tests\common_spaces_images\1.jpg', NULL);
INSERT INTO public.common_spaces (cs_id, common_space_name, int_num, floor_num, imgs_dir, aptb_id) VALUES (2, 'Luogo comune 2', 1, 1, 'LTW-Condominium\tests\common_spaces_images\2.jpg', NULL);
INSERT INTO public.common_spaces (cs_id, common_space_name, int_num, floor_num, imgs_dir, aptb_id) VALUES (3, 'Luogo comune 3', 1, 1, 'LTW-Condominium\tests\common_spaces_images\3.jpg', NULL);


--
-- TOC entry 3688 (class 0 OID 17498)
-- Dependencies: 232
-- Data for Name: post_thread; Type: TABLE DATA; Schema: public; Owner: admin
--



--
-- TOC entry 3710 (class 0 OID 17934)
-- Dependencies: 254
-- Data for Name: post_thread_admin; Type: TABLE DATA; Schema: public; Owner: admin
--

INSERT INTO public.post_thread_admin (thread_id, ut_id, post_admin_id, comm_text, time_born, time_lastreplay) VALUES (4, 1, 7, 'ddsdsa', '2024-06-02 14:14:06.653547', '2024-06-02 14:14:06.653547');
INSERT INTO public.post_thread_admin (thread_id, ut_id, post_admin_id, comm_text, time_born, time_lastreplay) VALUES (5, 1, 14, 'as', '2024-06-02 23:09:14.111079', '2024-06-02 23:09:14.111079');
INSERT INTO public.post_thread_admin (thread_id, ut_id, post_admin_id, comm_text, time_born, time_lastreplay) VALUES (6, 1, 14, 's', '2024-06-02 23:14:46.75176', '2024-06-02 23:14:46.75176');
INSERT INTO public.post_thread_admin (thread_id, ut_id, post_admin_id, comm_text, time_born, time_lastreplay) VALUES (7, 1, 14, 's', '2024-06-02 23:14:52.030171', '2024-06-02 23:14:52.030171');
INSERT INTO public.post_thread_admin (thread_id, ut_id, post_admin_id, comm_text, time_born, time_lastreplay) VALUES (8, 1, 14, 's', '2024-06-02 23:15:35.297846', '2024-06-02 23:15:35.297846');
INSERT INTO public.post_thread_admin (thread_id, ut_id, post_admin_id, comm_text, time_born, time_lastreplay) VALUES (9, 1, 14, 's', '2024-06-02 23:17:16.444371', '2024-06-02 23:17:16.444371');
INSERT INTO public.post_thread_admin (thread_id, ut_id, post_admin_id, comm_text, time_born, time_lastreplay) VALUES (10, 1, 12, 'sexo', '2024-06-02 23:19:04.819051', '2024-06-02 23:19:04.819051');


--
-- TOC entry 3686 (class 0 OID 17454)
-- Dependencies: 230
-- Data for Name: posts; Type: TABLE DATA; Schema: public; Owner: admin
--



--
-- TOC entry 3707 (class 0 OID 17890)
-- Dependencies: 251
-- Data for Name: posts_admin; Type: TABLE DATA; Schema: public; Owner: admin
--

INSERT INTO public.posts_admin (post_id, bb_id, aptblockreq_id, title, ttext, time_born, time_mod, time_event, data_json, off_comments) VALUES (7, 2, 1, 'asdasdasdasdasd', 'asdasdasdadadasdadad', '2024-06-02 11:55:25.638734', '2024-06-02 11:55:25.638734', '2024-06-30 15:55:00', NULL, false);
INSERT INTO public.posts_admin (post_id, bb_id, aptblockreq_id, title, ttext, time_born, time_mod, time_event, data_json, off_comments) VALUES (8, 2, 1, 'UDITE UDITE UDITE', 'ijkllllllllllllllllllllllllllllllllllllllllllllllllll', '2024-06-02 12:47:17.47284', '2024-06-02 12:47:17.47284', '2024-06-08 15:47:00', NULL, false);
INSERT INTO public.posts_admin (post_id, bb_id, aptblockreq_id, title, ttext, time_born, time_mod, time_event, data_json, off_comments) VALUES (9, 2, 1, 'UDITE UDITE UDITE', 'kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk', '2024-06-02 12:47:33.253175', '2024-06-02 12:47:33.253175', '2024-06-02 10:47:33', NULL, false);
INSERT INTO public.posts_admin (post_id, bb_id, aptblockreq_id, title, ttext, time_born, time_mod, time_event, data_json, off_comments) VALUES (10, 2, 1, 'UDITE UDITE UDITE', 'kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk', '2024-06-02 12:55:19.260351', '2024-06-02 12:55:19.260351', '2024-06-02 10:55:19', NULL, false);
INSERT INTO public.posts_admin (post_id, bb_id, aptblockreq_id, title, ttext, time_born, time_mod, time_event, data_json, off_comments) VALUES (11, 2, 1, 'UDITE UDITE UDITE', 'asdasdasdasdasdasdadadasdasdasdadadasdasdads', '2024-06-02 12:57:13.917219', '2024-06-02 12:57:13.917219', '2024-06-02 10:57:13', NULL, false);
INSERT INTO public.posts_admin (post_id, bb_id, aptblockreq_id, title, ttext, time_born, time_mod, time_event, data_json, off_comments) VALUES (12, 2, 1, 'UDITE UDITE UDITE', 'sdfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff', '2024-06-02 13:02:25.494903', '2024-06-02 13:02:25.494903', '2024-06-02 11:02:25', NULL, false);
INSERT INTO public.posts_admin (post_id, bb_id, aptblockreq_id, title, ttext, time_born, time_mod, time_event, data_json, off_comments) VALUES (14, 2, 1, 'UDITE UDITE UDITE', 'kjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj', '2024-06-02 13:09:03.189681', '2024-06-02 13:09:03.189681', '2024-06-02 11:09:03', NULL, false);


--
-- TOC entry 3699 (class 0 OID 17669)
-- Dependencies: 243
-- Data for Name: python_log; Type: TABLE DATA; Schema: public; Owner: admin
--

INSERT INTO public.python_log (id, log_message, created_at) VALUES (1, 'usr_id: None', '2024-05-03 13:08:32.338924');
INSERT INTO public.python_log (id, log_message, created_at) VALUES (3, 'usr_id: None', '2024-05-03 13:09:10.603229');


--
-- TOC entry 3673 (class 0 OID 17213)
-- Dependencies: 217
-- Data for Name: region; Type: TABLE DATA; Schema: public; Owner: admin
--

INSERT INTO public.region (name) VALUES ('Abruzzo');
INSERT INTO public.region (name) VALUES ('Basilicata');
INSERT INTO public.region (name) VALUES ('Calabria');
INSERT INTO public.region (name) VALUES ('Campania');
INSERT INTO public.region (name) VALUES ('Emilia Romagna');
INSERT INTO public.region (name) VALUES ('Friuli Venezia Giulia');
INSERT INTO public.region (name) VALUES ('Lazio');
INSERT INTO public.region (name) VALUES ('Liguria');
INSERT INTO public.region (name) VALUES ('Lombardia');
INSERT INTO public.region (name) VALUES ('Marche');
INSERT INTO public.region (name) VALUES ('Molise');
INSERT INTO public.region (name) VALUES ('Piemonte');
INSERT INTO public.region (name) VALUES ('Puglia');
INSERT INTO public.region (name) VALUES ('Sardegna');
INSERT INTO public.region (name) VALUES ('Sicilia');
INSERT INTO public.region (name) VALUES ('Toscana');
INSERT INTO public.region (name) VALUES ('Trentino Alto-Adige');
INSERT INTO public.region (name) VALUES ('Umbria');
INSERT INTO public.region (name) VALUES ('Valle d Aosta');
INSERT INTO public.region (name) VALUES ('Veneto');


--
-- TOC entry 3697 (class 0 OID 17642)
-- Dependencies: 241
-- Data for Name: rental_request; Type: TABLE DATA; Schema: public; Owner: admin
--

INSERT INTO public.rental_request (rental_req_id, ut_owner_id, cs_id, rental_datetime_start, rental_datetime_end, submit_time, stat) VALUES (27, 11, 3, '2024-06-05 14:00:00', '2024-06-05 16:00:00', '2024-05-30 13:43:36', 'accepted');
INSERT INTO public.rental_request (rental_req_id, ut_owner_id, cs_id, rental_datetime_start, rental_datetime_end, submit_time, stat) VALUES (28, 11, 3, '2024-06-05 17:00:00', '2024-06-05 18:00:00', '2024-05-30 13:43:36', 'accepted');
INSERT INTO public.rental_request (rental_req_id, ut_owner_id, cs_id, rental_datetime_start, rental_datetime_end, submit_time, stat) VALUES (22, 11, 1, '2024-05-28 12:02:00', '2024-05-28 13:04:00', '2024-05-27 15:42:37', 'accepted');
INSERT INTO public.rental_request (rental_req_id, ut_owner_id, cs_id, rental_datetime_start, rental_datetime_end, submit_time, stat) VALUES (23, 11, 1, '2024-05-31 12:34:00', '2024-05-31 14:54:00', '2024-05-29 14:41:44', 'refused');


--
-- TOC entry 3689 (class 0 OID 17518)
-- Dependencies: 233
-- Data for Name: reply_thread; Type: TABLE DATA; Schema: public; Owner: admin
--



--
-- TOC entry 3680 (class 0 OID 17294)
-- Dependencies: 224
-- Data for Name: req_aptblock_create; Type: TABLE DATA; Schema: public; Owner: admin
--

INSERT INTO public.req_aptblock_create (ut_id, aptblockreq_id, time_born, time_mod, stat, addr_aptb, city, cap) VALUES (1, 1, '2024-04-24 15:23:06', '2024-04-24 20:03:02', 'accepted', 'Via Dante, 1', 'Roma', '00123');
INSERT INTO public.req_aptblock_create (ut_id, aptblockreq_id, time_born, time_mod, stat, addr_aptb, city, cap) VALUES (7, 2, '2024-04-24 15:23:06', '2024-04-24 20:03:02', 'accepted', 'Via Virgilio, 1', 'Milano', '20131');
INSERT INTO public.req_aptblock_create (ut_id, aptblockreq_id, time_born, time_mod, stat, addr_aptb, city, cap) VALUES (7, 3, '2024-05-03 17:33:51.335657', '2024-05-05 22:57:06.542562', 'accepted', 'Via Roma, 1', 'Milano', '00122');


--
-- TOC entry 3683 (class 0 OID 17327)
-- Dependencies: 227
-- Data for Name: req_ut_access; Type: TABLE DATA; Schema: public; Owner: admin
--

INSERT INTO public.req_ut_access (ut_id, utreq_id, aptblock_id, time_born, time_mod, status, img_dir) VALUES (2, 1, 1, '2024-04-25 16:31:06', '2024-04-25 18:00:06', 'accepted', NULL);
INSERT INTO public.req_ut_access (ut_id, utreq_id, aptblock_id, time_born, time_mod, status, img_dir) VALUES (3, 2, 1, '2024-04-25 16:31:06', '2024-04-25 18:00:06', 'accepted', NULL);
INSERT INTO public.req_ut_access (ut_id, utreq_id, aptblock_id, time_born, time_mod, status, img_dir) VALUES (4, 3, 1, '2024-04-25 16:31:06', '2024-04-25 18:00:06', 'accepted', NULL);
INSERT INTO public.req_ut_access (ut_id, utreq_id, aptblock_id, time_born, time_mod, status, img_dir) VALUES (5, 4, 1, '2024-04-25 16:31:06', '2024-04-25 18:00:06', 'accepted', NULL);
INSERT INTO public.req_ut_access (ut_id, utreq_id, aptblock_id, time_born, time_mod, status, img_dir) VALUES (6, 5, 1, '2024-04-25 16:31:06', '2024-04-25 18:00:06', 'accepted', NULL);
INSERT INTO public.req_ut_access (ut_id, utreq_id, aptblock_id, time_born, time_mod, status, img_dir) VALUES (8, 6, 2, '2024-04-25 16:31:06', '2024-04-25 18:00:06', 'accepted', NULL);
INSERT INTO public.req_ut_access (ut_id, utreq_id, aptblock_id, time_born, time_mod, status, img_dir) VALUES (9, 7, 2, '2024-04-25 16:31:06', '2024-04-25 18:00:06', 'accepted', NULL);
INSERT INTO public.req_ut_access (ut_id, utreq_id, aptblock_id, time_born, time_mod, status, img_dir) VALUES (10, 8, 2, '2024-04-25 16:31:06', '2024-04-25 18:00:06', 'accepted', NULL);
INSERT INTO public.req_ut_access (ut_id, utreq_id, aptblock_id, time_born, time_mod, status, img_dir) VALUES (11, 9, 2, '2024-04-25 16:31:06', '2024-04-25 18:00:06', 'accepted', NULL);
INSERT INTO public.req_ut_access (ut_id, utreq_id, aptblock_id, time_born, time_mod, status, img_dir) VALUES (12, 10, 2, '2024-04-25 16:31:06', '2024-04-25 18:00:06', 'accepted', NULL);
INSERT INTO public.req_ut_access (ut_id, utreq_id, aptblock_id, time_born, time_mod, status, img_dir) VALUES (13, 11, 1, '2024-05-27 16:09:36.432194', '2024-05-29 18:46:51.536417', 'accepted', 'C:\Condominium-LTW\tests\users\tommaso@site.it\pictures\photos\fb_img_1533802567848.jpg');
INSERT INTO public.req_ut_access (ut_id, utreq_id, aptblock_id, time_born, time_mod, status, img_dir) VALUES (32, 12, 1, '2024-06-01 11:55:43.08525', '2024-06-01 11:56:28.771954', 'accepted', 'C:\Condominium-LTW\tests\users\nome5@site.it\pictures\photos\fb_img_1533802567848.jpg');


--
-- TOC entry 3677 (class 0 OID 17242)
-- Dependencies: 221
-- Data for Name: site_personel; Type: TABLE DATA; Schema: public; Owner: admin
--

INSERT INTO public.site_personel (ut_id) VALUES (13);
INSERT INTO public.site_personel (ut_id) VALUES (14);
INSERT INTO public.site_personel (ut_id) VALUES (15);


--
-- TOC entry 3690 (class 0 OID 17533)
-- Dependencies: 234
-- Data for Name: tags; Type: TABLE DATA; Schema: public; Owner: admin
--

INSERT INTO public.tags (name_tag, evento) VALUES ('Evento', true);
INSERT INTO public.tags (name_tag, evento) VALUES ('Riunione', true);
INSERT INTO public.tags (name_tag, evento) VALUES ('Avvertenze', true);
INSERT INTO public.tags (name_tag, evento) VALUES ('Danni spazi comuni', false);
INSERT INTO public.tags (name_tag, evento) VALUES ('Danno palazzina', false);
INSERT INTO public.tags (name_tag, evento) VALUES ('Lamentela', false);
INSERT INTO public.tags (name_tag, evento) VALUES ('Proposta condominio', false);


--
-- TOC entry 3691 (class 0 OID 17538)
-- Dependencies: 235
-- Data for Name: tags_posts; Type: TABLE DATA; Schema: public; Owner: admin
--



--
-- TOC entry 3708 (class 0 OID 17913)
-- Dependencies: 252
-- Data for Name: tags_posts_admin; Type: TABLE DATA; Schema: public; Owner: admin
--

INSERT INTO public.tags_posts_admin (name_tag, post_admin_id) VALUES ('Evento', 7);
INSERT INTO public.tags_posts_admin (name_tag, post_admin_id) VALUES ('Evento', 8);
INSERT INTO public.tags_posts_admin (name_tag, post_admin_id) VALUES ('Evento', 9);
INSERT INTO public.tags_posts_admin (name_tag, post_admin_id) VALUES ('Danno palazzina', 10);
INSERT INTO public.tags_posts_admin (name_tag, post_admin_id) VALUES ('Evento', 11);
INSERT INTO public.tags_posts_admin (name_tag, post_admin_id) VALUES ('Danni spazi comuni', 12);
INSERT INTO public.tags_posts_admin (name_tag, post_admin_id) VALUES ('Danno palazzina', 14);


--
-- TOC entry 3694 (class 0 OID 17572)
-- Dependencies: 238
-- Data for Name: tags_tickets; Type: TABLE DATA; Schema: public; Owner: admin
--



--
-- TOC entry 3712 (class 0 OID 18007)
-- Dependencies: 256
-- Data for Name: thread_admin_comments; Type: TABLE DATA; Schema: public; Owner: admin
--



--
-- TOC entry 3714 (class 0 OID 18027)
-- Dependencies: 258
-- Data for Name: thread_comments; Type: TABLE DATA; Schema: public; Owner: admin
--



--
-- TOC entry 3705 (class 0 OID 17843)
-- Dependencies: 249
-- Data for Name: ticket_responses; Type: TABLE DATA; Schema: public; Owner: admin
--



--
-- TOC entry 3693 (class 0 OID 17554)
-- Dependencies: 237
-- Data for Name: tickets; Type: TABLE DATA; Schema: public; Owner: admin
--

INSERT INTO public.tickets (ticket_id, ud_id, aptblock_admin, title, comm_text, imgs_data, time_born, time_lastreplay, img_fname, status) VALUES (1, 2, 1, 'inserimento 1', 'sono stancosono stancosono stancosono stancosono stancosono stancosono stancosono stancosono stancosono stancosono stancosono stanco', NULL, '2024-06-01 00:00:00', '2024-06-01 00:00:00', NULL, 'open');
INSERT INTO public.tickets (ticket_id, ud_id, aptblock_admin, title, comm_text, imgs_data, time_born, time_lastreplay, img_fname, status) VALUES (9, 11, 1, 'inserimento 1', 'ASDasdsadasdasdaASDasdsadasdasdaASDasdsadasdasdaASDasdsadasdasdaASDasdsadasdasdaASDasdsadasdasdaASDasdsadasdasdaASDasdsadasdasdaASDasdsadasdasda', NULL, '2024-06-01 15:02:43', '2024-06-01 15:02:43', 'C:\Condominium-LTW\tests\users\tommaso@site.it\pictures\photos\fb_img_1533802567848.jpg', 'open');
INSERT INTO public.tickets (ticket_id, ud_id, aptblock_admin, title, comm_text, imgs_data, time_born, time_lastreplay, img_fname, status) VALUES (10, 11, 1, 'inserimento 2', 'ASDasdsadasdasdaASDasdsadasdasdaASDasdsadasdasdaASDasdsadasdasdaASDasdsadasdasdaASDasdsadasdasdaASDasdsadasdasdaASDasdsadasdasdaASDasdsadasdasda', NULL, '2024-06-01 15:03:19', '2024-06-01 15:03:19', 'C:\Condominium-LTW\tests\users\tommaso@site.it\pictures\photos\fb_img_1533802567848.jpg', 'open');
INSERT INTO public.tickets (ticket_id, ud_id, aptblock_admin, title, comm_text, imgs_data, time_born, time_lastreplay, img_fname, status) VALUES (11, 11, 1, 'inserimento 1', 'adasdadadasdasdasdasdadadadasdadadasdasdasdasdadadadasdadadasdasdasdasdadadadasdadadasdasdasdasdadadadasdadadasdasdasdasdadadadasdadadasdasdasdasdadad', NULL, '2024-06-01 15:58:21', '2024-06-01 15:58:21', NULL, 'open');
INSERT INTO public.tickets (ticket_id, ud_id, aptblock_admin, title, comm_text, imgs_data, time_born, time_lastreplay, img_fname, status) VALUES (12, 11, 1, 'inserimento 1', ' esfdfsgsdfgfsdgsdfsdfgesfdfsgsdfgfsdgsdfsdfgesfdfsgsdfgfsdgsdfsdfgesfdfsgsdfgfsdgsdfsdfgesfdfsgsdfgfsdgsdfsdfgesfdfsgsdfgfsdgsdfsdfg', NULL, '2024-06-01 17:02:52', '2024-06-01 17:02:52', 'C:\Condominium-LTW\tests\users\tommaso@site.it\pictures\photos\fb_img_1533802567848.jpg', 'open');


--
-- TOC entry 3672 (class 0 OID 17197)
-- Dependencies: 216
-- Data for Name: ut_no_reg; Type: TABLE DATA; Schema: public; Owner: admin
--



--
-- TOC entry 3684 (class 0 OID 17345)
-- Dependencies: 228
-- Data for Name: ut_owner; Type: TABLE DATA; Schema: public; Owner: admin
--

INSERT INTO public.ut_owner (utreq_id, ut_ownership_doc_fname) VALUES (1, 'directory');
INSERT INTO public.ut_owner (utreq_id, ut_ownership_doc_fname) VALUES (2, 'directory');
INSERT INTO public.ut_owner (utreq_id, ut_ownership_doc_fname) VALUES (3, 'directory');
INSERT INTO public.ut_owner (utreq_id, ut_ownership_doc_fname) VALUES (4, 'directory');
INSERT INTO public.ut_owner (utreq_id, ut_ownership_doc_fname) VALUES (5, 'directory');
INSERT INTO public.ut_owner (utreq_id, ut_ownership_doc_fname) VALUES (6, 'directory');
INSERT INTO public.ut_owner (utreq_id, ut_ownership_doc_fname) VALUES (7, 'directory');
INSERT INTO public.ut_owner (utreq_id, ut_ownership_doc_fname) VALUES (8, 'directory');
INSERT INTO public.ut_owner (utreq_id, ut_ownership_doc_fname) VALUES (9, 'directory');
INSERT INTO public.ut_owner (utreq_id, ut_ownership_doc_fname) VALUES (10, 'directory');
INSERT INTO public.ut_owner (utreq_id, ut_ownership_doc_fname) VALUES (11, 'C:\Condominium-LTW\tests\users\tommaso@site.it\pictures\photos\fb_img_1533802567848.jpg');
INSERT INTO public.ut_owner (utreq_id, ut_ownership_doc_fname) VALUES (12, 'C:\Condominium-LTW\tests\users\nome5@site.it\pictures\photos\fb_img_1533802567848.jpg');


--
-- TOC entry 3695 (class 0 OID 17628)
-- Dependencies: 239
-- Data for Name: ut_personal_documents; Type: TABLE DATA; Schema: public; Owner: admin
--

INSERT INTO public.ut_personal_documents (ut_id, expr_date_id, img_id_fname, ut_fiscalcode, img_fiscalcode_fname) VALUES (1, '2030-01-01', 'directory', 'TRVDLA48R58H501N', 'directory');
INSERT INTO public.ut_personal_documents (ut_id, expr_date_id, img_id_fname, ut_fiscalcode, img_fiscalcode_fname) VALUES (2, '2030-01-01', 'directory', 'GLLGRS84A15H501Q', 'directory');
INSERT INTO public.ut_personal_documents (ut_id, expr_date_id, img_id_fname, ut_fiscalcode, img_fiscalcode_fname) VALUES (3, '2030-01-01', 'directory', 'NPLBRN59L27F839Y', 'directory');
INSERT INTO public.ut_personal_documents (ut_id, expr_date_id, img_id_fname, ut_fiscalcode, img_fiscalcode_fname) VALUES (4, '2030-01-01', 'directory', 'CCCDDT43D05H501P', 'directory');
INSERT INTO public.ut_personal_documents (ut_id, expr_date_id, img_id_fname, ut_fiscalcode, img_fiscalcode_fname) VALUES (5, '2030-01-01', 'directory', 'LCCLMA65A70E715A', 'directory');
INSERT INTO public.ut_personal_documents (ut_id, expr_date_id, img_id_fname, ut_fiscalcode, img_fiscalcode_fname) VALUES (6, '2030-01-01', 'directory', 'GLLQTL59D64H501F', 'directory');
INSERT INTO public.ut_personal_documents (ut_id, expr_date_id, img_id_fname, ut_fiscalcode, img_fiscalcode_fname) VALUES (7, '2030-01-01', 'directory', 'PZZDGN91L41F205F', 'directory');
INSERT INTO public.ut_personal_documents (ut_id, expr_date_id, img_id_fname, ut_fiscalcode, img_fiscalcode_fname) VALUES (8, '2030-01-01', 'directory', 'LFNSMN59H08F205D', 'directory');
INSERT INTO public.ut_personal_documents (ut_id, expr_date_id, img_id_fname, ut_fiscalcode, img_fiscalcode_fname) VALUES (9, '2030-01-01', 'directory', 'GRCBLA77H12F205I', 'directory');
INSERT INTO public.ut_personal_documents (ut_id, expr_date_id, img_id_fname, ut_fiscalcode, img_fiscalcode_fname) VALUES (10, '2030-01-01', 'directory', 'CPNDNA74A31F205H', 'directory');
INSERT INTO public.ut_personal_documents (ut_id, expr_date_id, img_id_fname, ut_fiscalcode, img_fiscalcode_fname) VALUES (11, '2030-01-01', 'directory', 'GLLGRS84A15H501Q', 'directory');
INSERT INTO public.ut_personal_documents (ut_id, expr_date_id, img_id_fname, ut_fiscalcode, img_fiscalcode_fname) VALUES (12, '2030-01-01', 'directory', 'GLLGRS84A15H501Q', 'directory');


--
-- TOC entry 3676 (class 0 OID 17229)
-- Dependencies: 220
-- Data for Name: ut_registered; Type: TABLE DATA; Schema: public; Owner: admin
--

INSERT INTO public.ut_registered (ut_id, nome, cognome, d_nascita, telefono, address, citta_residenza, ut_email, passwd, data_iscrizione) VALUES (1, 'Clara', 'Fallaci', '1986-07-09', '+390677894706', 'Via Vipacco 56', 'Roma', 'ClaraFallaci@superrito.com', 'aedai1ohPae', '2024-04-22');
INSERT INTO public.ut_registered (ut_id, nome, cognome, d_nascita, telefono, address, citta_residenza, ut_email, passwd, data_iscrizione) VALUES (2, 'Dalia', 'Trevisani', '1948-10-18', '+390627979271', 'Via Nazario Sauro 86', 'Roma', 'DaliaTrevisani@rhyta.com', 'ahw3ie1Oh', '2024-04-22');
INSERT INTO public.ut_registered (ut_id, nome, cognome, d_nascita, telefono, address, citta_residenza, ut_email, passwd, data_iscrizione) VALUES (3, 'Generoso', 'Gallo', '1984-01-15', '+390643553810', 'Piazzetta Scalette Rubiani 81', 'Roma', 'GenerosoGallo@jourrapide.com', 'ri7kaiC1ie', '2024-04-22');
INSERT INTO public.ut_registered (ut_id, nome, cognome, d_nascita, telefono, address, citta_residenza, ut_email, passwd, data_iscrizione) VALUES (4, 'Bruno', 'Napolitano', '1959-07-27', '+390819673171', 'Piazza Guglielmo Pepe 36', 'Napoli', 'BrunoNapolitano@teleworm.us', 'quie5Shuod', '2024-04-22');
INSERT INTO public.ut_registered (ut_id, nome, cognome, d_nascita, telefono, address, citta_residenza, ut_email, passwd, data_iscrizione) VALUES (5, 'Deodato', 'Cocci', '1943-04-05', '+390623656516', 'Via Solfatara 17', 'Roma', 'DeodatoCocci@rhyta.com', 'ohG1aer8hee', '2024-04-22');
INSERT INTO public.ut_registered (ut_id, nome, cognome, d_nascita, telefono, address, citta_residenza, ut_email, passwd, data_iscrizione) VALUES (6, 'Alma', 'Lucchesi', '1965-01-30', '+390621823702', 'Via Silvio Spaventa 135', 'Roma', 'AlmaLucchesi@teleworm.us', 'iaSohhie6', '2024-04-22');
INSERT INTO public.ut_registered (ut_id, nome, cognome, d_nascita, telefono, address, citta_residenza, ut_email, passwd, data_iscrizione) VALUES (7, 'Gabriella', 'Boni', '1970-11-03', '+390677494666', 'Via A.G. Alaimo 137', 'Milano', 'GabriellaBoni@dayrep.com', 'Ewu3Noo4aeRae', '2024-04-22');
INSERT INTO public.ut_registered (ut_id, nome, cognome, d_nascita, telefono, address, citta_residenza, ut_email, passwd, data_iscrizione) VALUES (8, 'Quintilia', 'Gallo', '1959-04-24', '+390229054276', 'Via Santa Teresa degli Scalzi 72', 'Milano', 'QuintiliaGallo@dayrep.com', 'deepie0C', '2024-04-22');
INSERT INTO public.ut_registered (ut_id, nome, cognome, d_nascita, telefono, address, citta_residenza, ut_email, passwd, data_iscrizione) VALUES (9, 'Degna', 'Piazza', '1991-07-01', '+39021407413', 'Via Pasquale Scura 24', 'Milano', 'DegnaPiazza@armyspy.com', 'Thoo3mee', '2024-04-22');
INSERT INTO public.ut_registered (ut_id, nome, cognome, d_nascita, telefono, address, citta_residenza, ut_email, passwd, data_iscrizione) VALUES (10, 'Simone', 'Li Fonti', '1959-06-08', '+390244196594', 'Via Varrone 121', 'Milano', 'SimoneLiFonti@rhyta.com', 'eu2dohSei', '2024-04-22');
INSERT INTO public.ut_registered (ut_id, nome, cognome, d_nascita, telefono, address, citta_residenza, ut_email, passwd, data_iscrizione) VALUES (11, 'Abele', 'Greco', '1977-06-12', '+390245188763', 'Via San Domenico 134', 'Milano', 'AbeleGreco@armyspy.com', 'shaa7Aivai', '2024-04-22');
INSERT INTO public.ut_registered (ut_id, nome, cognome, d_nascita, telefono, address, citta_residenza, ut_email, passwd, data_iscrizione) VALUES (12, 'Adone', 'Capon', '1974-01-31', '+390229076771', 'Via Moiariello 143', 'Milano', 'AdoneCapon@teleworm.us', 'diegheeMe2', '2024-04-22');
INSERT INTO public.ut_registered (ut_id, nome, cognome, d_nascita, telefono, address, citta_residenza, ut_email, passwd, data_iscrizione) VALUES (13, 'Tommaso', 'Lopedote', '2001-05-14', '+390000000000', 'Via Moiariello 143', 'Roma', 'tommaso@site.it', 'service', '2024-04-22');
INSERT INTO public.ut_registered (ut_id, nome, cognome, d_nascita, telefono, address, citta_residenza, ut_email, passwd, data_iscrizione) VALUES (14, 'Iacopo', 'Cardelli', '2000-01-01', '+390000000000', 'Via Moiariello 143', 'Roma', 'Iacopo@site.it', 'service', '2024-04-22');
INSERT INTO public.ut_registered (ut_id, nome, cognome, d_nascita, telefono, address, citta_residenza, ut_email, passwd, data_iscrizione) VALUES (15, 'Rinaldo', 'Evangelista', '2000-01-01', '+390000000000', 'Via Moiariello 143', 'Roma', 'Rinaldo@site.it', 'service', '2024-04-22');
INSERT INTO public.ut_registered (ut_id, nome, cognome, d_nascita, telefono, address, citta_residenza, ut_email, passwd, data_iscrizione) VALUES (16, 'nome1', 'cognome1', '2001-01-01', '0000000000', 'VIA DEGLI ACERI , 16', 'Roma', 'nome1@site.it', 'service', '2024-05-19');
INSERT INTO public.ut_registered (ut_id, nome, cognome, d_nascita, telefono, address, citta_residenza, ut_email, passwd, data_iscrizione) VALUES (17, 'nome2', 'cognome2', '2002-02-01', '00000000001', 'VIA DEGLI ACERI , 16', 'Roma', 'nome2@site.it', 'service', '2024-05-19');
INSERT INTO public.ut_registered (ut_id, nome, cognome, d_nascita, telefono, address, citta_residenza, ut_email, passwd, data_iscrizione) VALUES (18, 'nome3', 'cognome3', '1932-02-05', '0909203928', 'via bruh, 420', 'Palermo', 'nome3@site.it', 'service', '2024-05-19');
INSERT INTO public.ut_registered (ut_id, nome, cognome, d_nascita, telefono, address, citta_residenza, ut_email, passwd, data_iscrizione) VALUES (19, 'nome4', 'cognome4', '1999-03-23', '134984809', 'VIA DEGLI ACERI , 16', 'Napoli', 'nome4@site.it', 'IhateitHer', '2024-05-19');
INSERT INTO public.ut_registered (ut_id, nome, cognome, d_nascita, telefono, address, citta_residenza, ut_email, passwd, data_iscrizione) VALUES (20, 'nome5', 'cognome5', '1999-03-12', '2939200940', 'VIa bruh, 69', 'Catanzaro', 'nome4@site.it', 'LoveYOuRSelf', '2024-05-19');
INSERT INTO public.ut_registered (ut_id, nome, cognome, d_nascita, telefono, address, citta_residenza, ut_email, passwd, data_iscrizione) VALUES (32, 'nome5', 'nome5', '2024-06-04', '3929956796', 'VIA DEGLI ACERI , 16', 'Catanzaro', 'nome5@site.it', 'nome5@site.it', '2024-06-01');


--
-- TOC entry 3780 (class 0 OID 0)
-- Dependencies: 246
-- Name: aptblock_bulletinboard_bb_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.aptblock_bulletinboard_bb_id_seq', 1, false);


--
-- TOC entry 3781 (class 0 OID 0)
-- Dependencies: 244
-- Name: common_spaces_cs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.common_spaces_cs_id_seq', 4, true);


--
-- TOC entry 3782 (class 0 OID 0)
-- Dependencies: 253
-- Name: post_thread_admin_thread_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.post_thread_admin_thread_id_seq', 10, true);


--
-- TOC entry 3783 (class 0 OID 0)
-- Dependencies: 231
-- Name: post_thread_thread_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.post_thread_thread_id_seq', 10, true);


--
-- TOC entry 3784 (class 0 OID 0)
-- Dependencies: 250
-- Name: posts_admin_post_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.posts_admin_post_id_seq', 15, true);


--
-- TOC entry 3785 (class 0 OID 0)
-- Dependencies: 229
-- Name: posts_post_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.posts_post_id_seq', 21, true);


--
-- TOC entry 3786 (class 0 OID 0)
-- Dependencies: 242
-- Name: python_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.python_log_id_seq', 3, true);


--
-- TOC entry 3787 (class 0 OID 0)
-- Dependencies: 240
-- Name: rental_request_rental_req_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.rental_request_rental_req_id_seq', 29, true);


--
-- TOC entry 3788 (class 0 OID 0)
-- Dependencies: 223
-- Name: req_aptblock_create_aptblockreq_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.req_aptblock_create_aptblockreq_id_seq', 2, true);


--
-- TOC entry 3789 (class 0 OID 0)
-- Dependencies: 226
-- Name: req_ut_access_utreq_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.req_ut_access_utreq_id_seq', 12, true);


--
-- TOC entry 3790 (class 0 OID 0)
-- Dependencies: 255
-- Name: thread_admin_comments_comment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.thread_admin_comments_comment_id_seq', 1, false);


--
-- TOC entry 3791 (class 0 OID 0)
-- Dependencies: 257
-- Name: thread_comments_comment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.thread_comments_comment_id_seq', 1, false);


--
-- TOC entry 3792 (class 0 OID 0)
-- Dependencies: 248
-- Name: ticket_responses_response_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.ticket_responses_response_id_seq', 1, false);


--
-- TOC entry 3793 (class 0 OID 0)
-- Dependencies: 236
-- Name: tickets_ticket_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.tickets_ticket_id_seq', 12, true);


--
-- TOC entry 3794 (class 0 OID 0)
-- Dependencies: 219
-- Name: ut_registered_ut_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.ut_registered_ut_id_seq', 32, true);


--
-- TOC entry 3427 (class 2606 OID 17315)
-- Name: aptblock aptblock_addr_aptb_city_key; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.aptblock
    ADD CONSTRAINT aptblock_addr_aptb_city_key UNIQUE (addr_aptb, city);


--
-- TOC entry 3423 (class 2606 OID 17284)
-- Name: aptblock_admin aptblock_admin_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.aptblock_admin
    ADD CONSTRAINT aptblock_admin_pkey PRIMARY KEY (ut_id);


--
-- TOC entry 3464 (class 2606 OID 17795)
-- Name: aptblock_bulletinboard aptblock_bulletinboard_bb_id_aptblock_id_key; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.aptblock_bulletinboard
    ADD CONSTRAINT aptblock_bulletinboard_bb_id_aptblock_id_key UNIQUE (bb_id, aptblock_id);


--
-- TOC entry 3466 (class 2606 OID 17793)
-- Name: aptblock_bulletinboard aptblock_bulletinboard_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.aptblock_bulletinboard
    ADD CONSTRAINT aptblock_bulletinboard_pkey PRIMARY KEY (bb_id);


--
-- TOC entry 3429 (class 2606 OID 17313)
-- Name: aptblock aptblock_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.aptblock
    ADD CONSTRAINT aptblock_pkey PRIMARY KEY (aptblock_id);


--
-- TOC entry 3415 (class 2606 OID 17222)
-- Name: city city_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.city
    ADD CONSTRAINT city_pkey PRIMARY KEY (name);


--
-- TOC entry 3462 (class 2606 OID 17720)
-- Name: common_spaces common_spaces_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.common_spaces
    ADD CONSTRAINT common_spaces_pkey PRIMARY KEY (cs_id);


--
-- TOC entry 3476 (class 2606 OID 17942)
-- Name: post_thread_admin post_thread_admin_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.post_thread_admin
    ADD CONSTRAINT post_thread_admin_pkey PRIMARY KEY (thread_id);


--
-- TOC entry 3478 (class 2606 OID 17944)
-- Name: post_thread_admin post_thread_admin_thread_id_post_admin_id_key; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.post_thread_admin
    ADD CONSTRAINT post_thread_admin_thread_id_post_admin_id_key UNIQUE (thread_id, post_admin_id);


--
-- TOC entry 3442 (class 2606 OID 17505)
-- Name: post_thread post_thread_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.post_thread
    ADD CONSTRAINT post_thread_pkey PRIMARY KEY (thread_id);


--
-- TOC entry 3444 (class 2606 OID 17507)
-- Name: post_thread post_thread_thread_id_post_id_key; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.post_thread
    ADD CONSTRAINT post_thread_thread_id_post_id_key UNIQUE (thread_id, post_id);


--
-- TOC entry 3470 (class 2606 OID 17900)
-- Name: posts_admin posts_admin_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.posts_admin
    ADD CONSTRAINT posts_admin_pkey PRIMARY KEY (post_id);


--
-- TOC entry 3472 (class 2606 OID 17902)
-- Name: posts_admin posts_admin_post_id_bb_id_key; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.posts_admin
    ADD CONSTRAINT posts_admin_post_id_bb_id_key UNIQUE (post_id, bb_id);


--
-- TOC entry 3438 (class 2606 OID 17462)
-- Name: posts posts_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_pkey PRIMARY KEY (post_id);


--
-- TOC entry 3440 (class 2606 OID 17464)
-- Name: posts posts_post_id_bb_id_key; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_post_id_bb_id_key UNIQUE (post_id, bb_id);


--
-- TOC entry 3460 (class 2606 OID 17677)
-- Name: python_log python_log_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.python_log
    ADD CONSTRAINT python_log_pkey PRIMARY KEY (id);


--
-- TOC entry 3413 (class 2606 OID 17217)
-- Name: region region_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.region
    ADD CONSTRAINT region_pkey PRIMARY KEY (name);


--
-- TOC entry 3458 (class 2606 OID 17648)
-- Name: rental_request rental_request_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.rental_request
    ADD CONSTRAINT rental_request_pkey PRIMARY KEY (rental_req_id);


--
-- TOC entry 3446 (class 2606 OID 17522)
-- Name: reply_thread reply_thread_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.reply_thread
    ADD CONSTRAINT reply_thread_pkey PRIMARY KEY (thread_id, ud_id);


--
-- TOC entry 3425 (class 2606 OID 17301)
-- Name: req_aptblock_create req_aptblock_create_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.req_aptblock_create
    ADD CONSTRAINT req_aptblock_create_pkey PRIMARY KEY (aptblockreq_id);


--
-- TOC entry 3431 (class 2606 OID 17332)
-- Name: req_ut_access req_ut_access_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.req_ut_access
    ADD CONSTRAINT req_ut_access_pkey PRIMARY KEY (utreq_id);


--
-- TOC entry 3433 (class 2606 OID 17334)
-- Name: req_ut_access req_ut_access_ut_id_utreq_id_key; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.req_ut_access
    ADD CONSTRAINT req_ut_access_ut_id_utreq_id_key UNIQUE (ut_id, utreq_id);


--
-- TOC entry 3421 (class 2606 OID 17246)
-- Name: site_personel site_personel_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.site_personel
    ADD CONSTRAINT site_personel_pkey PRIMARY KEY (ut_id);


--
-- TOC entry 3448 (class 2606 OID 17863)
-- Name: tags tags_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (name_tag);


--
-- TOC entry 3474 (class 2606 OID 17917)
-- Name: tags_posts_admin tags_posts_admin_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.tags_posts_admin
    ADD CONSTRAINT tags_posts_admin_pkey PRIMARY KEY (name_tag, post_admin_id);


--
-- TOC entry 3450 (class 2606 OID 17882)
-- Name: tags_posts tags_posts_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.tags_posts
    ADD CONSTRAINT tags_posts_pkey PRIMARY KEY (name_tag, post_id);


--
-- TOC entry 3454 (class 2606 OID 17875)
-- Name: tags_tickets tags_tickets_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.tags_tickets
    ADD CONSTRAINT tags_tickets_pkey PRIMARY KEY (name_tag, ticket_id);


--
-- TOC entry 3480 (class 2606 OID 18015)
-- Name: thread_admin_comments thread_admin_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.thread_admin_comments
    ADD CONSTRAINT thread_admin_comments_pkey PRIMARY KEY (comment_id);


--
-- TOC entry 3482 (class 2606 OID 18035)
-- Name: thread_comments thread_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.thread_comments
    ADD CONSTRAINT thread_comments_pkey PRIMARY KEY (comment_id);


--
-- TOC entry 3468 (class 2606 OID 17851)
-- Name: ticket_responses ticket_responses_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.ticket_responses
    ADD CONSTRAINT ticket_responses_pkey PRIMARY KEY (response_id);


--
-- TOC entry 3452 (class 2606 OID 17561)
-- Name: tickets tickets_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_pkey PRIMARY KEY (ticket_id);


--
-- TOC entry 3411 (class 2606 OID 17202)
-- Name: ut_no_reg ut_no_reg_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.ut_no_reg
    ADD CONSTRAINT ut_no_reg_pkey PRIMARY KEY (cookie);


--
-- TOC entry 3435 (class 2606 OID 17351)
-- Name: ut_owner ut_owner_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.ut_owner
    ADD CONSTRAINT ut_owner_pkey PRIMARY KEY (utreq_id);


--
-- TOC entry 3456 (class 2606 OID 17634)
-- Name: ut_personal_documents ut_personal_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.ut_personal_documents
    ADD CONSTRAINT ut_personal_documents_pkey PRIMARY KEY (ut_id);


--
-- TOC entry 3417 (class 2606 OID 17234)
-- Name: ut_registered ut_registered_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.ut_registered
    ADD CONSTRAINT ut_registered_pkey PRIMARY KEY (ut_id);


--
-- TOC entry 3419 (class 2606 OID 17236)
-- Name: ut_registered ut_registered_ut_id_ut_email_key; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.ut_registered
    ADD CONSTRAINT ut_registered_ut_id_ut_email_key UNIQUE (ut_id, ut_email);


--
-- TOC entry 3436 (class 1259 OID 17806)
-- Name: fki_posts_id_bb_id_fkey; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX fki_posts_id_bb_id_fkey ON public.posts USING btree (bb_id);


--
-- TOC entry 3522 (class 2620 OID 17681)
-- Name: req_aptblock_create insert_aptblock_on_req_accepted; Type: TRIGGER; Schema: public; Owner: admin
--

CREATE TRIGGER insert_aptblock_on_req_accepted AFTER UPDATE ON public.req_aptblock_create FOR EACH ROW EXECUTE FUNCTION public.new_aptblock();


--
-- TOC entry 3523 (class 2620 OID 17682)
-- Name: aptblock insert_bulletinboard_on_aptblock_creation; Type: TRIGGER; Schema: public; Owner: admin
--

CREATE TRIGGER insert_bulletinboard_on_aptblock_creation AFTER INSERT ON public.aptblock FOR EACH ROW EXECUTE FUNCTION public.define_relative_bulletinboards();


--
-- TOC entry 3527 (class 2620 OID 17686)
-- Name: rental_request max_rental_req_accepted_per_user; Type: TRIGGER; Schema: public; Owner: admin
--

CREATE TRIGGER max_rental_req_accepted_per_user BEFORE INSERT OR UPDATE ON public.rental_request FOR EACH ROW EXECUTE FUNCTION public.max_rental_req_accepted_per_user();


--
-- TOC entry 3528 (class 2620 OID 17680)
-- Name: rental_request rental_req_disj_check; Type: TRIGGER; Schema: public; Owner: admin
--

CREATE TRIGGER rental_req_disj_check BEFORE INSERT ON public.rental_request FOR EACH ROW EXECUTE FUNCTION public.rental_req_disj();


--
-- TOC entry 3524 (class 2620 OID 17839)
-- Name: req_ut_access timestamp_update_on_update_req_ut_access; Type: TRIGGER; Schema: public; Owner: admin
--

CREATE TRIGGER timestamp_update_on_update_req_ut_access AFTER UPDATE ON public.req_ut_access FOR EACH ROW EXECUTE FUNCTION public.timestamp_update_on_update_req_ut_access();


--
-- TOC entry 3526 (class 2620 OID 17841)
-- Name: tickets timestamp_update_on_update_ticket; Type: TRIGGER; Schema: public; Owner: admin
--

CREATE TRIGGER timestamp_update_on_update_ticket AFTER UPDATE ON public.tickets FOR EACH ROW EXECUTE FUNCTION public.timestamp_update_on_update_ticket();


--
-- TOC entry 3525 (class 2620 OID 17812)
-- Name: req_ut_access ut_owner_on_accepted_req; Type: TRIGGER; Schema: public; Owner: admin
--

CREATE TRIGGER ut_owner_on_accepted_req AFTER UPDATE ON public.req_ut_access FOR EACH ROW EXECUTE FUNCTION public.ut_owner_on_accepted_req();


--
-- TOC entry 3486 (class 2606 OID 17285)
-- Name: aptblock_admin aptblock_admin_ut_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.aptblock_admin
    ADD CONSTRAINT aptblock_admin_ut_id_fkey FOREIGN KEY (ut_id) REFERENCES public.ut_registered(ut_id);


--
-- TOC entry 3488 (class 2606 OID 17316)
-- Name: aptblock aptblock_aptblock_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.aptblock
    ADD CONSTRAINT aptblock_aptblock_id_fkey FOREIGN KEY (aptblock_id) REFERENCES public.req_aptblock_create(aptblockreq_id);


--
-- TOC entry 3509 (class 2606 OID 17796)
-- Name: aptblock_bulletinboard aptblock_bulletinboard_aptblock_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.aptblock_bulletinboard
    ADD CONSTRAINT aptblock_bulletinboard_aptblock_id_fkey FOREIGN KEY (aptblock_id) REFERENCES public.aptblock(aptblock_id);


--
-- TOC entry 3489 (class 2606 OID 17321)
-- Name: aptblock aptblock_city_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.aptblock
    ADD CONSTRAINT aptblock_city_fkey FOREIGN KEY (city) REFERENCES public.city(name);


--
-- TOC entry 3483 (class 2606 OID 17223)
-- Name: city city_region_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.city
    ADD CONSTRAINT city_region_fkey FOREIGN KEY (region) REFERENCES public.region(name);


--
-- TOC entry 3508 (class 2606 OID 17777)
-- Name: common_spaces common_spaces_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.common_spaces
    ADD CONSTRAINT common_spaces_fkey FOREIGN KEY (aptb_id) REFERENCES public.aptblock(aptblock_id);


--
-- TOC entry 3516 (class 2606 OID 17945)
-- Name: post_thread_admin post_thread_admin_post_admin_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.post_thread_admin
    ADD CONSTRAINT post_thread_admin_post_admin_id_fkey FOREIGN KEY (post_admin_id) REFERENCES public.posts_admin(post_id);


--
-- TOC entry 3517 (class 2606 OID 17950)
-- Name: post_thread_admin post_thread_admin_ut_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.post_thread_admin
    ADD CONSTRAINT post_thread_admin_ut_id_fkey FOREIGN KEY (ut_id) REFERENCES public.ut_registered(ut_id);


--
-- TOC entry 3495 (class 2606 OID 17508)
-- Name: post_thread post_thread_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.post_thread
    ADD CONSTRAINT post_thread_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.posts(post_id);


--
-- TOC entry 3496 (class 2606 OID 17928)
-- Name: post_thread post_thread_ut_id; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.post_thread
    ADD CONSTRAINT post_thread_ut_id FOREIGN KEY (ut_id) REFERENCES public.ut_registered(ut_id) NOT VALID;


--
-- TOC entry 3512 (class 2606 OID 17908)
-- Name: posts_admin posts_admin_aptblockreq_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.posts_admin
    ADD CONSTRAINT posts_admin_aptblockreq_id_fkey FOREIGN KEY (aptblockreq_id) REFERENCES public.req_aptblock_create(aptblockreq_id);


--
-- TOC entry 3513 (class 2606 OID 17903)
-- Name: posts_admin posts_admin_bb_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.posts_admin
    ADD CONSTRAINT posts_admin_bb_id_fkey FOREIGN KEY (bb_id) REFERENCES public.aptblock_bulletinboard(bb_id);


--
-- TOC entry 3493 (class 2606 OID 17801)
-- Name: posts posts_id_bb_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_id_bb_id_fkey FOREIGN KEY (bb_id) REFERENCES public.aptblock_bulletinboard(bb_id);


--
-- TOC entry 3494 (class 2606 OID 17470)
-- Name: posts posts_ut_owner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_ut_owner_id_fkey FOREIGN KEY (ut_owner_id) REFERENCES public.ut_owner(utreq_id);


--
-- TOC entry 3506 (class 2606 OID 17731)
-- Name: rental_request rental_request_cs_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.rental_request
    ADD CONSTRAINT rental_request_cs_id_fkey FOREIGN KEY (cs_id) REFERENCES public.common_spaces(cs_id);


--
-- TOC entry 3507 (class 2606 OID 17833)
-- Name: rental_request rental_request_ut_owner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.rental_request
    ADD CONSTRAINT rental_request_ut_owner_id_fkey FOREIGN KEY (ut_owner_id) REFERENCES public.ut_owner(utreq_id) NOT VALID;


--
-- TOC entry 3497 (class 2606 OID 17523)
-- Name: reply_thread reply_thread_thread_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.reply_thread
    ADD CONSTRAINT reply_thread_thread_id_fkey FOREIGN KEY (thread_id) REFERENCES public.post_thread(thread_id);


--
-- TOC entry 3498 (class 2606 OID 17528)
-- Name: reply_thread reply_thread_ud_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.reply_thread
    ADD CONSTRAINT reply_thread_ud_id_fkey FOREIGN KEY (ud_id) REFERENCES public.ut_owner(utreq_id);


--
-- TOC entry 3487 (class 2606 OID 17302)
-- Name: req_aptblock_create req_aptblock_create_ut_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.req_aptblock_create
    ADD CONSTRAINT req_aptblock_create_ut_id_fkey FOREIGN KEY (ut_id) REFERENCES public.aptblock_admin(ut_id);


--
-- TOC entry 3490 (class 2606 OID 17340)
-- Name: req_ut_access req_ut_access_aptblock_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.req_ut_access
    ADD CONSTRAINT req_ut_access_aptblock_id_fkey FOREIGN KEY (aptblock_id) REFERENCES public.aptblock(aptblock_id);


--
-- TOC entry 3491 (class 2606 OID 17335)
-- Name: req_ut_access req_ut_access_ut_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.req_ut_access
    ADD CONSTRAINT req_ut_access_ut_id_fkey FOREIGN KEY (ut_id) REFERENCES public.ut_registered(ut_id);


--
-- TOC entry 3485 (class 2606 OID 17247)
-- Name: site_personel site_personel_ut_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.site_personel
    ADD CONSTRAINT site_personel_ut_id_fkey FOREIGN KEY (ut_id) REFERENCES public.ut_registered(ut_id);


--
-- TOC entry 3514 (class 2606 OID 17918)
-- Name: tags_posts_admin tags_posts_admin_name_tag_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.tags_posts_admin
    ADD CONSTRAINT tags_posts_admin_name_tag_fkey FOREIGN KEY (name_tag) REFERENCES public.tags(name_tag);


--
-- TOC entry 3515 (class 2606 OID 17923)
-- Name: tags_posts_admin tags_posts_admin_post_admin_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.tags_posts_admin
    ADD CONSTRAINT tags_posts_admin_post_admin_id_fkey FOREIGN KEY (post_admin_id) REFERENCES public.posts_admin(post_id);


--
-- TOC entry 3499 (class 2606 OID 17883)
-- Name: tags_posts tags_posts_name_tag_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.tags_posts
    ADD CONSTRAINT tags_posts_name_tag_fkey FOREIGN KEY (name_tag) REFERENCES public.tags(name_tag);


--
-- TOC entry 3500 (class 2606 OID 17548)
-- Name: tags_posts tags_posts_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.tags_posts
    ADD CONSTRAINT tags_posts_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.posts(post_id);


--
-- TOC entry 3503 (class 2606 OID 17876)
-- Name: tags_tickets tags_tickets_name_tag_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.tags_tickets
    ADD CONSTRAINT tags_tickets_name_tag_fkey FOREIGN KEY (name_tag) REFERENCES public.tags(name_tag);


--
-- TOC entry 3504 (class 2606 OID 17582)
-- Name: tags_tickets tags_tickets_ticket_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.tags_tickets
    ADD CONSTRAINT tags_tickets_ticket_id_fkey FOREIGN KEY (ticket_id) REFERENCES public.tickets(ticket_id);


--
-- TOC entry 3518 (class 2606 OID 18016)
-- Name: thread_admin_comments thread_admin_comments_thread_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.thread_admin_comments
    ADD CONSTRAINT thread_admin_comments_thread_id_fkey FOREIGN KEY (thread_id) REFERENCES public.post_thread_admin(thread_id) ON DELETE CASCADE;


--
-- TOC entry 3519 (class 2606 OID 18021)
-- Name: thread_admin_comments thread_admin_comments_ut_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.thread_admin_comments
    ADD CONSTRAINT thread_admin_comments_ut_id_fkey FOREIGN KEY (ut_id) REFERENCES public.ut_registered(ut_id);


--
-- TOC entry 3520 (class 2606 OID 18036)
-- Name: thread_comments thread_comments_thread_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.thread_comments
    ADD CONSTRAINT thread_comments_thread_id_fkey FOREIGN KEY (thread_id) REFERENCES public.post_thread(thread_id) ON DELETE CASCADE;


--
-- TOC entry 3521 (class 2606 OID 18041)
-- Name: thread_comments thread_comments_ut_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.thread_comments
    ADD CONSTRAINT thread_comments_ut_id_fkey FOREIGN KEY (ut_id) REFERENCES public.ut_registered(ut_id);


--
-- TOC entry 3510 (class 2606 OID 17852)
-- Name: ticket_responses ticket_responses_ticket_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.ticket_responses
    ADD CONSTRAINT ticket_responses_ticket_id_fkey FOREIGN KEY (ticket_id) REFERENCES public.tickets(ticket_id);


--
-- TOC entry 3511 (class 2606 OID 17857)
-- Name: ticket_responses ticket_responses_ut_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.ticket_responses
    ADD CONSTRAINT ticket_responses_ut_id_fkey FOREIGN KEY (ut_id) REFERENCES public.ut_registered(ut_id);


--
-- TOC entry 3501 (class 2606 OID 17562)
-- Name: tickets tickets_aptblock_admin_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_aptblock_admin_fkey FOREIGN KEY (aptblock_admin) REFERENCES public.aptblock_admin(ut_id);


--
-- TOC entry 3502 (class 2606 OID 17567)
-- Name: tickets tickets_ud_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_ud_id_fkey FOREIGN KEY (ud_id) REFERENCES public.ut_owner(utreq_id);


--
-- TOC entry 3492 (class 2606 OID 17354)
-- Name: ut_owner ut_owner_utreq_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.ut_owner
    ADD CONSTRAINT ut_owner_utreq_id_fkey FOREIGN KEY (utreq_id) REFERENCES public.req_ut_access(utreq_id);


--
-- TOC entry 3505 (class 2606 OID 17635)
-- Name: ut_personal_documents ut_personal_documents_ut_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.ut_personal_documents
    ADD CONSTRAINT ut_personal_documents_ut_id_fkey FOREIGN KEY (ut_id) REFERENCES public.ut_registered(ut_id);


--
-- TOC entry 3484 (class 2606 OID 17237)
-- Name: ut_registered ut_registered_citta_residenza_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.ut_registered
    ADD CONSTRAINT ut_registered_citta_residenza_fkey FOREIGN KEY (citta_residenza) REFERENCES public.city(name);


--
-- TOC entry 3721 (class 0 OID 0)
-- Dependencies: 3720
-- Name: DATABASE condominium_ltw; Type: ACL; Schema: -; Owner: admin
--

GRANT CONNECT ON DATABASE condominium_ltw TO readonly;
GRANT CONNECT ON DATABASE condominium_ltw TO writeonly;


--
-- TOC entry 3722 (class 0 OID 0)
-- Dependencies: 6
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: admin
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;
GRANT USAGE ON SCHEMA public TO readonly;
GRANT USAGE ON SCHEMA public TO usr_register;
GRANT USAGE ON SCHEMA public TO users_rwu;
GRANT USAGE ON SCHEMA public TO usr_service;
GRANT USAGE ON SCHEMA public TO user_condominium;


--
-- TOC entry 3723 (class 0 OID 0)
-- Dependencies: 271
-- Name: FUNCTION timestamp_update_on_update_req_ut_access(); Type: ACL; Schema: public; Owner: admin
--

GRANT ALL ON FUNCTION public.timestamp_update_on_update_req_ut_access() TO users_rwu;


--
-- TOC entry 3724 (class 0 OID 0)
-- Dependencies: 274
-- Name: FUNCTION timestamp_update_on_update_ticket(); Type: ACL; Schema: public; Owner: admin
--

GRANT ALL ON FUNCTION public.timestamp_update_on_update_ticket() TO users_rwu;


--
-- TOC entry 3725 (class 0 OID 0)
-- Dependencies: 225
-- Name: TABLE aptblock; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.aptblock TO site_personel;
GRANT SELECT,INSERT,UPDATE ON TABLE public.aptblock TO users_rwu;


--
-- TOC entry 3726 (class 0 OID 0)
-- Dependencies: 222
-- Name: TABLE aptblock_admin; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.aptblock_admin TO site_personel;
GRANT SELECT,INSERT,UPDATE ON TABLE public.aptblock_admin TO users_rwu;


--
-- TOC entry 3727 (class 0 OID 0)
-- Dependencies: 247
-- Name: TABLE aptblock_bulletinboard; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.aptblock_bulletinboard TO user_condominium;
GRANT SELECT,INSERT,UPDATE ON TABLE public.aptblock_bulletinboard TO users_rwu;


--
-- TOC entry 3729 (class 0 OID 0)
-- Dependencies: 218
-- Name: TABLE city; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.city TO site_personel;
GRANT SELECT,INSERT,UPDATE ON TABLE public.city TO users_rwu;


--
-- TOC entry 3730 (class 0 OID 0)
-- Dependencies: 245
-- Name: TABLE common_spaces; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.common_spaces TO users_rwu;


--
-- TOC entry 3732 (class 0 OID 0)
-- Dependencies: 244
-- Name: SEQUENCE common_spaces_cs_id_seq; Type: ACL; Schema: public; Owner: admin
--

GRANT ALL ON SEQUENCE public.common_spaces_cs_id_seq TO users_rwu;


--
-- TOC entry 3733 (class 0 OID 0)
-- Dependencies: 232
-- Name: TABLE post_thread; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.post_thread TO site_personel;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.post_thread TO users_rwu;


--
-- TOC entry 3734 (class 0 OID 0)
-- Dependencies: 254
-- Name: TABLE post_thread_admin; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.post_thread_admin TO users_rwu;


--
-- TOC entry 3736 (class 0 OID 0)
-- Dependencies: 253
-- Name: SEQUENCE post_thread_admin_thread_id_seq; Type: ACL; Schema: public; Owner: admin
--

GRANT ALL ON SEQUENCE public.post_thread_admin_thread_id_seq TO users_rwu;


--
-- TOC entry 3738 (class 0 OID 0)
-- Dependencies: 231
-- Name: SEQUENCE post_thread_thread_id_seq; Type: ACL; Schema: public; Owner: admin
--

GRANT ALL ON SEQUENCE public.post_thread_thread_id_seq TO users_rwu;


--
-- TOC entry 3739 (class 0 OID 0)
-- Dependencies: 230
-- Name: TABLE posts; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.posts TO site_personel;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.posts TO users_rwu;


--
-- TOC entry 3740 (class 0 OID 0)
-- Dependencies: 251
-- Name: TABLE posts_admin; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.posts_admin TO users_rwu;


--
-- TOC entry 3742 (class 0 OID 0)
-- Dependencies: 250
-- Name: SEQUENCE posts_admin_post_id_seq; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT,UPDATE ON SEQUENCE public.posts_admin_post_id_seq TO users_rwu;


--
-- TOC entry 3744 (class 0 OID 0)
-- Dependencies: 229
-- Name: SEQUENCE posts_post_id_seq; Type: ACL; Schema: public; Owner: admin
--

GRANT ALL ON SEQUENCE public.posts_post_id_seq TO users_rwu;


--
-- TOC entry 3745 (class 0 OID 0)
-- Dependencies: 243
-- Name: TABLE python_log; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.python_log TO site_personel;


--
-- TOC entry 3747 (class 0 OID 0)
-- Dependencies: 217
-- Name: TABLE region; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.region TO site_personel;
GRANT SELECT,INSERT,UPDATE ON TABLE public.region TO users_rwu;


--
-- TOC entry 3748 (class 0 OID 0)
-- Dependencies: 241
-- Name: TABLE rental_request; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.rental_request TO site_personel;
GRANT SELECT,INSERT,UPDATE ON TABLE public.rental_request TO users_rwu;


--
-- TOC entry 3750 (class 0 OID 0)
-- Dependencies: 240
-- Name: SEQUENCE rental_request_rental_req_id_seq; Type: ACL; Schema: public; Owner: admin
--

GRANT ALL ON SEQUENCE public.rental_request_rental_req_id_seq TO users_rwu;


--
-- TOC entry 3751 (class 0 OID 0)
-- Dependencies: 233
-- Name: TABLE reply_thread; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.reply_thread TO site_personel;
GRANT SELECT,INSERT,UPDATE ON TABLE public.reply_thread TO users_rwu;


--
-- TOC entry 3752 (class 0 OID 0)
-- Dependencies: 224
-- Name: TABLE req_aptblock_create; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.req_aptblock_create TO site_personel;
GRANT SELECT,INSERT,UPDATE ON TABLE public.req_aptblock_create TO users_rwu;


--
-- TOC entry 3754 (class 0 OID 0)
-- Dependencies: 223
-- Name: SEQUENCE req_aptblock_create_aptblockreq_id_seq; Type: ACL; Schema: public; Owner: admin
--

GRANT ALL ON SEQUENCE public.req_aptblock_create_aptblockreq_id_seq TO users_rwu;


--
-- TOC entry 3755 (class 0 OID 0)
-- Dependencies: 227
-- Name: TABLE req_ut_access; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.req_ut_access TO site_personel;
GRANT SELECT,INSERT,UPDATE ON TABLE public.req_ut_access TO users_rwu;


--
-- TOC entry 3757 (class 0 OID 0)
-- Dependencies: 226
-- Name: SEQUENCE req_ut_access_utreq_id_seq; Type: ACL; Schema: public; Owner: admin
--

GRANT ALL ON SEQUENCE public.req_ut_access_utreq_id_seq TO users_rwu;


--
-- TOC entry 3758 (class 0 OID 0)
-- Dependencies: 221
-- Name: TABLE site_personel; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.site_personel TO site_personel;
GRANT SELECT,INSERT,UPDATE ON TABLE public.site_personel TO users_rwu;


--
-- TOC entry 3759 (class 0 OID 0)
-- Dependencies: 234
-- Name: TABLE tags; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tags TO site_personel;
GRANT SELECT,INSERT,UPDATE ON TABLE public.tags TO users_rwu;


--
-- TOC entry 3760 (class 0 OID 0)
-- Dependencies: 235
-- Name: TABLE tags_posts; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tags_posts TO site_personel;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tags_posts TO users_rwu;


--
-- TOC entry 3761 (class 0 OID 0)
-- Dependencies: 252
-- Name: TABLE tags_posts_admin; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tags_posts_admin TO users_rwu;


--
-- TOC entry 3762 (class 0 OID 0)
-- Dependencies: 238
-- Name: TABLE tags_tickets; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tags_tickets TO site_personel;
GRANT SELECT,INSERT,UPDATE ON TABLE public.tags_tickets TO users_rwu;


--
-- TOC entry 3763 (class 0 OID 0)
-- Dependencies: 256
-- Name: TABLE thread_admin_comments; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.thread_admin_comments TO users_rwu;


--
-- TOC entry 3765 (class 0 OID 0)
-- Dependencies: 255
-- Name: SEQUENCE thread_admin_comments_comment_id_seq; Type: ACL; Schema: public; Owner: admin
--

GRANT ALL ON SEQUENCE public.thread_admin_comments_comment_id_seq TO users_rwu;


--
-- TOC entry 3766 (class 0 OID 0)
-- Dependencies: 258
-- Name: TABLE thread_comments; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.thread_comments TO users_rwu;


--
-- TOC entry 3768 (class 0 OID 0)
-- Dependencies: 257
-- Name: SEQUENCE thread_comments_comment_id_seq; Type: ACL; Schema: public; Owner: admin
--

GRANT ALL ON SEQUENCE public.thread_comments_comment_id_seq TO users_rwu;


--
-- TOC entry 3769 (class 0 OID 0)
-- Dependencies: 249
-- Name: TABLE ticket_responses; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.ticket_responses TO users_rwu;


--
-- TOC entry 3771 (class 0 OID 0)
-- Dependencies: 237
-- Name: TABLE tickets; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tickets TO site_personel;
GRANT SELECT,INSERT,UPDATE ON TABLE public.tickets TO users_rwu;


--
-- TOC entry 3773 (class 0 OID 0)
-- Dependencies: 236
-- Name: SEQUENCE tickets_ticket_id_seq; Type: ACL; Schema: public; Owner: admin
--

GRANT ALL ON SEQUENCE public.tickets_ticket_id_seq TO users_rwu;


--
-- TOC entry 3774 (class 0 OID 0)
-- Dependencies: 216
-- Name: TABLE ut_no_reg; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.ut_no_reg TO site_personel;
GRANT SELECT,INSERT,UPDATE ON TABLE public.ut_no_reg TO users_rwu;


--
-- TOC entry 3775 (class 0 OID 0)
-- Dependencies: 228
-- Name: TABLE ut_owner; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.ut_owner TO site_personel;
GRANT SELECT,INSERT,UPDATE ON TABLE public.ut_owner TO users_rwu;


--
-- TOC entry 3776 (class 0 OID 0)
-- Dependencies: 239
-- Name: TABLE ut_personal_documents; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.ut_personal_documents TO site_personel;
GRANT SELECT,INSERT,UPDATE ON TABLE public.ut_personal_documents TO users_rwu;


--
-- TOC entry 3777 (class 0 OID 0)
-- Dependencies: 220
-- Name: TABLE ut_registered; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.ut_registered TO site_personel;
GRANT SELECT,INSERT,UPDATE ON TABLE public.ut_registered TO users_rwu;
GRANT INSERT ON TABLE public.ut_registered TO writeonly;
GRANT SELECT ON TABLE public.ut_registered TO readonly;


--
-- TOC entry 3779 (class 0 OID 0)
-- Dependencies: 219
-- Name: SEQUENCE ut_registered_ut_id_seq; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT,USAGE ON SEQUENCE public.ut_registered_ut_id_seq TO site_personel;
GRANT UPDATE ON SEQUENCE public.ut_registered_ut_id_seq TO writeonly;
GRANT ALL ON SEQUENCE public.ut_registered_ut_id_seq TO users_rwu;


-- Completed on 2024-06-03 11:02:24

--
-- PostgreSQL database dump complete
--

