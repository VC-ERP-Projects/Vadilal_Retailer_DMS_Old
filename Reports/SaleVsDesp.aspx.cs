using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Reports_SaleVsDesp : System.Web.UI.Page
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

    #endregion

    #region Page Load
    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        if (!IsPostBack)
        {
            txtToDate.Text = txtFromDate.Text = Common.DateTimeConvert(DateTime.Now);
            using (DDMSEntities ctx = new DDMSEntities())
            {
                var Division = ctx.ODIVs.Where(x => x.Active).ToList();
                ddlDivision.DataSource = Division;
                ddlDivision.DataBind();
                ddlDivision.Items.Insert(0, new ListItem("---Select---", "0"));
                ddlDivision.SelectedValue = "3";
            }

            if (CustType == 4)
            {
                divRegion.Attributes.Add("style", "display:none;");
                divEmpCode.Attributes.Add("style", "display:none;");
                ddlSaleBy.SelectedValue = "4";
                txtSSDistCode.Enabled = ddlSaleBy.Enabled = false;
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    var Data = ctx.OCRDs.Where(x => x.CustomerID == ParentID).Select(x => new { x.CustomerID, x.CustomerCode, CustomerName = x.CustomerName.Replace("-", "") }).FirstOrDefault();
                    txtSSDistCode.Text = Data.CustomerCode + " - " + Data.CustomerName + " - " + Data.CustomerID;
                }
            }
            else if (CustType == 2)
            {
                divRegion.Attributes.Add("style", "display:none;");
                divEmpCode.Attributes.Add("style", "display:none;");
                divSS.Attributes.Add("style", "display:none;");
                txtRegion.Style.Add("display", "none");
                ddlSaleBy.SelectedValue = "2";
                txtDistCode.Enabled = ddlSaleBy.Enabled = false;
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    var Data = ctx.OCRDs.Where(x => x.CustomerID == ParentID).Select(x => new { x.CustomerID, x.CustomerCode, CustomerName = x.CustomerName.Replace("-", "") }).FirstOrDefault();
                    txtDistCode.Text = Data.CustomerCode + " - " + Data.CustomerName + " - " + Data.CustomerID;
                }
            }
        }
        ScriptManager scriptManager = ScriptManager.GetCurrent(this.Page);
        scriptManager.RegisterPostBackControl(this.btnGenerat);
    }
    #endregion Page Load

    protected void btnGenerat_Click(object sender, EventArgs e)
    {
        DateTime StartDate = Convert.ToDateTime(txtFromDate.Text);
        DateTime EndDate = Convert.ToDateTime(txtToDate.Text);
        Decimal SSID = Decimal.TryParse(txtSSDistCode.Text.Split("-".ToArray()).Last().Trim(), out SSID) ? SSID : 0;
        Decimal DistributorID = Decimal.TryParse(txtDistCode.Text.Split("-".ToArray()).Last().Trim(), out DistributorID) ? DistributorID : 0;
        Decimal DealerID = Decimal.TryParse(txtDealerCode.Text.Split("-".ToArray()).Last().Trim(), out DealerID) ? DealerID : 0;
        Int32 RegionID = Int32.TryParse(txtRegion.Text.Split("-".ToArray()).Last().Trim(), out RegionID) ? RegionID : 0;
        Int32 SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;

        //if (!string.IsNullOrEmpty(txtCode.Text) && SUserID == 0)
        //{
        //    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper User.',3);", true);
        //    return;
        //}

        if (SSID == 0 && DistributorID == 0 && DealerID == 0 && RegionID == 0 && SUserID == 0 && (EndDate - StartDate).TotalDays > 30)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('You have to select at least one parameter due to Date Range.',3);", true);
            return;
        }

        try
        {
            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();

            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "SaleVsDispatch";

            Cm.Parameters.AddWithValue("@FromDate", StartDate);
            Cm.Parameters.AddWithValue("@ToDate", EndDate);
            Cm.Parameters.AddWithValue("@SSID", SSID);
            Cm.Parameters.AddWithValue("@DealerID", DealerID);
            Cm.Parameters.AddWithValue("@DistributorID", DistributorID);
            Cm.Parameters.AddWithValue("@RegionID", RegionID);
            Cm.Parameters.AddWithValue("@SUserID", SUserID);
            Cm.Parameters.AddWithValue("@ParentID", ParentID);
            Cm.Parameters.AddWithValue("@EmpID", UserID);
            Cm.Parameters.AddWithValue("@SaleBy", ddlSaleBy.SelectedValue);
            Cm.Parameters.AddWithValue("@DivisionID", ddlDivision.SelectedValue);
            Cm.Parameters.AddWithValue("@DateType", ddlDateOption.SelectedValue);
            Cm.Parameters.AddWithValue("@CreatedBy", chkCreatedBy.Checked);
            Cm.Parameters.AddWithValue("@ReportType", ddlReportType.SelectedValue);
            Cm.Parameters.AddWithValue("@DealerType", ddlDealer.SelectedValue);

            Response.Clear();
            Response.Buffer = true;
            Response.ClearContent();
            IDataReader reader = objClass.CommonFunctionForSelectDR(Cm);
            StringWriter writer = new StringWriter();

            writer.WriteLine("Order Vs Despatch ,");
            writer.WriteLine("From Date ,'" + DateTime.Parse(txtFromDate.Text).ToString("dd-MMM-yy") + ",");
            writer.WriteLine("To Date ,'" + DateTime.Parse(txtToDate.Text).ToString("dd-MMM-yy"));
            writer.WriteLine("Date Option ," + ddlDateOption.SelectedItem.Text);
            writer.WriteLine("Division ," + ddlDivision.SelectedItem.Text);
            writer.WriteLine("Region ," + (RegionID != 0 ? txtRegion.Text.Split('-')[1].ToString() : "All"));
            writer.WriteLine("Sale By ," + ddlSaleBy.SelectedItem.Text);
            writer.WriteLine("Report Type ," + ddlReportType.SelectedItem.Text);
            if (ddlSaleBy.SelectedValue == "4")
                writer.WriteLine("Super Stockist ," + (SSID != 0 ? txtSSDistCode.Text.Split('-')[0].ToString() + "," + txtSSDistCode.Text.Split('-')[1].ToString() : "All"));
            writer.WriteLine("Distributor ," + (DistributorID != 0 ? txtDistCode.Text.Split('-')[0].ToString() + "," + txtDistCode.Text.Split('-')[1].ToString() : "All"));
            if (ddlSaleBy.SelectedValue == "2")
                writer.WriteLine("Dealer ," + (DealerID != 0 ? txtDealerCode.Text.Split('-')[0].ToString() + "," + txtDealerCode.Text.Split('-')[1].ToString() : "All"));
            writer.WriteLine("Employee ," + (SUserID != 0 ? txtCode.Text.Split('-')[0].ToString() + "," + txtCode.Text.Split('-')[1].ToString() : "All"));
            writer.WriteLine("User ," + UserName);
            writer.WriteLine("Created On ,'" + DateTime.Now.ToString("dd-MMM-yy hh:mm"));
            writer.WriteLine("Dealer ," + ddlDealer.SelectedItem.Text);

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

            Response.AddHeader("content-disposition", "attachment; filename=OrderVsDespatch_" + DateTime.Now.ToString("ddMMyyyyhhmmss") + ".csv");
            Response.ContentType = "application/txt";
            Response.Write(writer.ToString());
            Response.Flush();
            Response.End();


            //if (ds.Tables[0].Rows.Count > 0)
            //{
            //    Response.Clear();
            //    Response.Buffer = true;
            //    Response.ClearContent();
            //    Response.AddHeader("content-disposition", "attachment; filename=SaleVsDespatch_" + DateTime.Now.ToString("ddMMyyyyhhmmss") + ".xls");
            //    //Response.ContentType = "application/vnd.ms-excel";
            //    Response.ContentType = "application/excel";

            //    GridView excel = new GridView();
            //    excel.DataSource = ds.Tables[0];
            //    excel.DataBind();
            //    StringWriter sw = new StringWriter();
            //    HtmlTextWriter htw = new HtmlTextWriter(sw);
            //    excel.RenderControl(htw);
            //    string style = @"<style> td { mso-number-format:\@;} </style>";
            //    Response.Write(style);
            //    Response.Write(sw.ToString());
            //    Response.Flush();
            //    Response.End();
            //}
            //else
            //    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('No Data Found.',3);", true);
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + Common.GetString(ex) + "',2);", true);
        }
    }

    protected void gvSalevsDispatch_PreRender(object sender, EventArgs e)
    {
        if (gvSalevsDispatch.Rows.Count > 0)
        {
            gvSalevsDispatch.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvSalevsDispatch.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }
}