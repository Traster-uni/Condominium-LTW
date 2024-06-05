CREATE GROUP site_personel;
CREATE USER Tommaso WITH PASSWORD 'service' IN GROUP site_personel CREATEROLE;
CREATE USER Rinaldo WITH PASSWORD 'service' IN GROUP site_personel CREATEROLE;
CREATE USER Iacopo WITH PASSWORD 'service' IN GROUP site_personel CREATEROLE;

----------------------------------------------------------------------------------------------------------

CREATE DOMAIN telNumber as varchar(13)
CHECK(
	 VALUE ~ '^\+39[0-9]{6,12}$'
);

CREATE DOMAIN postalCode as varchar(5)
CHECK(
	VALUE ~ '^\d{5}$'
);

CREATE DOMAIN email as varchar(50)
CHECK(
	VALUE ~ '^[\w-\.]+@([\w-]+\.)+[\w-]{2,10}$'
);

CREATE DOMAIN fiscalCode as varchar(16)
CHECK(
	VALUE ~ '^[A-Za-z]{6}[0-9]{2}[A-Za-z]{1}[0-9]{2}[A-Za-z]{1}[0-9]{3}[A-Za-z]{1}$'
);

CREATE TYPE ut_request_stat AS ENUM ('pending', 'accepted', 'refused', 'aborted', 'abandoned');

CREATE TYPE ticket_status AS ENUM ('open', 'closed');

CREATE TYPE request_status AS ENUM ('accepted', 'pending', 'refused');

CREATE TYPE bb_type AS ENUM('general', 'admin');
-- may needs deletion and creation, ALSO THE TABLE THAT USE THIS TYPE MAY NEED TO BE DROPPED FIRST
-- DROP DOMAIN IF EXISTS request_status 

---------------------------------------------

CREATE TABLE IF NOT EXISTS region(
	name varchar(50),
	PRIMARY KEY (name)
);

CREATE TABLE IF NOT EXISTS city(
	name varchar(50),
	region varchar(50),
	provence varchar(2),
	PRIMARY KEY (name),
	FOREIGN KEY (region) REFERENCES region(name)
);

CREATE TABLE IF NOT EXISTS ut_no_reg ( -- DEPRECATED
	cookie integer check (cookie >= 0), -- cookie maybe random, maybe always non negative
	PRIMARY KEY (cookie)
);


CREATE TABLE IF NOT EXISTS ut_registered(
	ut_id serial,
	nome varchar(50) NOT NULL,
	cognome varchar(50) NOT NULL,
	d_nascita date NOT NULL,
	telefono varchar(13) NOT NULL,
	address varchar(50) NOT NULL,
	citta_residenza varchar(100) NOT NULL,
	ut_email varchar(50) NOT NULL,
	passwd varchar(50) NOT NULL,
	data_iscrizione date NOT NULL DEFAULT current_time,
	PRIMARY KEY (ut_id),
	FOREIGN KEY (citta_residenza) REFERENCES city(name),
	UNIQUE (ut_id, ut_email)
);


CREATE TABLE IF NOT EXISTS site_personel(
	ut_id integer,
	PRIMARY KEY (ut_id),
	FOREIGN KEY (ut_id) REFERENCES ut_registered(ut_id)
);

CREATE TABLE IF NOT EXISTS aptBlock_admin(
	ut_id integer,
	pdf_doc_AdmValidity_fname varchar(100) NOT NULL,
	adm_telephone varchar(13) NOT NULL,
	PRIMARY KEY (ut_id),
	FOREIGN KEY (ut_id) REFERENCES ut_registered(ut_id)
);

CREATE TABLE IF NOT EXISTS req_aptBlock_create(
	ut_id integer,
	aptBlockReq_id serial,
	time_born timestamp NOT NULL DEFAULT current_timestamp,
	time_mod timestamp NOT NULL DEFAULT current_timestamp, --updated on mod
	stat request_status NOT NULL,
	addr_aptB varchar(50) NOT NULL,
	city varchar(50) NOT NULL,
	cap postalcode NOT NULL,
	PRIMARY KEY (aptBlockReq_id),
	FOREIGN KEY (ut_id) REFERENCES aptBlock_admin(ut_id)
);
-- may needs deletion and creation
-- DROP TABLE IF EXISTS req_aptBlock_create CASCADE
CREATE TABLE IF NOT EXISTS aptBlock(
	aptBlock_id integer,
	addr_aptB varchar(50) NOT NULL,
	city varchar(50) NOT NULL,
	cap postalcode NOT NULL,
	aptBlock_imgs_dir varchar(100),
	PRIMARY KEY (aptBlock_id),
	FOREIGN KEY (aptBlock_id) REFERENCES req_aptBlock_create(aptBlockReq_id),
	FOREIGN KEY (city) REFERENCES city(name),
	UNIQUE (addr_aptB, city)
);
-- may needs deletion and creation
-- DROP TABLE IF EXISTS aptBlock CASCADE

