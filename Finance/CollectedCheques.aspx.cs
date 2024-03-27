using System;
using System.IO;
using System.Linq;
using System.Net;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Finance_CollectedCheques : System.Web.UI.Page
{
    protected int UserID;
    protected decimal ParentID;
    protected String AuthType;
    DDMSEntities ctx;

    #region Helper Method

    public void ClearAllInputs()
    {
        var Data = (from c in ctx.POS2.Include("OPOS")
                    where c.ParentID == ParentID && c.PaymentMode == 3 && c.Status == ddlStatus.SelectedValue
                    select new
                    {
                        c.POS2ID,
                        CustomerID = c.OPOS.CustomerID,
                        c.DocName,
                        c.DocNo,
                        c.Date,
                        c.Amount,
                        c.Status,
                        c.DepositDate,
                        c.ReconcileDate
                    }).ToList();

        gvCollectedCheques.DataSource = Data;
        gvCollectedCheques.DataBind();

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
                        var unit = xml.Descendants("collected_cheques");
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

    protected void btnDeposit_Click(object sender, EventArgs e)
    {
        try
        {
            if (Page.IsValid)
            {

                int POS2ID;
                DateTime dt;
                int CountJE = ctx.GetKey("OJET", "JournalID", "", ParentID, 0).FirstOrDefault().Value;
                foreach (GridViewRow item in gvCollectedCheques.Rows)
                {
                    CheckBox chkCheck = (CheckBox)item.FindControl("chkCheck");
                    if (chkCheck.Checked)
                    {
                        Label lblID = ((Label)item.FindControl("lblID"));
                        if (lblID != null && Int32.TryParse(lblID.Text, out POS2ID) && POS2ID > 0)
                        {
                            var objPOS2 = ctx.POS2.FirstOrDefault(x => x.POS2ID == POS2ID && x.ParentID == ParentID);
                            if (objPOS2 != null)
                            {
                                DropDownList ddlStatus = (DropDownList)item.FindControl("ddlStatus");
                                TextBox txtDepositDate = (TextBox)item.FindControl("txtDepositDate");
                                TextBox txtReconcileDate = (TextBox)item.FindControl("txtReconcileDate");
                                TextBox txtNotes = (TextBox)item.FindControl("txtNotes");

                                if (Common.DateTimeConvert(txtReconcileDate.Text, out dt))
                                    objPOS2.ReconcileDate = dt;
                                if (Common.DateTimeConvert(txtDepositDate.Text, out dt))
                                    objPOS2.DepositDate = dt;
                                objPOS2.Notes = txtNotes.Text;
                                objPOS2.Status = ddlStatus.SelectedValue;
                            }
                        }
                    }
                }
                ctx.SaveChanges();
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Cheques deposited successfully!',1);", true);
                ClearAllInputs();

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

    protected void ddlStatus_SelectedIndexChanged(object sender, EventArgs e)
    {
        ClearAllInputs();
    }

    protected void gvCollectedCheques_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            Label lblCustomerID = (Label)e.Row.FindControl("lblCustomerID");
            Label lblCustomerName = (Label)e.Row.FindControl("lblCustomerName");

            Decimal CID;
            if (!String.IsNullOrEmpty(lblCustomerID.Text) && Decimal.TryParse(lblCustomerID.Text, out CID) && CID > 0)
            {
                var objOCRD = ctx.OCRDs.FirstOrDefault(x => x.CustomerID == CID && x.ParentID == ParentID);
                if (objOCRD != null)
                    lblCustomerName.Text = objOCRD.CustomerName;
            }
        }
    }
}