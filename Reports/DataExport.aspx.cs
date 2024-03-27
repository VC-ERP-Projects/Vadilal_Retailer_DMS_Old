using System;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Reports_DataExport : System.Web.UI.Page
{
    #region Declaration

    protected int UserID;
    public int CustType;
    public decimal ParentID;
    protected String AuthType, UserName;

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

                int lIndex = Request.ServerVariables["script_name"].ToString().LastIndexOf('/');
                string pagename = Request.ServerVariables["script_name"].ToString().Substring(lIndex + 1);
                var Auth = ctx.GRP1.Include("OMNU").FirstOrDefault(x => x.OMNU.PageName == pagename && x.EmpGroupID == EGID && x.ParentID == ParentID);
                if (Auth == null || Auth.AuthorizationType == "N")
                    Response.Redirect("~/AccessError.aspx");
                else if (!(CustType == 1 ? Auth.OMNU.Company : CustType == 2 ? Auth.OMNU.CMS : CustType == 3 ? Auth.OMNU.DMS : CustType == 4 ? Auth.OMNU.SS : false))
                    Response.Redirect("~/AccessError.aspx");
                else
                {
                    AuthType = Auth.AuthorizationType;

                    var UserType = Session["UserType"].ToString();
                    if (Auth.OMNU.MenuType.ToUpper() == "B" || UserType.ToUpper() == "B" || UserType.ToUpper() == Auth.OMNU.MenuType.ToUpper()) { }
                    else
                        Response.Redirect("~/AccessError.aspx");

                    UserName = ctx.OEMPs.Where(x => x.EmpID == UserID && x.ParentID == ParentID).Select(x => x.EmpCode + "," + x.Name).FirstOrDefault().ToString();
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

    public void ClearAllInputes()
    {
        using (DDMSEntities ctx = new DDMSEntities())
        {
            var Division = ctx.ODIVs.Where(x => x.Active).ToList();
            ddlDivision.DataSource = Division;
            ddlDivision.DataBind();
            ddlDivision.Items.Insert(0, new ListItem("---Select---", "0"));
            ddlDivision.SelectedValue = "3";
        }
        txtFromDate.Text = txtToDate.Text = Common.DateTimeConvert(DateTime.Now);
        acetxtName.ContextKey = (CustType + 1).ToString();
        txtDistCode.Text = txtDealerCode.Text = "";
    }
    #endregion

    #region PageLoad

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        if (!IsPostBack)
        {
            ClearAllInputes();
        }
        ScriptManager scriptManager = ScriptManager.GetCurrent(this.Page);
        scriptManager.RegisterPostBackControl(this.btnDetailData);
    }

    #endregion

    protected void btnDetailData_Click(object sender, EventArgs e)
    {
        try
        {
            DateTime FromDate = Convert.ToDateTime(txtFromDate.Text);
            DateTime ToDate = Convert.ToDateTime(txtToDate.Text);
            if ((ToDate - FromDate).TotalDays >= 31)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Date difference should be only 31 days.',3);", true);
                return;
            }
            Decimal SSID = Decimal.TryParse(txtSSDistCode.Text.Split("-".ToArray()).Last().Trim(), out SSID) ? SSID : 0;
            Decimal DistributorID = Decimal.TryParse(txtDistCode.Text.Split("-".ToArray()).Last().Trim(), out DistributorID) ? DistributorID : 0;
            Decimal DealerID = Decimal.TryParse(txtDealerCode.Text.Split("-".ToArray()).Last().Trim(), out DealerID) ? DealerID : 0;
            Int32 RegionID = Int32.TryParse(txtRegion.Text.Split("-".ToArray()).Last().Trim(), out RegionID) ? RegionID : 0;
            Int32 PlantID = Int32.TryParse(txtPlant.Text.Split("-".ToArray()).Last().Trim(), out PlantID) ? PlantID : 0;
            Int32 InvPlant = Int32.TryParse(txtInvPlant.Text.Split("-".ToArray()).Last().Trim(), out InvPlant) ? InvPlant : 0;
            Int32 ItemGroupID = Int32.TryParse(txtGroup.Text.Split("-".ToArray()).First().Trim(), out ItemGroupID) ? ItemGroupID : 0;
            Int32 ItemSubGroupID = Int32.TryParse(txtSubGroup.Text.Split("-".ToArray()).First().Trim(), out ItemSubGroupID) ? ItemSubGroupID : 0;
            Int32 SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;

            using (DDMSEntities ctx = new DDMSEntities())
            {
                if (ddlReportBy.SelectedValue == "2" && DistributorID > 0 && ddlPurFrom.SelectedValue != "2" && ctx.OCRDs.Any(x => x.CustomerID == DistributorID && x.ParentID != 1000010000000000))
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Selected Distributor is under Super Stockist. Please select Purchase From as Super Stockist to Distributor',3);", true);
                    return;
                }
            }

            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();
            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "SalepurchaseSummaryRecord";
            Cm.Parameters.AddWithValue("@EmpID", UserID);
            Cm.Parameters.AddWithValue("@ParentID", ParentID);
            Cm.Parameters.AddWithValue("@SUserID", SUserID);
            Cm.Parameters.AddWithValue("@Type", ddlType.SelectedValue);
            Cm.Parameters.AddWithValue("@DivisionID", ddlDivision.SelectedValue);
            Cm.Parameters.AddWithValue("@RegionID", RegionID);
            Cm.Parameters.AddWithValue("@PlantID", PlantID);
            Cm.Parameters.AddWithValue("@InvPlantID", InvPlant);
            Cm.Parameters.AddWithValue("@SSID", SSID);
            Cm.Parameters.AddWithValue("@DistributorID", DistributorID);
            Cm.Parameters.AddWithValue("@DealerID", DealerID);
            Cm.Parameters.AddWithValue("@itemGroupID", ItemGroupID);
            Cm.Parameters.AddWithValue("@ItemSubGroupID", ItemSubGroupID);
            Cm.Parameters.AddWithValue("@FromDate", FromDate);
            Cm.Parameters.AddWithValue("@ToDate", ToDate);
            Cm.Parameters.AddWithValue("@SaleFrom", ddlSaleFrom.SelectedValue);
            Cm.Parameters.AddWithValue("@PurchaseFrom", ddlPurFrom.SelectedValue);
            Cm.Parameters.AddWithValue("@ReportBy", ddlReportBy.SelectedValue);
            Cm.Parameters.AddWithValue("@DateType", ddlDateOption.SelectedValue);

            Response.Clear();
            Response.Buffer = true;
            Response.ClearContent();
            IDataReader reader = objClass.CommonFunctionForSelectDR(Cm);
            StringWriter writer = new StringWriter();

            writer.WriteLine(ddlType.SelectedItem.Text + " Data Export ,");
            writer.WriteLine("Report Of ," + ddlReportBy.SelectedItem.Text);
            writer.WriteLine("Employee ," + (SUserID != 0 ? txtCode.Text.Split('-')[0].ToString() + "," + txtCode.Text.Split('-')[1].ToString() : ""));
            writer.WriteLine("From Date ," + txtFromDate.Text + ",");
            writer.WriteLine("To Date ," + txtToDate.Text);
            writer.WriteLine("Region ," + (RegionID != 0 ? txtRegion.Text.Split('-')[1].ToString() : "All Region"));
            //writer.WriteLine("Plant ," + (PlantID != 0 ? txtPlant.Text.Split('-')[0].ToString() + "," + txtPlant.Text.Split('-')[1].ToString() : "All Plant"));
            if (ddlReportBy.SelectedValue == "4")
                writer.WriteLine("Super Stockist ," + (SSID != 0 ? txtSSDistCode.Text.Split('-')[0].ToString() + "," + txtSSDistCode.Text.Split('-')[1].ToString() : "All Super Stockist"));
            writer.WriteLine("Distributor ," + (DistributorID != 0 ? txtDistCode.Text.Split('-')[0].ToString() + "," + txtDistCode.Text.Split('-')[1].ToString() : "All Distributors"));
            if (ddlReportBy.SelectedValue == "2")
                writer.WriteLine("Dealer ," + (DealerID != 0 ? txtDealerCode.Text.Split('-')[0].ToString() + "," + txtDealerCode.Text.Split('-')[1].ToString() : "All Dealer"));
            writer.WriteLine("Division ," + ddlDivision.SelectedItem.Text);
            //writer.WriteLine("Sale From ," + ddlSaleFrom.SelectedItem.Text);
            writer.WriteLine("Item Group ," + (ItemGroupID != 0 ? txtGroup.Text.Split('-')[0].ToString() + "," + txtGroup.Text.Split('-')[1].ToString() : "All Item Group"));
            writer.WriteLine("Item SubGroup ," + (ItemSubGroupID != 0 ? txtSubGroup.Text.Split('-')[0].ToString() + "," + txtSubGroup.Text.Split('-')[1].ToString() : "All Item SubGroup"));
            writer.WriteLine("User ," + UserName);
            writer.WriteLine("Created On ," + DateTime.Now);

            do
            {
                writer.WriteLine(string.Join(",", Enumerable.Range(0, reader.FieldCount).Select(reader.GetName).ToList()));
                int count = 0;
                while (reader.Read())
                {
                    writer.WriteLine(string.Join(",", Enumerable.Range(0, reader.FieldCount).Select(reader.GetValue).ToList()));
                    if (++count % 100 == 0)
                    {
                        writer.Flush();
                    }
                }
            }
            while (reader.NextResult());

            Response.AddHeader("content-disposition", "attachment; filename=DataExport_" + ddlType.SelectedItem.Text + "_" + DateTime.Now.ToString("ddMMyyyyhhmmss") + ".csv");
            Response.ContentType = "application/txt";
            Response.Write(writer.ToString());
            Response.Flush();
            Response.End();
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + Common.GetString(ex) + "',2);", true);

        }

    }

}