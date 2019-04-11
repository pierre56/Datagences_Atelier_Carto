# Temp

select
	numero_annee as numero_annee
from
	dimensions.annees,
	faits.populations
where
	annees.id_annee = populations.id_annee
and
	populations.id_annee = 67

  ________________
  SELECT
	  sum(nbr_actif_occ_lt.nbr_actif_occ) AS nbr_actif_lt
	FROM
	  faits.nbr_actif_occ_lt
