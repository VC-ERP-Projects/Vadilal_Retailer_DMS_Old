using System;
using System.Data;
using MigraDoc.DocumentObjectModel;
using MigraDoc.DocumentObjectModel.Tables;
using MigraDoc.DocumentObjectModel.Shapes;


public class PDFFormCreation
{
    public PDFFormCreation()
    {
        //
        // TODO: Add constructor logic here
        //
    }
    private Document document;
    private DataTable dt;
    private string path;
    private string Title;
    private TextFrame addressFrame;
    private Table table;
    private string p;
    private string subject;
    private string Period, ReportOption, Employee, Region, CreatedBy, BeatEmp, Competitor, UserID;

    public PDFFormCreation(DataTable dtIn, string pathIn, string Heading, string strPeriod, string strReportOption, string strEmployee, string strRegion, string strCreatedBy, string strBeatEmp, string strCompetitor, string strUserID)
    {
        dt = dtIn;
        path = pathIn;
        Title = Heading;
        Period = strPeriod;
        ReportOption = strReportOption;
        Employee = strEmployee; Region = strRegion; CreatedBy = strCreatedBy; BeatEmp = strBeatEmp;
        Competitor = strCompetitor; UserID = strUserID;
    }

    public Document CreateDocument()
    {
        this.document = new Document();
        this.document.Info.Title = "";
        this.document.Info.Subject = "";
        this.document.Info.Author = "DMS";
        DefineStyles();
        CreatePage();
        FillContent();
        return this.document;
    }

    private void DefineStyles()
    {
        Style style = this.document.Styles["Normal"];
        style.Font.Name = "Verdana";

        style = this.document.Styles[StyleNames.Header];
        style.ParagraphFormat.AddTabStop("16cm", TabAlignment.Left);

        style = this.document.Styles[StyleNames.Footer];
        style.ParagraphFormat.AddTabStop("8cm", TabAlignment.Center);

        // Create a new style called Table based on style Normal
        style = this.document.Styles.AddStyle("Table", "Normal");
        style.Font.Name = "Verdana";
        //style.Font.Name = "Times New Roman"
        style.Font.Size = 8;

        // Create a new style called Reference based on style Normal
        style = this.document.Styles.AddStyle("Reference", "Normal");
        style.ParagraphFormat.SpaceBefore = "-0.05mm";
        style.ParagraphFormat.SpaceAfter = "-0.05mm";
        style.ParagraphFormat.TabStops.AddTabStop("5cm", TabAlignment.Right);
    }

