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
		ut_r.nome, ut_r.cognome, pt.title, pt.ttext, pt.time_born, pt.time_edit, pt.off_comments
FROM aptblock aptb 
	JOIN aptblock_bulletinboard aptb_bb ON aptb.aptblock_id = aptb_bb.aptblock_id
	JOIN posts pt ON pt.bb_id = aptb_bb.bb_id
	JOIN ut_registered ut_r ON ut_r.ut_id = pt.ut_owner_id
WHERE aptb.aptblock_id = $aptblock


select * from posts
INSERT INTO posts(post_id, bb_id, ut_owner_id, title, ttext)
	VALUES (1, 1, 1, 'abracadabra', 'text');











