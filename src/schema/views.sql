-------------------------------------------
CREATE OR REPLACE VIEW public.communities_search AS (
    SELECT c.id, c.name AS name, z.zip
    FROM public.communities AS c
    INNER JOIN public.zipcode AS z ON z.community_id = c.id
);

-------------------------------------------
CREATE OR REPLACE VIEW public.wiki_background_images AS (
    SELECT community_id, url FROM public.wikipedia_images
    WHERE url NOT ILIKE '%logo%'
      AND url NOT ILIKE '%coat%'
      AND url NOT ILIKE '%karte%'
      AND url NOT ILIKE '%wappen%'
);

-------------------------------------------
CREATE OR REPLACE VIEW public.political_parties_aggregated AS (
    SELECT community_id, year, party, round(sum(voters)) as voters FROM (
        SELECT community_id, year, party, voters FROM public.political_parties
        WHERE party <> 'FGA/AVF'
           AND party <> 'EVP/PEV'
           AND party <> 'EDU/UDF'
           AND party <> 'CSP/PCS'
           AND party <> 'PdA/PST'
           AND party <> 'SD/DS'
           AND party <> 'FPS/PSL'
           AND party <> 'LdU/AdI'
           AND party <> 'Lega'
           AND party <> 'LPS/PLS'
           AND party <> 'MCR'
           AND party <> 'POCH'
           AND party <> 'PSA'
           AND party <> 'Rep./Rép.'
           AND party <> 'Sep./Sép.'
           AND party <> 'Sol.'
           AND party <> 'Übrige/Autres'
        UNION ALL
        SELECT community_id, year, 'Other' as party, voters FROM public.political_parties
        WHERE party = 'FGA/AVF'
           OR party = 'EVP/PEV'
           OR party = 'EDU/UDF'
           OR party = 'CSP/PCS'
           OR party = 'PdA/PST'
           OR party = 'SD/DS'
           OR party = 'FPS/PSL'
           OR party = 'LdU/AdI'
           OR party = 'Lega'
           OR party = 'LPS/PLS'
           OR party = 'MCR'
           OR party = 'POCH'
           OR party = 'PSA'
           OR party = 'Rep./Rép.'
           OR party = 'Sep./Sép.'
           OR party = 'Sol.'
           OR party = 'Übrige/Autres'
    ) AS t
    GROUP BY community_id, year, party
);

-------------------------------------------
CREATE OR REPLACE VIEW public.building_investments_by_category AS (
    SELECT community_id, year, category, sum(amount) as amount FROM (
        SELECT community_id, year, category, amount FROM public.building_investments
        WHERE category <> 'Infrastruktur: Entsorgung'
           AND category <> 'Infrastruktur: Strassenverkehr'
           AND category <> 'Infrastruktur: Versorgung'
           AND category <> 'Infrastruktur: Übrige Verkehr und Kommunikation'
           AND category <> 'Übrige Infrastruktur'
        UNION ALL
        SELECT community_id, year, 'Infrastruktur' as category, amount FROM public.building_investments
        WHERE category = 'Infrastruktur: Entsorgung'
           OR category = 'Infrastruktur: Strassenverkehr'
           OR category = 'Infrastruktur: Versorgung'
           OR category = 'Infrastruktur: Übrige Verkehr und Kommunikation'
           AND category <> 'Übrige Infrastruktur'
    ) AS t
    GROUP BY community_id, year, category
);

