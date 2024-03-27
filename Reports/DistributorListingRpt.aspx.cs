using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Reports_DistributorListingRpt : System.Web.UI.Page
{
    #region Declaration

    protected int UserID, CustType;
    protected decimal ParentID;
    protected String AuthType;
    DDMSEntities ctx;

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
        else
        {
            Response.Redirect("~/Login.aspx");
        }
    }

    private void ClearAllInputs()
    {
        txtSSDistCode.Text = "";

        //if (CustType == 1)
        //{
        //    divDistributor.Visible = true;
        //    //acetxtName.ContextKey = (CustType + 1).ToString();
        //}
        //else
        //{
        //    divDistributor.Visible = false;
        //    divDistributor.Style.Add("Display", "none");
        //}
    }

    #endregion

    #region Page Load

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();

        if (!IsPostBack)
        {
            ClearAllInputs();
        }
    }

    #endregion

    protected void btnGenerat_Click(object sender, EventArgs e)
    {
        int RegionID = 0;
        int PlantID = 0;
        Decimal SSID = 0;
        if (ddlOption.SelectedValue == "1")
        {
            if (String.IsNullOrEmpty(txtRegion.Text))
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select Region.',3);", true);
                txtRegion.Text = "";
                txtRegion.Focus();
                return;
            }
            else
                RegionID = Int32.TryParse(txtRegion.Text.Split("-".ToArray()).Last().Trim(), out RegionID) ? RegionID : 0;
        }
        if (ddlOption.SelectedValue == "2")
        {
            if (String.IsNullOrEmpty(txtPlant.Text))
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select Plant.',3);", true);
                txtPlant.Text = "";
                txtPlant.Focus();
                return;
            }
            else
                PlantID = Int32.TryParse(txtPlant.Text.Split("-".ToArray()).Last().Trim(), out PlantID) ? PlantID : 0;
        }
        if (ddlOption.SelectedValue == "3")
        {
            if (String.IsNullOrEmpty(txtSSDistCode.Text))
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select Super Stockist.',3);", true);
                txtSSDistCode.Text = "";
                txtSSDistCode.Focus();
                return;
            }
            else
                SSID = Decimal.TryParse(txtSSDistCode.Text.Split("-".ToArray()).Last().Trim(), out SSID) ? SSID : 0;
        }
        Int32 SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;
        ifmClaimReq.Attributes.Add("src", "../Reports/ViewReport.aspx?&DistListCustStatus=" + ddlDistStatus.SelectedValue + "&DistListRegionID=" + RegionID + "&DistListPlantID=" + PlantID + "&DistListSSID=" + SSID + "&DistListSUserID=" + SUserID);
    }

    protected void ifmClaimReq_Load(object sender, EventArgs e)
    {

    }
    protected void btnExport_Click(object sender, EventArgs e)
    {
        int RegionID = 0;
        int PlantID = 0;
        Decimal SSID = 0;
        if (ddlOption.SelectedValue == "1")
        {
            if (String.IsNullOrEmpty(txtRegion.Text))
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select Region.',3);", true);
                txtRegion.Text = "";
                txtRegion.Focus();
                return;
            }
            else
                RegionID = Int32.TryParse(txtRegion.Text.Split("-".ToArray()).Last().Trim(), out RegionID) ? RegionID : 0;
        }
        if (ddlOption.SelectedValue == "2")
        {
            if (String.IsNullOrEmpty(txtPlant.Text))
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select Plant.',3);", true);
                txtPlant.Text = "";
                txtPlant.Focus();
                return;
            }
            else
                PlantID = Int32.TryParse(txtPlant.Text.Split("-".ToArray()).Last().Trim(), out PlantID) ? PlantID : 0;
        }
        if (ddlOption.SelectedValue == "3")
        {
            if (String.IsNullOrEmpty(txtSSDistCode.Text))
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select Super Stockist.',3);", true);
                txtSSDistCode.Text = "";
                txtSSDistCode.Focus();
                return;
            }
            else
                SSID = Decimal.TryParse(txtSSDistCode.Text.Split("-".ToArray()).Last().Trim(), out SSID) ? SSID : 0;
        }
        Int32 SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;
        ifmClaimReq.Attributes.Add("src", "../Reports/ViewReport.aspx?&DistListCustStatus=" + ddlDistStatus.SelectedValue + "&DistListRegionID=" + RegionID + "&DistListPlantID=" + PlantID + "&DistListSSID=" + SSID + "&DistListSUserID=" + SUserID + "&Export=1");
    }
}