using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Reports_AssetRequest : System.Web.UI.Page
{
    #region Declaration

    protected int UserID, CustType;
    protected decimal ParentID;
    protected String AuthType;

    #endregion

    #region Helper Method

    public void ValidateUser()
    {
        if (Session["UserID"] != null && Session["ParentID"] != null &&
          Int32.TryParse(Session["UserID"].ToString(), out UserID) && Decimal.TryParse(Session["ParentID"].ToString(), out ParentID))
        {
            int EGID = Convert.ToInt32(Session["GroupID"]);
            CustType = Convert.ToInt32(Session["Type"]);
            using (DDMSEntities ctx = new DDMSEntities())
            {
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

    private void ClearAllInputs()
    {
        txtDealerCode.Text = txtPlant.Text = txtRegion.Text = txtDistCode.Text = "";
        chkIsDetail.Checked = true;
        txtToDate.Text = txtFromDate.Text = Common.DateTimeConvert(DateTime.Now);

        if (CustType == 4)
        {
            divEmpCode.Attributes.Add("style", "display:none;");
            divDistributor.Attributes.Add("style", "display:none;");
            divPlant.Attributes.Add("style", "display:none;");
            divRegion.Attributes.Add("style", "display:none;");
            divDealer.Attributes.Add("style", "display:none;");

            ddlReportBy.SelectedValue = "4";
            txtSSDistCode.Enabled = ddlReportBy.Enabled = false;
            using (DDMSEntities ctx = new DDMSEntities())
            {
                var Data = ctx.OCRDs.Where(x => x.CustomerID == ParentID).Select(x => new { x.CustomerID, x.CustomerCode, CustomerName = x.CustomerName.Replace("-", "") }).FirstOrDefault();
                txtSSDistCode.Text = Data.CustomerCode + " - " + Data.CustomerName + " - " + Data.CustomerID;
            }
        }
        else if (CustType == 2)
        {
            divEmpCode.Attributes.Add("style", "display:none;");
            divSS.Attributes.Add("style", "display:none;");
            divPlant.Attributes.Add("style", "display:none;");
            divRegion.Attributes.Add("style", "display:none;");

            ddlReportBy.SelectedValue = "2";
            txtDistCode.Enabled = ddlReportBy.Enabled = false;

            using (DDMSEntities ctx = new DDMSEntities())
            {
                var Data = ctx.OCRDs.Where(x => x.CustomerID == ParentID).Select(x => new { x.CustomerID, x.CustomerCode, CustomerName = x.CustomerName.Replace("-", "") }).FirstOrDefault();
                txtDistCode.Text = Data.CustomerCode + " - " + Data.CustomerName + " - " + Data.CustomerID;
            }
        }
    }

    #endregion

    #region Page Load

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        if (!IsPostBack)
        {
            ClearAllInputs();
            using (DDMSEntities ctx = new DDMSEntities())
            {
                var Status = ctx.OEAS.Where(x => x.Active).ToList();
                ddlStatus.DataSource = Status;
                ddlStatus.DataBind();
                ddlStatus.Items.Insert(0, new ListItem("---Select---", "0"));
            }
        }
    }

    #endregion

    #region ButtonEvent

    protected void btnExport_Click(object sender, EventArgs e)
    {
        Int32 RegionID = Int32.TryParse(txtRegion.Text.Split("-".ToArray()).Last().Trim(), out RegionID) ? RegionID : 0;
        Int32 PlantID = Int32.TryParse(txtPlant.Text.Split("-".ToArray()).Last().Trim(), out PlantID) ? PlantID : 0;
        Decimal SSID = Decimal.TryParse(txtSSDistCode.Text.Split("-".ToArray()).Last().Trim(), out SSID) ? SSID : 0;
        Decimal DistributorID = Decimal.TryParse(txtDistCode.Text.Split("-".ToArray()).Last().Trim(), out DistributorID) ? DistributorID : 0;
        Decimal CustomerID = Decimal.TryParse(txtDealerCode.Text.Split("-".ToArray()).Last().Trim(), out CustomerID) ? CustomerID : 0;
        Int32 SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;
        if (!string.IsNullOrEmpty(txtCode.Text) && SUserID == 0)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper User.',3);", true);
            return;
        }
        string IsDetail = chkIsDetail.Checked ? "1" : "0";
        //CustomerID = CustomerID > 0 ? CustomerID : DistributorID > 0 ? DistributorID : SSID > 0 ? SSID : 0;

        ifmAssetReq.Attributes.Add("src", "../Reports/ViewReport.aspx?AssetRequestFromDate=" + txtFromDate.Text + "&AssetRequestToDate=" + txtToDate.Text + "&AssetRqstSSID=" + SSID + "&AssetRqstDistributorID=" + DistributorID + "&AssetRqstDealerID=" + CustomerID + "&AssetRqstPlantID=" + PlantID + "&AssetRqstRegionID=" + RegionID + "&AssetRqstEmpID=" + SUserID + "&AssetRqstStatusID=" + ddlStatus.SelectedValue + "&IsDetail=" + IsDetail + "&AssetRqstRptBy=" + ddlReportBy.SelectedValue + "&Export=1");
    }

    protected void btnGenerat_Click(object sender, EventArgs e)
    {
        Int32 RegionID = Int32.TryParse(txtRegion.Text.Split("-".ToArray()).Last().Trim(), out RegionID) ? RegionID : 0;
        Int32 PlantID = Int32.TryParse(txtPlant.Text.Split("-".ToArray()).Last().Trim(), out PlantID) ? PlantID : 0;
        Decimal SSID = Decimal.TryParse(txtSSDistCode.Text.Split("-".ToArray()).Last().Trim(), out SSID) ? SSID : 0;
        Decimal DistributorID = Decimal.TryParse(txtDistCode.Text.Split("-".ToArray()).Last().Trim(), out DistributorID) ? DistributorID : 0;
        Decimal CustomerID = Decimal.TryParse(txtDealerCode.Text.Split("-".ToArray()).Last().Trim(), out CustomerID) ? CustomerID : 0;
        Int32 SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;
        if (!string.IsNullOrEmpty(txtCode.Text) && SUserID == 0)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper User.',3);", true);
            return;
        }
        string IsDetail = chkIsDetail.Checked ? "1" : "0";
        //CustomerID = CustomerID > 0 ? CustomerID : DistributorID > 0 ? DistributorID : SSID > 0 ? SSID : 0;

        ifmAssetReq.Attributes.Add("src", "../Reports/ViewReport.aspx?AssetRequestFromDate=" + txtFromDate.Text + "&AssetRequestToDate=" + txtToDate.Text + "&AssetRqstSSID=" + SSID + "&AssetRqstDistributorID=" + DistributorID + "&AssetRqstDealerID=" + CustomerID + "&AssetRqstPlantID=" + PlantID + "&AssetRqstRegionID=" + RegionID + "&AssetRqstEmpID=" + SUserID + "&AssetRqstStatusID=" + ddlStatus.SelectedValue + "&IsDetail=" + IsDetail + "&AssetRqstRptBy=" + ddlReportBy.SelectedValue);
    }

    protected void ifmAssetReq_Load(object sender, EventArgs e)
    {

    }

    #endregion
}