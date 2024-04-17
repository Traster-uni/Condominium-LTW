CREATE DOMAIN telNumber as varchar(12)
CHECK(
	 VALUE ~ '^\+39[0-9]{6,12}$'
);

CREATE DOMAIN postalCode as varchar(5)
CHECK(
	VALUE ~ '^\d{5}$'
);

CREATE TYPE ut_reqest_stat AS ENUM ('accepted', 'refused', 'aborted');

CREATE TYPE aptBlock_request_stat AS ENUM ('accepted', 'refused');

CREATE TABLE IF NOT EXISTS ut_no_reg (
	cookie integer check (cookie >= 0), -- cookie maybe random, maybe always non negative
	PRIMARY KEY (cookie)
);

CREATE TABLE IF NOT EXISTS ut_registered(
	ut_id serial,
	nome varchar(50) NOT NULL,
	cognome varchar(50) NOT NULL,
	user_name varchar(50) NOT NULL,
	passwd varchar(50) NOT NULL,
	telefono telNumber NOT NULL,
	data_iscrizione date NOT NULL, -- call current_date at time of insertion
	codice_fiscale varchar(16),
	PRIMARY KEY (ut_id),
	UNIQUE (codice_fiscale, user_name, ut_id)
);

CREATE TABLE IF NOT EXISTS ut_owner(
	ut_id integer,
	ut_doc_fname varchar(100) NOT NULL,
	ut_doc_purchase bytea NOT NULL,
	PRIMARY KEY (ut_id),
	FOREIGN KEY (ut_id) REFERENCES ut_registered(ut_id)
);

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
	provence varchar(50),
	region varchar(50),
	PRIMARY KEY (name),
	FOREIGN KEY (provence) REFERENCES city(name),
	FOREIGN KEY (region) REFERENCES region(name)
);

CREATE TABLE IF NOT EXISTS req_aptBlock_create(
	ut_id integer,
	aptBlockReq_id serial,
	time_born timestamp,
	time_mod timestamp,
	status aptBlock_request_stat,
	PRIMARY KEY (aptBlockReq_id),
	FOREIGN KEY (ut_id) REFERENCES aptBlock_admin(ut_id)
);

CREATE TABLE IF NOT EXISTS aptBlock(
	aptBlock_id integer,
	address varchar(50) NOT NULL,
	postalCode postalCode NOT NULL,
	city varchar(50),
	PRIMARY KEY (aptBlock_id),
	FOREIGN KEY (aptBlock_id) REFERENCES req_aptBlock_create(aptBlockReq_id),
	FOREIGN KEY (city) REFERENCES city(name),
	UNIQUE (address, city)
);

CREATE TABLE IF NOT EXISTS ut_personal_documents(
	ut_id integer,
	expr_date_ID date NOT NULL,
	img_ID bytea NOT NULL,
	img_ID_fname varchar(100) NOT NULL,
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
	--more attributes may be needed
	PRIMARY KEY (bb_id),
	FOREIGN KEY (aptBlock_id) REFERENCES aptBlock(aptBlock_id)
);

CREATE TABLE IF NOT EXISTS post(
	post_id serial,
	bb_id integer,	-- bullettin board where the post is pinned to
	ut_owner_id integer,
	title varchar(100) NOT NULL,
	ttext text NOT NULL,
	time_born timestamp NOT NULL, -- current_time
	time_edit timestamp NOT NULL,
	off_comments bool DEFAULT false,
	PRIMARY KEY (post_id),
	FOREIGN KEY (bb_id) REFERENCES aptBlock_bulletinBoard(bb_id),
	FOREIGN KEY (ut_owner_id) REFERENCES ut_owner(ut_id),
	UNIQUE (post_id, bb_id)
);

CREATE TABLE IF NOT EXISTS post_thread(
	thread_id serial,
	ud_id integer,
	post_id integer,	-- therad is related to a certain post
	comm_text text,
	time_born timestamp NOT NULL, -- current_time
	time_lastReplay timestamp NOT NULL, -- current_time last reply
	PRIMARY KEY (thread_id),
	FOREIGN KEY (post_id) REFERENCES post(post_id),
	FOREIGN KEY (ud_id) REFERENCES ut_owner(ut_id),
	UNIQUE (thread_id, post_id)
);

CREATE TABLE IF NOT EXISTS reply_thread(
	thread_id integer,
	ud_id integer,
	PRIMARY KEY (thread_id, ud_id),
	FOREIGN KEY (thread_id) REFERENCES post_thread(thread_id),
	FOREIGN KEY (ud_id) REFERENCES ut_owner(ut_id)
);

CREATE TABLE IF NOT EXISTS post_plugin();

CREATE TABLE IF NOT EXISTS tags();

