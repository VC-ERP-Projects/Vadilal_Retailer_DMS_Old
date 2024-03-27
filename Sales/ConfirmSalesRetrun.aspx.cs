using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Net;
using System.Web;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Xml.Linq;
using WebReference;

public partial class Sales_ConfirmSalesRetrun : System.Web.UI.Page
{
    #region Declaration

    protected int UserID;
    protected decimal ParentID;
    protected String AuthType;
    DDMSEntities ctx;
    string InwardNumber;
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

    #endregion

    #region Page Load

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        if (!IsPostBack)
        {
            //txtFromDate.Focus();
            txtToDate.Text = txtFromDate.Text = Common.DateTimeConvert(DateTime.Now);
            btnSearch_Click(null, null);
        }
    }

    #endregion

    #region Button Click
    protected void btnSearch_Click(object sender, EventArgs e)
    {
        try
        {
            DateTime start = Convert.ToDateTime(txtFromDate.Text);
            DateTime end = Convert.ToDateTime(txtToDate.Text).AddDays(1);

            string MessageType = ddlDisplay.SelectedValue.Trim();
            var lstData = ctx.ORETs.Where(x => x.ParentID == ParentID && x.Date >= start && x.Date <= end && x.Status == MessageType).ToList();

            btnCancelAll.Visible = false;
            btnResendAll.Visible = false;

            if (lstData.Count > 0)
            {
                if (MessageType == "O")
                {
                    gvOrder.Columns[0].Visible = true; // checkbox column
                    gvOrder.Columns[6].Visible = true;
                    btnResendAll.Visible = true;
                }
                else if (MessageType == "C")
                {
                    gvOrder.Columns[0].Visible = true; // checkbox column
                    gvOrder.Columns[6].Visible = false;
                    btnCancelAll.Visible = true;
                }
                else
                {
                    gvOrder.Columns[0].Visible = false; // checkbox column
                    gvOrder.Columns[6].Visible = false;
                }
            }

            gvOrder.DataSource = lstData;
            gvOrder.DataBind();
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',3);", true);
        }
    }

    protected void btnResendAll_Click(object sender, EventArgs e)
    {
        try
        {
            for (int i = 0; i < gvOrder.Rows.Count; i++)
            {
                HtmlInputCheckBox chkBox = (HtmlInputCheckBox)gvOrder.Rows[i].FindControl("chkCheck");
                Label lblOrderID = (Label)gvOrder.Rows[i].FindControl("lblOrderID");

                if (chkBox.Checked)
                {
                    int oretID = Convert.ToInt32(lblOrderID.Text);
                    ORET objORET = ctx.ORETs.FirstOrDefault(x => x.ORETID == oretID && x.ParentID == ParentID);
                    objORET.Status = "C";
                    objORET.UpdatedBy = UserID;
                    objORET.UpdatedDate = DateTime.Now;
                }
            }
            ctx.SaveChanges();
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Status changed successfully.',1);", true);
            btnSearch_Click(null, null);

        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',3);", true);
        }
    }

    protected void btnCancelAll_Click(object sender, EventArgs e)
    {
        try
        {
            for (int i = 0; i < gvOrder.Rows.Count; i++)
            {
                HtmlInputCheckBox chkBox = (HtmlInputCheckBox)gvOrder.Rows[i].FindControl("chkCheck");
                Label lblOrderID = (Label)gvOrder.Rows[i].FindControl("lblOrderID");

                if (chkBox.Checked)
                {
                    int oretID = Convert.ToInt32(lblOrderID.Text);
                    ORET objORET = ctx.ORETs.FirstOrDefault(x => x.ORETID == oretID && x.ParentID == ParentID);
                    objORET.Status = "L";
                    objORET.UpdatedBy = UserID;
                    objORET.UpdatedDate = DateTime.Now;
                }
            }
            ctx.SaveChanges();
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Status changed successfully.',1);", true);
            btnSearch_Click(null, null);
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',3);", true);
        }
    }

    #endregion

    #region GridView Events
    protected void gvOrder_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        try
        {
            if (e.CommandName == "RESEND")
            {
                int index = Convert.ToInt32(e.CommandArgument.ToString());
                Label lblOrderID = (Label)gvOrder.Rows[index].FindControl("lblOrderID");
                int ORETID = Convert.ToInt32(lblOrderID.Text);
                ORET objORET = null;
                objORET = ctx.ORETs.FirstOrDefault(x => x.ORETID == ORETID && x.ParentID == ParentID);

                // write code for SAP

                btnSearch_Click(null, null);
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',3);", true);
        }
    }
    #endregion

    protected void lnkViewDetail_Click(object sender, EventArgs e)
    {
        for (int i = 0; i < gvOrder.Rows.Count; i++)
        {
            Label lblOrderID = (Label)gvOrder.Rows[i].FindControl("lblOrderID");
            int OrderNumber = Convert.ToInt32(lblOrderID.Text);
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "ViewDetails(" + OrderNumber + ");", true);
        }
    }
}