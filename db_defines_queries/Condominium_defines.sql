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
)

CREATE TYPE ut_reqest_stat AS ENUM ('accepted', 'refused', 'aborted');

CREATE TYPE request_status AS ENUM ('accepted', 'pending', 'refused');
-- may needs deletion and creation, ALSO THE TABLE THAT USE THIS TYPE MAY NEED TO BE DROPPED FIRST
-- DROP DOMAIN IF EXISTS request_status 

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
	data_iscrizione date NOT NULL, -- call current_date at time of insertion
	PRIMARY KEY (ut_id),
	FOREIGN KEY (citta_residenza) REFERENCES city(name),
	UNIQUE (ut_id, ut_email)
);


CREATE TABLE IF NOT EXISTS site_personel(
	ut_id integer,
	PRIMARY KEY (ut_id),
	FOREIGN KEY (ut_id) REFERENCES ut_registered(ut_id)
);

CREATE TABLE IF NOT EXISTS ut_owner(
	utReq_id integer,
	codice_fiscale fiscalCode NOT NULL,
	ut_doc_fname varchar(100) NOT NULL,
	ut_doc_purchase bytea NOT NULL,
	PRIMARY KEY (utReq_id),
	FOREIGN KEY (utReq_id) REFERENCES req_ut_access(utReq_id),
	UNIQUE(codice_fiscale)
);
-- hash algorithms: https://security.stackexchange.com/questions/211/how-to-securely-hash-passwords
-- may needs deletion and creation
-- DROP TABLE IF EXISTS ut_owner CASCADE 

CREATE TABLE IF NOT EXISTS aptBlock_admin(
	ut_id integer,
	pdf_doc_AdmValidity_fname varchar(100) NOT NULL,
	pdf_doc_AdmValidity bytea NOT NULL,
	adm_telephone telNumber NOT NULL,
	PRIMARY KEY (ut_id),
	FOREIGN KEY (ut_id) REFERENCES ut_registered(ut_id)
);

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


CREATE TABLE IF NOT EXISTS req_aptBlock_create(
	ut_id integer,
	aptBlockReq_id serial,
	time_born timestamp NOT NULL,
	time_mod timestamp,
	stat request_status NOT NULL,
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
	PRIMARY KEY (aptBlock_id),
	FOREIGN KEY (aptBlock_id) REFERENCES req_aptBlock_create(aptBlockReq_id),
	FOREIGN KEY (city) REFERENCES city(name),
	UNIQUE (addr_aptB, city)
);
-- may needs deletion and creation
-- DROP TABLE IF EXISTS aptBlock CASCADE
CREATE TABLE IF NOT EXISTS ut_personal_documents(
	ut_id integer,
	expr_date_ID date NOT NULL,
	img_ID bytea[] NOT NULL,
	img_ID_fname varchar(100)[] NOT NULL,
	img_FiscalCode bytea NOT NULL,
	PRIMARY KEY (ut_id),
	FOREIGN KEY (ut_id) REFERENCES ut_registered(ut_id)
);

-- https://stackoverflow.com/questions/54500/storing-images-in-postgresql
CREATE TABLE IF NOT EXISTS req_ut_access(
	ut_id integer,
	utReq_id serial,
	aptBlock_id integer,
	time_born timestamp NOT NULL,
	time_mod timestamp NOT NULL,
	status ut_reqest_stat NOT NULL,
	PRIMARY KEY (utReq_id),
	FOREIGN KEY (ut_id) REFERENCES ut_owner(ut_id),
	FOREIGN KEY (aptBlock_id) REFERENCES aptBlock(aptBlock_id),
	UNIQUE (ut_id, utReq_id)
);

-- [bb](0,N) <---> (0,N) [post] (0,N) <---> (0,1) [thread] (1,N) <---> (1,1) [reply]

CREATE TABLE IF NOT EXISTS aptBlock_bulletinBoard(
	aptBlock_id integer,
	bb_id serial,
	bb_name varchar(20) NOT NULL,
	bb_year date NOT NULL, -- must be 01-01-year
	--more attributes may be needed
	PRIMARY KEY (aptBlock_id, bb_id),
	FOREIGN KEY (aptBlock_id) REFERENCES aptBlock(aptBlock_id)
);


