
/*																										
----------------------------------------------------------------------------------
-- Requête Part des foyers allocataires percevant le RSA				--
----------------------------------------------------------------------------------
*/


WITH part_foyers_rsa AS
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
			),

	annees_serie AS -- selection dernier millésimes dispo de la série de données CAF
		(
		WITH temp AS
			(
			SELECT
			  MIN(rsa_caf.id_annee) as id_annee
			FROM 
			  faits.rsa_caf
			GROUP BY
			  rsa_caf.id_annee
			)
		SELECT 
		  max(annees.numero_annee) as numero_annee
		FROM 
		  temp, 
		  dimensions.annees
		WHERE 
		  temp.id_annee = annees.id_annee
		ORDER BY
		  numero_annee
		)
		
	SELECT 
	  table_correspondance_geo.code_com AS code_com,
	  max(annees.numero_annee) AS annee,
	  sum(rsa_caf.nb_all_rsa)/sum(rsa_caf.nb_all_tot) AS pfoyrsa -- part des foyers allocataires RSA
	FROM 
	  dimensions.annees, 
	  dimensions.communes, 
	  faits.rsa_caf,
	  table_correspondance_geo
	WHERE 
	  annees.id_annee = rsa_caf.id_annee
	AND
	  rsa_caf.id_commune = communes.id_commune
	AND
	  communes.id_commune = table_correspondance_geo.id_commune_hist
	AND
	  communes.code_reg = '53'
	AND
	  annees.numero_annee =(select numero_annee from annees_serie)
	GROUP BY
	  table_correspondance_geo.code_com
	)

SELECT 
 communes.code_com,
 communes.lib_com,
 part_foyers_rsa.annee,
 part_foyers_rsa.pfoyrsa
 communes.the_geom
FROM
 geographies.communes,
 part_foyers_rsa
WHERE
 communes.code_com =  part_foyers_rsa.code_com
AND
  communes.code_reg='53'
--LIMIT 10