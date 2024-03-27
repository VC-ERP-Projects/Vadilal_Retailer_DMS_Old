using AjaxControlToolkit;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Transactions;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Master_VendorMaster : System.Web.UI.Page
{
    #region Declaration

    protected int UserID;
    protected decimal ParentID;
    protected String AuthType;
    DDMSEntities ctx;
    int CustType;

    private List<VND1> VND1s
    {
        get { return this.Session["VND1s"] as List<VND1>; }
        set { this.Session["VND1s"] = value; }
    }

    #endregion

    #region Helper Method

    [WebMethod(EnableSession = true)]
    public static Boolean AddRecord(int LineID, int UnitID, Decimal Price, int TaxID)
    {
        Boolean RetVal = false;
        try
        {
            List<VND1> VND1s = HttpContext.Current.Session["VND1s"] as List<VND1>;
            if (VND1s == null) VND1s = new List<VND1>();
            var objVND1 = VND1s[LineID];
            if (objVND1 != null)
            {
                objVND1.UnitID = UnitID;
                objVND1.Price = Price;
                objVND1.TaxID = TaxID;
            }
            HttpContext.Current.Session["VND1s"] = VND1s;

            RetVal = true;
        }
        catch (Exception)
        {
            RetVal = true;
        }
        return RetVal;
    }


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
                        var unit = xml.Descendants("bill_of_material");
                        if (unit != null)
                        {
                            var ctrls = Common.GetAll(this, typeof(Label));
                            foreach (Label Vendor in ctrls)
                            {
                                if (unit.Elements().Any(x => x.Name == Vendor.ID))
                                    Vendor.Text = unit.Elements().FirstOrDefault(x => x.Name == Vendor.ID).Value;
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
        txtTemplate.Style.Add("background-color", "rgb(250, 255, 189);");

        if (chkMode.Checked)
        {
            acetxtVendorCode.Enabled = false;
            btnSubmit.Text = "Submit";
            txtVendorCode.Style.Remove("background-color");
        }
        else
        {
            acetxtVendorCode.Enabled = true;
            btnSubmit.Text = "Submit";
            txtVendorCode.Style.Add("background-color", "rgb(250, 255, 189);");
        }
        if (CustType == 1)
            lblIsDefault.Visible = chkIsDefault.Visible = true;
        else
            lblIsDefault.Visible = chkIsDefault.Visible = false;

        txtVendorCode.Focus();
        txtTemplate.Text = txtVendorCode.Text = txtVendorName.Text = txtAddress1.Text = txtAddress2.Text = txtLocation.Text = txtPinCode.Text = txtContactPerson.Text = txtPhone1.Text = txtPhone2.Text = txtEmail.Text = txtNotes.Text = "";
        chkActive.Checked = true;
        chkIsDefault.Checked = false;
        ddlCity.SelectedValue = ddlState.SelectedValue = ddlCountry.SelectedValue = "0";

        ViewState["VendorID"] = null;
        VND1s = null;
        gvItem.DataSource = null;
        gvItem.DataBind();

        acetxtVendorCode.ContextKey = ParentID.ToString();
    }

    #endregion

    #region Page Load

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        if (!IsPostBack)
            ClearAllInputs();
    }

    #endregion

    #region Button Click

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        try
        {
            if (Page.IsValid)
            {
                int IntNum = 0;
                OVND objOVND;
                if (ViewState["VendorID"] != null && Int32.TryParse(ViewState["VendorID"].ToString(), out IntNum))
                {
                    objOVND = ctx.OVNDs.Include("VND1").FirstOrDefault(x => x.VendorID == IntNum && x.ParentID == ParentID);
                }
                else
                {
                    if (ctx.OVNDs.Any(x => x.VendorName == txtVendorName.Text && x.ParentID == ParentID))
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same Vendor is not allowed!',3);", true);
                        return;
                    }

                    objOVND = new OVND();
                    objOVND.VendorID = ctx.GetKey("OVND", "VendorID", "", ParentID, 0).FirstOrDefault().Value;
                    objOVND.ParentID = ParentID;
                    objOVND.CreatedBy = UserID;
                    objOVND.CreatedDate = DateTime.Now;
                    ctx.OVNDs.Add(objOVND);
                }
                objOVND.VendorCode = txtVendorCode.Text;
                objOVND.VendorName = txtVendorName.Text;
                objOVND.Address1 = txtAddress1.Text;
                objOVND.Address2 = txtAddress2.Text;
                objOVND.Location = txtLocation.Text;
                objOVND.CityID = Convert.ToInt32(ddlCity.SelectedValue);
                objOVND.StateID = Convert.ToInt32(ddlState.SelectedValue);
                objOVND.CountryID = Convert.ToInt32(ddlCountry.SelectedValue);
                objOVND.PinCode = txtPinCode.Text;
                objOVND.ContactPerson = txtContactPerson.Text;
                objOVND.Phone1 = txtPhone1.Text;
                objOVND.Phone2 = txtPhone2.Text;
                objOVND.Email = txtEmail.Text;
                objOVND.Notes = txtNotes.Text;
                objOVND.UpdatedBy = UserID;
                objOVND.UpdatedDate = DateTime.Now;
                objOVND.Active = chkActive.Checked;
                objOVND.IsDefault = chkIsDefault.Checked;

                VND1 objVND1 = null;

                objOVND.VND1.ToList().ForEach(x => x.IsDeleted = true);

                int Count = ctx.GetKey("VND1", "VND1ID", "", ParentID, 0).FirstOrDefault().Value;
                Decimal DecNum = 0;
                foreach (GridViewRow item in gvItem.Rows)
                {
                    objVND1 = new VND1();
                    objVND1.VND1ID = Count++;

                    Label lblItemID = (Label)item.FindControl("lblItemID");
                    Label lblUnitID = (Label)item.FindControl("lblUnitID");
                    TextBox txtPrice = (TextBox)item.FindControl("txtPrice");
                    DropDownList ddlTaxCode = (DropDownList)item.FindControl("ddlTaxCode");

                    objVND1.ItemID = Int32.TryParse(lblItemID.Text, out IntNum) ? IntNum : 0;
                    objVND1.UnitID = Int32.TryParse(lblUnitID.Text, out IntNum) ? IntNum : 0;
                    objVND1.Price = Decimal.TryParse(txtPrice.Text, out DecNum) ? DecNum : 0;
                    objVND1.TaxID = Int32.TryParse(ddlTaxCode.SelectedValue, out IntNum) ? IntNum : 0;
                    objOVND.VND1.Add(objVND1);
                }

                ctx.SaveChanges();
                ClearAllInputs();
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Record submitted successfully: " + objOVND.VendorName + "',1);", true);
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please enter proper data!',3);", true);
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        Response.Redirect("BusinessPartner.aspx");
    }

    #endregion

    #region Change Event

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
            ddlCity.Focus();
        }
    }

    protected void chkMode_Checked(object sender, EventArgs e)
    {
        ClearAllInputs();
    }

    protected void txtVendorCode_TextChanged(object sender, EventArgs e)
    {
        try
        {
            if (!chkMode.Checked && !string.IsNullOrEmpty(txtVendorCode.Text))
            {
                var word = txtVendorCode.Text.Split("-".ToArray());
                if (word.Length == 2)
                {
                    string VD = word.First().Trim();
                    var objOVND = ctx.OVNDs.FirstOrDefault(x => x.VendorCode == VD && x.ParentID == ParentID);
                    if (objOVND != null)
                    {
                        txtVendorCode.Text = objOVND.VendorCode.ToString();
                        txtVendorName.Text = objOVND.VendorName;
                        txtAddress1.Text = objOVND.Address1;
                        txtAddress2.Text = objOVND.Address2;
                        txtLocation.Text = objOVND.Location;
                        ddlCity.SelectedValue = objOVND.CityID.ToString();
                        ddlState.SelectedValue = objOVND.StateID.ToString();
                        ddlCountry.SelectedValue = objOVND.CountryID.ToString();
                        txtPinCode.Text = objOVND.PinCode;
                        txtContactPerson.Text = objOVND.ContactPerson;
                        txtPhone1.Text = objOVND.Phone1;
                        txtPhone2.Text = objOVND.Phone2;
                        txtEmail.Text = objOVND.Email;
                        txtNotes.Text = objOVND.Notes;
                        chkActive.Checked = objOVND.Active;
                        chkIsDefault.Checked = objOVND.IsDefault;
                        ViewState["VendorID"] = objOVND.VendorID;

                        VND1s = objOVND.VND1.ToList();
                        gvItem.DataSource = VND1s;
                        gvItem.DataBind();
                    }
                    else
                    {
                        ScriptManager.RegisterStartupScript(this, GetType(), "ModelMsg", "ModelMsg('Select valid vendor!',3);", true);
                        ClearAllInputs();
                    }
                }
                else
                {
                    ScriptManager.RegisterStartupScript(this, GetType(), "ModelMsg", "ModelMsg('Select proper vendor!',3);", true);
                    ClearAllInputs();
                }
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "Modelmsg('" + Common.GetString(ex) + "',2);", true);
        }
        txtVendorName.Focus();
    }

    #endregion

    #region Grid View Command

    protected void gvItem_PreRender(object sender, EventArgs e)
    {
        if (gvItem.Rows.Count > 0)
        {
            gvItem.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvItem.FooterRow.TableSection = TableRowSection.TableFooter;
        }
        MergeRows(gvItem);
    }

    #endregion

    public static void MergeRows(GridView gridView)
    {
        for (int rowIndex = gridView.Rows.Count - 2; rowIndex >= 0; rowIndex--)
        {
            GridViewRow row = gridView.Rows[rowIndex];
            GridViewRow previousRow = gridView.Rows[rowIndex + 1];

            for (int i = 0; i < 2; i++)
            {
                if (row.Cells[i].Text == previousRow.Cells[i].Text)
                {
                    row.Cells[i].RowSpan = previousRow.Cells[i].RowSpan < 2 ? 2 : previousRow.Cells[i].RowSpan + 1;
                    previousRow.Cells[i].Visible = false;
                }
            }
        }
    }

    protected void txtTemplate_TextChanged(object sender, EventArgs e)
    {
        var Text = txtTemplate.Text.Split("-".ToArray());
        if (Text.Length == 2)
        {
            int TID = Convert.ToInt32(Text.First());
            var Data = ctx.SITMs.Where(x => x.TemplateID == TID && x.ParentID == ParentID).OrderBy(x => x.Priority).Select(x => x.ItemID).ToList();
            int IntNum = 0;

            VND1s = new List<VND1>();

            if (ViewState["VendorID"] != null && Int32.TryParse(ViewState["VendorID"].ToString(), out IntNum))
            {
                VND1s = ctx.VND1.Where(x => x.VendorID == IntNum && x.ParentID == ParentID).ToList();
            }
            foreach (Int32 itemID in Data)
            {
                var objOITM = ctx.OITMs.Include("ITM1").Include("ITM1.OUNT").FirstOrDefault(x => x.ItemID == itemID && x.Active);
                if (objOITM != null)
                {
                    var objITM1 = objOITM.ITM1.Where(x => new int[] { 2, 3 }.Contains(x.UnitType) && x.UnitItemID == null).ToList();
                    foreach (var ITM1 in objITM1)
                    {
                        if (!VND1s.Any(x => x.ItemID == ITM1.ItemID))
                        {
                            VND1 objVND1 = new VND1();
                            objVND1.ItemID = ITM1.ItemID;
                            objVND1.OITM = ITM1.OITM;
                            objVND1.UnitID = ITM1.UnitID;
                            objVND1.OUNT = ITM1.OUNT;
                            VND1s.Add(objVND1);
                        }
                    }
                }
            }
            gvItem.DataSource = VND1s;
            gvItem.DataBind();
        }
    }

    protected void gvItem_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "DeleteItem")
        {
            int LineID = Convert.ToInt32(e.CommandArgument);
            VND1s.RemoveAt(LineID);

            gvItem.DataSource = VND1s;
            gvItem.DataBind();
        }
    }
}