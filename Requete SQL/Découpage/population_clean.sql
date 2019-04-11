# V1 FAIL

WITH Table_Data AS
(
    SELECT id_commune, id_annee,
      sum(nbr_actif_occ_lt.nbr_actif_occ) AS nbr_actif_lt

    FROM
      faits.nbr_actif_occ_lt
	group by id_annee, id_commune
    ),
table_passage AS
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
	),
table_correspondance_geo AS -- correspondance entre le code commune historique et le code commune actuel
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
  	),
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

SELECT
   communes.code_com,
   communes.lib_com,
   millesime.numero_annee,
   Table_Data.nbr_actif_lt
FROM
Table_Data,
millesime,
table_correspondance_geo,
table_passage,
dimensions.communes
WHERE
 millesime.numero_annee = Table_Data.id_annee
AND
 Table_Data.id_commune = communes.id_commune
AND
 communes.id_commune = table_correspondance_geo.id_commune_hist
AND
 communes.code_reg = '53'
AND
 Table_Data.id_annee =(select numero_annee from millesime)
GROUP BY
 table_correspondance_geo.code_com,
 communes.code_com,
 communes.lib_com,
 millesime.numero_annee,
   Table_Data.nbr_actif_lt
