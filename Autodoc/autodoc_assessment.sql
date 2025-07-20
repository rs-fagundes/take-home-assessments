-- Exercicse 1
WITH
    first_session AS (
        SELECT
            user,
            MIN(session) AS first_session
        FROM
            data_set_da_test d
        GROUP BY
            user
    ),
    first_session_events AS (
        SELECT
            e.user,
            e.event_date,
            e.event_type
        FROM
            data_set_da_test e
            JOIN first_session f ON e.user = f.user
            AND e.session = f.first_session
    ),
    clients_only_viewed AS (
        SELECT
            user,
            event_date
        FROM
            first_session_events
        GROUP BY
            user,
            event_date
        HAVING
            SUM(
                CASE
                    WHEN event_type != 'page_view' THEN 1
                    ELSE 0
                END
            ) = 0
    )
SELECT
    DATE (event_date),
    COUNT(DISTINCT user) AS clients_only_viewed
FROM
    clients_only_viewed
GROUP BY
    DATE (event_date);

-- Exercise 2
WITH
    user_events AS (
        SELECT
            session,
            SUM(
                CASE
                    WHEN event_type = 'page_view' THEN 1
                    ELSE 0
                END
            ) AS views,
            SUM(
                CASE
                    WHEN event_type = 'add_to_cart' THEN 1
                    ELSE 0
                END
            ) AS carts,
            SUM(
                CASE
                    WHEN event_type = 'order' THEN 1
                    ELSE 0
                END
            ) AS orders
        FROM
            data_set_da_test d
        GROUP BY
            session
    ),
    orders_without_views_or_carts AS (
        SELECT
            session,
            views,
            carts,
            orders
        FROM
            user_events
        WHERE
            orders > 0
            AND (
                views = 0
                OR carts = 0
            )
    )
SELECT
    COUNT(
        CASE
            WHEN views > 0 THEN 1
        END
    ) as views,
    COUNT(
        CASE
            WHEN carts > 0 THEN 1
        END
    ) as carts,
    COUNT(
        CASE
            WHEN orders > 0 THEN 1
        END
    ) as orders
FROM
    orders_without_views_or_carts;