-------------------------------------------
CREATE OR REPLACE VIEW public.communities_detail AS (
    SELECT
        c.id AS community_id,
        c.name AS name,
        (SELECT url FROM public.wikipedia_links WHERE c.id = community_id) AS wikipedia_link,
        (
            SELECT array_to_json(array_agg(t)) FROM (
                SELECT url FROM public.wiki_background_images
                WHERE c.id = community_id
            ) AS t
        ) AS wikipedia_images,
        (
            SELECT array_to_json(array_agg(t)) FROM (
                SELECT year, births FROM public.births
                WHERE community_id = c.id
                ORDER BY year ASC
            ) AS t
        ) AS births,
        (
            SELECT array_to_json(array_agg(t)) FROM (
                SELECT year, deaths FROM public.deaths
                WHERE community_id = c.id
                ORDER BY year ASC
            ) AS t
        ) AS deaths,
        (
            SELECT array_to_json(array_agg(t)) FROM (
                SELECT year, population FROM public.residential_population
                WHERE community_id = c.id
                ORDER BY year ASC
            ) AS t
        ) AS residential_population,
        (
            SELECT array_to_json(array_agg(t)) FROM (
                SELECT year, language FROM public.language_areas
                WHERE community_id = c.id
                ORDER BY year ASC
            ) AS t
        ) AS language_areas,
        (
            SELECT array_to_json(array_agg(t)) FROM (
                SELECT year, share FROM public.housing_estate_share
                WHERE community_id = c.id
                ORDER BY year ASC
            ) AS t
        ) AS housing_estate_share,
        (
            SELECT array_to_json(array_agg(t)) FROM (
                SELECT year, commuters, balance_per_100_workers FROM public.commuter_balance
                WHERE community_id = c.id
                ORDER BY year ASC
            ) AS t
        ) AS commuter_balance,
        (
            SELECT array_to_json(array_agg(t)) FROM (
                SELECT year, cinemas FROM public.cinemas
                WHERE community_id = c.id
                ORDER BY year ASC
            ) AS t
        ) AS cinemas,
        (
            SELECT array_to_json(array_agg(t)) FROM (
                SELECT * FROM public.population_age_group
                WHERE community_id = c.id
                ORDER BY year ASC
            ) AS t
        ) AS population_by_age_groups,
        (
            SELECT array_to_json(array_agg(t)) FROM (
                SELECT year, immigration FROM public.immigration
                WHERE community_id = c.id
                ORDER BY year ASC
            ) AS t
        ) AS immigration,
        (
            SELECT array_to_json(array_agg(t)) FROM (
                SELECT year, emigration FROM public.emigration
                WHERE community_id = c.id
                ORDER BY year ASC
            ) AS t
        ) AS emigration,
        (
            SELECT array_to_json(array_agg(t)) FROM (
                SELECT year, immigration FROM public.immigration_from_same_canton
                WHERE community_id = c.id
                ORDER BY year ASC
            ) AS t
        ) AS immigration_from_same_canton,
        (
            SELECT array_to_json(array_agg(t)) FROM (
                SELECT year, immigration FROM public.immigration_from_other_canton
                WHERE community_id = c.id
                ORDER BY year ASC
            ) AS t
        ) AS immigration_from_other_canton,
        (
            SELECT array_to_json(array_agg(t)) FROM (
                SELECT year, emigration FROM public.emigration_from_same_canton
                WHERE community_id = c.id
                ORDER BY year ASC
            ) AS t
        ) AS emigration_from_same_canton,
        (
            SELECT array_to_json(array_agg(t)) FROM (
                SELECT year, emigration FROM public.emigration_from_other_canton
                WHERE community_id = c.id
                ORDER BY year ASC
            ) AS t
        ) AS emigration_from_other_canton,
        (
            SELECT array_to_json(array_agg(t)) FROM (
                SELECT year, surplus FROM public.birth_surplus
                WHERE community_id = c.id
                ORDER BY year ASC
            ) AS t
        ) AS birth_surplus,
        (
            SELECT array_to_json(array_agg(t)) FROM (
                SELECT year, balance FROM public.migration_balance
                WHERE community_id = c.id
                ORDER BY year ASC
            ) AS t
        ) AS migration_balance,
        (
            SELECT array_to_json(array_agg(t)) FROM (
                SELECT year, citizenships FROM public.new_citizenships
                WHERE community_id = c.id
                ORDER BY year ASC
            ) AS t
        ) AS new_citizenships,
        (
            SELECT array_to_json(array_agg(t)) FROM (
                SELECT year, distance_km FROM public.commute_distance
                WHERE community_id = c.id
                ORDER BY year ASC
            ) AS t
        ) AS commute_distance,
        (
            SELECT array_to_json(array_agg(t)) FROM (
                SELECT year, people FROM public.population_birth_place_switzerland
                WHERE community_id = c.id
                ORDER BY year ASC
            ) AS t
        ) AS population_birth_place_switzerland,
        (
            SELECT array_to_json(array_agg(t)) FROM (
                SELECT year, people FROM public.population_birth_place_abroad
                WHERE community_id = c.id
                ORDER BY year ASC
            ) AS t
        ) AS population_birth_place_abroad,
        (
            SELECT array_to_json(array_agg(t)) FROM (
                SELECT year, sector, workplaces, workers FROM public.workplaces_by_sector
                WHERE community_id = c.id
                ORDER BY year ASC
            ) AS t
        ) AS workplaces_by_sector,
        (
            SELECT array_to_json(array_agg(t)) FROM (
                SELECT year, workplace_size, workplaces, workers FROM public.workplaces_by_size
                WHERE community_id = c.id
                ORDER BY year ASC
            ) AS t
        ) AS workplaces_by_size,
        (
            SELECT array_to_json(array_agg(t)) FROM (
                SELECT year, party, voters FROM public.political_parties_aggregated
                WHERE community_id = c.id
                ORDER BY year ASC
            ) AS t
        ) AS political_parties,
        (
            SELECT array_to_json(array_agg(t)) FROM (
                SELECT year, category, amount FROM public.building_investments_by_category
                WHERE community_id = c.id
                ORDER BY year ASC
            ) AS t
        ) AS building_investments_by_category,
        (
            SELECT array_to_json(array_agg(t)) FROM (
                SELECT year, rooms, sum(flats) AS flats FROM public.flats
                WHERE community_id = c.id
                GROUP BY year, rooms
                ORDER BY year ASC
            ) AS t
        ) AS flats_by_rooms,
        (
            SELECT array_to_json(array_agg(t)) FROM (
                SELECT year, origin_man, origin_woman, marriages FROM public.marriages
                WHERE community_id = c.id
                ORDER BY year ASC
            ) AS t
        ) AS marriages,
        (
            SELECT array_to_json(array_agg(t)) FROM (
                SELECT year, origin_man, origin_woman, sum(divorces) as divorces FROM public.divorces
                WHERE community_id = c.id
                GROUP BY year, origin_man, origin_woman
                ORDER BY year ASC
            ) AS t
        ) AS divorces,
        (
            SELECT array_to_json(array_agg(t)) FROM (
                SELECT year, construction_type, work_type, sum(amount) AS amount FROM public.building_projects
                WHERE community_id = c.id
                GROUP BY year, construction_type, work_type
                ORDER BY year ASC
            ) AS t
        ) AS building_projects
    FROM public.communities AS c
);
