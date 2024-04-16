CREATE DOMAIN telNumber as varchar(12)
CHECK(
	VALUE '^\+39[0-9]{6,12}$'
);

CREATE DOMAIN postalCode as varchar(5)
CHECK(
	VALUE '^\d{5}$'
);

CREATE DOMAIN ut_reqest_stat as enum{'accepted', 'refused', 'aborted'};

CREATE DOMAIN aptBlock_request_stat as enum{'accepted', 'refused'};

CREATE TABLE IF NOT EXISTS ut_no_reg (
	cookie integer check (cookie >= 0) -- cookie maybe random, maybe always non negative
	PRIMARY KEY (cookie)
);

CREATE TABLE IF NOT EXISTS ut_registered(
	ut_id serial
	nome varchar(50) NOT NULL
	cognome varchar(50) NOT NULL
	user_name varchar(50) NOT NULL
	passwd varchar(50) NOT NULL
	data_iscrizione CURRENT_DATE
	codice_fiscale varchar(16)
	PRIMARY KEY (ut_id)
	UNIQUE (codice_fiscale, user_name, ut_id)
);

CREATE TABLE IF NOT EXISTS ut_owner(
	ut_id integer
	ut_doc_purchase blob NOT NULL
	PRIMARY KEY (ut_id)
	FOREIGN KEY (ut_id) REFERENCES ut_registered(ut_id)
);

CREATE TABLE IF NOT EXISTS aptBlock_admin(
	ut_id integer
	pdf_doc_AdmValidity blob NOT NULL
	PRIMARY KEY (ut_id)
	FOREIGN KEY (ut_id) REFERENCES ut_registered(ut_id)
);

CREATE TABLE IF NOT EXISTS req_aptBlock_create(
	ut_id integer
	aptBlockReq_id serial
	time_born timestamp
	time_mod timestamp
	status aptBlock_request_stat
	PRIMARY KEY (aptBlockReq_id)
	FOREIGN KEY ut_id REFERENCES aptBlock_admin(ut_id)
);

CREATE TABLE IF NOT EXISTS aptBlock(
	aptBlock_id integer
	address varchar(50) NOT NULL
	postalCode postalCode NOT NULL
	city varchar(50)
	PRIMARY KEY (aptBlock_id)
	PRIMARY KEY (aptBlock_id) REFERENCES req_aptBlock_create(aptBlockReq_id)
	FOREIGN KEY (city) REFERENCES city(name)
	UNIQUE (address, city)
);


CREATE TABLE IF NOT EXISTS city(
	name varchar(50)
	provence varchar(50)
	region varchar(50)
	PRIMARY KEY (name)
	FOREIGN KEY (provence) REFERENCES city(name)
	FOREIGN KEY (region) REFERENCES region(name)
);

CREATE TABLE IF NOT EXISTS region(
	name varchar(50)
	PRIMARY KEY (name)
);

CREATE TABLE IF NOT EXISTS ut_personal_documents(
	ut_id integer
	expr_date_ID date NOT NULL
	img_ID blob NOT NULL
	img_FiscalCode blob NOT NULL
	PRIMARY KEY (ut_id)
	FOREIGN KEY (ut_id) REFERENCES ut_registered(ut_id)
);

-- https://stackoverflow.com/questions/54500/storing-images-in-postgresql
CREATE TABLE IF NOT EXISTS req_ut_access(
	ut_id integer
	utReq_id serial
	aptBlock_id integer
	time_born timestamp NOT NULL
	time_mod timestamp NOT NULL
	status ut_reqest_stat NOT NULL
	PRIMARY KEY (utReq_id)
	FOREIGN KEY (ut_id) REFERENCES ut_owner(ut_id)
	FOREIGN KEY (aptBlock_id) REFERENCES aptBlock(aptBlock_id)
	UNIQUE (ut_id, utReq_id)
);





