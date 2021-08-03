/* Q1 How much was the best selling movie sold for, the total sales of
categories, and the number of movies in each category? */

WITH max_f AS
(
  SELECT 	f.title movie,
          c.name category,
          SUM(p.amount) over (partition by c.name) AS total_sales
	FROM  film f
	JOIN  film_category fc
	ON    f.film_id = fc.film_id
	JOIN  category c
	ON    fc.category_id = c.category_id
	JOIN  inventory i
	ON    f.film_id = i.film_id
	JOIN  rental r
	ON    i.inventory_id = r.inventory_id
	JOIN  payment p
	ON    r.rental_id = p.rental_id
)

SELECT 	max_f.category,
				COUNT(max_f.movie) movie_count,
        MAX(max_f.total_sales) max_sales,
        SUM(max_f.total_sales) total_sales
FROM  max_f
GROUP BY 1
ORDER BY 3 DESC;

/* Q2 Avg rental per each category */

SELECT  ROW_NUMBER() OVER (ORDER BY c.name) AS row_num,
        c.name AS genre,
        ROUND(AVG(f.rental_rate),2) AS Average_rental_rate
FROM category c
JOIN film_category fc
ON    fc.category_id = c.category_id
JOIN film f
ON  f.film_id = fc.film_id
GROUP BY 2, c.name
ORDER BY 1 DESC;

/* Number of movies in family friendly categories and divide to 4 categories */

WITH
cat AS
	(
    SELECT  fc.film_id, c.name
    FROM    film_category fc
    JOIN    category c
    ON      c.category_id = fc.category_id
  ),
quad_cat AS
  (
      SELECT DISTINCT f.title film_title,
                      cat.name
    FROM film f
    JOIN cat
    ON cat.film_id = f.film_id
    WHERE cat.name IN ('Family', 'Children', 'Music', 'Animation', 'Comedy','Games')
    ORDER BY 2
  )

SELECT  name,
		    count(*)
FROM quad_cat
GROUP BY 1
ORDER BY 2;

/* Q4 What is the sales of movies compared with movie length divided into 4
categories? */

SELECT DISTINCT
          CASE
            WHEN f.length BETWEEN 46 AND 92 THEN 'SHORT'
            WHEN f.length BETWEEN 93 AND 139 THEN 'MEDIUM'
            ELSE 'LONG' END AS mov_len,
            SUM(p.amount) sales,
            COUNT(f.rental_rate) rental_rate
FROM  film f
JOIN  film_category fc
ON    f.film_id = fc.film_id
JOIN  category c
ON    fc.category_id = c.category_id
JOIN  inventory i
ON    f.film_id = i.film_id
JOIN  rental r
ON    i.inventory_id = r.inventory_id
JOIN  payment p
ON    r.rental_id = p.rental_id
GROUP BY 1
ORDER BY 2 DESC
