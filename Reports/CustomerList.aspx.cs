using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Reports_CustomerList : System.Web.UI.Page
{
    #region Declaration

    protected int UserID;
    public int CustType;
    public decimal ParentID;
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
                var UserType = Session["UserType"].ToString();
                int lIndex = Request.ServerVariables["script_name"].ToString().LastIndexOf('/');
                string pagename = Request.ServerVariables["script_name"].ToString().Substring(lIndex + 1);
                int menuid = ctx.OMNUs.FirstOrDefault(x => x.PageName == pagename && (UserType == "b" ? true : x.MenuType == UserType)).MenuID;
                var Auth = ctx.GRP1.Include("OMNU").FirstOrDefault(x => x.MenuID == menuid && x.EmpGroupID == EGID && x.ParentID == ParentID);
                if (Auth == null || Auth.AuthorizationType == "N")
                    Response.Redirect("~/AccessError.aspx");
                else if (!(CustType == 1 ? Auth.OMNU.Company : CustType == 2 ? Auth.OMNU.CMS : CustType == 3 ? Auth.OMNU.DMS : CustType == 4 ? Auth.OMNU.SS : false))
                    Response.Redirect("~/AccessError.aspx");
                else
                {
                    AuthType = Auth.AuthorizationType;


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

    private void ClearAllInputs()
    {
        txtCustCode.Text = txtGSTIN.Text = txtPhoneNo.Text = txtPhoneNo2.Text = txtPhoneNo3.Text = "";
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
    #endregion Page Load

    #region ButtonClick

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        try
        {
            var Code = txtCustCode.Text.Split("-".ToArray()).First().Trim();
            using (DDMSEntities ctx = new DDMSEntities())
            {
                if (!ctx.OCRDs.Any(x => x.CustomerCode == Code))
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper Customer.',3);", true);
                    txtCustCode.Text = "";
                    txtCustCode.Focus();
                    return;
                }
                OCRD objOCRD = ctx.OCRDs.FirstOrDefault(x => x.CustomerCode == Code);

                if (objOCRD.Type == 3)
                {
                    CRD1 objOCRD1 = ctx.CRD1.FirstOrDefault(x => x.CustomerID == objOCRD.CustomerID);
                    objOCRD.Phone = txtPhoneNo.Text;
                    objOCRD1.PhoneNumber = txtPhoneNo2.Text;
                    objOCRD.Phone3 = txtPhoneNo3.Text;
                    objOCRD.GSTIN = txtGSTIN.Text;
                    objOCRD.UpdatedBy = UserID;
                    objOCRD.UpdatedDate = DateTime.Now;
                    ctx.SaveChanges();
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Record submitted successfully for " + objOCRD.CustomerCode + "',1);", true);
                    ClearAllInputs();
                    divGST.Visible = divMobile.Visible = divSubmit.Visible = divMobile2.Visible = divMobile3.Visible = false;
                    txtCustCode.Focus();
                }
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }

    protected void btnGenerat_Click(object sender, EventArgs e)
    {
        using (var ctx = new DDMSEntities())
        {
            var Code = txtCustCode.Text.Split("-".ToArray()).First().Trim();
            if (!ctx.OCRDs.Any(x => x.CustomerCode == Code))
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select Customer.',3);", true);
                txtCustCode.Text = "";
                txtCustCode.Focus();
                ifmCustomer.Visible = false;
                return;
            }
            string DealerDistPW = "";
            string DistPW = "";
            string SSPW = "";
            OCRD objOCRD = ctx.OCRDs.FirstOrDefault(x => x.CustomerCode == Code);
            if (objOCRD.Type == 2)
            {
                divMobile.Visible = false;
                divMobile2.Visible = false;
                divMobile3.Visible = false;
                divGST.Visible = false;
                divSubmit.Visible = false;
                //Distributor
                var ObjDist = ctx.OEMPs.Where(x => x.ParentID == objOCRD.CustomerID && x.EmpID == 1).Select(x => new { x.UserName, x.Password }).FirstOrDefault();
                DistPW = Common.DecryptNumber(ObjDist.UserName, ObjDist.Password);
                //SS
                if (objOCRD.ParentID != 1000010000000000)
                {
                    var ObjSS = ctx.OEMPs.Where(x => x.ParentID == objOCRD.ParentID && x.EmpID == 1).Select(x => new { x.UserName, x.Password }).FirstOrDefault();
                    SSPW = Common.DecryptNumber(ObjSS.UserName, ObjSS.Password);
                }
            }
            else if (objOCRD.Type == 3)
            {
                CRD1 objOCRD1 = ctx.CRD1.FirstOrDefault(x => x.CustomerID == objOCRD.CustomerID);
                divMobile.Visible = true;
                divMobile2.Visible = true;
                divMobile3.Visible = true;
                divGST.Visible = true;
                divSubmit.Visible = true;
                txtPhoneNo.Text = objOCRD.Phone;
                txtPhoneNo2.Text = objOCRD1.PhoneNumber;
                txtPhoneNo3.Text = objOCRD.Phone3;
                txtGSTIN.Text = objOCRD.GSTIN;

                //Distributor
                var ObjDist = ctx.OEMPs.Where(x => x.ParentID == objOCRD.ParentID && x.EmpID == 1).Select(x => new { x.UserName, x.Password }).FirstOrDefault();
                if(ObjDist != null)
                {
                    DistPW = Common.DecryptNumber(ObjDist.UserName, ObjDist.Password);
                }
                //Dealer App --- Added By Dharmendra
                var ObjDealer = ctx.DPWDs.Where(x => x.CustomerCode == objOCRD.CustomerCode && x.Active == true).Select(x => new { x.CustomerCode, x.PassWord }).FirstOrDefault();
                if(ObjDealer != null)
                {
                    DealerDistPW = Common.DecryptNumber(ObjDealer.CustomerCode, ObjDealer.PassWord);
                }
                //SS
                Decimal DistParent = ctx.OCRDs.FirstOrDefault(x => x.CustomerID == objOCRD.ParentID).ParentID;
                if (DistParent != 1000010000000000)
                {
                    var ObjSS = ctx.OEMPs.Where(x => x.ParentID == DistParent && x.EmpID == 1).Select(x => new { x.UserName, x.Password }).FirstOrDefault();
                    SSPW = Common.DecryptNumber(ObjSS.UserName, ObjSS.Password);
                }
            }
            else if (objOCRD.Type == 4)
            {
                divMobile.Visible = false;
                divMobile2.Visible = false;
                divMobile3.Visible = false;
                divGST.Visible = false;
                divSubmit.Visible = false;
                //SS
                var ObjSS = ctx.OEMPs.Where(x => x.ParentID == objOCRD.CustomerID && x.EmpID == 1).Select(x => new { x.UserName, x.Password }).FirstOrDefault();
                SSPW = Common.DecryptNumber(ObjSS.UserName, ObjSS.Password);
            }
            ifmCustomer.Visible = true;
            ifmCustomer.Attributes.Add("src", "../Reports/ViewReport.aspx?&CustListCUSTID=" + objOCRD.CustomerID + "&CustListCustType=" + objOCRD.Type + "&CustListDealerDistPW=" + Server.UrlEncode(DealerDistPW) + "&CustListDISTPW=" + Server.UrlEncode(DistPW) + "&CustListSSPW=" + Server.UrlEncode(SSPW));
        }
    }

    protected void btnExport_Click(object sender, EventArgs e)
    {
        using (var ctx = new DDMSEntities())
        {
            var Code = txtCustCode.Text.Split("-".ToArray()).First().Trim();
            if (!ctx.OCRDs.Any(x => x.CustomerCode == Code))
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select Customer.',3);", true);
                txtCustCode.Text = "";
                txtCustCode.Focus();
                ifmCustomer.Visible = false;
                return;
            }
            var DistPW = "";
            var SSPW = "";
            OCRD objOCRD = ctx.OCRDs.FirstOrDefault(x => x.CustomerCode == Code);
            if (objOCRD.Type == 2)
            {
                divMobile.Visible = false;
                divMobile2.Visible = false;
                divMobile3.Visible = false;
                divGST.Visible = false;
                divSubmit.Visible = false;
                //Distributor
                var ObjDist = ctx.OEMPs.Where(x => x.ParentID == objOCRD.CustomerID && x.EmpID == 1).Select(x => new { x.UserName, x.Password }).FirstOrDefault();
                DistPW = Common.DecryptNumber(ObjDist.UserName, ObjDist.Password);
                //SS
                if (objOCRD.ParentID != 1000010000000000)
                {
                    var ObjSS = ctx.OEMPs.Where(x => x.ParentID == objOCRD.ParentID && x.EmpID == 1).Select(x => new { x.UserName, x.Password }).FirstOrDefault();
                    SSPW = Common.DecryptNumber(ObjSS.UserName, ObjSS.Password);
                }
            }
            else if (objOCRD.Type == 3)
            {
                CRD1 objOCRD1 = ctx.CRD1.FirstOrDefault(x => x.CustomerID == objOCRD.CustomerID);
                divMobile.Visible = true;
                divMobile2.Visible = true;
                divMobile3.Visible = true;
                divGST.Visible = true;
                divSubmit.Visible = true;
                txtPhoneNo.Text = objOCRD.Phone;
                txtPhoneNo2.Text = objOCRD1.PhoneNumber;
                txtPhoneNo3.Text = objOCRD.Phone3;
                txtGSTIN.Text = objOCRD.GSTIN;

                //Distributor
                var ObjDist = ctx.OEMPs.Where(x => x.ParentID == objOCRD.ParentID && x.EmpID == 1).Select(x => new { x.UserName, x.Password }).FirstOrDefault();
                DistPW = Common.DecryptNumber(ObjDist.UserName, ObjDist.Password);
                //SS
                Decimal DistParent = ctx.OCRDs.FirstOrDefault(x => x.CustomerID == objOCRD.ParentID).ParentID;
                if (DistParent != 1000010000000000)
                {
                    var ObjSS = ctx.OEMPs.Where(x => x.ParentID == DistParent && x.EmpID == 1).Select(x => new { x.UserName, x.Password }).FirstOrDefault();
                    SSPW = Common.DecryptNumber(ObjSS.UserName, ObjSS.Password);
                }
            }
            else if (objOCRD.Type == 4)
            {
                divMobile.Visible = false;
                divMobile2.Visible = false;
                divMobile3.Visible = false;
                divGST.Visible = false;
                divSubmit.Visible = false;
                //SS
                var ObjSS = ctx.OEMPs.Where(x => x.ParentID == objOCRD.CustomerID && x.EmpID == 1).Select(x => new { x.UserName, x.Password }).FirstOrDefault();
                SSPW = Common.DecryptNumber(ObjSS.UserName, ObjSS.Password);
            }
            ifmCustomer.Visible = true;
            ifmCustomer.Attributes.Add("src", "../Reports/ViewReport.aspx?&CustListCUSTID=" + objOCRD.CustomerID + "&CustListCustType=" + objOCRD.Type + "&CustListDISTPW=" + Server.UrlEncode(DistPW) + "&CustListSSPW=" + Server.UrlEncode(SSPW) + "&Export=1");
        }
    }

    #endregion

    protected void ifmCustomer_Load(object sender, EventArgs e)
    {

    }
}