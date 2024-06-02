-- qry post reltivi a tutti gli utenti relativamente ad un certo aptblock
SELECT * 
FROM aptblock aptb JOIN aptblock_bulletinboard aptb_bb ON aptb.aptblock_id = aptb_bb.aptblock_id
    JOIN posts ON posts.bb_id = aptb_bb.bb_id
WHERE 1 = apt.aptblock_id

-- qry post relativi al admin relativamente ad un certo aptblock post id, nome, cognome, 
SELECT sub2.aptblock_id, sub2.admin_id, sub2.bb_id, sub2.bb_name, sub2.bb_year, pt.post_id
FROM(
    SELECT sub1.aptblock_id, sub1.admin_id, aptb_bb.bb_id, aptb_bb.bb_name, aptb_bb.bb_year
    FROM(
        SELECT aptb.aptblock_id, aptb_adm.ut_id as admin_id 
        FROM aptblock aptb JOIN req_aptblock_create r_aptb_c ON aptb.aptblock_id = r_aptb_c.aptblockreq_id
            JOIN aptblock_admin aptb_adm ON r_aptb_c.ut_id = aptb_adm.ut_id
        WHERE r_aptb_c.stat = 'accepted'
        ) as sub1
        JOIN aptblock_bulletinboard aptb_bb ON aptb_bb.aptblock_id = sub1.aptblock_id
    ) as sub2
    JOIN posts pt ON pt.bb_id = sub2.bb_id
WHERE sub2.admin_id = pt.ut_owner_id

select * from aptblock_bulletinboard

INSERT INTO posts(aptblock_id, bb_id, bb_name, bb_year)
       VALUES (3, 1, general)
/*
Tutti i post di un determinato condominio

post id
user id
nome
cognome
title
ttext
time_born
time_mod
off comments
parametro che mi dice se è post utente o post admin
*/


SELECT aptb.aptblock_id, aptb_bb.bb_id, aptb_bb.bb_name, pt.post_id, pt.ut_owner_id ut_id, 
		ut_r.nome, ut_r.cognome, pt.title, pt.ttext, pt.time_born, pt.time_mod, pt.off_comments
FROM aptblock aptb 
	JOIN aptblock_bulletinboard aptb_bb ON aptb.aptblock_id = aptb_bb.aptblock_id
	JOIN posts pt ON pt.bb_id = aptb_bb.bb_id
	JOIN ut_registered ut_r ON ut_r.ut_id = pt.ut_owner_id
WHERE aptb.aptblock_id = $aptblock


select * from posts
INSERT INTO posts(post_id, bb_id, ut_owner_id, title, ttext)
	VALUES (1, 1, 1, 'abracadabra', 'text');


ALTER TABLE posts
	RENAME COLUMN time_edit TO time_mod


SELECT ut_id, ut_email, passwd
FROM ut_registered ut_r
WHERE ut_r.ut_email = 'tommaso@site.it' AND ut_r.passwd = 'service'


SELECT aptb.aptblock_id as id, addr_aptb, city, cap, time_born as data_richiesta, time_mod as data_verifica
FROM ut_registered ut_r 
	JOIN req_ut_access rutc ON ut_r.ut_id = rutc.ut_id
	JOIN aptblock aptb ON rutc.aptblock_id = aptb.aptblock_id
WHERE ut_r.ut_id = $utid
ORDER BY (time_mod) ASC

ALTER TABLE req_ut_access
	ALTER COLUMN status SET DEFAULT 'pending'

ALTER TABLE tags
	ALTER COLUMN name_tag TYPE varchar(20)
	ADD COLUMN evento bool

ALTER TABLE tags_posts
	ALTER COLUMN name_tag TYPE varchar(20)
	
ALTER TABLE tags_tickets
	ALTER COLUMN name_tag TYPE varchar(20)

select * from tags

SELECT EXISTS(
			SELECT rr.rental_req_id 
			FROM rental_request rr
			WHERE (
			date_part('day', timestamp '2024-06-05 17:00:00') BETWEEN date_part('day', rr.rental_datetime_start) AND date_part('day', rr.rental_datetime_end)
			OR 
			date_part('day', timestamp '2024-06-05 18:00:00') BETWEEN date_part('day', rr.rental_datetime_start) AND date_part('day', rr.rental_datetime_end)
			)
			AND rr.stat = 'accepted'
		) as day_disj

