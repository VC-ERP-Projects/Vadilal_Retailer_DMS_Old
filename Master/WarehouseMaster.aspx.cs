using System;
using System.Collections.Generic;
using System.Data.Entity.Validation;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Master_WarehouseMaster : System.Web.UI.Page
{
    #region Declaration

    DDMSEntities ctx;
    protected int UserID;
    protected decimal ParentID;
    protected String AuthType;

    #endregion

    #region Helper Method

    public void ValidateUser()
    {
        if (Session["UserID"] != null && Session["ParentID"] != null &&
          Int32.TryParse(Session["UserID"].ToString(), out UserID) && Decimal.TryParse(Session["ParentID"].ToString(), out ParentID))
        {
            ctx = new DDMSEntities();
            int EGID = Convert.ToInt32(Session["GroupID"]);
            int CustType = Convert.ToInt32(Session["Type"]);

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
                        var unit = xml.Descendants("warehouse_master");
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
        if (chkMode.Checked)
        {
            txtWhsNo.Text = "Auto generated";
            txtWhsNo.Enabled = ACEtxtName.Enabled = false;
            btnSubmit.Text = "Submit";
            txtWhsNo.Style.Remove("background-color");
            txtWhsCode.Focus();
        }
        else
        {
            txtWhsNo.Text = "";
            txtWhsNo.Enabled = ACEtxtName.Enabled = true;
            btnSubmit.Text = "Submit";
            txtWhsNo.Style.Add("background-color", "rgb(250, 255, 189);");
            txtWhsNo.Focus();
        }

        txtWhsCode.Text = txtName.Text = txtBlock.Text = txtLocation.Text = txtPinCode.Text = txtContactPerson.Text = txtPhone.Text = txtNotes.Text = txtStreet.Text = txtMobile.Text = "";
        ddlCity.SelectedValue = "0";
        ddlState.SelectedValue = "0";
        ddlCountry.SelectedValue = "0";
        ddlType.SelectedValue = "0";

        chkIsActive.Checked = true;
        chkDefault.Checked = false;
        ViewState["WhsID"] = null;
    }

    #endregion

    #region Page Load

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        ACEtxtName.ContextKey = ParentID.ToString();
        if (!IsPostBack)
        {
            ClearAllInputs();
        }
    }

    #endregion

    #region Button Click

    protected void btnSubmitClick(object sender, EventArgs e)
    {
        try
        {
            OWH objOWH;
            int WhsID;
            if (ViewState["WhsID"] != null && Int32.TryParse(ViewState["WhsID"].ToString(), out WhsID))
            {
                objOWH = ctx.OWHS.FirstOrDefault(x => x.WhsID == WhsID && x.ParentID == ParentID);
                int WarID = objOWH.WhsID;
                if (ctx.ITM2.Any(x => x.WhsID == WarID && x.ParentID == ParentID && x.TotalPacket > 0))
                {
                    if (!chkIsActive.Checked)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('This warehouse can not be deactivated!',3);", true);
                        return;
                    }
                }
            }
            else
            {
                if (ctx.OWHS.Any(x => x.WhsName == txtName.Text && x.ParentID == ParentID))
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same warehouse name is not allowed!',3);", true);
                    return;
                }

                objOWH = new OWH();
                objOWH.WhsID = ctx.GetKey("OWHS", "WhsID", "", ParentID, 0).FirstOrDefault().Value;
                objOWH.ParentID = ParentID;
                objOWH.CreatedDate = DateTime.Now;
                objOWH.CreatedBy = UserID;

                ctx.OWHS.Add(objOWH);
            }
            objOWH.WhsName = txtName.Text;
            objOWH.WhsCode = txtWhsCode.Text;
            objOWH.Active = chkIsActive.Checked;
            objOWH.Length = 0;
            objOWH.Height = 0;
            objOWH.Width = 0;
            objOWH.Type = ddlType.SelectedValue.ToString();
            objOWH.Notes = txtNotes.Text;
            objOWH.UpdatedDate = DateTime.Now;
            objOWH.UpdatedBy = UserID;
            objOWH.ROOFType = false;
            objOWH.RCCType = false;
            objOWH.OwnerShip = "0";
            objOWH.NetArea = 0;
            objOWH.GrossArea = 0;

            if (chkDefault.Checked)
            {
                ctx.OWHS.Where(x => x.ParentID == ParentID && x.Active).ToList().ForEach(y => y.IsDefault = false);
                objOWH.IsDefault = true;
            }
            else
            {
                objOWH.IsDefault = false;
            }

            objOWH.Block = txtBlock.Text;
            objOWH.Street = txtStreet.Text;
            objOWH.Location = txtLocation.Text;

            if (ddlCity.SelectedValue != "0")
                objOWH.CityID = Convert.ToInt32(ddlCity.SelectedValue);

            if (ddlState.SelectedValue != "0")
                objOWH.StateID = Convert.ToInt32(ddlState.SelectedValue);

            if (ddlCountry.SelectedValue != "0")
                objOWH.CountryID = Convert.ToInt32(ddlCountry.SelectedValue);

            objOWH.ZipCode = txtPinCode.Text;
            objOWH.ContactPerson = txtContactPerson.Text;
            objOWH.Mobile = txtMobile.Text;
            objOWH.Phone = txtPhone.Text;

            ctx.SaveChanges();
            ClearAllInputs();
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Record Submitted Successfully : " + objOWH.WhsName + "',1);", true);
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }

    }

    protected void btnCancelClick(object sender, EventArgs e)
    {
        Response.Redirect("Master.aspx");
    }

    #endregion

    #region Change Event

    protected void txtWhsNo_TextChanged(object sender, EventArgs e)
    {
        try
        {
            if (!chkMode.Checked && !string.IsNullOrEmpty(txtWhsNo.Text))
            {
                var OWHS = ctx.OWHS.FirstOrDefault(x => x.WhsName == txtWhsNo.Text && x.ParentID == ParentID);

                if (OWHS != null)
                {
                    txtWhsNo.Text = OWHS.WhsID.ToString();
                    txtWhsCode.Text = OWHS.WhsCode;
                    txtName.Text = OWHS.WhsName;
                    txtWhsCode.Text = OWHS.WhsCode;
                    chkIsActive.Checked = OWHS.Active;
                    chkDefault.Checked = OWHS.IsDefault;
                    ddlType.SelectedValue = OWHS.Type.ToString();
                    txtNotes.Text = OWHS.Notes;

                    ViewState["WhsID"] = OWHS.WhsID;


                    txtBlock.Text = OWHS.Block;
                    txtStreet.Text = OWHS.Street;
                    txtLocation.Text = OWHS.Location;
                    ddlCity.SelectedValue = OWHS.CityID.ToString();
                    txtPinCode.Text = OWHS.ZipCode;
                    ddlState.SelectedValue = OWHS.StateID.ToString();
                    ddlCountry.SelectedValue = OWHS.CountryID.ToString();
                    txtContactPerson.Text = OWHS.ContactPerson;
                    txtPhone.Text = OWHS.Phone;
                    txtMobile.Text = OWHS.Mobile;
                }
                else
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select proper warehouse!',3);", true);
                    ClearAllInputs();
                }
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
        txtWhsCode.Focus();
    }

    protected void ddlCity_SelectedIndexChanged(object sender, EventArgs e)
    {
        int CityID = Convert.ToInt32(ddlCity.SelectedValue);
        if (CityID > 0)
        {
            var state = ctx.OCTies.Include("OCST").Include("OCST.OCRY").FirstOrDefault(x => x.CityID == CityID);

            if (state.OCST != null && !string.IsNullOrEmpty(state.OCST.StateID.ToString()))
            {
                int StateID = state.OCST.StateID;
                ddlState.SelectedValue = state.OCST.StateID.ToString();

                if (state.OCST.OCRY != null && !string.IsNullOrEmpty(state.OCST.OCRY.CountryID.ToString()))
                {
                    int CountryID = state.OCST.CountryID;
                    ddlCountry.SelectedValue = state.OCST.OCRY.CountryID.ToString();
                }
            }
        }
        ddlCity.Focus();
    }

    protected void chkMode_Checked(object sender, EventArgs e)
    {
        try
        {
            ClearAllInputs();
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }

    #endregion
}

