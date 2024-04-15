CREATE DOMAIN telNumber as varchar(12)
CHECK(
	VALUE '^\+39[0-9]{6,12}$'
);

CREATE DOMAIN postalCode as varchar(5)
CHECK(
	VALUE '^\d{5}$'
);


CREATE TABLE IF NOT EXISTS ut_no_reg (
	cookie integer check (cookie >= 0)
	ut_id serial
	PRIMARY KEY (ut_id)
	UNIQUE (cookie)
);

CREATE TABLE IF NOT EXISTS ut_registrato(
	ut_id serial
	nome varchar(50) NOT NULL
	cognome varchar(50) NOT NULL
	user_name varchar(50) NOT NULL
	passwd varchar(50) NOT NULL
	data_iscrizione CURRENT_DATE
	codice_fiscale 	
	FOREIGN KEY ut_id REFERENCES TO ut_no_reg(ut_id)
);