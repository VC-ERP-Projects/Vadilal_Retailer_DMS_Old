using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Sales_OpenOrders : System.Web.UI.Page
{
    #region Property
    protected int UserID;
    protected decimal ParentID;
    protected String AuthType;
    DDMSEntities ctx;
    #endregion

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        if (!IsPostBack)
        {
            if (Session["SaleOrderDelivery"] != null)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Order Inserted Successfully: OrderID: " + Convert.ToString(Session["SaleOrderDelivery"]) + "',1);", true);
                Session["SaleOrderDelivery"] = null;
            }
            ClearAllInputs();
        }
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
                        var unit = xml.Descendants("Inward");
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

    public void ClearAllInputs()
    {
        var DayCloseData = ctx.CheckDayClose(DateTime.Now, ParentID).FirstOrDefault();
        if (!String.IsNullOrEmpty(DayCloseData))
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + DayCloseData + "',3);", true);
            btnSearch.Visible = false;
            return;
        }
        else
        {
            btnSearch.Visible = true;
        }
        gvItem.Visible = false;
        txtFromDate.Text = DateTime.Today.ToString("dd/MM/yyyy");
        txtToDate.Text = DateTime.Today.AddDays(1).ToString("dd/MM/yyyy");
        chkIsMobile.Checked = true;
        ddlType.SelectedValue = "O";

        DateTime frmDate = Convert.ToDateTime(txtFromDate.Text);
        DateTime toDate = Convert.ToDateTime(txtToDate.Text);

        FillGridData(frmDate, toDate, chkIsMobile.Checked, ddlType.SelectedValue);
    }

    protected void gvItem_PreRender(object sender, EventArgs e)
    {
        if (gvItem.Rows.Count > 0)
        {
            gvItem.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvItem.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }

    protected void btnSearch_Click(object sender, EventArgs e)
    {
        DateTime frmDate = Convert.ToDateTime(txtFromDate.Text);
        DateTime toDate = Convert.ToDateTime(txtToDate.Text);

        FillGridData(frmDate, toDate, chkIsMobile.Checked, ddlType.SelectedValue);
    }

    public void FillGridData(DateTime frmDate, DateTime toDate, bool mobileFlag, string type)
    {
        if (type == "O")
        {
            var orders = ctx.OPOS.Include("OCRD").Include("OCRD.CRD1").Where(x => x.OrderType == 11 && x.ParentID == ParentID && x.IsMobile == mobileFlag && (x.Date >= frmDate && x.Date <= toDate)).Select(c => new
            {
                BillRefNo = c.BillRefNo,
                Date = c.Date,
                CustomerName = c.OCRD.CustomerName,
                Address = c.OCRD.CRD1.FirstOrDefault(y => y.IsDeleted == false).Address1 + " " + c.OCRD.CRD1.FirstOrDefault(y => y.IsDeleted == false).Address2,
                ZipCode = c.OCRD.CRD1.FirstOrDefault(y => y.IsDeleted == false).ZipCode,
                PhoneNumber = c.OCRD.Phone,
                Total = c.Total,
                SubTotal = c.SubTotal,
                Discount = c.Discount,
                SaleID = c.SaleID

            }).ToList();

            gvItem.Visible = true;
            gvItem.DataSource = orders;
            gvItem.DataBind();
            gvDispatch.DataSource = null;
            gvDispatch.DataBind();
            gvDispatch.Visible = false;
        }
        else
        {
            var orders = ctx.OPOS.Include("OCRD").Include("OCRD.CRD1").Where(x => x.OrderType == 12 && x.ParentID == ParentID && x.IsMobile == true && (x.Date >= frmDate && x.Date <= toDate)).Select(c => new
            {
                BillRefNo = c.BillRefNo,
                Date = c.Date,
                CustomerName = c.OCRD.CustomerName,
                Address = c.OCRD.CRD1.FirstOrDefault(y => y.IsDeleted == false).Address1 + " " + c.OCRD.CRD1.FirstOrDefault(y => y.IsDeleted == false).Address2,
                ZipCode = c.OCRD.CRD1.FirstOrDefault(y => y.IsDeleted == false).ZipCode,
                PhoneNumber = c.OCRD.Phone,
                Total = c.Total,
                SubTotal = c.SubTotal,
                Discount = c.Discount,
                SaleID = c.SaleID

            }).ToList();

            gvDispatch.Visible = true;
            gvDispatch.DataSource = orders;
            gvDispatch.DataBind();
            gvItem.DataSource = null;
            gvItem.DataBind();
            gvItem.Visible = false;
        }
    }

    protected void btnDelete_Click(object sender, EventArgs e)
    {

        LinkButton lnk = (LinkButton)sender;
        GridViewRow gr = (GridViewRow)lnk.NamingContainer;
        Label lblPhone = (Label)gr.FindControl("lblPhone");
        Label lblBillRefNo = (Label)gr.FindControl("lblBillRefNo");

        OPOS objOPOS = ctx.OPOS.FirstOrDefault(x => x.BillRefNo == lblBillRefNo.Text && x.ParentID == ParentID);
        if (objOPOS != null)
        {
            objOPOS.OrderType = 15;
            objOPOS.UpdatedDate = DateTime.Now;
            objOPOS.UpdatedBy = UserID;
        }
        ctx.SaveChanges();
        try
        {
            if (!string.IsNullOrEmpty(objOPOS.OCRD.Phone))       // Send SMS
            {
                string SMS = "Hi " + objOPOS.OCRD.CustomerName + ", Your order has been cancelled and your Order No. " + objOPOS.BillRefNo + ". We Happy to Serve you. Vadilal";
                Service wb = new Service();
                wb.SendSMS(lblPhone.Text, SMS);
            }
        }
        catch (Exception ex)
        {
        }
        //try
        //{
        //    if (!string.IsNullOrEmpty(objOPOS.OCRD.DeviceID))       // Send PUSH Notification
        //    {
        //        WebService wbService = new WebService();
        //        string message = "Hi " + objOPOS.OCRD.CustomerName + ", " + " your Order No: " + objOPOS.BillRefNo + " has been cancelled. We Happy to Serve you. Vadilal";
        //        wbService.PushNotificationOnDispatch(message, objOPOS.OCRD.DeviceID);
        //    }
        //}
        //catch (Exception ex)
        //{
        //}

        DateTime frmDate = Convert.ToDateTime(txtFromDate.Text);
        DateTime toDate = Convert.ToDateTime(txtToDate.Text);

        FillGridData(frmDate, toDate, chkIsMobile.Checked, ddlType.SelectedValue);
    }

    protected void gvDispatch_PreRender(object sender, EventArgs e)
    {
        if (gvDispatch.Rows.Count > 0)
        {
            gvDispatch.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvDispatch.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }

    protected void btnReceipt_Click(object sender, EventArgs e)
    {
        LinkButton lnk = (LinkButton)sender;
        GridViewRow gr = (GridViewRow)lnk.NamingContainer;
        Label lblPhone = (Label)gr.FindControl("lblPhone");
        Label lblBillRefNo = (Label)gr.FindControl("lblBillRefNo");

        OPOS objOPOS = ctx.OPOS.FirstOrDefault(x => x.BillRefNo == lblBillRefNo.Text && x.ParentID == ParentID);
        if (objOPOS != null)
        {
            objOPOS.OrderType = 16;
            objOPOS.UpdatedDate = DateTime.Now;
            objOPOS.UpdatedBy = UserID;
        }
        ctx.SaveChanges();

        try
        {
            if (!string.IsNullOrEmpty(objOPOS.OCRD.EMail1))     // Send E-Mail
            {
                string mailBody = GetMailBody(objOPOS.SaleID, objOPOS.ParentID);

                Common.SendMail("Vadilal - Order Confirmation", mailBody, objOPOS.OCRD.EMail1, "", null, null);
            }
        }
        catch (Exception ex)
        {
        }

        try
        {
            if (!string.IsNullOrEmpty(objOPOS.OCRD.Phone))       // Send SMS
            {
                string SMS = "Hi " + objOPOS.OCRD.CustomerName + ", Thanks for receiving your Order No. " + objOPOS.BillRefNo + ". We Happy to Serve you. Vadilal";
                Service wb = new Service();
                wb.SendSMS(lblPhone.Text, SMS);
            }
        }
        catch (Exception ex)
        {
        }
        //try
        //{
        //    // Do NOT remove "receiving" word from Push Notification message. It is used in Mobile App.
        //    // If you want to  change please update the same work in Mobile App.

        //    if (!string.IsNullOrEmpty(objOPOS.OCRD.DeviceID))       // Send PUSH Notification
        //    {
        //        WebService wbService = new WebService();
        //        string message = "Hi " + objOPOS.OCRD.CustomerName + ", Thanks for receiving your Order No. " + objOPOS.BillRefNo + ". Please give your Feedback on our Mobile App. Vadilal";
        //        wbService.PushNotificationOnDispatch(message, objOPOS.OCRD.DeviceID);
        //    }
        //}
        //catch (Exception ex)
        //{
        //}

        DateTime frmDate = Convert.ToDateTime(txtFromDate.Text);
        DateTime toDate = Convert.ToDateTime(txtToDate.Text);

        FillGridData(frmDate, toDate, chkIsMobile.Checked, ddlType.SelectedValue);
    }

    protected string GetMailBody(int SaleID, decimal ParentID)
    {
        string mailBody = "";
        OPOS objOPOS = ctx.OPOS.FirstOrDefault(x => x.SaleID == SaleID && x.ParentID == ParentID);
        CRD1 objCRD1 = objOPOS.OCRD.CRD1.FirstOrDefault(x => x.IsDeleted == false);

        mailBody += "<html><body style='background:url(http://vadilalicecreams.com/wp-content/uploads/2015/04/doodle.jpg)'>";
        mailBody += "<div style='padding:5px;width:100%'>";
        mailBody += "<table border='0' width='100%'><tr><td width='30%'><img src='http://115.248.46.196/mCommerce/Images/mail_img.png' alt='vadilal' style='float:left;' /></td><td width='70%' align='right'><strong style='font-size:30px;margin-left:-30%'>Order Confirmation</strong></td></tr></table>";

        mailBody += "<br/><br/>Dear " + objOPOS.OCRD.CustomerName + ",<br/><br/>";
        mailBody += "Thanks for receiving your Order No. <b>" + objOPOS.BillRefNo + "</b> on " + objOPOS.UpdatedDate.ToShortDateString() + ", " + objOPOS.UpdatedDate.ToShortTimeString() + ". Please give your Feedback on our Mobile App.";
        mailBody += "<br/>We Happy to Serve you.<br/><br/>";
        mailBody += "<h3 align='center' style='margin:0'>* Thank you for your Order *</h3>";
        mailBody += "<hr>";
        mailBody += "<div align='center' style='font-size:12px'>Vadilal Industries Ltd,Nr. Navrangpura Rly Crossing,Navangapura, Ahmedabad -9,Gujarat,India</div>";
        mailBody += "<div align='center' style='font-size:12px'>Tele: +91 79 26564018 to 24 Email : info@vadilalgroup.com</div><hr>";
        mailBody += "<div align='center'><span>This is an electronically generated invoice and does not require a signatury</span></div></div>";
        mailBody += "</body></html>";

        return mailBody;
    }
}