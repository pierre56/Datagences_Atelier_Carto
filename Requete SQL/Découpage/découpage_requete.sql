/*
----------------------------------------------------------------------------------
-- Découpage  Requête Population légale 					--
----------------------------------------------------------------------------------
*/

WITH donnees_pop AS
	(
	WITH table_correspondance_geo AS -- correspondance entre le code commune historique et le code commune actuel
		(
		WITH table_passage AS
			(
			SELECT
			  id_commune AS id_commune_hist,
			  code_com AS code_com_hist,
			CASE
			  WHEN id_commune_pole IS NULL THEN id_commune --
			  WHEN id_commune_pole IS NOT NULL THEN id_commune_pole -- regroupement de commune
			END AS id_commune
			FROM
			  dimensions.communes
			)

		SELECT
		  table_passage.id_commune_hist,
		  table_passage.code_com_hist, -- code commune historique
		  dimensions.communes.code_com AS code_com -- code commune actuel
		FROM
		  dimensions.communes,
		  table_passage
		WHERE
		  communes.id_commune = table_passage.id_commune
		)

	,millesime AS -- selection du dernier millésime Insee
		(
		WITH temp2 AS
			(
			WITH temp AS
				(
					select
						numero_annee,
						id_annee
						from dimensions.annees
						where dimensions.annees.est_une_borne = 'Oui'
				)
			select
			numero_annee as numero_annee,
			row_number() over (order by numero_annee desc) as rn
			from temp
			)
		select
		numero_annee
		from temp2
		where rn=1
		order by numero_annee
		)


	SELECT
	  table_correspondance_geo.code_com AS code_com,
	  max(annees.numero_annee) AS annee,
	  sum(populations.population) AS population
	FROM
	  dimensions.annees,
	  dimensions.communes,
	  faits.populations,
	  table_correspondance_geo
	WHERE
	  annees.id_annee = populations.id_annee
	AND
	  populations.id_commune = communes.id_commune
	AND
	  communes.id_commune = table_correspondance_geo.id_commune_hist
	AND
	  communes.code_reg = '53'
	AND
	  annees.numero_annee =(select numero_annee from millesime)
	GROUP BY
	  table_correspondance_geo.code_com
	)
SELECT
 communes_pt.code_com,
 communes_pt.lib_com,
 donnees_pop.annee,
 donnees_pop.population,
 communes_pt.the_geom
FROM
 geographies.communes_pt,
 donnees_pop
WHERE
 communes_pt.code_com =  donnees_pop.code_com
AND
  communes_pt.code_reg='53'
  ;



_________
# Découpage requete

WITH table_passage AS
	(
	SELECT
		id_commune AS id_commune_hist,
		code_com AS code_com_hist,
	CASE
		WHEN id_commune_pole IS NULL THEN id_commune --
		WHEN id_commune_pole IS NOT NULL THEN id_commune_pole -- regroupement de commune
	END AS id_commune
	FROM
		dimensions.communes
	)
________________
WITH table_correspondance_geo AS -- correspondance entre le code commune historique et le code commune actuel
	(

	SELECT
		table_passage.id_commune_hist,
		table_passage.code_com_hist, -- code commune historique
		dimensions.communes.code_com AS code_com -- code commune actuel
	FROM
		dimensions.communes,
		table_passage
	WHERE
		communes.id_commune = table_passage.id_commune
	)
________________
millesime AS -- selection du dernier millésime Insee
	(
	WITH temp2 AS
		(
		WITH temp AS
			(
			select
			numero_annee as numero_annee
			from "dimensions"."annees"
			where "dimensions"."annees"."est_une_borne" = 'Oui'
			)
		select
		numero_annee as numero_annee,
		row_number() over (order by numero_annee desc) as rn
		from temp
		)
	select
	numero_annee
	from temp2
	where rn=1
	order by numero_annee
	)

________________

WITH table_data AS
	(

	SELECT
	  table_correspondance_geo.code_com AS code_com,
	  max(annees.numero_annee) AS annee,
	  sum(nbr_actif_occ_lt.nbr_actif_occ) AS nbr_actif_lt
	FROM
	  dimensions.annees,
	  dimensions.communes,
	  faits.nbr_actif_occ_lt,
	  table_correspondance_geo
	WHERE
	  annees.id_annee = nbr_actif_occ_lt.id_annee
	AND
	  nbr_actif_occ_lt.id_commune = communes.id_commune
	AND
	  communes.id_commune = table_correspondance_geo.id_commune_hist
	AND
	  communes.code_reg = '53'
	AND
	  annees.numero_annee =(select numero_annee from millesime)
	GROUP BY
	  table_correspondance_geo.code_com
	)
________________

SELECT
 communes_pt.code_com,
 communes_pt.lib_com,
 donnees_emploi_lt.annee,
 donnees_emploi_lt.nbr_actif_lt,
 communes_pt.the_geom
FROM
 geographies.communes_pt,
 donnees_emploi_lt
WHERE
 communes_pt.code_com =  donnees_emploi_lt.code_com
AND
  communes_pt.code_reg='53'


_____________________________
# V1

-- Select des data qui nous intéresse, recupère tout la table avec
-- id_année || id_commune ||
SELECT
-- ajout indicateurs calculés
	sum(nbr_actif_occ_lt.nbr_actif_occ) AS nbr_actif_lt,
-- ajout id foreign key pour
	nbr_actif_occ_lt.id_commune AS code_com,
	max(nbr_actif_occ_lt.id_annee) AS last_annee
FROM
	  faits.nbr_actif_occ_lt
group by
	nbr_actif_occ_lt.id_commune

_____________________________
# V2

SELECT
-- ajout indicateurs calculés
	sum(nbr_actif_occ_lt.nbr_actif_occ) AS nbr_actif_lt,
-- ajout id foreign key pour
	nbr_actif_occ_lt.id_commune AS code_com,
	communes.lib_com as lib_com,
	nbr_actif_occ_lt.id_annee AS last_annee,
	annees.numero_annee as num_annee

FROM
	  faits.nbr_actif_occ_lt,
	  dimensions.annees,
	  dimensions.communes

where
	communes.id_commune = nbr_actif_occ_lt.id_commune
and
	annees.id_annee= nbr_actif_occ_lt.id_annee
group by
	nbr_actif_occ_lt.id_commune,
	annees.numero_annee,
communes.lib_com
order by last_annee
limit 10;

_____________________________
