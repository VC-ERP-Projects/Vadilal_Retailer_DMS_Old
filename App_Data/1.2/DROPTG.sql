SELECT ' ' + Char(10) + Char(13) + 'DROP TRIGGER ' 
    + QUOTENAME(OBJECT_SCHEMA_NAME(O.[object_id])) + '.' 
    + QUOTENAME(name)
FROM sys.sql_modules as M 
    INNER JOIN sys.triggers as O 
        ON M.object_id = O.object_id; 