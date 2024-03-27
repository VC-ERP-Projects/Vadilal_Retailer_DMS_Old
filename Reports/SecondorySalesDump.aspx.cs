using ClosedXML.Excel;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Reports_SecondorySalesDump : System.Web.UI.Page
{
    #region Declaration

    protected int UserID;
    public int CustType;
    public decimal ParentID;
    protected String AuthType;
    protected String Version;
    protected String LogoURL;
    #endregion

    #region Helper Method

    public void ValidateUser()
    {
        if (Session["UserID"] != null && Session["ParentID"] != null &&
          Int32.TryParse(Session["UserID"].ToString(), out UserID) && Decimal.TryParse(Session["ParentID"].ToString(), out ParentID))
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                int EGID = Convert.ToInt32(Session["GroupID"]);
                CustType = Convert.ToInt32(Session["Type"]);
                Version = Convert.ToString(ConfigurationManager.AppSettings["Version"]);
                LogoURL = Common.GetLogo(ParentID);
                int lIndex = Request.ServerVariables["script_name"].ToString().LastIndexOf('/');
                string pagename = Request.ServerVariables["script_name"].ToString().Substring(lIndex + 1);
                var Auth = ctx.GRP1.Include("OMNU").FirstOrDefault(x => x.OMNU.PageName == pagename && x.EmpGroupID == EGID && x.ParentID == ParentID);
                if (Auth == null || Auth.AuthorizationType == "N")
                    Response.Redirect("~/AccessError.aspx");
                else if (!(CustType == 1 ? Auth.OMNU.Company : CustType == 2 ? Auth.OMNU.CMS : CustType == 3 ? Auth.OMNU.DMS : CustType == 4 ? Auth.OMNU.SS : false))
                    Response.Redirect("~/AccessError.aspx");
                else
                {
                    hdnUserName.Value = ctx.OEMPs.Where(x => x.EmpID == UserID && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault().ToString();
                    AuthType = Auth.AuthorizationType;

                    var UserType = Session["UserType"].ToString();
                    if (Auth.OMNU.MenuType.ToUpper() == "B" || UserType.ToUpper() == "B" || UserType.ToUpper() == Auth.OMNU.MenuType.ToUpper()) { }
                    else
                        Response.Redirect("~/AccessError.aspx");

                    if (Session["Lang"] != null && Session["Lang"].ToString() == "gujarati")
                    {
                        try
                        {
                            var xml = XDocument.Load(Server.MapPath("../Document/forlanguage.xml"));
                            var unit = xml.Descendants("reports");
                            if (unit != null)
                            {
                                var ctrls = Common.GetAll(this, typeof(Label));
                                foreach (Label item in ctrls)
                                {
                                    if (unit.Elements().Any(x => x.Name == item.ID))
                                        item.Text = unit.Elements().FirstOrDefault(x => x.Name == item.ID).Value;
                                }
                            }
                        }
                        catch (Exception)
                        { }
                    }
                }
            }
        }
        else
        {
            Response.Redirect("~/Login.aspx");
        }
    }

    public void ClearAllInputs()
    {
        txtToDate.Text = txtFromDate.Text = Common.DateTimeConvert(DateTime.Now);
        //ddlDocType.Items.Insert(0, new ListItem("----Select----", "0"));
        //ddlDocType.DataBind();
        if (CustType == 4) // SS
        {
            divEmpCode.Attributes.Add("style", "display:none;");
            divDealer.Attributes.Add("style", "display:none;");
            ddlSaleBy.SelectedValue = "4";
            txtSSDistCode.Enabled = ddlSaleBy.Enabled = false;
            using (DDMSEntities ctx = new DDMSEntities())
            {
                var SS = ctx.OCRDs.Where(x => x.CustomerID == ParentID).Select(x => new { x.CustomerID, x.CustomerCode, CustomerName = x.CustomerName.Replace("-", "") }).FirstOrDefault();
                txtSSDistCode.Text = SS.CustomerCode + " - " + SS.CustomerName + " - " + SS.CustomerID;
            }
        }
        else if (CustType == 2)// Distributor
        {
            divEmpCode.Attributes.Add("style", "display:none;");
            divSS.Attributes.Add("style", "display:none;");
            ddlSaleBy.SelectedValue = "2";
            txtDistCode.Enabled = ddlSaleBy.Enabled = false;
            using (DDMSEntities ctx = new DDMSEntities())
            {
                var Data = ctx.OCRDs.Where(x => x.CustomerID == ParentID).Select(x => new { x.CustomerID, x.CustomerCode, CustomerName = x.CustomerName.Replace("-", "") }).FirstOrDefault();
                txtDistCode.Text = Data.CustomerCode + " - " + Data.CustomerName + " - " + Data.CustomerID;
            }
        }
    }

    #endregion

    #region PageLoad

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        if (!IsPostBack)
        {
            ClearAllInputs();
        }
        ScriptManager scriptManager = ScriptManager.GetCurrent(this.Page);
        scriptManager.RegisterPostBackControl(this.btnGenerat);
        //txtFromDate.Text = txtToDate.Text = "01/02/2020";
        //txtCode.Text = "21200420 - RASESH SHUKLA - 71";
        //txtDistCode.Text = "DABS9440 - SAGAR CORP. [I/C DIST] BAPUNAGAR - 2000010000100000";
    }

    #endregion



    #region Button Events
    protected void btnGenerat_Click(object sender, EventArgs e)
    {
        try
        {
            int CustType = Convert.ToInt32(Session["Type"]);
            int UserID = Convert.ToInt32(Session["UserID"].ToString());
            decimal ParentID = Convert.ToDecimal(Session["ParentID"].ToString());
            DateTime StartDate = Convert.ToDateTime(txtFromDate.Text);
            DateTime EndDate = Convert.ToDateTime(txtToDate.Text);
            Decimal SSID = 0;
            Decimal DistributorID = Decimal.TryParse(txtDistCode.Text.Split("-".ToArray()).Last().Trim(), out DistributorID) ? DistributorID : 0;
            Decimal DealerID = Decimal.TryParse(txtDealerCode.Text.Split("-".ToArray()).Last().Trim(), out DealerID) ? DealerID : 0;
            Int32 SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;

            Int32 RegionId = Int32.TryParse(txtRegion.Text.Split("-".ToArray()).Last().Trim(), out RegionId) ? RegionId : 0;

            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();
            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "SecondorySalesDump";
            Cm.Parameters.AddWithValue("@EmpID", UserID);
            Cm.Parameters.AddWithValue("@SUserID", SUserID);
            Cm.Parameters.AddWithValue("@ParentID", ParentID);
            Cm.Parameters.AddWithValue("@FromDate", StartDate.ToString("yyyyMMdd"));
            Cm.Parameters.AddWithValue("@ToDate", EndDate.ToString("yyyyMMdd"));
            Cm.Parameters.AddWithValue("@SSID", SSID);
            Cm.Parameters.AddWithValue("@DistributorID", DistributorID);
            Cm.Parameters.AddWithValue("@DealerID", DealerID);
            Cm.Parameters.AddWithValue("@DocType", ddlDocType.SelectedValue);
            Cm.Parameters.AddWithValue("@SaleBy", ddlSaleBy.SelectedValue);
            Cm.Parameters.AddWithValue("@RegionId", RegionId);
            DataSet Ds = objClass.CommonFunctionForSelect(Cm);
            if (Ds.Tables.Count > 0)
            {
                using (XLWorkbook wb = new XLWorkbook())
                {
                    //wb.Worksheets.Add(Ds.Tables[0], "Customers");
                    var ws = wb.Worksheets.Add("Sales Data");
                    ws.Cell("A1").Value = "From Date";
                    ws.Cell("A2").Value = "To Date";
                    ws.Cell("A3").Value = "Invoice Type";
                    ws.Cell("A4").Value = "Employee";
                    ws.Cell("A5").Value = "Region";
                    ws.Cell("A6").Value = "Distributor";
                    ws.Cell("A7").Value = "Dealer";
                    //ws.Cell("A1").Style.Font.Bold = true;
                    ws.Cell("B1").Value = Convert.ToDateTime(txtFromDate.Text).ToString("dd-MMM-yyyy");
                    ws.Cell("B2").Value = Convert.ToDateTime(txtToDate.Text).ToString("dd-MMM-yyyy");
                    ws.Cell("B3").Value = ddlDocType.SelectedItem.ToString();
                    ws.Cell("B4").Value = txtCode.Text == "" ? "All" : txtCode.Text.Split("-".ToArray())[0].ToString() + " - " + txtCode.Text.Split("-".ToArray())[1].ToString();
                    ws.Cell("B5").Value = txtRegion.Text == "" ? "All" : txtRegion.Text.Split("-".ToArray())[0].ToString() + " - " + txtRegion.Text.Split("-".ToArray())[1].ToString();
                    ws.Cell("B6").Value = txtDistCode.Text == "" ? "All" : txtDistCode.Text.Split("-".ToArray())[0].ToString() +" - "+ txtDistCode.Text.Split("-".ToArray())[1].ToString();
                    ws.Cell("B7").Value = txtDealerCode.Text == "" ? "All" : txtDealerCode.Text.Split("-".ToArray())[0].ToString() + " - " + txtDealerCode.Text.Split("-".ToArray())[1].ToString();

                    if (Ds.Tables[0].Rows.Count > 0)
                    {

                        ws.Cell("A9").Value = Ds.Tables[0].Columns[0].ColumnName;
                        ws.Cell("B9").Value = Ds.Tables[0].Columns[1].ColumnName;
                        ws.Cell("C9").Value = Ds.Tables[0].Columns[2].ColumnName;
                        ws.Cell("D9").Value = Ds.Tables[0].Columns[3].ColumnName;
                        ws.Cell("E9").Value = Ds.Tables[0].Columns[4].ColumnName;
                        ws.Cell("F9").Value = Ds.Tables[0].Columns[5].ColumnName;
                        ws.Cell("G9").Value = Ds.Tables[0].Columns[6].ColumnName;
                        ws.Cell("H9").Value = Ds.Tables[0].Columns[7].ColumnName;
                        ws.Cell("I9").Value = Ds.Tables[0].Columns[8].ColumnName;
                        ws.Cell("J9").Value = Ds.Tables[0].Columns[9].ColumnName;
                        ws.Cell("K9").Value = Ds.Tables[0].Columns[10].ColumnName;
                        ws.Cell("L9").Value = Ds.Tables[0].Columns[11].ColumnName;
                        ws.Cell("M9").Value = Ds.Tables[0].Columns[12].ColumnName;
                        ws.Cell("N9").Value = Ds.Tables[0].Columns[13].ColumnName;
                        ws.Cell("O9").Value = Ds.Tables[0].Columns[14].ColumnName;
                        ws.Cell("P9").Value = Ds.Tables[0].Columns[15].ColumnName;
                        ws.Cell("Q9").Value = Ds.Tables[0].Columns[16].ColumnName;
                        ws.Cell("R9").Value = Ds.Tables[0].Columns[17].ColumnName;
                        ws.Cell("S9").Value = Ds.Tables[0].Columns[18].ColumnName;
                        ws.Cell("T9").Value = Ds.Tables[0].Columns[19].ColumnName;
                        ws.Cell("U9").Value = Ds.Tables[0].Columns[20].ColumnName;
                        ws.Cell("V9").Value = Ds.Tables[0].Columns[21].ColumnName;
                        ws.Cell("W9").Value = Ds.Tables[0].Columns[22].ColumnName;
                        ws.Cell("X9").Value = Ds.Tables[0].Columns[23].ColumnName;
                        ws.Cell("Y9").Value = Ds.Tables[0].Columns[24].ColumnName;
                        ws.Cell("Z9").Value = Ds.Tables[0].Columns[25].ColumnName;
                        ws.Cell("AA9").Value = Ds.Tables[0].Columns[26].ColumnName;
                        ws.Cell("AB9").Value = Ds.Tables[0].Columns[27].ColumnName;
                        ws.Cell("AC9").Value = Ds.Tables[0].Columns[28].ColumnName;
                        ws.Cell("AD9").Value = Ds.Tables[0].Columns[29].ColumnName;
                        ws.Cell("AE9").Value = Ds.Tables[0].Columns[30].ColumnName;
                        ws.Cell("AF9").Value = Ds.Tables[0].Columns[31].ColumnName;
                        ws.Cell("AG9").Value = Ds.Tables[0].Columns[32].ColumnName;
                        ws.Cell("AH9").Value = Ds.Tables[0].Columns[33].ColumnName;
                        ws.Cell("AI9").Value = Ds.Tables[0].Columns[34].ColumnName;
                        ws.Cell("AJ9").Value = Ds.Tables[0].Columns[35].ColumnName;
                        ws.Cell("AK9").Value = Ds.Tables[0].Columns[36].ColumnName;
                        ws.Cell("AL9").Value = Ds.Tables[0].Columns[37].ColumnName;
                        ws.Cell("AM9").Value = Ds.Tables[0].Columns[38].ColumnName;
                        ws.Cell("AN9").Value = Ds.Tables[0].Columns[39].ColumnName;
                        ws.Cell("AO9").Value = Ds.Tables[0].Columns[40].ColumnName;
                        ws.Cell("AP9").Value = Ds.Tables[0].Columns[41].ColumnName;
                        ws.Cell("AQ9").Value = Ds.Tables[0].Columns[42].ColumnName;
                        ws.Cell("AR9").Value = Ds.Tables[0].Columns[43].ColumnName;
                        ws.Cell("AS9").Value = Ds.Tables[0].Columns[44].ColumnName;
                        ws.Cell("AT9").Value = Ds.Tables[0].Columns[45].ColumnName;
                         
                        // Adding DataRows.
                        for (int i = 0; i < Ds.Tables[0].Rows.Count; i++)
                        {
                            ws.Cell("A" + (i + 10)).Value = Ds.Tables[0].Rows[i][0];
                            ws.Cell("B" + (i + 10)).Value = Ds.Tables[0].Rows[i][1];
                            ws.Cell("C" + (i + 10)).Value = Ds.Tables[0].Rows[i][2];
                            ws.Cell("D" + (i + 10)).Value = Ds.Tables[0].Rows[i][3];
                            ws.Cell("E" + (i + 10)).Value = Ds.Tables[0].Rows[i][4];
                            ws.Cell("F" + (i + 10)).Value = Ds.Tables[0].Rows[i][5];
                            ws.Cell("G" + (i + 10)).Value = Ds.Tables[0].Rows[i][6];
                            ws.Cell("H" + (i + 10)).Value = Ds.Tables[0].Rows[i][7];
                            ws.Cell("I" + (i + 10)).Value = Ds.Tables[0].Rows[i][8];
                            ws.Cell("J" + (i + 10)).Value = Ds.Tables[0].Rows[i][9];
                            ws.Cell("K" + (i + 10)).Value = Ds.Tables[0].Rows[i][10];
                            ws.Cell("L" + (i + 10)).Value = Ds.Tables[0].Rows[i][11];
                            ws.Cell("M" + (i + 10)).Value = Ds.Tables[0].Rows[i][12];
                            ws.Cell("N" + (i + 10)).Value = Ds.Tables[0].Rows[i][13];
                            ws.Cell("O" + (i + 10)).Value = Ds.Tables[0].Rows[i][14];
                            ws.Cell("P" + (i + 10)).Value = Ds.Tables[0].Rows[i][15];
                            ws.Cell("Q" + (i + 10)).Value = Ds.Tables[0].Rows[i][16];
                            ws.Cell("R" + (i + 10)).Value = Ds.Tables[0].Rows[i][17];
                            ws.Cell("S" + (i + 10)).Value = Ds.Tables[0].Rows[i][18];
                            ws.Cell("T" + (i + 10)).Value = Ds.Tables[0].Rows[i][19];
                            ws.Cell("U" + (i + 10)).Value = Ds.Tables[0].Rows[i][20];
                            ws.Cell("V" + (i + 10)).Value = Ds.Tables[0].Rows[i][21];
                            ws.Cell("W" + (i + 10)).Value = Ds.Tables[0].Rows[i][22];
                            ws.Cell("X" + (i + 10)).Value = Ds.Tables[0].Rows[i][23];
                            ws.Cell("Y" + (i + 10)).Value = Ds.Tables[0].Rows[i][24];
                            ws.Cell("Z" + (i + 10)).Value = Ds.Tables[0].Rows[i][25];
                            ws.Cell("AA" + (i + 10)).Value = Ds.Tables[0].Rows[i][26];
                            ws.Cell("AB" + (i + 10)).Value = Ds.Tables[0].Rows[i][27];
                            ws.Cell("AC" + (i + 10)).Value = Ds.Tables[0].Rows[i][28];
                            ws.Cell("AD" + (i + 10)).Value = Ds.Tables[0].Rows[i][29];
                            ws.Cell("AE" + (i + 10)).Value = Ds.Tables[0].Rows[i][30];
                            ws.Cell("AF" + (i + 10)).Value = Ds.Tables[0].Rows[i][31];
                            ws.Cell("AG" + (i + 10)).Value = Ds.Tables[0].Rows[i][32];
                            ws.Cell("AH" + (i + 10)).Value = Ds.Tables[0].Rows[i][33];
                            ws.Cell("AI" + (i + 10)).Value = Ds.Tables[0].Rows[i][34];
                            ws.Cell("AJ" + (i + 10)).Value = Ds.Tables[0].Rows[i][35];
                            ws.Cell("AK" + (i + 10)).Value = Ds.Tables[0].Rows[i][36];
                            ws.Cell("AL" + (i + 10)).Value = Ds.Tables[0].Rows[i][37];
                            ws.Cell("AM" + (i + 10)).Value = Ds.Tables[0].Rows[i][38];
                            ws.Cell("AN" + (i + 10)).Value = Ds.Tables[0].Rows[i][39];
                            ws.Cell("AO" + (i + 10)).Value = Ds.Tables[0].Rows[i][40];
                            ws.Cell("AP" + (i + 10)).Value = Ds.Tables[0].Rows[i][41];
                            ws.Cell("AQ" + (i + 10)).Value = Ds.Tables[0].Rows[i][42];
                            ws.Cell("AR" + (i + 10)).Value = Ds.Tables[0].Rows[i][43];
                            ws.Cell("AS" + (i + 10)).Value = Ds.Tables[0].Rows[i][44];
                            ws.Cell("AT" + (i + 10)).Value = Ds.Tables[0].Rows[i][45];
                        }
                    }

                    ws.Column(2).AdjustToContents();
                    ws.Column(3).AdjustToContents();

                    string Filename = DateTime.Now.ToString("yyyyMMddHHmmss") + ".xlsx";
                    Response.Clear();
                    Response.Buffer = true;
                    Response.Charset = "";
                    Response.ContentType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
                    Response.AddHeader("content-disposition", "attachment;filename=" + Filename);
                    using (MemoryStream MyMemoryStream = new MemoryStream())
                    {
                        
                        // Adding HeaderRow.
                       
                        wb.SaveAs(MyMemoryStream);
                        MyMemoryStream.WriteTo(Response.OutputStream);
                        Response.Flush();
                        Response.End();
                    }


                 
                   
                }
            }
        }
        catch (Exception ex)
        {

        }
    }
    #endregion
}