/*
----------------------------------------------------------------------------------
-- Template Datagences pour requete SQL - Datagences_Atelier_Carto  					--
----------------------------------------------------------------------------------
*/

/*
-- Pour profiter pleinement du Template, il faut :
-- 1) Modifier la table_faits, le FROM de table_data
-- 2) Mettre indicateurs calculés dans table_data
-- 3) Modifier le nom de l'indicateur dans le SELECT final
--
-- Options possibles:
-- 1) Ajouter le geom
-- 2) Réduire la Sélection sur la Bretagne || Pays de la loire
-- 3) Sélection de la dernière borne || dernier millesime
--
*/

WITH table_data as (
  SELECT
  -- ajout indicateurs calculés
    sum(table_faits.effectif) AS effectif_total,

  -- ajout id foreign key
  -- garder id_commune || id_annee
    table_faits.id_commune ,
    table_faits.id_annee

  FROM -- changer nom de la table
      faits.etab_eff_sal_na732_acoss as table_faits
  group by
      table_faits.id_commune,
      table_faits.id_annee
), --  Merci de ne pas modifier ci-dessous
table_commune as (
    SELECT
    		communes.lib_com,
    		communes.id_commune AS id_commune_historique,
    		communes.code_com AS code_com_historique,

    	CASE
    		WHEN id_commune_pole IS NULL THEN id_commune --
    		WHEN id_commune_pole IS NOT NULL THEN id_commune_pole -- regroupement de commune
    	END AS
    		id_commune_actuelle,

    	CASE
    		WHEN code_com_pole IS NULL THEN code_com --
    		WHEN code_com_pole IS NOT NULL THEN code_com_pole -- regroupement de commune
    	END AS
    		code_com_actuelle

    	FROM
    		dimensions.communes
  ),
table_correspondance_geo as (
    SELECT
        table_commune.lib_com,
        table_commune.id_commune_historique,
        table_commune.code_com_historique,
        table_commune.id_commune_actuelle,
        table_commune.code_com_actuelle
--	Ajout du geom, attention requete + longue
--		geographies.communes.the_geom
    FROM
        geographies.communes,
        dimensions.communes,
        table_commune
    WHERE
        geographies.communes.id_commune = table_commune.id_commune_historique
    AND
        dimensions.communes.id_commune  = table_commune.id_commune_historique
     -- Sélection réduite sur la Bretagne
    --AND     dimensions.communes.code_reg = '53'
      -- Sélection sur Bretagne + Pays de la Loire
    --AND     (dimensions.communes.code_reg = '53' OR dimensions.communes.code_reg = '52')
),
table_last_millesime as (
    select
        numero_annee ,
        id_annee
    from
        dimensions.annees
        table_data
    where
        table_data.id_annee = (
            SELECT max(id_annee)
            from table_data
        )
)
,
table_last_borne as (
	select
		numero_annee ,
		id_annee ,
	row_number() over (order by numero_annee desc) as rn
	from dimensions.annees
	where dimensions.annees.est_une_borne = 'Oui'
	order by rn
	limit 1
 )

SELECT DISTINCT
-- Modification de l'indicateur
    table_data.effectif_total,

-- Choix du millesime
    table_last_millesime.numero_annee as last_millesime ,
    table_last_borne.numero_annee as last_borne ,

--  Merci de ne pas modifier ci-dessous
    table_correspondance_geo.lib_com,
    table_correspondance_geo.code_com_actuelle,
    table_correspondance_geo.id_commune_actuelle
--	Ajout du geom, attention requete + longue
--	table_correspondance_geo.the_geom
FROM
    table_correspondance_geo,
    table_last_millesime,
    table_last_borne,
    table_data
WHERE
    table_data.id_commune = table_correspondance_geo.id_commune_historique

/* Sélection du dernier millesime */
-- AND  table_last_millesime.id_annee = table_data.id_annee

/* Sélection de la dernière borne */
AND  table_last_borne.id_annee = table_data.id_annee

ORDER BY lib_com