CREATE TABLE IF NOT EXISTS posts(
	post_id serial,
	bb_id integer,		-- bullettin board where the post is pinned to
	ut_owner_id integer,
	title varchar(100) NOT NULL,
	ttext text[] NOT NULL,
	time_born timestamp NOT NULL, 	-- current_time
	time_edit timestamp NOT NULL,	-- current_time at time of last modification
	data_json json,		-- to be defined: JSON module for polls and JSON module for payments
	off_comments bool DEFAULT false,
	PRIMARY KEY (post_id),
	FOREIGN KEY (bb_id) REFERENCES aptBlock_bulletinBoard(bb_id),
	FOREIGN KEY (ut_owner_id) REFERENCES ut_owner(ut_id),
	UNIQUE (post_id, bb_id)
);

-- may needs deletion and creation
-- DROP TABLE IF EXISTS post_thread CASCADE
CREATE TABLE IF NOT EXISTS post_thread(		
	thread_id serial,
	ud_id integer,
	post_id integer,	-- therad is related to a certain post
	comm_text text[],
	time_born timestamp NOT NULL, 		-- current_time
	time_lastReplay timestamp NOT NULL, -- current_time last reply
	PRIMARY KEY (thread_id),
	FOREIGN KEY (post_id) REFERENCES post(post_id),
	FOREIGN KEY (ud_id) REFERENCES ut_owner(ut_id),
	UNIQUE (thread_id, post_id)
);

-- used for post_thread and tickets
CREATE TABLE IF NOT EXISTS reply_thread(
	thread_id integer,
	ud_id integer,
	PRIMARY KEY (thread_id, ud_id),
	FOREIGN KEY (thread_id) REFERENCES post_thread(thread_id),
	FOREIGN KEY (ud_id) REFERENCES ut_owner(ut_id)
);

CREATE TABLE IF NOT EXISTS tags(
	name_tag varchar(10) PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS tags_posts(
	name_tag varchar(10),
	post_id integer,
	PRIMARY KEY (name_tag, post_id),
	FOREIGN KEY (name_tag) REFERENCES tags(name_tag),
	FOREIGN KEY (post_id) REFERENCES posts(post_id)
);

-- tickets are a special kind of threads
CREATE TABLE IF NOT EXISTS tickets(		
	ticket_id serial,
	ud_id integer,
	aptBlock_admin integer,	-- therad is related to a certain post
	title varchar(50) NOT NULL,
	comm_text text[] NOT NULL,
	imgs_data bytea[],
	imgs_fname varchar(100)[],
	time_born timestamp NOT NULL, 		-- current_time
	time_lastReplay timestamp NOT NULL, -- current_time last reply
	PRIMARY KEY (ticket_id),
	FOREIGN KEY (aptBlock_admin) REFERENCES aptBlock_admin(ut_id),
	FOREIGN KEY (ud_id) REFERENCES ut_owner(ut_id)
);
-- TRIGGER: max 5 tickets per ud_id

CREATE TABLE IF NOT EXISTS tags_tickets(
	name_tag varchar(10),
	ticket_id integer,
	PRIMARY KEY (name_tag, ticket_id),
	FOREIGN KEY (name_tag) REFERENCES tags(name_tag),
	FOREIGN KEY (ticket_id) REFERENCES tickets(ticket_id)
);
 
 CREATE TABLE IF NOT EXISTS common_spaces(
	cs_id serial,
	common_space_name varchar(50) NOT NULL,
	int_num integer NOT NULL,
	floor_num integer NOT NULL,
	PRIMARY KEY (common_space_name)
 );

 CREATE TABLE IF NOT EXISTS rental_request(
	rental_req_id serial,
	ut_id integer,
	adm_id integer,
	rental_time time NOT NULL, 
	rental_day date CHECK (rental_day > current_date) NOT NULL, 
	retal_period integer CHECK (retal_period > 0),
	submit_time timestamp NOT NULL,
	stat request_status NOT NULL,
	PRIMARY KEY (rental_req_id),
	FOREIGN KEY (ut_id) REFERENCES ut_owner(ut_id),
	FOREIGN KEY (adm_id) REFERENCES aptBlock_admin(ut_id)
 );
 -- TRIGGER: max n rental_req accepted per user
 -- TRIGGER: rental_req acceptable if within x days from current_date
 -- TRIGGER: for each user there can't be multiple rental_req in the same period/day

-------------------------------------------------------------------------------
