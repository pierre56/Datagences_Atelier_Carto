  
/*																										
----------------------------------------------------------------------------------
-- Requête TCAM Population 					--
----------------------------------------------------------------------------------
*/

WITH donnees_pop_n_5 AS --population annee n-5 dernier millesime insee
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

	,millesime AS -- selection avant dernier millésime Insee
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
		where rn=2
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
	  annees.numero_annee =(select (numero_annee) from millesime)
	GROUP BY
	  table_correspondance_geo.code_com
	)


, donnees_pop_n AS --population annee n dernier millesime insee
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
	  annees.numero_annee =(select max(numero_annee) from millesime)
	GROUP BY
	  table_correspondance_geo.code_com
	)
SELECT 
 communes.code_com,
 communes.lib_com,
 donnees_pop_n_5.annee as annee_n_5,
 donnees_pop_n_5.population as pop_n_5,
 donnees_pop_n.annee as annee_n,
 donnees_pop_n.population as pop_n,
 power((donnees_pop_n.population/donnees_pop_n_5.population),1.0/(donnees_pop_n.annee-donnees_pop_n_5.annee))-1 as tcamp, -- formule taux croissance annuel moyen
 communes.the_geom
FROM
 geographies.communes,
 donnees_pop_n_5,
 donnees_pop_n
WHERE
 communes.code_com =  donnees_pop_n_5.code_com
AND
 donnees_pop_n_5.code_com = donnees_pop_n.code_com
AND
  communes.code_reg='53' -- Bretagne
--LIMIT 10   
  