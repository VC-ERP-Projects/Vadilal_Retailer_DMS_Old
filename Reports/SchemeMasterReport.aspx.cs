using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;


public partial class Reports_SchemeMasterReport : System.Web.UI.Page
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
        txtdealer.Text = txtPlant.Text = txtRegion.Text = txtCustCode.Text = "";
        chkIsActive.Checked = true;

        if (CustType == 1)
        {
            divDistributor.Visible = true;
            acetxtName.ContextKey = (CustType + 1).ToString();
        }
        else
        {
            divDistributor.Visible = false;
            divDistributor.Style.Add("Display", "none");
            acetxtdealer.ContextKey = ParentID.ToString();
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
        }
    }
    protected void ifmEmployee_Load(object sender, EventArgs e)
    {

    }
    #endregion

    #region Button Click

    protected void btnGenerat_Click(object sender, EventArgs e)
    {
        Decimal DistributorID = Decimal.TryParse(txtCustCode.Text.Split("-".ToArray()).Last().Trim(), out DistributorID) ? DistributorID : 0;
        Decimal DealerID = Decimal.TryParse(txtdealer.Text.Split("-".ToArray()).Last().Trim(), out DealerID) ? DealerID : 0;
        int PlantID = Int32.TryParse(txtPlant.Text.Split("-".ToArray()).First().Trim(), out PlantID) ? PlantID : 0;
        int RegionID = Int32.TryParse(txtRegion.Text.Split("-".ToArray()).First().Trim(), out RegionID) ? RegionID : 0;

        if (DistributorID == 0 && DealerID == 0 && PlantID == 0 && RegionID == 0)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select at least one parameter.',3);", true);
            return;
        }

        string Active = chkIsActive.Checked ? "1" : "0";
        string Detail = chkIsDetail.Checked ? "1" : "0";

        ifmEmployee.Attributes.Add("src", "../Reports/ViewReport.aspx?SchmMstActive=" + Active + "&SchmMstDistributorID=" + DistributorID + "&SchmMstDealerID=" + DealerID + "&SchmMstIsDetail=" + Detail + "&SchmMstSchemeType=" + ddltype.SelectedValue + "&SchmMstPlantID=" + PlantID + "&SchmMstRegionID=" + RegionID);
    }

    protected void btnExport_Click(object sender, EventArgs e)
    {
        Decimal DistributorID = Decimal.TryParse(txtCustCode.Text.Split("-".ToArray()).Last().Trim(), out DistributorID) ? DistributorID : 0;
        Decimal DealerID = Decimal.TryParse(txtdealer.Text.Split("-".ToArray()).Last().Trim(), out DealerID) ? DealerID : 0;
        int PlantID = Int32.TryParse(txtPlant.Text.Split("-".ToArray()).First().Trim(), out PlantID) ? PlantID : 0;
        int RegionID = Int32.TryParse(txtRegion.Text.Split("-".ToArray()).First().Trim(), out RegionID) ? RegionID : 0;

        if (DistributorID == 0 && DealerID == 0 && PlantID == 0 && RegionID == 0)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select at least one parameter.',3);", true);
            return;
        }
        string Active = chkIsActive.Checked ? "1" : "0";
        string Detail = chkIsDetail.Checked ? "1" : "0";

        ifmEmployee.Attributes.Add("src", "../Reports/ViewReport.aspx?SchmMstActive=" + Active + "&SchmMstDistributorID=" + DistributorID + "&SchmMstDealerID=" + DealerID + "&SchmMstIsDetail=" + Detail + "&SchmMstSchemeType=" + ddltype.SelectedValue + "&SchmMstPlantID=" + PlantID + "&SchmMstRegionID=" + RegionID + "&Export=1");

    }

    #endregion
}