    private void CreatePage()
    {
        // Each MigraDoc document needs at least one section.
        Section section = this.document.AddSection();
        //HeaderFooter header = section.Headers.Primary;
        //header.AddParagraph("\tOdd Page Header");

        // Create Header
        Paragraph paragraph = section.Headers.Section.AddParagraph();
        paragraph = section.Headers.Section.AddParagraph();
        paragraph.AddText(Title.ToString());
        paragraph.Format.Font.Size = 9;
        paragraph.Format.Alignment = ParagraphAlignment.Left;
        paragraph.Format.SpaceBefore =-5;
        paragraph.Format.SpaceAfter = -5;
        


        Paragraph paragraph1 = section.Headers.Section.AddParagraph();
        paragraph1 = section.Headers.Section.AddParagraph();
        paragraph1.AddText(Period);
        paragraph1.Format.Font.Size = 8;
        paragraph1.Format.Alignment = ParagraphAlignment.Left;
        paragraph1.Format.KeepTogether = true;
        //paragraph1.Format.SpaceBefore = -10;
        paragraph1.Format.SpaceAfter = -10;

        Paragraph paragraph2 = section.Headers.Section.AddParagraph();
        paragraph2 = section.Headers.Section.AddParagraph();
        paragraph2.AddText(Employee);
        paragraph2.Format.Font.Size = 8;
        paragraph2.Format.Alignment = ParagraphAlignment.Left;
        //paragraph2.Format.SpaceBefore = -10;
        paragraph2.Format.SpaceAfter = -10;

        Paragraph paragraph3 = section.Headers.Section.AddParagraph();
        paragraph3 = section.Headers.Section.AddParagraph();
        paragraph3.AddText(Region);
        paragraph3.Format.Font.Size = 8;
        paragraph3.Format.Alignment = ParagraphAlignment.Left;
        paragraph3.Format.SpaceAfter = -10;

        Paragraph paragraph4 = section.Headers.Section.AddParagraph();
        paragraph4 = section.Headers.Section.AddParagraph();
        paragraph4.AddText(CreatedBy);
        paragraph4.Format.Font.Size = 8;
        paragraph4.Format.Alignment = ParagraphAlignment.Left;
        paragraph4.Format.SpaceAfter = -10;

        Paragraph paragraph5 = section.Headers.Section.AddParagraph();
        paragraph5 = section.Headers.Section.AddParagraph();
        paragraph5.AddText(BeatEmp);
        paragraph5.Format.Font.Size = 8;
        paragraph5.Format.Alignment = ParagraphAlignment.Left;
        paragraph5.Format.SpaceAfter = -10;

        Paragraph paragraph6 = section.Headers.Section.AddParagraph();
        paragraph6 = section.Headers.Section.AddParagraph();
        paragraph6.AddText(Competitor);
        paragraph6.Format.Font.Size = 8;
        paragraph6.Format.Alignment = ParagraphAlignment.Left;
        paragraph6.Format.SpaceAfter = -10;

        Paragraph paragraph7 = section.Headers.Section.AddParagraph();
        paragraph7 = section.Headers.Section.AddParagraph();
        paragraph7.AddText("Created on : " + DateTime.Now.ToString("dd/MM/yyyy HH:mm:ss tt"));
        paragraph7.Format.Font.Size = 8;
        paragraph7.Format.Alignment = ParagraphAlignment.Left;
        paragraph7.Format.SpaceAfter = -10;

        Paragraph paragraph8 = section.Headers.Section.AddParagraph();
        paragraph8 = section.Headers.Section.AddParagraph();
        paragraph8.AddText(UserID);
        paragraph8.Format.Font.Size = 8;
        paragraph8.Format.Alignment = ParagraphAlignment.Left;
        paragraph8.Format.KeepTogether = true;
        paragraph8.Format.SpaceAfter = -30;

        section.PageSetup.LeftMargin = 15;
        section.PageSetup.TopMargin = 15;
        section.PageSetup.BottomMargin = 15;
        // Create the text frame for the address
        this.addressFrame = section.AddTextFrame();
        this.addressFrame.Height = "1.0cm";
        this.addressFrame.Width = "7.0cm";
        this.addressFrame.Left = ShapePosition.Left;
        this.addressFrame.RelativeHorizontal = RelativeHorizontal.Margin;
        this.addressFrame.Top = "0.1cm";
        this.addressFrame.MarginLeft = "0.1cm";
        this.addressFrame.RelativeVertical = RelativeVertical.Page;

        // Put sender in address frame
        paragraph = this.addressFrame.AddParagraph("");
        paragraph.Format.Font.Name = "Verdana";
        paragraph.Format.Font.Size = 6;
        paragraph.Format.SpaceAfter = 0.1;

        // Add the print date field
        paragraph = section.AddParagraph();
        paragraph.Format.SpaceBefore = "1cm";
        paragraph.Style = "Reference";

        // Create the item table
        this.table = section.AddTable();
        this.table.Style = "Table";

        this.table.Borders.Color = TableBorder;
        this.table.Borders.Width = 0.25;
        this.table.Borders.Left.Width = 0.5;
        this.table.Borders.Right.Width = 0.5;
        this.table.Rows.LeftIndent = 0;
        section.LastTable.KeepTogether = true;
        //section.LastTable.TopPadding=-10;

        // Before you can add a row, you must define the columns
        Column column = default(Column);
        Int32 ColCnt = dt.Columns.Count;

        //Dim Width As Double
        if (ColCnt > 10)
        {
            section.PageSetup.PageFormat = PageFormat.A3;
            section.PageSetup.Orientation = Orientation.Landscape;
        }
        else
        {
            section.PageSetup.PageFormat = PageFormat.A4;
            section.PageSetup.Orientation = Orientation.Landscape;
        }
        //section.PageSetup.TopMargin = -5;
        foreach (DataColumn col in dt.Columns)
        {
            column = this.table.AddColumn();
            if (col.ColumnName.ToLower().Contains("sr."))
                column.Width = 30;
            else if (col.ColumnName.ToLower().Contains("outlet code"))
                column.Width = 50;
            else if (col.ColumnName.ToLower().Contains("outlet name"))
                column.Width = 155;
            else if (col.ColumnName.ToLower() == "question")
                column.Width = 180;
            else if (col.ColumnName.ToLower() == "question status")
                column.Width = 60;
            else if (col.ColumnName.ToLower() == "visited by code")
                column.Width = 70;
            else
                column.Width = 90;
            column.Format.Alignment = ParagraphAlignment.Left;
            //column.Format.Font.Bold = true;
        }

        // Create the header of the table
        Row row = table.AddRow();
        row.HeadingFormat = true;
        row.Format.Alignment = ParagraphAlignment.Center;
        // row.Format.Font.Bold = true;
        row.Shading.Color = TableBlue;

        for (int i = 0; i <= dt.Columns.Count - 1; i++)
        {
            row.Cells[i].AddParagraph(dt.Columns[i].ColumnName);
            row.Cells[i].Format.Font.Bold = true;
            row.Cells[i].Format.Font.Size = 8;
            row.Cells[i].Format.Alignment = ParagraphAlignment.Left;
            row.Cells[i].VerticalAlignment = VerticalAlignment.Center;
        }

        this.table.SetEdge(0, 0, dt.Columns.Count, 1, Edge.Box, BorderStyle.Single, 0.75, Color.Empty);
    }

    private void FillContent()
    {
        Paragraph paragraph = this.addressFrame.AddParagraph();

        Row row1 = default(Row);
        for (int i = 0; i <= dt.Rows.Count - 1; i++)
        {
            row1 = this.table.AddRow();
            row1.Format.Font.Size = 8;
            for (int j = 0; j <= dt.Columns.Count - 1; j++)
            {
                row1.Cells[j].Shading.Color = TableGray;
                row1.Cells[j].VerticalAlignment = VerticalAlignment.Center;
                row1.Cells[j].Format.Alignment = ParagraphAlignment.Left;
                row1.Cells[j].Format.FirstLineIndent = 1;
                row1.Cells[j].AddParagraph(dt.Rows[i][j].ToString());
                this.table.SetEdge(0, this.table.Rows.Count - 2, dt.Columns.Count, 1, Edge.Box, BorderStyle.Single, 0.75);
            }

        }

        // Add the notes paragraph
        paragraph = this.document.LastSection.AddParagraph();
        paragraph.Format.SpaceBefore = "1cm";
        paragraph.Format.Font.Size = 8;
        paragraph.Format.Font.Bold = true;
        paragraph.Format.Alignment = ParagraphAlignment.Right;
        //paragraph.AddText("Auto generated report from DMS");
    }

    static readonly Color TableBorder = new Color(81, 125, 192);
    static readonly Color TableBlue = new Color(176, 196, 231);
    static readonly Color TableGray = new Color(242, 242, 242);
}
