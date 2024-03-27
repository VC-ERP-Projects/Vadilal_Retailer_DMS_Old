mkdir D:\DDMS\AutoBackUp
sqlcmd -U sa -P vc@erp_123 -S VCCRPD020\SqlExpress -Q "EXEC sp_BackupDatabases 'DDMS_Balaji','F','D:\DDMS\AutoBackUp\'"