CREATE TABLE IF NOT EXISTS req_ut_access(
	utReq_id serial,
	ut_id integer,
	aptBlock_id integer,
	time_born timestamp NOT NULL DEFAULT current_timestamp,
	time_mod timestamp NOT NULL DEFAULT current_timestamp, -- updated on mod
	status ut_request_stat NOT NULL,
	img_dir varchar(300),
	PRIMARY KEY (utReq_id),
	FOREIGN KEY (ut_id) REFERENCES ut_registered(ut_id),
	FOREIGN KEY (aptBlock_id) REFERENCES aptBlock(aptBlock_id),
	UNIQUE (ut_id, utReq_id)
);

CREATE TABLE IF NOT EXISTS ut_owner(
	utReq_id integer,
	ut_ownership_doc_fname varchar(300) NOT NULL,
	PRIMARY KEY (utReq_id),
	FOREIGN KEY (utReq_id) REFERENCES req_ut_access(utReq_id),
	UNIQUE(codice_fiscale)
);
-- hash algorithms: https://security.stackexchange.com/questions/211/how-to-securely-hash-passwords
-- may needs deletion and creation
-- DROP TABLE IF EXISTS ut_owner CASCADE 


CREATE TABLE IF NOT EXISTS ut_personal_documents(
	ut_id integer,
	expr_date_ID date NOT NULL,
	img_ID_fname varchar(100) NOT NULL,
	ut_FiscalCode fiscalCode NOT NULL,
	img_FiscalCode_fname varchar(100) NOT NULL,
	PRIMARY KEY (ut_id),
	FOREIGN KEY (ut_id) REFERENCES ut_registered(ut_id)
);


CREATE TABLE IF NOT EXISTS aptBlock_bulletinBoard(
	aptBlock_id integer NOT NULL,
	bb_id serial,
	bb_name bb_type NOT NULL,
	bb_year integer NOT NULL, -- must be 01-01-year
	--more attributes may be needed
	PRIMARY KEY (bb_id),
	FOREIGN KEY (aptBlock_id) REFERENCES aptBlock(aptBlock_id),
	UNIQUE (bb_id, aptBlock_id)
);


CREATE TABLE IF NOT EXISTS posts(
	post_id serial,
	bb_id integer,		-- bullettin board where the post is pinned to
	ut_owner_id integer,
	title varchar(100) NOT NULL,
	ttext text NOT NULL,
	time_born timestamp NOT NULL DEFAULT current_timestamp,
	time_mod timestamp NOT NULL DEFAULT current_timestamp,
	time_event timestamp,
	data_json json,		
	off_comments bool DEFAULT false,
	PRIMARY KEY (post_id),
	FOREIGN KEY (bb_id) REFERENCES aptBlock_bulletinBoard(bb_id),
	FOREIGN KEY (ut_owner_id) REFERENCES ut_owner(utReq_id),
	UNIQUE (post_id, bb_id)
);


CREATE TABLE IF NOT EXISTS posts_admin(
	post_id serial,
	bb_id integer,		-- bullettin board where the post is pinned to
	aptblockreq_id integer,
	title varchar(100) NOT NULL,
	ttext text NOT NULL,
	time_born timestamp NOT NULL DEFAULT current_timestamp,
	time_mod timestamp NOT NULL DEFAULT current_timestamp,
	time_event timestamp,
	data_json json,		
	off_comments bool DEFAULT false,
	PRIMARY KEY (post_id),
	FOREIGN KEY (bb_id) REFERENCES aptBlock_bulletinBoard(bb_id),
	FOREIGN KEY (aptblockreq_id) REFERENCES req_aptBlock_create(aptblockreq_id),
	UNIQUE (post_id, bb_id)
);


CREATE TABLE IF NOT EXISTS post_thread(		
	thread_id serial,
	ut_id integer,
	post_id integer,	-- therad is related to a certain post
	comm_text text,
	time_born timestamp DEFAULT current_timestamp, 		-- current_time
	time_lastReplay timestamp NOT NULL, -- current_time last reply
	PRIMARY KEY (thread_id),
	FOREIGN KEY (post_id) REFERENCES posts(post_id),
	FOREIGN KEY (ut_id) REFERENCES ut_registered(ut_id),
	UNIQUE (thread_id, post_id)
);


