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
using ReturnReference;
using System.Data.Objects.SqlClient;
using System.Data.Objects;

public partial class Purchase_PurchaseReturnStatus : System.Web.UI.Page
{

    #region Declaration

    protected int UserID;
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
            DateTime end = Convert.ToDateTime(txtToDate.Text);

            string MessageType = ddlDisplay.SelectedValue.Trim();
            var lstData = (from c in ctx.ORETs
                           join d in ctx.OCRDs on c.ParentID equals d.CustomerID
                           join y in ctx.OMIDs on new { c.BillRefNo, c.ParentID } equals new { BillRefNo = SqlFunctions.StringConvert((double)y.InwardID).Trim(), y.ParentID }
                           where EntityFunctions.TruncateTime(c.Date) >= start && EntityFunctions.TruncateTime(c.Date) <= end && c.Status == MessageType
                           && c.Type == "4" && c.BillRefNo != null
                           select new
                           {
                               c.ORETID,
                               Customer = d.CustomerCode + " - " + d.CustomerName,
                               c.ParentID,
                               c.Date,
                               c.InvoiceNumber,
                               c.BillRefNo,
                               c.Amount,
                               c.Ref1,
                               y.BillNumber
                           }).ToList();

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

                if (chkBox.Checked)
                {
                    Label lblOrderID = (Label)gvOrder.Rows[i].FindControl("lblOrderID");
                    Label lblParentID = (Label)gvOrder.Rows[i].FindControl("lblParentID");

                    int oretID = Convert.ToInt32(lblOrderID.Text);
                    Decimal lblparentid = Convert.ToDecimal(lblParentID.Text);

                    ORET objORET = ctx.ORETs.FirstOrDefault(x => x.ORETID == oretID && x.ParentID == lblparentid);
                    if (objORET != null)
                    {
                        objORET.Status = "C";
                        objORET.UpdatedBy = UserID;
                        objORET.UpdatedDate = DateTime.Now;
                    }
                }
            }
            ctx.SaveChanges();
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Status changed successfully.',1);", true);
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

                if (chkBox.Checked)
                {
                    Label lblOrderID = (Label)gvOrder.Rows[i].FindControl("lblOrderID");
                    Label lblParentID = (Label)gvOrder.Rows[i].FindControl("lblParentID");

                    int oretID = Convert.ToInt32(lblOrderID.Text);
                    Decimal lblparentid = Convert.ToDecimal(lblParentID.Text);

                    ORET objORET = ctx.ORETs.FirstOrDefault(x => x.ORETID == oretID && x.ParentID == lblparentid);
                    if (objORET != null)
                    {
                        objORET.Status = "L";
                        objORET.UpdatedBy = UserID;
                        objORET.UpdatedDate = DateTime.Now;
                    }
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
                Label lblParentID = (Label)gvOrder.Rows[index].FindControl("lblParentID");

                HiddenField hdnBillNumber = (HiddenField)gvOrder.Rows[index].FindControl("hdnBillNumber");

                int ORETID = Convert.ToInt32(lblOrderID.Text);
                Decimal lblparentid = Convert.ToDecimal(lblParentID.Text);

                ORET objORET = null;
                objORET = ctx.ORETs.FirstOrDefault(x => x.ORETID == ORETID && x.ParentID == lblparentid);
                if (objORET != null)
                {

                    try
                    {

                        OCFG objOCFG = ctx.OCFGs.FirstOrDefault();

                        var objRET1s = objORET.RET1.ToList();

                        DT_ReturnOrder_Response Res = new DT_ReturnOrder_Response();
                        SI_SynchOut_ReturnOrderService _proxy = new SI_SynchOut_ReturnOrderService();
                        _proxy.Url = objOCFG.SAPRLINK;
                        _proxy.Timeout = 3000000;
                        _proxy.Credentials = new NetworkCredential(objOCFG.UserID, objOCFG.Password);
                        DT_ReturnOrder_Request Req = new DT_ReturnOrder_Request();
                        Req.INVOICE_NO = Convert.ToString(hdnBillNumber.Value);

                        DT_ReturnOrder_RequestItem[] Item = new DT_ReturnOrder_RequestItem[1];

                        int i = 0;
                        Item = new DT_ReturnOrder_RequestItem[objRET1s.Count];

                        foreach (RET1 obj in objRET1s)
                        {
                            if (i > objRET1s.Count)
                            {
                                break;
                            }
                            Item[i] = new DT_ReturnOrder_RequestItem();
                            Item[i].MATERIAL_NO = obj.OITM.ItemCode;
                            Item[i].QUANTITY = Convert.ToString(obj.Quantity.ToString("0.000"));
                            Item[i].POSITION_NO = obj.RANKNO;
                            Item[i].UNIT = obj.OUNT.UnitCode;

                            i++;
                        }

                        Req.REASON = "V22";
                        Req.IT_ITEM = Item;
                        Res = _proxy.SI_SynchOut_ReturnOrder(Req);
                        if (Res.FLAG.ToUpper() == "SUCCESS")
                        {
                            objORET.Status = "C";
                            objORET.Ref1 = Res.NUMBER_DOC;
                            objORET.ErrMsg = Res.MESSAGE;
                        }
                        else
                        {
                            DT_ReturnOrder_ResponseITEM[] ItemFs = Res.FAULTY;
                            foreach (DT_ReturnOrder_ResponseITEM item in ItemFs)
                            {
                                RET1 objRET1 = objRET1s.FirstOrDefault(x => x.OITM.ItemCode == item.MATERIAL);
                                objRET1.Desc = item.DESCRIPTION;
                                //objRET1.MSG_TYPE = item.MSG_TYPE;
                            }
                            objORET.Ref1 = Res.NUMBER_DOC;
                            objORET.ErrMsg = Res.MESSAGE;
                        }

                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('DOC : " + Res.NUMBER_DOC + " MSG :" + Res.MESSAGE + "',1);", true);
                        ctx.SaveChanges();

                    }
                    catch (Exception ex)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',3);", true);
                    }
                }

                btnSearch_Click(null, null);
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',3);", true);
        }
    }

    #endregion
}