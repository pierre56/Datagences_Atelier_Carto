﻿
/*																										
----------------------------------------------------------------------------------
-- Requête emploi au lieu de travail					--
----------------------------------------------------------------------------------
*/


WITH donnees_emploi_lt AS
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