CREATE TABLE IF NOT EXISTS post_thread_admin(		
	thread_id serial,
	ut_id integer,
	post_admin_id integer,	-- therad is related to a certain post
	comm_text text,
	time_born timestamp DEFAULT current_timestamp, 		-- current_time
	time_lastReplay timestamp NOT NULL, -- current_time last reply
	PRIMARY KEY (thread_id),
	FOREIGN KEY (post_admin_id) REFERENCES posts_admin(post_id),
	FOREIGN KEY (ut_id) REFERENCES ut_registered(ut_id),
	UNIQUE (thread_id, post_admin_id)
);


CREATE TABLE IF NOT EXISTS reply_thread(
	thread_id integer,
	ud_id integer,
	msg text,
	PRIMARY KEY (thread_id, ud_id),
	FOREIGN KEY (thread_id) REFERENCES post_thread(thread_id),
	FOREIGN KEY (ud_id) REFERENCES ut_owner(utReq_id)
);


CREATE TABLE IF NOT EXISTS tags(
	name_tag varchar(20) PRIMARY KEY
	evento bool
);

CREATE TABLE IF NOT EXISTS tags_posts(
	name_tag varchar(20),
	post_id integer,
	PRIMARY KEY (name_tag, post_id),
	FOREIGN KEY (name_tag) REFERENCES tags(name_tag),
	FOREIGN KEY (post_id) REFERENCES posts(post_id)
);

CREATE TABLE IF NOT EXISTS tags_posts_admin(
	name_tag varchar(20),
	post_admin_id integer,
	PRIMARY KEY (name_tag, post_admin_id),
	FOREIGN KEY (name_tag) REFERENCES tags(name_tag),
	FOREIGN KEY (post_admin_id) REFERENCES posts_admin(post_id)
);

-- tickets are a special kind of threads
CREATE TABLE IF NOT EXISTS tickets(		
	ticket_id serial,
	ud_id integer,
	aptBlock_admin integer,	-- therad is related to a certain post
	title varchar(50) NOT NULL,
	status ticket_status NOT NULL,
	comm_text text NOT NULL,
	imgs_fname varchar(100),
	time_born timestamp DEFAULT current_timestamp, 		-- current_time
	time_lastReplay timestamp NOT NULL, -- current_time last reply
	PRIMARY KEY (ticket_id),
	FOREIGN KEY (aptBlock_admin) REFERENCES aptBlock_admin(ut_id),
	FOREIGN KEY (ud_id) REFERENCES ut_owner(utReq_id)
);


CREATE TABLE IF NOT EXISTS tags_tickets(
	name_tag varchar(20),
	ticket_id integer,
	PRIMARY KEY (name_tag, ticket_id),
	FOREIGN KEY (name_tag) REFERENCES tags(name_tag),
	FOREIGN KEY (ticket_id) REFERENCES tickets(ticket_id)
);
 

CREATE TABLE IF NOT EXISTS common_spaces(
	cs_id serial,
	aptb_id integer,
	common_space_name varchar(50) NOT NULL,
	int_num integer NOT NULL,
	floor_num integer NOT NULL,
	imgs_dir varchar(100),  
	PRIMARY KEY (cs_id),
	FOREIGN KEY  (aptb_id) REFERENCES TO aptBlock(aptBlock_id)
 );


CREATE TABLE IF NOT EXISTS rental_request(
	rental_req_id serial,
	ut_owner_id integer,
	cs_id integer,
	rental_datetime_start timestamp NOT NULL, 
	rental_datetime_end timestamp NOT NULL CHECK(rental_datetime_end > rental_datetime_start),
	submit_time timestamp NOT NULL,
	stat request_status NOT NULL,
	PRIMARY KEY (rental_req_id),
	FOREIGN KEY (ut_owner_id) REFERENCES ut_owner(utReq_id),
	FOREIGN KEY (cs_id) REFERENCES common_spaces(cs_id)
);


CREATE TABLE thread_comments (
	comment_id SERIAL,
	thread_id integer,
	ut_id integer,
	comm_text TEXT NOT NULL,
	time_born TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY (comment_id),
	FOREIGN KEY (thread_id) REFERENCES post_thread(thread_id) ON DELETE CASCADE,
	FOREIGN KEY (ut_id) REFERENCES ut_registered(ut_id)
);


CREATE TABLE thread_admin_comments (
    comment_id SERIAL,
	thread_id integer,
	ut_id integer,
    comm_text TEXT NOT NULL,
    time_born TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (comment_id),
    FOREIGN KEY (thread_id) REFERENCES post_thread_admin(thread_id) ON DELETE CASCADE,
	FOREIGN KEY (ut_id) REFERENCES ut_registered(ut_id)
);


CREATE TABLE ticket_responses (
    response_id SERIAL PRIMARY KEY,
    ticket_id INTEGER REFERENCES tickets(ticket_id),
    response_text TEXT NOT NULL,
    ut_id INTEGER REFERENCES ut_registered(ut_id) NOT NULL, -- "user" o "admin"
    response_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
	