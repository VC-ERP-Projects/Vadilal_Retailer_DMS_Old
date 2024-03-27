using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using CustomerLedger;
using System.Net;
using System.Xml.Linq;
using System.Threading;
using System.Configuration;
using System.IO;
using System.Net.Mail;

public partial class MyAccount_LedgerRequest : System.Web.UI.Page
{

    #region Declaration

    protected int UserID, CustType;
    protected decimal ParentID;
    protected String AuthType;

    #endregion

    #region Helper Method

    public void ClearAllInputs()
    {
        txtDivision.Text = txtNotes.Text = "";
        chkIsConfirm.Checked = false;

        txtToDate.Text = txtFromDate.Text = txtReqDate.Text = Common.DateTimeConvert(DateTime.Now);
        using (DDMSEntities ctx = new DDMSEntities())
        {
            var objOCLG = ctx.OCLGs.FirstOrDefault(x => x.ParentID == ParentID && x.Status == (int)LedgerReqStatus.Open);

            if (objOCLG != null)
            {
                var objODIV = ctx.ODIVs.FirstOrDefault(x => x.DivisionlID == objOCLG.DivisionID);

                txtFromDate.Enabled = txtToDate.Enabled = txtDivision.Enabled = false;
                chkIsConfirm.Enabled = txtNotes.Enabled = true;

                txtFromDate.Text = Common.DateTimeConvert(objOCLG.FromDate);
                txtToDate.Text = Common.DateTimeConvert(objOCLG.ToDate);
                txtReqDate.Text = Common.DateTimeConvert(objOCLG.RequiredDate);
                txtDivision.Text = objODIV.DivisionlID + " - " + objODIV.DivisionName;
            }
            else
            {
                txtFromDate.Enabled = txtToDate.Enabled = txtDivision.Enabled = true;
                chkIsConfirm.Enabled = txtNotes.Enabled = false;
            }
        }
    }

    public void SendLedgerReqToSap(Decimal ParentID, int LedgerReqID)
    {
        var FileName = Server.MapPath("~/Document/SendLedgerReq.txt");
        using (DDMSEntities ctx = new DDMSEntities())
        {
            OCLG objOCLG = ctx.OCLGs.FirstOrDefault(x => x.ParentID == ParentID && x.LedgerReqID == LedgerReqID);

            try
            {
                OCFG objOCFG = ctx.OCFGs.FirstOrDefault();

                if (objOCFG != null && objOCLG != null)
                {
                    OCRD objOCRD = ctx.OCRDs.FirstOrDefault(x => x.CustomerID == ParentID);
                    OGCRD objOGCRD = ctx.OGCRDs.FirstOrDefault(x => x.CustomerID == ParentID && x.DivisionlID == objOCLG.DivisionID);
                    OCPY objOCPY = ctx.OCPies.FirstOrDefault(x => x.CompanyID == objOGCRD.CompanyID);
                    ODIV ObjODIV = ctx.ODIVs.FirstOrDefault(x => x.DivisionlID == objOCLG.DivisionID);

                    if (objOCPY != null && ObjODIV != null)
                    {
                        DT_CustLedMail_Res Response = new DT_CustLedMail_Res();
                        SI_SynchOut_CustledmailService _proxy = new SI_SynchOut_CustledmailService();

                        _proxy.Url = objOCFG.SAPQPSClaimLink;
                        _proxy.Timeout = 3000000;
                        _proxy.Credentials = new NetworkCredential(objOCFG.UserID, objOCFG.Password);

                        DT_CustLedMail_Req Request = new DT_CustLedMail_Req();
                        DT_CustLedMail_ReqGWA_MAIL D1 = new DT_CustLedMail_ReqGWA_MAIL();

                        D1.COMPANY_CODE = objOCPY.CompanyCode;
                        D1.CUSTOMER = objOCRD.CustomerCode;
                        D1.DIVISION = ObjODIV.DivisionCode;
                        D1.FRDATE = objOCLG.FromDate.ToString("dd.MM.yyyy");
                        D1.TODATE = objOCLG.ToDate.ToString("dd.MM.yyyy");
                        D1.REQ_DATE = objOCLG.RequiredDate.ToString("ddMMyyyy") + DateTime.Now.ToString("hhmmss");

                        Request.GWA_MAIL = D1;
                        Response = _proxy.SI_SynchOut_Custledmail(Request);

                        objOCLG.SapMsg = Response.MESSAGE;
                        objOCLG.SapFlag = Response.FLAG;
                    }
                    else
                    {
                        objOCLG.SapMsg = "Company or Division detail not found for : " + ParentID.ToString();
                        objOCLG.SapFlag = "false";
                    }
                }
                else
                {
                    objOCLG.SapMsg = "Configuration or request detail not found for : " + ParentID.ToString();
                    objOCLG.SapFlag = "false";
                }

            }
            catch (Exception ex)
            {
                objOCLG.SapMsg = Common.GetString(ex);
                objOCLG.SapFlag = "false";
            }
            ctx.SaveChanges();
        }
    }

