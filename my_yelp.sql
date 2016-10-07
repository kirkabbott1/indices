-- explain
Seq Scan on restaurant  (cost=0.00..57655.25 rows=47 width=23)
  Filter: ((name)::text = 'Nienow, Kiehn and DuBuque'::text)
--explain after creating index
Bitmap Heap Scan on restaurant  (cost=4.79..186.57 rows=47 width=23)
  Recheck Cond: ((name)::text = 'Nienow, Kiehn and DuBuque'::text)
  ->  Bitmap Index Scan on restaurant_name_idx  (cost=0.00..4.78 rows=47 width=0)
        Index Cond: ((name)::text = 'Nienow, Kiehn and DuBuque'::text)

select reviewer.name reviewer_name, karma
from reviewer
order by karma DESC limit 10;

--explain
Limit  (cost=114942.08..114942.11 rows=10 width=19)
  ->  Sort  (cost=114942.08..122442.33 rows=3000100 width=19)
        Sort Key: karma DESC
        ->  Seq Scan on reviewer  (cost=0.00..50111.00 rows=3000100 width=19)

--explain after indexing 4ms>1ms
Limit  (cost=0.43..0.95 rows=10 width=19)
  ->  Index Scan Backward using reviewer_karma_idx on reviewer  (cost=0.43..157278.76 rows=3000100 width=19)

select * from restaurant, review
where restaurant.id = review.restaurant_id and restaurant.name = 'Nienow, Kiehn and DuBuque';
6s

--explain
Hash Join  (cost=187.16..287063.43 rows=94 width=265)
  Hash Cond: (review.restaurant_id = restaurant.id)
  ->  Seq Scan on review  (cost=0.00..264374.42 rows=6000242 width=242)
  ->  Hash  (cost=186.57..186.57 rows=47 width=23)
        ->  Bitmap Heap Scan on restaurant  (cost=4.79..186.57 rows=47 width=23)
              Recheck Cond: ((name)::text = 'Nienow, Kiehn and DuBuque'::text)
              ->  Bitmap Index Scan on restaurant_name_idx  (cost=0.00..4.78 rows=47 width=0)
                    Index Cond: ((name)::text = 'Nienow, Kiehn and DuBuque'::text)

select avg(review.stars) from restaurant, review
where restaurant.id = review.restaurant_id and restaurant.name = 'Nienow, Kiehn and DuBuque';
--2.7s
--explainAggregate  (cost=287063.67..287063.68 rows=1 width=32)
  ->  Hash Join  (cost=187.16..287063.43 rows=94 width=4)
        Hash Cond: (review.restaurant_id = restaurant.id)
        ->  Seq Scan on review  (cost=0.00..264374.42 rows=6000242 width=8)
        ->  Hash  (cost=186.57..186.57 rows=47 width=4)
              ->  Bitmap Heap Scan on restaurant  (cost=4.79..186.57 rows=47 width=4)
                    Recheck Cond: ((name)::text = 'Nienow, Kiehn and DuBuque'::text)
                    ->  Bitmap Index Scan on restaurant_name_idx  (cost=0.00..4.78 rows=47 width=0)
                          Index Cond: ((name)::text = 'Nienow, Kiehn and DuBuque'::text)
--after Index
Aggregate  (cost=962.99..963.00 rows=1 width=32)
  ->  Nested Loop  (cost=5.23..962.76 rows=94 width=4)
        ->  Bitmap Heap Scan on restaurant  (cost=4.79..186.57 rows=47 width=4)
              Recheck Cond: ((name)::text = 'Nienow, Kiehn and DuBuque'::text)
              ->  Bitmap Index Scan on restaurant_name_idx  (cost=0.00..4.78 rows=47 width=0)
                    Index Cond: ((name)::text = 'Nienow, Kiehn and DuBuque'::text)
        ->  Index Scan using review_restaurant_id_idx on review  (cost=0.43..16.48 rows=3 width=8)
              Index Cond: (restaurant_id = restaurant.id)
--1ms

--step 1 new explain
Bitmap Heap Scan on restaurant  (cost=4.79..186.57 rows=47 width=23)
  Recheck Cond: ((name)::text = 'Nienow, Kiehn and DuBuque'::text)
  ->  Bitmap Index Scan on restaurant_name_idx  (cost=0.00..4.78 rows=47 width=0)
        Index Cond: ((name)::text = 'Nienow, Kiehn and DuBuque'::text)
