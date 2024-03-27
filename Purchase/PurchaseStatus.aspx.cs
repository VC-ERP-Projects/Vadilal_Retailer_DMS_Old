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
using System.Web.Services;
using System.Data.Objects;
using System.Net.Mail;

public partial class Purchase_PurchaseStatus : System.Web.UI.Page
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

    public void ClearAllInputs()
    {
        if (CustType == 1)
        {
            divInward.Visible = false;
        }
        else
        {
            divInward.Visible = true;
            acetxtDocNumber.ContextKey = "1," + ParentID;
        }
        txtDocNo.Text = "";
        txtDocNo.Style.Add("background-color", "rgb(250, 255, 189);");
        txtToDate.Text = txtFromDate.Text = Common.DateTimeConvert(DateTime.Now);
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

    protected void btnSearch_Click(object sender, EventArgs e)
    {
        using (DDMSEntities ctx = new DDMSEntities())
        {
            //if (CustType == 1)
            //    gvOrder.Columns[1].Visible = true;
            //else
            //    gvOrder.Columns[1].Visible = false;

            var word = txtDocNo.Text.Split("-".ToArray()).First().Trim();
            if (!String.IsNullOrEmpty(word))
            {
                int InwardID = Int32.TryParse(word, out InwardID) ? InwardID : 0;

                var objOMIDs = (from a in ctx.OMIDs
                                join b in ctx.ODIVs on a.DivisionID.Value equals b.DivisionlID into M
                                from Division in M.DefaultIfEmpty()
                                join c in ctx.OPLTs on a.PlantID.Value equals c.PlantID into N
                                from Plant in N.DefaultIfEmpty()
                                join d in ctx.OCRDs on a.ParentID equals d.CustomerID
                                where a.InwardType == 1 && a.InwardID == InwardID && a.ParentID == ParentID && a.VendorParentID == 1000010000000000
                                select new
                                {
                                    Date = a.Date,
                                    InvoiceNumber = a.InvoiceNumber,
                                    InwardID = a.InwardID,
                                    ParentID = a.ParentID,
                                    DivisionName = (Division == null ? "" : Division.DivisionName),
                                    PlantName = (Plant == null ? "" : Plant.PlantCode + " # " + Plant.PlantName),
                                    Qty = a.MID1.Select(x => x.TotalQty).DefaultIfEmpty(0).Sum(),
                                    GrossAmount = a.SubTotal,
                                    TaxAmount = a.Tax,
                                    NetAmount = a.Total,
                                    PaidAmount = a.Paid,
                                    PendingAmount = a.Pending,
                                    Message = a.Ref1.Substring(0, 100),
                                    Ref2 = a.Ref2,
                                    CustCode = d.CustomerCode,
                                    Customer = d.CustomerCode + " # " + d.CustomerName,
                                    UpdatedDte = a.UpdatedDate
                                }).OrderBy(x => x.Date).ThenBy(x => x.CustCode).ToList();

                if (objOMIDs.Count > 0)
                {
                    gvOrder.DataSource = objOMIDs;
                    gvOrder.DataBind();
                    string str = objOMIDs.FirstOrDefault().Ref2 == null ? "ERROR" : objOMIDs.FirstOrDefault().Ref2;

                    if (str.ToUpper().Trim() == "SUCCESS")
                    {
                        ddlDisplay.SelectedValue = "1";
                        foreach (GridViewRow item in gvOrder.Rows)
                        {
                            item.FindControl("btnResend").Visible = false;
                        }
                    }
                    else
                    {
                        ddlDisplay.SelectedValue = "2";
                        foreach (GridViewRow item in gvOrder.Rows)
                        {
                            item.FindControl("btnResend").Visible = true;
                        }
                    }
                }
                else
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select proper inward number',3);", true);
                    return;
                }
            }
            else
            {
                DateTime start = Convert.ToDateTime(txtFromDate.Text);
                DateTime end = Convert.ToDateTime(txtToDate.Text);

                if (CustType == 1)
                {
                    var objOMIDs = (from a in ctx.OMIDs
                                    join b in ctx.ODIVs on a.DivisionID.Value equals b.DivisionlID into M
                                    from Division in M.DefaultIfEmpty()
                                    join c in ctx.OPLTs on a.PlantID.Value equals c.PlantID into N
                                    from Plant in N.DefaultIfEmpty()
                                    join d in ctx.OCRDs on a.ParentID equals d.CustomerID
                                    where a.InwardType == 1 && a.VendorParentID == 1000010000000000 && (ddlDisplay.SelectedValue == "1" ? a.Ref2 == "SUCCESS" : (a.Ref2 == null || a.Ref2 != "SUCCESS"))
                                          && EntityFunctions.TruncateTime(a.Date) >= start && EntityFunctions.TruncateTime(a.Date) <= end
                                    select new
                                    {
                                        Date = a.Date,
                                        InvoiceNumber = a.InvoiceNumber,
                                        InwardID = a.InwardID,
                                        ParentID = a.ParentID,
                                        DivisionName = (Division == null ? "" : Division.DivisionName),
                                        PlantName = (Plant == null ? "" : Plant.PlantCode + " # " + Plant.PlantName),
                                        Qty = a.MID1.Select(x => x.TotalQty).DefaultIfEmpty(0).Sum(),
                                        GrossAmount = a.SubTotal,
                                        TaxAmount = a.Tax,
                                        NetAmount = a.Total,
                                        PaidAmount = a.Paid,
                                        PendingAmount = a.Pending,
                                        Message = a.Ref1.Substring(0, 100),
                                        Ref2 = a.Ref2,
                                        CustCode = d.CustomerCode,
                                        Customer = d.CustomerCode + " # " + d.CustomerName,
                                        UpdatedDte = a.UpdatedDate
                                    }).OrderBy(x => x.Date).ThenBy(x => x.CustCode).ToList();

                    gvOrder.DataSource = objOMIDs;
                }
                else
                {

                    var objOMIDs = (from a in ctx.OMIDs
                                    join b in ctx.ODIVs on a.DivisionID.Value equals b.DivisionlID into M
                                    from Division in M.DefaultIfEmpty()
                                    join c in ctx.OPLTs on a.PlantID.Value equals c.PlantID into N
                                    from Plant in N.DefaultIfEmpty()
                                    join d in ctx.OCRDs on a.ParentID equals d.CustomerID
                                    where a.InwardType == 1 && a.VendorParentID == 1000010000000000 && a.ParentID == ParentID && (ddlDisplay.SelectedValue == "1" ? a.Ref2 == "SUCCESS" : (a.Ref2 == null || a.Ref2 != "SUCCESS"))
                                        && EntityFunctions.TruncateTime(a.Date) >= start && EntityFunctions.TruncateTime(a.Date) <= end
                                    select new
                                    {
                                        Date = a.Date,
                                        InvoiceNumber = a.InvoiceNumber,
                                        InwardID = a.InwardID,
                                        ParentID = a.ParentID,
                                        DivisionName = (Division == null ? "" : Division.DivisionName),
                                        PlantName = (Plant == null ? "" : Plant.PlantCode + " # " + Plant.PlantName),
                                        Qty = a.MID1.Select(x => x.TotalQty).DefaultIfEmpty(0).Sum(),
                                        GrossAmount = a.SubTotal,
                                        TaxAmount = a.Tax,
                                        NetAmount = a.Total,
                                        PaidAmount = a.Paid,
                                        PendingAmount = a.Pending,
                                        Message = a.Ref1.Substring(0, 100),
                                        Ref2 = a.Ref2,
                                        CustCode = d.CustomerCode,
                                        Customer = d.CustomerCode + " # " + d.CustomerName,
                                        UpdatedDte = a.UpdatedDate
                                    }).OrderBy(x => x.Date).ThenBy(x => x.CustCode).ToList();

                    gvOrder.DataSource = objOMIDs;
                }
                gvOrder.DataBind();

                if (ddlDisplay.SelectedValue == "1")
                {
                    foreach (GridViewRow item in gvOrder.Rows)
                    {
                        item.FindControl("btnResend").Visible = false;
                    }
                }
                else
                {
                    foreach (GridViewRow item in gvOrder.Rows)
                    {
                        item.FindControl("btnResend").Visible = true;
                    }
                }
            }
        }
    }

    protected void gvOrder_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "RESEND")
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                int index = Convert.ToInt32(e.CommandArgument.ToString());

                Label lblOrderID = (Label)gvOrder.Rows[index].FindControl("lblOrderID");
                Label lblParentID = (Label)gvOrder.Rows[index].FindControl("lblParentID");

                int inwaredid = Convert.ToInt32(lblOrderID.Text);
                decimal orderparentid = Convert.ToDecimal(lblParentID.Text);

                OMID objOMID = ctx.OMIDs.FirstOrDefault(x => x.InwardID == inwaredid && x.ParentID == orderparentid && x.VendorParentID == 1000010000000000);

                try
                {
                    if (objOMID != null && objOMID.InProcess.GetValueOrDefault(false) == false)
                    {
                        //objOMID.InProcess = true;
                        //ctx.SaveChanges();

                        OCFG objOCFG = ctx.OCFGs.FirstOrDefault();

                        if (objOMID.DivisionID.HasValue)
                        {
                            var objMIDs = objOMID.MID1.ToList();

                            if (ctx.OGCRDs.Any(x => x.PlantID != null && x.DivisionlID == objOMID.DivisionID.Value && x.CustomerID == orderparentid)
                            && ctx.OGCRDs.Any(x => x.SaleOrgID != null && x.CustomerID == orderparentid))
                            {
                                OPLT objOPLT = ctx.OGCRDs.FirstOrDefault(x => x.PlantID != null && x.DivisionlID == objOMID.DivisionID.Value && x.CustomerID == orderparentid).OPLT;
                                objOMID.PlantID = objOPLT.PlantID;
                                ctx.SaveChanges();

                                //#region INDENT

                                //try
                                //{
                                //    DT_IndentCreation_Response Response = new DT_IndentCreation_Response();
                                //    SI_SynchOut_IndentCreationService _proxy = new SI_SynchOut_IndentCreationService();
                                //    _proxy.Url = objOCFG.SAPLINK;
                                //    _proxy.Timeout = 3000000;
                                //    _proxy.Credentials = new NetworkCredential(objOCFG.UserID, objOCFG.Password);
                                //    DT_IndentCreation_Request Request = new DT_IndentCreation_Request();
                                //    DT_IndentCreation_RequestItem[] D4 = new DT_IndentCreation_RequestItem[1];
                                //    DT_IndentCreation_RequestItem1[] D5 = new DT_IndentCreation_RequestItem1[objMIDs.Count];
                                //    Request = new DT_IndentCreation_Request();

                                //    string CustomerCode = ctx.OCRDs.FirstOrDefault(x => x.CustomerID == orderparentid).CustomerCode;
                                //    D4 = new DT_IndentCreation_RequestItem[1];

                                //    int j = 0;
                                //    D4[j] = new DT_IndentCreation_RequestItem();
                                //    D4[j].DistributionChannel = "11";
                                //    D4[j].Division = ctx.ODIVs.FirstOrDefault(x => x.DivisionlID == objOMID.DivisionID.Value).DivisionCode;
                                //    D4[j].DocumentType = "ZORD";
                                //    D4[j].SalesOrganization = ctx.OGCRDs.FirstOrDefault(x => x.SaleOrgID != null && x.DivisionlID == objOMID.DivisionID.Value && x.PlantID == objOPLT.PlantID && x.CustomerID == orderparentid).OSRG.SaleOrgCode;
                                //    D4[j].ShipToParty = CustomerCode;
                                //    D4[j].SoldToParty = CustomerCode;
                                //    D4[j].TransactionType = "A";
                                //    D4[j].Plant = objOPLT.PlantCode;
                                //    D4[j].DMS_REFNO = objOMID.InwardID.ToString();

                                //    int i = 0;
                                //    D5 = new DT_IndentCreation_RequestItem1[objMIDs.Count];
                                //    foreach (var obj in objMIDs)
                                //    {
                                //        if (i > objMIDs.Count)
                                //        {
                                //            break;
                                //        }
                                //        D5[i] = new DT_IndentCreation_RequestItem1();
                                //        D5[i].MaterialNumber = ctx.OITMs.FirstOrDefault(x => x.ItemID == obj.ItemID).ItemCode;
                                //        D5[i].Quantity = obj.RequestQty.ToString("0.000");
                                //        i = i + 1;
                                //    }
                                //    Request.REPEAT_FLAG = "X";
                                //    Request.IT_HEADER = D4;
                                //    Request.IT_ITEM = D5;
                                //    Response = _proxy.SI_SynchOut_IndentCreation(Request);
                                //    objOMID.Ref1 = Response.MESSAGE;
                                //    objOMID.Ref2 = Response.FLAG;
                                //    objOMID.Ref3 = Response.NUMBER_INDENT;
                                //    objOMID.Ref4 = Response.STATUS;
                                //    objOMID.UpdatedDate = DateTime.Now;
                                //    objOMID.InProcess = false;
                                //    ctx.SaveChanges();
                                //    if (Convert.ToString(Response.FLAG).ToUpper() == "SUCCESS")
                                //    {
                                //        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Response.MESSAGE + "',1);", true);
                                //    }
                                //    else
                                //    {
                                //        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Response.MESSAGE + "',2);", true);
                                //    }
                                //}

                                //catch (Exception ex)
                                //{
                                //    objOMID.Ref1 = Common.GetString(ex);
                                //    objOMID.Ref2 = "ERROR";
                                //    objOMID.UpdatedDate = DateTime.Now;
                                //    objOMID.InProcess = false;
                                //    ctx.SaveChanges();
                                //    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + objOMID.Ref1 + "',2);", true);
                                //}

                                //#endregion

                                #region Company Email

                                try
                                {
                                    string CustomerCode = ctx.OCRDs.FirstOrDefault(x => x.CustomerID == orderparentid).CustomerCode;

                                    EML2 objEML2 = ctx.EML2.FirstOrDefault(x => x.PlantID == objOPLT.PlantID && x.DocType == "P");
                                    if (objEML2 != null)
                                    {
                                        try
                                        {
                                            var Message = Common.GetMailBodyPurchase(objOMID.InwardID, objOMID.ParentID);
                                            var FileName = Server.MapPath("~/Document/POExport/") + Guid.NewGuid().ToString("N") + ".csv";
                                            Common.GetExcelBody(FileName, objOMID.InwardID, objOMID.ParentID);

                                            List<Attachment> Attchs = new List<Attachment>();
                                            var at = new Attachment(FileName);
                                            at.Name = CustomerCode + "_" + objOMID.InvoiceNumber + "_" + objOMID.InwardID + ".csv";
                                            Attchs.Add(at);
                                            Common.SendMail("Vadilal - Purchase Order", Message, objEML2.FailureEmail, "", null, Attchs);
                                        }
                                        catch (Exception)
                                        {

                                        }
                                    }
                                }
                                catch (Exception)
                                {

                                }
                                #endregion
                            }
                            else
                            {
                                objOMID.Ref1 = "Plant or SaleOrg not map";
                                objOMID.Ref2 = "ERROR";
                                objOMID.UpdatedDate = DateTime.Now;
                                objOMID.InProcess = false;
                                ctx.SaveChanges();
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + objOMID.Ref1 + "',2);", true);
                            }
                        }
                        else
                        {
                            objOMID.Ref1 = "Division Not Found";
                            objOMID.Ref2 = "ERROR";
                            objOMID.UpdatedDate = DateTime.Now;
                            objOMID.InProcess = false;
                            ctx.SaveChanges();
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + objOMID.Ref1 + "',2);", true);
                        }
                    }
                    else
                    {
                        objOMID.Ref1 = "Please wait for sometime your order is in InProcess.";
                        objOMID.Ref2 = "ERROR";
                        objOMID.UpdatedDate = DateTime.Now;
                        ctx.SaveChanges();
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + objOMID.Ref1 + "',2);", true);
                    }
                }
                catch (Exception ex)
                {
                    objOMID.Ref1 = ex.Message;
                    objOMID.Ref2 = "ERROR";
                    objOMID.UpdatedDate = DateTime.Now;
                    objOMID.InProcess = false;
                    ctx.SaveChanges();
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + ex.Message + "',2);", true);
                }
            }
            btnSearch_Click(null, null);
        }
    }

    //protected void gvOrder_RowDataBound(object sender, GridViewRowEventArgs e)
    //{
    //    if (e.Row.RowType == DataControlRowType.DataRow)
    //    {
    //        if (CustType == 1)
    //        {
    //            Label lblCustName = (Label)e.Row.FindControl("lblCustName");
    //            Label lblParentID = (Label)e.Row.FindControl("lblParentID");

    //            using (DDMSEntities ctx = new DDMSEntities())
    //            {
    //                Decimal parentid = Decimal.TryParse(lblParentID.Text, out parentid) ? parentid : 0;
    //                var Cust = ctx.OCRDs.FirstOrDefault(x => x.CustomerID == parentid);
    //                lblCustName.Text = Cust.CustomerCode + " # " + Cust.CustomerName;
    //            }
    //        }
    //    }
    //}

    #endregion
    protected void gvOrder_PreRender(object sender, EventArgs e)
    {
        if (gvOrder.Rows.Count > 0)
        {
            gvOrder.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvOrder.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }
}