    public void SendMail(Decimal ParentID, int LedgerReqID)
    {
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                OCFG objOCFG = ctx.OCFGs.FirstOrDefault();
                OCRD objOCRD = ctx.OCRDs.FirstOrDefault(x => x.CustomerID == ParentID);
                OCLG objOCLG = ctx.OCLGs.FirstOrDefault(x => x.ParentID == ParentID && x.LedgerReqID == LedgerReqID);

                string mailBody = "";

                mailBody += "<html><body>";
                mailBody += "<div style='font-weight: 700;'> Please Find Comment of Dealer For The Period : " + Common.DateTimeConvert(objOCLG.FromDate) + " TO " + Common.DateTimeConvert(objOCLG.ToDate) + " </div>";
                mailBody += "<br />";
                mailBody += "<div style='background-color: yellow; font-weight: 700;'> Notes : " + objOCLG.Notes + " </div>";
                mailBody += "</body></html>";
                try
                {
                    Common.SendMail("STATEMENT OF ACCOUNT " + objOCRD.CustomerCode + " - " + objOCRD.CustomerName + "", mailBody, objOCFG.Email, "", null, null);
                }
                catch (Exception)
                {

                }

            }
        }
        catch (Exception)
        {

        }
    }

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

    #endregion

    #region Page Load

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        if (!IsPostBack)
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                txtCustEmail.InnerText = ctx.OCRDs.FirstOrDefault(x => x.CustomerID == ParentID).EMail1;
            }
            ClearAllInputs();
            txtDivision.Style.Add("background-color", "rgb(250, 255, 189);");
            acetxtDivision.ContextKey = ParentID.ToString();
        }
    }

    #endregion

    #region button events

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {

                var Data = txtDivision.Text.Split("-".ToArray());

                int DivisionID = Int32.TryParse(Data.First().Trim(), out DivisionID) ? DivisionID : 0;
                if (!ctx.ODIVs.Any(x => x.DivisionlID == DivisionID))
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper Division.',3);", true);
                    return;
                }

                var objOCLG = ctx.OCLGs.FirstOrDefault(x => x.ParentID == ParentID && x.Status == 1);
                var Count = ctx.GetKey("OCLG", "LedgerReqID", "", ParentID, null).FirstOrDefault().Value;
                if (objOCLG != null && string.IsNullOrEmpty(txtNotes.Text))
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please enter notes.',3);", true);
                    return;
                }
                else if (objOCLG != null && !chkIsConfirm.Checked)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please Confirm for previous request.',3);", true);
                    return;
                }

                if (objOCLG == null)
                {
                    objOCLG = new OCLG();
                    objOCLG.LedgerReqID = Count++;
                    objOCLG.ParentID = ParentID;
                    objOCLG.FromDate = Common.DateTimeConvert(txtFromDate.Text);
                    objOCLG.ToDate = Common.DateTimeConvert(txtToDate.Text);
                    objOCLG.RequiredDate = Common.DateTimeConvert(txtReqDate.Text);
                    objOCLG.Status = (int)LedgerReqStatus.Open;
                    objOCLG.DivisionID = DivisionID;
                    objOCLG.CreatedDate = DateTime.Now;
                    objOCLG.CreatedBy = UserID;
                    ctx.OCLGs.Add(objOCLG);
                }
                else if (chkIsConfirm.Checked)
                    objOCLG.Status = (int)LedgerReqStatus.Confirm;

                objOCLG.UpdatedDate = DateTime.Now;
                objOCLG.UpdatedBy = UserID;
                objOCLG.Notes = txtNotes.Text;

                ctx.SaveChanges();

                if (objOCLG.Status == (int)LedgerReqStatus.Open)
                {
                    Int32 LedgerReqToSAP = Convert.ToInt32(ConfigurationManager.AppSettings["IndentToSAP"]);

                    int LedgerReqID = objOCLG.LedgerReqID;

                    Thread t = new Thread(() => { Thread.Sleep(LedgerReqToSAP); SendLedgerReqToSap(ParentID, LedgerReqID); });
                    t.Name = Guid.NewGuid().ToString();
                    t.Start();
                }
                else if (objOCLG.Status == (int)LedgerReqStatus.Confirm)
                {
                    int LedgerReqID = objOCLG.LedgerReqID;
                    Thread t = new Thread(() => { SendMail(ParentID, LedgerReqID); });
                    t.Name = Guid.NewGuid().ToString();
                    t.Start();
                }
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Record submitted successfully!',1);", true);
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