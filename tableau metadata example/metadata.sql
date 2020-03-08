-- This query will build a set of metadata for a database or databases
-- It contains the metadata for both tables and views

SELECT tables.database_name
    , tables.schema_name
    , tables.object_id
    , tables.type_desc
    , tables.object_name
    , tables.row_counts
    , tables.total_space_kb
    , tables.used_space_kb
    , tables.unused_space_kb
    , columns.column_name
    , columns.max_length
    , columns.column_type
    , columns.precision
FROM (
    -- Database name is hard-coded here and used below as well for all fully-referenced table/view queries
    SELECT 'AdventureWorks2017' AS database_name
        , UPPER(schemas.Name) AS schema_name
        , tables.type_desc
        , tables.object_id
        , UPPER(tables.name) AS object_name
        , partitions.rows AS row_counts
        , SUM(allocation_units.total_pages)*8 AS total_space_kb
        , SUM(allocation_units.used_pages)*8 AS used_space_kb
        , (SUM(allocation_units.total_pages) - SUM(allocation_units.used_pages))*8 AS unused_space_kb
    FROM (
        SELECT type_desc
            , name
            , object_id
            , schema_id
            , is_ms_shipped
        FROM AdventureWorks2017.sys.tables 
        UNION ALL 
        SELECT type_desc
            , name
            , object_id
            , schema_id
            , is_ms_shipped
        FROM AdventureWorks2017.sys.views 
    ) tables 
        LEFT JOIN AdventureWorks2017.sys.indexes indexes
            ON (tables.object_id = indexes.object_id)
        LEFT JOIN AdventureWorks2017.sys.partitions partitions
            ON (indexes.object_id = partitions.object_id)
                AND (indexes.index_id = partitions.index_id)
        LEFT JOIN AdventureWorks2017.sys.allocation_units allocation_units
            ON (partitions.partition_id = allocation_units.container_id)
        LEFT JOIN AdventureWorks2017.sys.schemas schemas
            ON (tables.schema_id = schemas.schema_id)
    WHERE (tables.NAME NOT LIKE 'dt%')
        AND (tables.is_ms_shipped = 0)
        AND (tables.object_id > 255)
    GROUP BY tables.type_desc
        , tables.Name
        , tables.object_id
        , schemas.name
        , partitions.rows
) tables 
    LEFT JOIN (
        SELECT 'AdventureWorks2017' AS database_name
            , UPPER(schemas.Name) AS schema_name
            , tables.object_id
            , LOWER(columns.name) AS column_name
            , columns.max_length
            , types.name AS column_type
            , types.precision
        FROM (
            SELECT object_id
                , schema_id
                , is_ms_shipped
            FROM AdventureWorks2017.sys.tables 
            UNION ALL 
            SELECT object_id
                , schema_id
                , is_ms_shipped
            FROM AdventureWorks2017.sys.views 
        ) tables
            LEFT JOIN AdventureWorks2017.sys.columns columns 
                ON (tables.object_id = columns.object_id) 
            LEFT JOIN AdventureWorks2017.sys.schemas schemas
                ON (tables.schema_id = schemas.schema_id) 
            LEFT JOIN AdventureWorks2017.sys.types types
                ON (columns.system_type_id = types.user_type_id) 
    ) columns 
        ON (tables.database_name = columns.database_name) 
            AND (tables.schema_name = columns.schema_name) 
            AND (tables.object_id = columns.object_id) 
;