SELECT EXISTS(
	SELECT rr.rental_req_id, rr.ut_owner_id, rr.cs_id
	FROM rental_request rr
	WHERE 
	date_part('day', timestamp '2024-06-05 17:00:00') = date_part('day', rr.rental_datetime_start) AND 
	date_part('day', timestamp '2024-06-05 18:00:00') = date_part('day', rr.rental_datetime_end) 
	AND(
	date_part('hour', timestamp '2024-06-05 17:00:00') BETWEEN date_part('hour', rr.rental_datetime_start) AND date_part('hour', rr.rental_datetime_end)	
	OR
	date_part('hour', timestamp '2024-06-05 18:00:00') BETWEEN date_part('hour', rr.rental_datetime_start) AND date_part('hour', rr.rental_datetime_end)
	)
	AND rr.stat = 'accepted'
) as hour_disj

INSERT INTO rental_request(ut_owner_id, cs_id, submit_time, stat, rental_datetime_start, rental_datetime_end)
            VALUES (11,2,'2024-06-05 17:30:00','accepted','2024-06-05 21:00:00','2024-06-05 16:00:00');

INSERT INTO rental_request(ut_owner_id, cs_id, submit_time, stat, rental_datetime_start, rental_datetime_end)
            VALUES (11,3,'2024-05-30 13:43:36','accepted','2024-06-05 17:00:00','2024-06-05 18:00:00');
'2024-06-05 14:00:00','2024-06-05 16:00:00' accettata
'2024-06-05 17:00:00','2024-06-05 18:00:00' genera errore

SELECT aptb.aptblock_id, aptb_bb.bb_id, aptb_bb.bb_name, pt.post_id, pt.ut_owner_id ut_id, 
            ut_r.nome, ut_r.cognome, pt.title, pt.ttext, pt.time_born, pt.time_mod, pt.off_comments,
            tp.name_tag, t.evento
            FROM aptblock aptb 
            JOIN aptblock_bulletinboard aptb_bb ON aptb.aptblock_id = aptb_bb.aptblock_id
            JOIN posts pt ON pt.bb_id = aptb_bb.bb_id
            LEFT JOIN ut_registered ut_r ON ut_r.ut_id = pt.ut_owner_id
            LEFT JOIN tags_posts tp ON tp.post_id = pt.post_id
            LEFT JOIN tags t ON tp.name_tag = tp.name_tag
            -- WHERE aptb.aptblock_id = $aptblock_id
            ORDER BY time_born DESC
SELECT *
FROM(
	select *, tp.name_tag
	from posts pt 
	left JOIN tags_posts tp ON tp.post_id = pt.post_id
	) as sub1
    sub1 JOIN tags t ON sub1.name_tag = tp.name_tag


SELECT last_value+1 AS new_id FROM posts_post_id_seq
SELECT setval('posts_post_id_seq', 1)

select * from ut_registered

SELECT ut_o.utreq_id as ut_owner_id
                      FROM ut_registered ut_r 
                      JOIN req_ut_access req_a ON ut_r.ut_id = req_a.ut_id
                      JOIN ut_owner ut_o ON ut_o.utreq_id = req_a.utreq_id
                      WHERE ut_r.ut_id = 13;

SELECT EXISTS(SELECT adm.ut_id
		FROM aptblock_admin adm 
			JOIN ut_registered ut_r ON adm.ut_id = ut_r.ut_id
		WHERE ut_r.ut_id = 13)

select * from tickets

SELECT req_aptblock_create.ut_id AS admin_id 
                    FROM req_ut_access 
                    JOIN req_aptblock_create ON req_ut_access.aptblock_id = req_aptblock_create.aptblockreq_id 
                    WHERE req_ut_access.status = 'accepted' 
                    AND req_ut_access.ut_id = 13

SELECT t.*, tr.response_text, tr.response_time, ur.ut_id, ur.nome, ur.cognome,
	CASE 
		WHEN (SELECT COUNT(*) FROM aptblock_admin aa WHERE aa.ut_id = ur.ut_id) > 0 THEN 'admin'
		ELSE 'user'
	END as role
FROM tickets t
LEFT JOIN ticket_responses tr ON t.ticket_id = tr.ticket_id
LEFT JOIN ut_registered ur ON tr.ut_id = ur.ut_id
WHERE aptblock_admin = 1
ORDER BY t.time_lastreplay DESC

select * from tags natural join tags_posts natural join posts

SELECT utreq_id as ut_owner_id
FROM req_ut_access NATURAL JOIN ut_owner NATURAL JOIN ut_registered
WHERE ut_registered.ut_id = 1

