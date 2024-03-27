using AjaxControlToolkit;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Transactions;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Master_TaxMaster : System.Web.UI.Page
{

    #region Declaration

    protected int UserID;
    protected decimal ParentID;
    protected String AuthType;
    DDMSEntities ctx;

    private List<TAX1> TAX1s
    {
        get { return this.ViewState["TAX1s"] as List<TAX1>; }
        set { this.ViewState["TAX1s"] = value; }
    }

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
                        var unit = xml.Descendants("bill_of_material");
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

    private void ClearItemInputs()
    {
        txtRCode.Text = txtRPercentage.Text = "";
        ViewState["TAX1ID"] = null;
        btnAddTax.Text = "Add Tax";
    }

    private void ClearAllInputs()
    {
        if (chkMode.Checked)
        {
            acettxtTName.Enabled = false;
            btnSubmit.Text = "Submit";
            txtTaxName.Focus();
            txtTaxName.Style.Remove("background-color");
        }
        else
        {
            txtTaxName.Focus();
            acettxtTName.Enabled = true;
            btnSubmit.Text = "Submit";
            txtTaxName.Style.Add("background-color", "rgb(250, 255, 189);");
        }

        ddlTaxType.SelectedValue = "0";
        txtPercent.Text = txtFormula.Text = txtTaxName.Text = txtDesc.Text = "";
        chkActive.Checked = true;
        ViewState["TaxID"] = null;

        ClearItemInputs();
        TAX1s = new List<TAX1>();
        gvTax.DataSource = TAX1s;
        gvTax.DataBind();

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

    protected void btnAddTax_Click(object sender, EventArgs e)
    {
        Decimal DecNum;
        if (TAX1s == null)
            TAX1s = new List<TAX1>();

        int LineID;
        TAX1 objTAX1 = null;

        if (String.IsNullOrEmpty(txtRCode.Text))
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Enter Tax Name!',3);", true);
            return;
        }
        if (String.IsNullOrEmpty(txtRPercentage.Text))
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Enter Percentage!',3);", true);
            return;
        }

        if (ViewState["TAX1ID"] != null && Int32.TryParse(ViewState["TAX1ID"].ToString(), out LineID))
        {
            objTAX1 = TAX1s[LineID];
        }
        else
        {
            if (TAX1s.Any(x => x.Code == txtRCode.Text))
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Tax already exist!',3);", true);
                return;
            }
            objTAX1 = new TAX1();
            TAX1s.Add(objTAX1);
        }
        objTAX1.Code = txtRCode.Text;
        objTAX1.Percentage = Decimal.TryParse(txtRPercentage.Text, out DecNum) ? DecNum : 0; ;

        ClearItemInputs();
        btnAddTax.Text = "Add Tax";

        gvTax.DataSource = TAX1s;
        gvTax.DataBind();
    }

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        try
        {
            if (Page.IsValid)
            {
                int TaxID = 0;
                decimal Deci;
                OTAX objOTAX;
                if (ViewState["TaxID"] != null && Int32.TryParse(ViewState["TaxID"].ToString(), out TaxID))
                {
                    objOTAX = ctx.OTAXes.Include("TAX1").FirstOrDefault(x => x.TaxID == TaxID);
                }
                else
                {

                    if (ctx.OTAXes.Any(x => x.TaxName == txtTaxName.Text))
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Tax already exist!',3);", true);
                        return;
                    }
                    objOTAX = new OTAX();
                    objOTAX.TaxID = ctx.GetKey("OTAX", "TaxID", "", 0, 0).FirstOrDefault().Value;
                    objOTAX.TaxName = txtTaxName.Text;
                    objOTAX.CreatedDate = DateTime.Now;
                    objOTAX.CreatedBy = UserID;
                    ctx.OTAXes.Add(objOTAX);
                }
                objOTAX.TaxDesc = txtDesc.Text;
                objOTAX.Percentage = Decimal.TryParse(txtPercent.Text, out Deci) ? Deci : 0;
                objOTAX.Formula = txtFormula.Text;
                objOTAX.Type = ddlTaxType.SelectedValue.ToString();
                objOTAX.Active = chkActive.Checked;
                objOTAX.UpdatedDate = DateTime.Now;
                objOTAX.UpdatedBy = UserID;

                TAX1 objTAX1 = null;
                objOTAX.TAX1.ToList().ForEach(x => ctx.TAX1.Remove(x));
                int Count = ctx.GetKey("TAX1", "TAX1ID", "", 0, 0).FirstOrDefault().Value;

                foreach (TAX1 item in TAX1s)
                {
                    objTAX1 = new TAX1();
                    objTAX1.Tax1ID = Count++;
                    objTAX1.TaxID = objOTAX.TaxID;
                    objTAX1.Code = item.Code;
                    objTAX1.Percentage = item.Percentage;
                    objTAX1.Active = true;
                    objOTAX.TAX1.Add(objTAX1);
                }
                ctx.SaveChanges();
                ClearAllInputs();
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Record submitted successfully: " + objOTAX.TaxName + "',1);", true);
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
        Response.Redirect("Master.aspx");
    }

    #endregion

    #region Change Event

    protected void chkMode_Checked(object sender, EventArgs e)
    {
        ClearAllInputs();
    }

    protected void txtTaxName_TextChanged(object sender, EventArgs e)
    {
        try
        {
            if (!chkMode.Checked && !String.IsNullOrEmpty(txtTaxName.Text))
            {
                var objOTAXes = ctx.OTAXes.Include("TAX1").FirstOrDefault(x => x.TaxName == txtTaxName.Text);
                if (objOTAXes != null)
                {
                    txtTaxName.Text = objOTAXes.TaxName;
                    txtDesc.Text = objOTAXes.TaxDesc;
                    chkActive.Checked = objOTAXes.Active;
                    txtPercent.Text = objOTAXes.Percentage.ToString();
                    txtFormula.Text = objOTAXes.Formula;
                    ddlTaxType.SelectedValue = objOTAXes.Type;
                    ViewState["TaxID"] = objOTAXes.TaxID;

                    TAX1s = objOTAXes.TAX1.ToList();
                    gvTax.DataSource = TAX1s;
                    gvTax.DataBind();

                }
                else
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select proper tax!',3);", true);
                    ClearAllInputs();
                }
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
        txtDesc.Focus();
    }

    #endregion

    #region Grid View Command

    protected void gvTax_RowCommand(object sender, GridViewCommandEventArgs e)
    {

        if (e.CommandName == "EditTax")
        {
            int LineID = Convert.ToInt32(e.CommandArgument);
            ViewState["TAX1ID"] = LineID;
            txtRCode.Text = TAX1s[LineID].Code;
            txtRPercentage.Text = TAX1s[LineID].Percentage.ToString();
            btnAddTax.Text = "Update Tax";
        }
        else if (e.CommandName == "DeleteTax")
        {
            int LineID = Convert.ToInt32(e.CommandArgument);
            TAX1s.RemoveAt(LineID);
            gvTax.DataSource = TAX1s;
            gvTax.DataBind();
        }
    }

    protected void gvTax_PreRender(object sender, EventArgs e)
    {
        if (gvTax.Rows.Count > 0)
        {
            gvTax.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvTax.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }


    #endregion
}