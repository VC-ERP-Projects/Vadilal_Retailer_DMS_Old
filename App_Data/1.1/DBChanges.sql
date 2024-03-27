GO
ALTER TABLE OPOS ADD OrderTypeReasonID int 
GO
ALTER TABLE OCFG ADD TopItem int
GO
CREATE PROCEDURE SetTopItems (@ParentID DECIMAL(18, 0), @TemplateID INT)
AS
IF (
		CONVERT(DATE, (
				SELECT UpdatedDate
				FROM OTMP
				WHERE TemplateID = @TemplateID AND ParentID = @ParentID
				)) <> Convert(DATE, GETDATE())
		)
BEGIN
	DELETE
	FROM SITM
	WHERE TemplateID = @TemplateID AND ParentID = @ParentID

	UPDATE OTMP
	SET UpdatedDate = GETDATE()
	WHERE TemplateID = @TemplateID AND ParentID = @ParentID

	DECLARE @TopItems INT

	SELECT @TopItems = ISNULL(TopItem, 0)
	FROM OCFG

	INSERT INTO SITM
	SELECT TOP (@TopItems) (
			SELECT isnull(MAX(SITMID), 0)
			FROM SITM
			WHERE ParentID = t.ParentID
			) + (
			row_number() OVER (
				ORDER BY t.ob DESC
				)
			), t.ParentID, t.TemplateID, t.ItemID, t.Priority, t.SyncStatus, t.MinStock, t.MaxStock, t.[Days]
	FROM (
		SELECT SUM(DispatchQty) AS Ob, POS1.ParentID, @TemplateID AS TemplateID, ItemID, row_number() OVER (
				ORDER BY SUM(DispatchQty) DESC
				) AS Priority, 0 AS SyncStatus, 0 AS MinStock, 0 AS MaxStock, 0 AS [Days]
		FROM POS1
		WHERE ParentID = @ParentID
		GROUP BY ItemID, POS1.ParentID
		) AS t
	ORDER BY t.Ob DESC
END
GO

