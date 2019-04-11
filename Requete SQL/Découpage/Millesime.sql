

table_millesime_borne as (
  select
  numero_annee ,
  row_number() over (order by numero_annee desc) as rn
  from dimensions.annees
  where dimensions.annees.est_une_borne = 'Oui'

)

table_last_millesime as (
  select
      numero_annee ,
      id_annee,
      row_number() over (order by numero_annee desc) as rn
  from
      dimensions.annees
      table_data
  where
      table_data.id_annees = dimensions.annees.id_annee
  AND


)

table_millesime as (
  SELECT
    last_annee as (
        SELECT row_number() over (order by numero_annee desc)
  ),
    last_borne as (
        select
            numero_annee ,
            row_number() over (order by numero_annee desc) as rn
        from dimensions.annees
        where dimensions.annees.est_une_borne = 'Oui'
        limit 1
  )
  from dimensions.annees
  where dimensions.annees.est_une_borne = 'Oui'

)


ROW_NUMBER() OVER (ORDER BY date DESC) AS first_row, /*It's logical required to be the same as major query*/
ROW_NUMBER() OVER (ORDER BY date ASC) AS last_row /*It's rigth, needs to be the inverse*/



table_last_millesime as (
    select
        numero_annee ,
        id_annee,
        row_number() over (order by numero_annee desc) as rn
    from
        dimensions.annees
        table_data
    where
        table_data.id_annee = (
          SELECT max(id_annee)
          from table_data
        )
)

________________
 Faire un last_borne et faire get 2 last_borne


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
_____________________________

## V0

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
	select *
	FROM millesime


> get 2015 || last annee avec est_une_borne

_____________________________

select
greatest(numero_annee) as numero_annee,
row_number() over (order by numero_annee desc) as rn
from dimensions.annees
where dimensions.annees.est_une_borne = 'Oui'

> get all annee avec est_une_borne

_____________________________

select
numero_annee ,
row_number() over (order by numero_annee desc) as rn
from dimensions.annees
where dimensions.annees.est_une_borne = 'Oui'
limit 1;

> get last annee avec est une est_une_borne

_____________________________

select
numero_annee ,
id_annee
from dimensions.annees
limit 1;
