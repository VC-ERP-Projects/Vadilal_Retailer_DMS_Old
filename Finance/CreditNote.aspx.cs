using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Finance_CreditNote : System.Web.UI.Page
{
    protected int UserID;
    protected decimal ParentID;
    protected String AuthType;
    DDMSEntities ctx;

    #region Helper Method

    private void ClearAllInputs()
    {
        ViewState["CreditNoteID"] = null;

        txtNotes.Text = txtRemainAmount.Text = txtCutomer.Text = txtAmount.Text = "";
        ddlStatus.SelectedValue = "O";

        txtValidTill.Text = txtCMDate.Text = Common.DateTimeConvert(DateTime.Now);

        txtCutomer.Focus();
        txtCutomer.Style.Add("background-color", "rgb(250, 255, 189);");

        gvCreditNote.DataSource = null;
        gvCreditNote.DataBind();
    }

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
                        var unit = xml.Descendants("credit_note");
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

    #region Button Click

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        try
        {
            if (Page.IsValid)
            {
                var Data = txtCutomer.Text.Split("-".ToArray());
                if (Data.Length == 2)
                {
                    var word = Data.First().Trim();
                    var Customer = ctx.OCRDs.FirstOrDefault(x => x.CustomerCode == word);
                    if (Customer != null)
                    {
                        int CreditNoteID = 0;
                        Decimal DecNum;
                        OCNT objOCNT;
                        if (ViewState["CreditNoteID"] != null && Int32.TryParse(ViewState["CreditNoteID"].ToString(), out CreditNoteID))
                        {
                            objOCNT = ctx.OCNTs.FirstOrDefault(x => x.CreditNoteID == CreditNoteID && x.ParentID == ParentID);
                        }
                        else
                        {
                            objOCNT = new OCNT();
                            objOCNT.CreditNoteID = ctx.GetKey("OCNT", "CreditNoteID", "", ParentID, 0).FirstOrDefault().Value;
                            objOCNT.ParentID = ParentID;
                            objOCNT.CreatedDate = DateTime.Now;
                            objOCNT.CreatedBy = UserID;
                            ctx.OCNTs.Add(objOCNT);
                        }

                        objOCNT.CreditNoteDate = Common.DateTimeConvert(txtCMDate.Text);
                        objOCNT.CustomerID = Customer.CustomerID;
                        objOCNT.CreditNoteType = "O";

                        if (Decimal.TryParse(txtAmount.Text, out DecNum))
                            objOCNT.Amount = DecNum;
                        if (Decimal.TryParse(txtRemainAmount.Text, out DecNum))
                            objOCNT.RemainAmount = DecNum;
                        else
                            objOCNT.RemainAmount = objOCNT.Amount;

                        if (!String.IsNullOrEmpty(txtValidTill.Text))
                            objOCNT.ValidTillDate = Common.DateTimeConvert(txtValidTill.Text);
                        if (ddlStatus.SelectedValue != "0")
                            objOCNT.Status = ddlStatus.SelectedValue.ToString();
                        objOCNT.Notes = txtNotes.Text;

                        objOCNT.UpdatedDate = DateTime.Now;
                        objOCNT.UpdatedBy = UserID;


                        ctx.SaveChanges();
                        ClearAllInputs();
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Record Submitted Successfully :" + objOCNT.CreditNoteID + "',1);", true);

                    }
                    else
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select proper customer!',3);", true);
                }
                else
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select proper customer!',3);", true);
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Page is invalid!',3);", true);
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        Response.Redirect("Finance.aspx");
    }

    #endregion

    protected void txtCutomer_TextChanged(object sender, EventArgs e)
    {
        List<OCNT> Data = new List<OCNT>();
        if (!String.IsNullOrEmpty(txtCutomer.Text))
        {
            var word = txtCutomer.Text.Split("-".ToArray()).First().Trim();
            var objCust = ctx.OCRDs.FirstOrDefault(x => x.CustomerCode.Contains(word));
            if (objCust != null)
            {
                Data = ctx.OCNTs.Include("OCRD").Where(x => x.CustomerID == objCust.CustomerID).OrderByDescending(x => x.CreditNoteID).ToList();
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select proper customer!',3);", true);
                txtCutomer.Text = "";
            }
        }
        gvCreditNote.DataSource = Data;
        gvCreditNote.DataBind();

    }

    protected void gvCreditNote_PageIndexChanging(object sender, GridViewPageEventArgs e)
    {
        gvCreditNote.PageIndex = e.NewPageIndex;
        txtCutomer_TextChanged(txtCutomer, EventArgs.Empty);
    }

    protected void gvCreditNote_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "EditItem")
        {
            int CreditNoteID = Convert.ToInt32(e.CommandArgument);
            var objOCNT = ctx.OCNTs.FirstOrDefault(x => x.CreditNoteID == CreditNoteID && x.ParentID == ParentID);
            if (objOCNT != null)
            {
                ViewState["CreditNoteID"] = CreditNoteID;

                txtAmount.Text = objOCNT.Amount.ToString("0.00");
                txtCMDate.Text = Common.DateTimeConvert(objOCNT.CreditNoteDate);
                txtRemainAmount.Text = objOCNT.RemainAmount.ToString("0.00");
                txtCutomer.Text = objOCNT.OCRD.CustomerCode + " - " + objOCNT.OCRD.CustomerName.Replace("-", " ");
                txtNotes.Text = objOCNT.Notes;
                if (objOCNT.ValidTillDate.HasValue)
                    txtValidTill.Text = Common.DateTimeConvert(objOCNT.ValidTillDate.Value);

                if (objOCNT.Status == "C")
                    txtAmount.Enabled = false;
            }
        }
    }

}