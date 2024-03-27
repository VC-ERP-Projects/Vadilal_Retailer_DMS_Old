
CREATE VIEW dbo.vwCustomer
AS
SELECT DISTINCT TOP (100) PERCENT REPLACE(C.CustomerName, '-', '') AS CustomerName, C.Type, C.CustomerCode, C.Phone, O.CustomerID, P.PlantID, P.StateID
FROM         dbo.OCRD AS C INNER JOIN
                      dbo.OGCRD AS O ON C.CustomerID = O.CustomerID INNER JOIN
                      dbo.OPLT AS P ON O.PlantID = P.PlantID
WHERE     (C.Active = 1)
ORDER BY C.Type, CustomerName
GO

CREATE TABLE [dbo].[OIMG]
(
[ImageID] [int] NOT NULL,
[ImageName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SortOrder] [int] NOT NULL,
[CreatedDate] [datetime] NOT NULL,
[CreatedBy] [int] NOT NULL,
[UpdatedDate] [datetime] NOT NULL,
[UpdatedBy] [int] NOT NULL,
[Active] [bit] NOT NULL CONSTRAINT [DF_OIMG_Active] DEFAULT ((0))
)
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating primary key [PK_OIMG] on [dbo].[OIMG]'
GO
ALTER TABLE [dbo].[OIMG] ADD CONSTRAINT [PK_OIMG] PRIMARY KEY CLUSTERED  ([ImageID])
GO