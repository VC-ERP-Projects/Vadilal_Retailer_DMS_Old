using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Reports_QPSSchemeListing : System.Web.UI.Page
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
        txtToDate.Text = txtFromDate.Text = txtBtwnDate.Text = Common.DateTimeConvert(DateTime.Now);

        //divBtwnDate.Visible = false;
    }

    #endregion

    #region Page Load

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();

        if (!IsPostBack)
        {
            acetxtName.ServiceMethod = "GetEmpty";
            ClearAllInputs();
            //var Division = ctx.ODIVs.Where(x => x.Active).ToList();
            //ddlDivision.DataSource = Division;
            //ddlDivision.DataBind();
        }
    }
    #endregion
    //protected void ddlDateOption_SelectedIndexChanged(object sender, EventArgs e)
    //{
    //    if (ddlDateOption.SelectedValue == "1")
    //    {
    //        divBtwnDate.Visible = false;
    //        divFromDate.Visible = true;
    //        divToDate.Visible = true;
    //    }
    //    else if (ddlDateOption.SelectedValue == "2")
    //    {
    //        divBtwnDate.Visible = true;
    //        divFromDate.Visible = false;
    //        divToDate.Visible = false;
    //    }
    //}
    //protected void ddlSchemeLvl_SelectedIndexChanged(object sender, EventArgs e)
    //{
    //    if (ddlSchemeLvl.SelectedValue == "0")
    //    {
    //        txtLvlInput.Text = "";
    //        txtLvlInput.Enabled = false;
    //    }
    //    else if (ddlSchemeLvl.SelectedValue == "1")
    //    {
    //        txtLvlInput.Enabled = true;
    //        txtLvlInput.Text = "";
    //        acetxtName.ServiceMethod = "GetStateNames";
    //    }
    //    else if (ddlSchemeLvl.SelectedValue == "2")
    //    {
    //        txtLvlInput.Enabled = true;
    //        txtLvlInput.Text = "";
    //        acetxtName.ServiceMethod = "GetPlant";
    //    }
    //    else if (ddlSchemeLvl.SelectedValue == "3")
    //    {
    //        txtLvlInput.Enabled = true;
    //        txtLvlInput.Text = "";
    //        acetxtName.ServiceMethod = "GetDistofPlantState";
    //    }
    //    else if (ddlSchemeLvl.SelectedValue == "4")
    //    {
    //        txtLvlInput.Enabled = true;
    //        txtLvlInput.Text = "";
    //        acetxtName.ServiceMethod = "GetDealerofDist";
    //    }
    //}
    protected void btnGenerat_Click(object sender, EventArgs e)
    {
        var SchemeCode = "0";
        Int32 ItemID = Int32.TryParse(txtItem.Text.Split("-".ToArray()).First().Trim(), out ItemID) ? ItemID : 0;
        Decimal LvlInput = 0;
        if (!String.IsNullOrEmpty(txtCode.Text))
        {
            SchemeCode = txtCode.Text.Split("-".ToArray()).First().Trim();
            //SchemeID = ctx.OSCMs.Where(x => x.SchemeCode == SchemeCode).Select(x => x.SchemeID).FirstOrDefault();
        }
        if (ddlSchemeLvl.SelectedValue != "0")
        {
            if (!string.IsNullOrEmpty(txtLvlInput.Text))
            {
                if (ddlSchemeLvl.SelectedValue == "3" || ddlSchemeLvl.SelectedValue == "4")
                    LvlInput = Decimal.TryParse(txtLvlInput.Text.Split("-".ToArray()).Last().Trim(), out LvlInput) ? LvlInput : 0;
                else
                    LvlInput = Decimal.TryParse(txtLvlInput.Text.Split("-".ToArray()).Last().Trim(), out LvlInput) ? LvlInput : 0;
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select Level Option.',3);", true);
                return;
            }
        }

        string IsDetail = chkIsDetail.Checked ? "1" : "0";

        //string txtCpnyContriFrom = Request.Form["txtCpnyContriFrom"];
        //string txtCpnyContriTo = Request.Form["txtCpnyContriTo"];
        //string txtDistContriFrom = Request.Form["txtDistContriFrom"];
        //string txtDistContriTo = Request.Form["txtDistContriTo"];
        Decimal CompanyFrom = Decimal.TryParse(txtCpnyContriFrom.Value, out CompanyFrom) ? CompanyFrom : 0;
        Decimal CompanyTo = Decimal.TryParse(txtCpnyContriTo.Value, out CompanyTo) ? CompanyTo : 100;
        Decimal DistFrom = Decimal.TryParse(txtDistContriFrom.Value, out DistFrom) ? DistFrom : 0;
        Decimal DistTo = Decimal.TryParse(txtDistContriTo.Value, out DistTo) ? DistTo : 100;
        Decimal LowerLimit = Decimal.TryParse(txtLowerLimit.Text, out LowerLimit) ? LowerLimit : 0;

        ifmDataReq.Attributes.Add("src", "../Reports/ViewReport.aspx?&QPSSchemeFromDate=" + txtFromDate.Text + "&QPSSchemeToDate=" + txtToDate.Text + "&QPSSchemeBtwnDate=" + txtBtwnDate.Text
            + "&QPSSchemeSchemeID=" + SchemeCode + "&QPSSchemeItmeID=" + ItemID + "&QPSSchemeLvl=" + ddlSchemeLvl.SelectedValue + "&QPSSchemeLvlInput=" + LvlInput
            + "&QPSSchemeCmpnyFrom=" + CompanyFrom + "&QPSSchemeCmpnyTo=" + CompanyTo + "&QPSSchemeDistFrom=" + DistFrom + "&QPSSchemeDistTo=" + DistTo
            + "&QPSSchemeDateOption=" + ddlDateOption.SelectedValue + "&QPSSchemeLowerLimit=" + LowerLimit + "&QPSSchemeDivisionID=" + 0 + "&IsDetail=" + IsDetail);
    }
    protected void btnExport_Click(object sender, EventArgs e)
    {
        var SchemeCode = "0";
        Int32 ItemID = Int32.TryParse(txtItem.Text.Split("-".ToArray()).First().Trim(), out ItemID) ? ItemID : 0;
        Decimal LvlInput = 0;
        if (!String.IsNullOrEmpty(txtCode.Text))
        {
            SchemeCode = txtCode.Text.Split("-".ToArray()).First().Trim();
            //SchemeID = ctx.OSCMs.Where(x => x.SchemeCode == SchemeCode).Select(x => x.SchemeID).FirstOrDefault();
        }
        if (ddlSchemeLvl.SelectedValue != "0")
        {
            if (!string.IsNullOrEmpty(txtLvlInput.Text))
            {
                if (ddlSchemeLvl.SelectedValue == "3" || ddlSchemeLvl.SelectedValue == "4")
                    LvlInput = Decimal.TryParse(txtLvlInput.Text.Split("-".ToArray()).Last().Trim(), out LvlInput) ? LvlInput : 0;
                else
                    LvlInput = Decimal.TryParse(txtLvlInput.Text.Split("-".ToArray()).Last().Trim(), out LvlInput) ? LvlInput : 0;
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select Level Option.',3);", true);
                return;
            }
        }

        string IsDetail = chkIsDetail.Checked ? "1" : "0";

        //string txtCpnyContriFrom = Request.Form["txtCpnyContriFrom"];
        //string txtCpnyContriTo = Request.Form["txtCpnyContriTo"];
        //string txtDistContriFrom = Request.Form["txtDistContriFrom"];
        //string txtDistContriTo = Request.Form["txtDistContriTo"];
        Decimal CompanyFrom = Decimal.TryParse(txtCpnyContriFrom.Value, out CompanyFrom) ? CompanyFrom : 0;
        Decimal CompanyTo = Decimal.TryParse(txtCpnyContriTo.Value, out CompanyTo) ? CompanyTo : 100;
        Decimal DistFrom = Decimal.TryParse(txtDistContriFrom.Value, out DistFrom) ? DistFrom : 0;
        Decimal DistTo = Decimal.TryParse(txtDistContriTo.Value, out DistTo) ? DistTo : 100;
        Decimal LowerLimit = Decimal.TryParse(txtLowerLimit.Text, out LowerLimit) ? LowerLimit : 0;

        ifmDataReq.Attributes.Add("src", "../Reports/ViewReport.aspx?&QPSSchemeFromDate=" + txtFromDate.Text + "&QPSSchemeToDate=" + txtToDate.Text + "&QPSSchemeBtwnDate=" + txtBtwnDate.Text
            + "&QPSSchemeSchemeID=" + SchemeCode + "&QPSSchemeItmeID=" + ItemID + "&QPSSchemeLvl=" + ddlSchemeLvl.SelectedValue + "&QPSSchemeLvlInput=" + LvlInput
            + "&QPSSchemeCmpnyFrom=" + CompanyFrom + "&QPSSchemeCmpnyTo=" + CompanyTo + "&QPSSchemeDistFrom=" + DistFrom + "&QPSSchemeDistTo=" + DistTo
            + "&QPSSchemeDateOption=" + ddlDateOption.SelectedValue + "&QPSSchemeLowerLimit=" + LowerLimit + "&QPSSchemeDivisionID=" + 0 + "&IsDetail=" + IsDetail + "&Export=1");
    }
   
}