SELECT rac.aptblockreq_id, ut_registered.*
FROM ut_registered NATURAL JOIN req_aptblock_create rac NATURAL JOIN aptblock_admin
WHERE ut_registered.ut_id = $user_id







-- new get_posts
SELECT 
	allposts.aptblock_id, 
	allposts.post_id,
	allposts.bb_name,
	allposts.nome, 
    allposts.cognome,
	allposts.title, 
	allposts.ttext, 
	allposts.time_born, 
	allposts.time_mod, 
	allposts.off_comments,
	allposts.name_tag
FROM (
	 SELECT DISTINCT
			aptb.aptblock_id,
			pt.post_id,
			aptb_bb.bb_name,
			ut_r.nome, 
            ut_r.cognome,
			pt.title, 
			pt.ttext, 
			pt.time_born, 
			pt.time_mod, 
			pt.off_comments,
			tp.name_tag
		FROM aptblock aptb 
		JOIN aptblock_bulletinboard aptb_bb ON aptb.aptblock_id = aptb_bb.aptblock_id
		JOIN posts pt ON pt.bb_id = aptb_bb.bb_id
		JOIN ut_owner ut_o ON ut_o.utreq_id = pt.ut_owner_id
		JOIN req_ut_access req_id ON req_id.utreq_id = ut_o.utreq_id
		JOIN ut_registered ut_r ON req_id.ut_id = ut_r.ut_id
		LEFT JOIN tags_posts tp ON tp.post_id = pt.post_id
		LEFT JOIN tags t ON tp.name_tag = tp.name_tag
	UNION
	SELECT DISTINCT
			aptb.aptblock_id,
			--aptb_adm.ut_id as admin_id,
			pt_a.post_id,
			aptb_bb.bb_name,
			ut_r.nome, 
            ut_r.cognome,
			pt_a.title, 
			pt_a.ttext, 
			pt_a.time_born, 
			pt_a.time_mod, 
			pt_a.off_comments,
			tp.name_tag
		FROM aptblock aptb 
		JOIN aptblock_bulletinboard aptb_bb ON aptb.aptblock_id = aptb_bb.aptblock_id
		JOIN posts_admin pt_a ON pt_a.bb_id = aptb_bb.bb_id
		JOIN req_aptblock_create r_aptb_c ON aptb.aptblock_id = r_aptb_c.aptblockreq_id
		JOIN aptblock_admin aptb_adm ON r_aptb_c.ut_id = aptb_adm.ut_id
		JOIN ut_registered ut_r ON r_aptb_c.ut_id = ut_r.ut_id
		JOIN tags_posts tp ON tp.post_id = pt_a.post_id
		LEFT JOIN tags t ON tp.name_tag = tp.name_tag
		WHERE r_aptb_c.stat = 'accepted'
	) as allposts
	WHERE allposts.aptblock_id = 1
ORDER BY (allposts.time_born)

-- old query get_posts
SELECT DISTINCT 
            aptb.aptblock_id, aptb_bb.bb_id, aptb_bb.bb_name, pt.post_id, ut_r.ut_id, 
            ut_r.nome, ut_r.cognome, pt.title, pt.ttext, pt.time_born, pt.time_mod, pt.time_event, pt.off_comments,
            tp.name_tag
            FROM aptblock aptb 
            JOIN aptblock_bulletinboard aptb_bb ON aptb.aptblock_id = aptb_bb.aptblock_id
            JOIN posts pt ON pt.bb_id = aptb_bb.bb_id
            JOIN ut_owner ut_o ON ut_o.utreq_id = pt.ut_owner_id
            JOIN req_ut_access req_id ON req_id.utreq_id = ut_o.utreq_id
            JOIN ut_registered ut_r ON req_id.ut_id = ut_r.ut_id
            LEFT JOIN tags_posts tp ON tp.post_id = pt.post_id
            LEFT JOIN tags t ON tp.name_tag = tp.name_tag
            WHERE aptb.aptblock_id = $aptblock_id
            ORDER BY time_born DESC
	

select * from posts_admin
INSERT INTO posts_admin(bb_id, aptblockreq_id, title, ttext, time_born, time_event)
	VALUES (2, 1, 'prova1 post_admin', 'testo1 post_admin', NOW(), '2024-06-01 18:30:00');
INSERT INTO tags_posts(name_tag, post_id)
	VALUES ('Evento', 1);

