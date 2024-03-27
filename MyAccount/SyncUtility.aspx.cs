using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Objects;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class MyAccount_SyncUtility : System.Web.UI.Page
{
    #region Declaration

    protected int UserID;
    protected decimal ParentID;
    protected String AuthType;

    #endregion

    #region Helper Method

    public void ClearAllInputs()
    {
        txtCustCode.Text = "";
        txtCustCode.Focus();
        gvOrder.DataSource = null;
        gvOrder.DataBind();
    }

    public void ValidateUser()
    {
        if (Session["UserID"] != null && Session["ParentID"] != null &&
          Int32.TryParse(Session["UserID"].ToString(), out UserID) && Decimal.TryParse(Session["ParentID"].ToString(), out ParentID))
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
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
                            var unit = xml.Descendants("authorization");
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

    #endregion

    #region Page Load

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        if (!IsPostBack)
        {
            ClearAllInputs();
            acetxtName.ContextKey = "2";
        }

    }

    #endregion

    #region Button Click

    protected void btnSearch_Click(object sender, EventArgs e)
    {
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                Decimal CustID = Decimal.TryParse(txtCustCode.Text.Split("-".ToArray()).Last().Trim(), out CustID) ? CustID : 0;
                if (CustID == 0)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper Distributor.',3);", true);
                    txtCustCode.Text = "";
                    return;
                }
                DateTime dt = new DateTime(2017, 6, 30);
                DateTime recdt = new DateTime(2017, 7, 1);
                var Data = ctx.OMIDs.Where(x => x.ParentID == CustID && x.InwardType == 2 && x.InvoiceDate.HasValue
                       && (EntityFunctions.TruncateTime(x.InvoiceDate.Value) <= EntityFunctions.TruncateTime(dt))).OrderByDescending(x => x.InvoiceDate)
                       .Select(x => new { x.InwardID, x.ParentID, x.InwardType, x.InvoiceNumber, x.BillNumber, x.Date, x.InvoiceDate, x.ReceiveDate, x.SubTotal, x.Tax, x.Total, TotalItems = x.MID1.Sum(y => y.TotalQty) }).ToList();

                var Data1 = ctx.OMIDs.Where(x => x.ParentID == CustID && x.InwardType == 3 && x.InvoiceDate.HasValue
                      && (EntityFunctions.TruncateTime(x.ReceiveDate) >= EntityFunctions.TruncateTime(recdt))
                      && (EntityFunctions.TruncateTime(x.InvoiceDate.Value) <= EntityFunctions.TruncateTime(dt))).OrderByDescending(x => x.InvoiceDate)
                         .Select(x => new { x.InwardID, x.ParentID, x.InwardType, x.InvoiceNumber, x.BillNumber, x.Date, x.InvoiceDate, x.ReceiveDate, x.SubTotal, x.Tax, x.Total, TotalItems = x.MID1.Sum(y => y.TotalQty) }).ToList();

                var rec = Data.Union(Data1).OrderByDescending(x => x.InvoiceDate).OrderByDescending(x => x.BillNumber);
                gvOrder.DataSource = rec;
                gvOrder.DataBind();
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',3);", true);
        }
    }

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        try
        {

            DateTime dt = new DateTime(2017, 6, 30);
            using (DDMSEntities ctx = new DDMSEntities())
            {
                Decimal CustID = Decimal.TryParse(txtCustCode.Text.Split("-".ToArray()).Last().Trim(), out CustID) ? CustID : 0;
                if (CustID == 0)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper Distributor.',3);", true);
                    txtCustCode.Text = "";
                    return;
                }

                int CountM = ctx.GetKey("ITM2", "StockID", "", CustID, null).FirstOrDefault().Value;
                foreach (GridViewRow gvr in gvOrder.Rows)
                {
                    CheckBox chkcheck = gvr.FindControl("chkcheck") as CheckBox;
                    if (chkcheck.Checked)
                    {
                        Label lblParentID = gvr.FindControl("lblParentID") as Label;
                        Label lblOrderID = gvr.FindControl("lblOrderID") as Label;

                        Decimal strParentID = Decimal.TryParse(lblParentID.Text.Split("-".ToArray()).Last().Trim(), out strParentID) ? strParentID : 0;
                        Int32 OrderID = Int32.TryParse(lblOrderID.Text.Split("-".ToArray()).Last().Trim(), out OrderID) ? OrderID : 0;

                        if (strParentID == 0 || OrderID == 0)
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select proper order number',3);", true);
                            return;
                        }
                        OMID objOMID = ctx.OMIDs.Include("MID1").FirstOrDefault(x => x.InwardID == OrderID && x.ParentID == strParentID);
                        if (objOMID == null)
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select proper order',3);", true);
                            return;
                        }
                        if (objOMID.InwardType == 2)
                        {
                            objOMID.ReceiveDate = dt.Add(DateTime.Now.TimeOfDay);
                            objOMID.InwardType = 3;
                            objOMID.UpdatedDate = dt.Add(DateTime.Now.TimeOfDay);
                            objOMID.UpdatedBy = UserID;
                            objOMID.Notes = "Auto";
                            OSEQ objOSEQ = ctx.OSEQs.Where(x => x.ParentID == strParentID && !x.IsDeleted && x.Type == "P" && EntityFunctions.TruncateTime(x.FromDate) <= EntityFunctions.TruncateTime(objOMID.ReceiveDate) && EntityFunctions.TruncateTime(x.ToDate) >= EntityFunctions.TruncateTime(objOMID.ReceiveDate)).FirstOrDefault();

                            if (objOSEQ != null)
                            {
                                objOSEQ.RorderNo++;
                                objOMID.InvoiceNumber = objOSEQ.Prefix + objOSEQ.RorderNo.ToString("D6");
                            }
                            else
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Invoice Series not found',3);", true);
                                return;
                            }
                            foreach (MID1 objMID1 in objOMID.MID1)
                            {
                                objMID1.DiffirenceQty = 0;
                                objMID1.RecieptQty = objMID1.DisptchQty;
                                objMID1.TotalQty = objMID1.MapQty * objMID1.RecieptQty;
                                ITM2 ITM2 = ctx.ITM2.FirstOrDefault(x => x.ParentID == strParentID && x.WhsID == objOMID.ToWhsID && x.ItemID == objMID1.ItemID);
                                if (ITM2 == null)
                                {
                                    ITM2 = new ITM2();
                                    ITM2.StockID = CountM++;
                                    ITM2.ParentID = strParentID;
                                    ITM2.WhsID = objOMID.ToWhsID;
                                    ITM2.ItemID = objMID1.ItemID;
                                    //ITM2.PPrice = objMID1.UnitPrice;
                                    ctx.ITM2.Add(ITM2);
                                }
                                ITM2.PPrice = objMID1.UnitPrice;
                                //else
                                //{
                                //    if ((ITM2.TotalPacket + objMID1.TotalQty) == 0)
                                //        ITM2.PPrice = ((ITM2.TotalPacket * ITM2.PPrice) + (objMID1.UnitPrice * objMID1.TotalQty)) / 1;
                                //    else
                                //        ITM2.PPrice = ((ITM2.TotalPacket * ITM2.PPrice) + (objMID1.UnitPrice * objMID1.TotalQty)) / (ITM2.TotalPacket + objMID1.TotalQty);
                                //}
                                if (objMID1.RecieptQty > 0)
                                {
                                    ITM2.TotalPacket += objMID1.TotalQty;
                                }
                            }
                        }
                    }
                }

                ctx.SaveChanges();

                try
                {
                    Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
                    SqlCommand Cm = new SqlCommand();

                    Cm.Parameters.Clear();
                    Cm.CommandType = CommandType.StoredProcedure;
                    Cm.CommandText = "ChangeOMID";
                    Cm.Parameters.AddWithValue("@ParentID", CustID);
                    objClass.CommonFunctionForSelect(Cm);
                }
                catch (Exception ex)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',3);", true);
                    return;
                }
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Record submitted successfully',1);", true);
                ClearAllInputs();
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',3);", true);
        }
    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        try
        {

            DateTime dt = new DateTime(2017, 6, 30);
            using (DDMSEntities ctx = new DDMSEntities())
            {
                Decimal CustID = Decimal.TryParse(txtCustCode.Text.Split("-".ToArray()).Last().Trim(), out CustID) ? CustID : 0;
                if (CustID == 0)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper Distributor.',3);", true);
                    txtCustCode.Text = "";
                    return;
                }

                foreach (GridViewRow gvr in gvOrder.Rows)
                {
                    CheckBox chkcheck = gvr.FindControl("chkcheck") as CheckBox;
                    if (chkcheck.Checked)
                    {
                        Label lblParentID = gvr.FindControl("lblParentID") as Label;
                        Label lblOrderID = gvr.FindControl("lblOrderID") as Label;

                        Decimal strParentID = Decimal.TryParse(lblParentID.Text.Split("-".ToArray()).Last().Trim(), out strParentID) ? strParentID : 0;
                        Int32 OrderID = Int32.TryParse(lblOrderID.Text.Split("-".ToArray()).Last().Trim(), out OrderID) ? OrderID : 0;

                        if (strParentID == 0 || OrderID == 0)
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select proper order number',3);", true);
                            return;
                        }
                        OMID objOMID = ctx.OMIDs.Include("MID1").FirstOrDefault(x => x.InwardID == OrderID && x.ParentID == strParentID);
                        if (objOMID == null)
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select proper order',3);", true);
                            return;
                        }
                        if (objOMID.InwardType == 2)
                        {
                            objOMID.InwardType = 5;
                            objOMID.UpdatedDate = dt.Add(DateTime.Now.TimeOfDay);
                            objOMID.UpdatedBy = UserID;
                            objOMID.Notes = "Auto";
                        }
                    }
                }
                ctx.SaveChanges();
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Record submitted successfully',1);", true);
                ClearAllInputs();
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',3);", true);
        }
    }

    #endregion
}