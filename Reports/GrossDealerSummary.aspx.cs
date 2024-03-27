using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Reports_GrossDealerSummary : System.Web.UI.Page
{

    #region Declaration

    string CustomerCode, CustomerIDs;
    Decimal DecNum;
    protected int UserID, CustType;
    protected decimal ParentID;
    protected String AuthType;
    DDMSEntities ctx;
    protected String Version;
    protected String LogoURL;
    #endregion

    #region Helper Method

    public void ValidateUser()
    {
        if (Session["UserID"] != null && Session["ParentID"] != null &&
          Int32.TryParse(Session["UserID"].ToString(), out UserID) && Decimal.TryParse(Session["ParentID"].ToString(), out ParentID))
        {
            ctx = new DDMSEntities();
            int EGID = Convert.ToInt32(Session["GroupID"]);
            CustType = Convert.ToInt32(Session["Type"]);
            Version = Convert.ToString(ConfigurationManager.AppSettings["Version"]);
            //  LogoURL = Common.GetLogo(ParentID);
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

                hdnUserName.Value = ctx.OEMPs.Where(x => x.EmpID == UserID && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault().ToString();
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
        else
        {
            Response.Redirect("~/Login.aspx");
        }
    }

    public void ClearAllInputs()
    {
        gvParlourScheme.Visible = gvMachineScheme.Visible = gvMasterScheme.Visible = gvRateDiff.Visible = gvQPSScheme.Visible = gvSecondTrans.Visible = gvFOWScheme.Visible = gvVRSDiscount.Visible = gvIOUClaim.Visible = gvSTODClaim.Visible = false;

        gvMasterScheme.DataSource = null;
        gvMasterScheme.DataBind();

        gvRateDiff.DataSource = null;
        gvRateDiff.DataBind();

        gvMachineScheme.DataSource = null;
        gvMachineScheme.DataBind();

        gvQPSScheme.DataSource = null;
        gvQPSScheme.DataBind();

        gvParlourScheme.DataSource = null;
        gvParlourScheme.DataBind();

        gvVRSDiscount.DataSource = null;
        gvVRSDiscount.DataBind();

        gvSecondTrans.DataSource = null;
        gvSecondTrans.DataBind();

        gvFOWScheme.DataSource = null;
        gvFOWScheme.DataBind();

        gvIOUClaim.DataSource = null;
        gvIOUClaim.DataBind();

        gvSTODClaim.DataSource = null;
        gvSTODClaim.DataBind();
    }

    #endregion

    #region PageLoad

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();

        if (!IsPostBack)
        {
            txtToDate.Text = txtFromDate.Text = Common.DateTimeConvert(DateTime.Now);
            txtSSCode.Text = txtDistCode.Text = txtDealerCode.Text = "";

            if (CustType == 4) // SS
            {
                divDealer.Attributes.Add("style", "display:none;");
                ddlSaleBy.SelectedValue = "4";
                txtSSCode.Enabled = ddlSaleBy.Enabled = false;
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    var SS = ctx.OCRDs.Where(x => x.CustomerID == ParentID).Select(x => new { x.CustomerID, x.CustomerCode, CustomerName = x.CustomerName.Replace("-", "") }).FirstOrDefault();
                    txtSSCode.Text = SS.CustomerCode + " - " + SS.CustomerName + " - " + SS.CustomerID;
                }
            }
            else if (CustType == 2) // Distributor
            {
                divSS.Attributes.Add("style", "display:none;");
                ddlSaleBy.SelectedValue = "2";
                txtDistCode.Enabled = ddlSaleBy.Enabled = false;
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    var Data = ctx.OCRDs.Where(x => x.CustomerID == ParentID).Select(x => new { x.CustomerID, x.CustomerCode, CustomerName = x.CustomerName.Replace("-", "") }).FirstOrDefault();
                    txtDistCode.Text = Data.CustomerCode + " - " + Data.CustomerName + " - " + Data.CustomerID;
                }
            }

            ClearAllInputs();


        }
        // txtDistCode.Text = "DABS9440 - SAGAR CORP. [I/C DIST] BAPUNAGAR - 2000010000100000";
        //// txtDistCode.Text = "DOGSZD68 - SHEKHAR CONFECTIONERY   BILASPUR - 2012640000100000";
        //// txtDistCode.Text = "DOGANR58 - ARYA ENTERPRISES BARAUT - 2010660000100000";
        // ddlMode.SelectedValue = "M";
        // txtFromDate.Text = new DateTime(2020, 2, 01).ToShortDateString();
        // txtToDate.Text = DateTime.Now.ToShortDateString();
        // //txtFromDate.Text = new DateTime(2019, 10, 01).ToShortDateString();
        // //txtToDate.Text = DateTime.Now.ToShortDateString();

    }

    #endregion

    #region GriedView Events

    protected void gvRateDiff_PreRender(object sender, EventArgs e)
    {
        if (gvRateDiff.Rows.Count > 0)
        {
            gvRateDiff.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvRateDiff.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }

    protected void gvMasterScheme_PreRender(object sender, EventArgs e)
    {
        if (gvMasterScheme.Rows.Count > 0)
        {
            gvMasterScheme.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvMasterScheme.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }

    protected void gvMachineScheme_PreRender(object sender, EventArgs e)
    {
        if (gvMachineScheme.Rows.Count > 0)
        {
            gvMachineScheme.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvMachineScheme.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }

    protected void gvQPSScheme_PreRender(object sender, EventArgs e)
    {
        if (gvQPSScheme.Rows.Count > 0)
        {
            gvQPSScheme.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvQPSScheme.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }

    protected void gvVRSDiscount_PreRender(object sender, EventArgs e)
    {
        if (gvVRSDiscount.Rows.Count > 0)
        {
            gvVRSDiscount.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvVRSDiscount.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }

    protected void gvParlourScheme_PreRender(object sender, EventArgs e)
    {
        if (gvParlourScheme.Rows.Count > 0)
        {
            gvParlourScheme.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvParlourScheme.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }

    protected void gvFOWScheme_PreRender(object sender, EventArgs e)
    {
        if (gvFOWScheme.Rows.Count > 0)
        {
            gvFOWScheme.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvFOWScheme.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }

    protected void gvSecondTrans_PreRender(object sender, EventArgs e)
    {
        if (gvSecondTrans.Rows.Count > 0)
        {
            gvSecondTrans.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvSecondTrans.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }

    protected void gvIOUClaim_PreRender(object sender, EventArgs e)
    {
        if (gvIOUClaim.Rows.Count > 0)
        {
            gvIOUClaim.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvIOUClaim.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }

    #endregion

    #region Button Events

    protected void btnGenerat_Click(object sender, EventArgs e)
    {
        try
        {
            ClearAllInputs();
            DateTime Fromdate = Convert.ToDateTime(txtFromDate.Text);
            DateTime Todate = Convert.ToDateTime(txtToDate.Text);
            int SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;
            Decimal SSID = Decimal.TryParse(txtSSCode.Text.Split("-".ToArray()).Last().Trim(), out SSID) ? SSID : 0;
            Decimal DistributorID = Decimal.TryParse(txtDistCode.Text.Split("-".ToArray()).Last().Trim(), out DistributorID) ? DistributorID : 0;
            Decimal DealerID = Decimal.TryParse(txtDealerCode.Text.Split("-".ToArray()).Last().Trim(), out DealerID) ? DealerID : 0;
            if (DistributorID == 0 && DealerID == 0 && SSID == 0 && SUserID == 0)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select at least one parameter',3);", true);
                return;
            }
            if ((Todate - Fromdate).TotalDays > 31)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Report should be Proceed Maximum 3 Months',3);", true);
                return;
            }
            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();

            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "GetClaimDetail";
            Cm.Parameters.AddWithValue("@ParentID",ParentID);
            Cm.Parameters.AddWithValue("@DistSSID", ddlSaleBy.SelectedValue == "2" ? DistributorID : SSID);
            Cm.Parameters.AddWithValue("@CustomerID", ddlSaleBy.SelectedValue == "2" ? DealerID : DistributorID);
            Cm.Parameters.AddWithValue("@FromDate", Fromdate.ToString("yyyyMMdd"));
            Cm.Parameters.AddWithValue("@ToDate", Todate.ToString("yyyyMMdd"));
            Cm.Parameters.AddWithValue("@Mode", ddlMode.SelectedValue);
            Cm.Parameters.AddWithValue("@ReportFor", ddlSaleBy.SelectedValue);
            Cm.Parameters.AddWithValue("@EmpID", UserID);
            Cm.Parameters.AddWithValue("@SUserId", SUserID);
            DataSet ds = objClass.CommonFunctionForSelect(Cm);
            if (ddlMode.SelectedValue == "M")
            {
                gvMasterScheme.DataSource = ds.Tables[0];
                gvMasterScheme.DataBind();
                gvMasterScheme.Visible = true;
            }
            else if (ddlMode.SelectedValue == "S")
            {
                gvQPSScheme.DataSource = ds.Tables[0];
                gvQPSScheme.DataBind();
                gvQPSScheme.Visible = true;
            }
            else if (ddlMode.SelectedValue == "D")
            {
                gvMachineScheme.DataSource = ds.Tables[0];
                gvMachineScheme.DataBind();
                gvMachineScheme.Visible = true;
            }
            else if (ddlMode.SelectedValue == "P")
            {
                gvParlourScheme.DataSource = ds.Tables[0];
                gvParlourScheme.DataBind();
                gvParlourScheme.Visible = true;
            }
            else if (ddlMode.SelectedValue == "V")
            {
                gvVRSDiscount.DataSource = ds.Tables[0];
                gvVRSDiscount.DataBind();
                gvVRSDiscount.Visible = true;
            }
            else if (ddlMode.SelectedValue == "F")
            {
                gvFOWScheme.DataSource = ds.Tables[0];
                gvFOWScheme.DataBind();
                gvFOWScheme.Visible = true;
            }
            else if (ddlMode.SelectedValue == "T")
            {
                gvSecondTrans.DataSource = ds.Tables[0];
                gvSecondTrans.DataBind();
                gvSecondTrans.Visible = true;
            }
            else if (ddlMode.SelectedValue == "R")
            {
                gvRateDiff.DataSource = ds.Tables[0];
                gvRateDiff.DataBind();
                gvRateDiff.Visible = true;
            }
            else if (ddlMode.SelectedValue == "I")
            {
                gvIOUClaim.DataSource = ds.Tables[0];
                gvIOUClaim.DataBind();
                gvIOUClaim.Visible = true;
            }
            else if (ddlMode.SelectedValue == "A")
            {
                gvSTODClaim.DataSource = ds.Tables[0];
                gvSTODClaim.DataBind();
                gvSTODClaim.Visible = true;
            }

        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + Common.GetString(ex) + "',2);", true);
        }
    }

    #endregion

    protected void gvSTODClaim_PreRender(object sender, EventArgs e)
    {
        if (gvSTODClaim.Rows.Count > 0)
        {
            gvSTODClaim.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvSTODClaim.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }
}