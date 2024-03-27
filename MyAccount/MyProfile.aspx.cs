using System;
using System.Collections.Generic;
using System.Data.Objects.SqlClient;
using System.IO;
using System.Linq;
using System.Web.Services;
using System.Web.UI;
using GST_CustomerSync;
using System.Net;
using System.Xml.Linq;
using System.Web.UI.WebControls;
using System.Threading;
using System.Configuration;

public partial class MyAccount_MyProfile : System.Web.UI.Page
{

    #region Declaration

    protected int TCustID, CustType;
    protected decimal ParentID;

    #endregion

    #region Helper Method


    [WebMethod(EnableSession = true)]
    public static List<dynamic> StateCountryData(string City)
    {
        List<dynamic> result = new List<dynamic>();

        if (!string.IsNullOrEmpty(City) && City.Split("-".ToArray()).Length > 0)
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                int CityID = Int32.TryParse(City.Split("-".ToArray()).First().Trim(), out CityID) ? CityID : 0;

                result.Add(ctx.OCTies.Where(x => x.CityID == CityID).Select(x =>
                    new { x.CityID, x.StateID, x.OCST.StateName, x.OCST.CountryID, x.OCST.OCRY.CountryName }).FirstOrDefault());
            }
        }
        return result;
    }

    [WebMethod(EnableSession = true)]
    public static dynamic GetCity()
    {
        List<dynamic> CityData = new List<dynamic>();
        List<string> Result = new List<string>();

        using (DDMSEntities ctx = new DDMSEntities())
        {
            Result = ctx.OCTies.Where(x => x.Active).Select(x => SqlFunctions.StringConvert((double)x.CityID).Trim() + "-" + x.CityName).ToList();
        }

        CityData.Add(Result);

        return CityData;
    }

    #endregion

    #region Page Load

    protected void Page_Load(object sender, EventArgs e)
    {

        if (Request.QueryString["DocKey"] != null && Request.QueryString["DocNo"] != null &&
              Decimal.TryParse(Request.QueryString["DocKey"].ToString(), out ParentID) && Int32.TryParse(Request.QueryString["DocNo"].ToString(), out TCustID) && ParentID > 0)
        {
        }
        else
        {
            Response.Redirect("~/Login.aspx");
        }
        if (Session["Type"] != null && Int32.TryParse(Session["Type"].ToString(), out CustType))
        {

        }

        if (!IsPostBack)
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {

                OCRD objOCRD = ctx.OCRDs.FirstOrDefault(x => x.CustomerID == ParentID);
                if (objOCRD != null)
                {
                    txtCustCode.Text = objOCRD.CustomerCode;
                    txtCustName.Text = objOCRD.CustomerName;
                }
                if (CustType == 1)
                {
                    TOCRD objTOCRD = ctx.TOCRDs.FirstOrDefault(x => x.TCustID == TCustID && x.ParentID == ParentID);
                    if (objTOCRD != null)
                    {
                        txtPanNo.Text = objTOCRD.PAN;
                        chkPanApplicable.Checked = !objTOCRD.PANApplicable;
                        hdnPANFile.Value = "../Document/GST_Files/" + objTOCRD.PANUpload;
                        txtGSTIN.Text = objTOCRD.GST;
                        hdnGSTFile.Value = "../Document/GST_Files/" + objTOCRD.GSTUpload;
                        chkCompositeScheme.Checked = !objTOCRD.CompositeScheme;
                        //txtStateVATRegNo.Text = objTOCRD.VAT;
                        rdoIsRegComposite.SelectedValue = objTOCRD.VAT;
                        if (!string.IsNullOrEmpty(objTOCRD.VATUpload))
                            hdnVATFile.Value = "../Document/GST_Files/" + objTOCRD.VATUpload;
                        txtCSTRegNo.Text = objTOCRD.CST;
                        if (!string.IsNullOrEmpty(objTOCRD.CSTupload))
                            hdnCSTFile.Value = "../Document/GST_Files/" + objTOCRD.CSTupload;

                        TCRD1 objPrimTCRD1 = objTOCRD.TCRD1.FirstOrDefault(x => x.AddressType == "P");
                        if (objPrimTCRD1 != null)
                        {
                            txtPrimAddress1.Text = objPrimTCRD1.Address1;
                            txtPrimAddress2.Text = objPrimTCRD1.Address2;
                            txtPrimLandMark.Text = objPrimTCRD1.Landmark;
                            hdnPrimCity.Value = objPrimTCRD1.CityID.Value.ToString();
                            txtPrimCity.Text = ctx.OCTies.FirstOrDefault(x => x.CityID == objPrimTCRD1.CityID.Value).CityName;
                            txtPrimDistrict.Text = objPrimTCRD1.District;
                            hdnPrimState.Value = objPrimTCRD1.StateID.ToString();
                            txtPrimState.Text = ctx.OCSTs.FirstOrDefault(x => x.StateID == objPrimTCRD1.StateID.Value).StateName;
                            hdnPrimCountry.Value = objPrimTCRD1.CountryID.ToString();
                            txtPrimCountry.Text = ctx.OCRies.FirstOrDefault(x => x.CountryID == objPrimTCRD1.CountryID.Value).CountryName;
                            txtPrimPinCode.Text = objPrimTCRD1.PinCode;
                            txtPrimOfficeEmail.Text = objPrimTCRD1.OfficalEmail;
                            txtPrimOfficePhoneNo.Text = objPrimTCRD1.OfficalPhone;
                            txtPrimContactPerson.Text = objPrimTCRD1.ContactPerson;
                            txtPrimMobileNo.Text = objPrimTCRD1.MobileNo;
                            txtPrimEmail.Text = objPrimTCRD1.EmailID;
                            txtPrimWebSite.Text = objPrimTCRD1.Web;
                        }

                        TCRD1 objSecTCRD1 = objTOCRD.TCRD1.FirstOrDefault(x => x.AddressType == "S");
                        if (objSecTCRD1 != null)
                        {
                            txtSecAddress1.Text = objSecTCRD1.Address1;
                            txtSecAddress2.Text = objSecTCRD1.Address2;
                            txtSecLandMark.Text = objSecTCRD1.Landmark;
                            hdnSecCity.Value = objSecTCRD1.CityID.Value.ToString();
                            txtSecCity.Text = ctx.OCTies.FirstOrDefault(x => x.CityID == objSecTCRD1.CityID.Value).CityName;
                            txtSecDistrict.Text = objSecTCRD1.District;
                            hdnSecState.Value = objSecTCRD1.StateID.ToString();
                            txtSecState.Text = ctx.OCSTs.FirstOrDefault(x => x.StateID == objSecTCRD1.StateID.Value).StateName;
                            hdnSecCountry.Value = objSecTCRD1.CountryID.ToString();
                            txtSecCountry.Text = ctx.OCRies.FirstOrDefault(x => x.CountryID == objSecTCRD1.CountryID.Value).CountryName;
                            txtSecPinCode.Text = objSecTCRD1.PinCode;
                            txtSecOfficeEmail.Text = objSecTCRD1.OfficalEmail;
                            txtSecOfficePhoneNo.Text = objSecTCRD1.OfficalPhone;
                            txtSecContactPerson.Text = objSecTCRD1.ContactPerson;
                            txtSecMobileNo.Text = objSecTCRD1.MobileNo;
                            txtSecEmail.Text = objSecTCRD1.EmailID;
                            txtSecWebSite.Text = objSecTCRD1.Web;
                        }

                        if (!chkPanApplicable.Checked)
                        {
                            txtPanNo.Attributes.Remove("disabled");
                            flCPanNoUpload.Attributes.Remove("disabled");
                            btnPanView.Attributes.Remove("disabled");

                        }
                        else
                        {
                            txtPanNo.Attributes.Add("disabled", "disabled");
                            flCPanNoUpload.Attributes.Add("disabled", "disabled");
                            btnPanView.Attributes.Add("disabled", "disabled");
                        }

                        if (!chkCompositeScheme.Checked)
                        {
                            txtGSTIN.Attributes.Remove("disabled");
                            flcGSTINUpload.Attributes.Remove("disabled");
                            btnGSTView.Attributes.Remove("disabled");

                        }
                        else
                        {
                            txtGSTIN.Attributes.Add("disabled", "disabled");
                            flcGSTINUpload.Attributes.Add("disabled", "disabled");
                            btnGSTView.Attributes.Add("disabled", "disabled");
                        }
                    }
                    else
                    {
                        if (objOCRD != null && !ctx.TOCRDs.Any(x => x.ParentID == ParentID))
                        {
                            txtCustCode.Text = objOCRD.CustomerCode;
                            txtCustName.Text = objOCRD.CustomerName;
                        }

                    }

                }
                else
                {
                    //Response.Redirect("~/MyAccount.aspx");
                }


            }

        }
    }

    #endregion

    #region Button Click

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                int CityID = 0;
                int StateID = 0;
                int CountryID = 0;

                CityID = Int32.TryParse(hdnPrimCity.Value, out CityID) ? CityID : 0;
                StateID = Int32.TryParse(hdnPrimState.Value, out StateID) ? StateID : 0;
                CountryID = Int32.TryParse(hdnPrimCountry.Value, out CountryID) ? CountryID : 0;
                if (!System.IO.Directory.Exists(Server.MapPath("~/Document/GST_Files/")))
                    System.IO.Directory.CreateDirectory(Server.MapPath("~/Document/GST_Files/"));
                if (CityID == 0 || StateID == 0 || CountryID == 0)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select proper Primary City.',3);", true);
                    return;
                }

                ctx.TOCRDs.Where(x => x.ParentID == ParentID).ToList().ForEach(x => x.Active = false);

                TOCRD objTOCRD = new TOCRD();
                objTOCRD.TCustID = ctx.GetKey("TOCRD", "TCustID", "", 0, 0).FirstOrDefault().Value;
                objTOCRD.ParentID = ParentID;
                objTOCRD.Active = true;


                objTOCRD.PAN = txtPanNo.Text;
                objTOCRD.PANApplicable = chkPanApplicable.Checked ? false : true;

                Dictionary<int, string> Paths = new Dictionary<int, string>();

                if (chkPanApplicable.Checked == false)
                {
                    if (flCPanNoUpload.HasFile)
                    {
                        string ext = Path.GetExtension(flCPanNoUpload.PostedFile.FileName);
                        if (ext.ToLower() == ".jpg" || ext.ToLower() == ".png" || ext.ToLower() == ".gif" || ext.ToLower() == ".jpeg" || ext.ToLower() == ".pdf")
                        {
                            string fileName = Path.Combine(Guid.NewGuid().ToString("N") + Path.GetExtension(flCPanNoUpload.PostedFile.FileName));
                            flCPanNoUpload.PostedFile.SaveAs(Server.MapPath("~/Document/GST_Files/") + fileName);
                            objTOCRD.PANUpload = fileName;
                            Paths.Add(1, Request.Url.GetLeftPart(UriPartial.Authority) + Request.ApplicationPath + "/Document/GST_Files/" + fileName);
                        }
                        else
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select Proper pan card image.',3);", true);
                            return;
                        }
                    }
                    else if (!string.IsNullOrEmpty(hdnPANFile.Value))
                    {
                        objTOCRD.PANUpload = Path.GetFileName(hdnPANFile.Value);
                        Paths.Add(1, Request.Url.GetLeftPart(UriPartial.Authority) + Request.ApplicationPath + "/Document/GST_Files/" + Path.GetFileName(hdnPANFile.Value));
                    }
                    else
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please upload pan card image.',3);", true);
                        return;
                    }
                }

                objTOCRD.GST = txtGSTIN.Text;
                objTOCRD.CompositeScheme = chkCompositeScheme.Checked ? false : true;
                if (chkCompositeScheme.Checked == false)
                {
                    if (flcGSTINUpload.HasFile)
                    {
                        string ext = Path.GetExtension(flcGSTINUpload.PostedFile.FileName);
                        if (ext.ToLower() == ".jpg" || ext.ToLower() == ".png" || ext.ToLower() == ".gif" || ext.ToLower() == ".jpeg" || ext.ToLower() == ".pdf")
                        {
                            string fileName = Path.Combine(Guid.NewGuid().ToString("N") + Path.GetExtension(flcGSTINUpload.PostedFile.FileName));
                            flcGSTINUpload.PostedFile.SaveAs(Server.MapPath("~/Document/GST_Files/") + fileName);
                            objTOCRD.GSTUpload = fileName;
                            Paths.Add(2, Request.Url.GetLeftPart(UriPartial.Authority) + Request.ApplicationPath + "/Document/GST_Files/" + fileName);
                        }
                        else
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select Proper GST card image.',3);", true);
                            return;
                        }
                    }
                    else if (!string.IsNullOrEmpty(hdnGSTFile.Value))
                    {
                        objTOCRD.GSTUpload = Path.GetFileName(hdnGSTFile.Value);
                        Paths.Add(2, Request.Url.GetLeftPart(UriPartial.Authority) + Request.ApplicationPath + "/Document/GST_Files/" + Path.GetFileName(hdnGSTFile.Value));
                    }
                    else
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please upload GST card image.',3);", true);
                        return;
                    }
                }
                //objTOCRD.VAT = txtStateVATRegNo.Text;
                objTOCRD.VAT = rdoIsRegComposite.SelectedValue;
                //if (!string.IsNullOrEmpty(txtStateVATRegNo.Text))
                //{
                if (flcVATRegNoUpload.HasFile)
                {
                    string ext = Path.GetExtension(flcVATRegNoUpload.PostedFile.FileName);
                    if (ext.ToLower() == ".jpg" || ext.ToLower() == ".png" || ext.ToLower() == ".gif" || ext.ToLower() == ".jpeg" || ext.ToLower() == ".pdf")
                    {
                        string fileName = Path.Combine(Guid.NewGuid().ToString("N") + Path.GetExtension(flcVATRegNoUpload.PostedFile.FileName));
                        flcVATRegNoUpload.PostedFile.SaveAs(Server.MapPath("~/Document/GST_Files/") + fileName);
                        objTOCRD.VATUpload = fileName;
                        Paths.Add(3, Request.Url.GetLeftPart(UriPartial.Authority) + Request.ApplicationPath + "/Document/GST_Files/" + fileName);
                    }
                }
                else if (!string.IsNullOrEmpty(hdnVATFile.Value))
                {
                    objTOCRD.VATUpload = Path.GetFileName(hdnVATFile.Value);
                    Paths.Add(3, Request.Url.GetLeftPart(UriPartial.Authority) + Request.ApplicationPath + "/Document/GST_Files/" + Path.GetFileName(hdnVATFile.Value));
                }
                else
                {
                    //ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please upload VAT Image.',3);", true);
                    //return;
                }
                //}
                objTOCRD.CST = txtCSTRegNo.Text;
                if (!string.IsNullOrEmpty(txtCSTRegNo.Text))
                {
                    if (flcCSTRegNoUpload.HasFile)
                    {
                        string ext = Path.GetExtension(flcCSTRegNoUpload.PostedFile.FileName);
                        if (ext.ToLower() == ".jpg" || ext.ToLower() == ".png" || ext.ToLower() == ".gif" || ext.ToLower() == ".jpeg" || ext.ToLower() == ".pdf")
                        {
                            string fileName = Path.Combine(Guid.NewGuid().ToString("N") + Path.GetExtension(flcCSTRegNoUpload.PostedFile.FileName));
                            flcCSTRegNoUpload.PostedFile.SaveAs(Server.MapPath("~/Document/GST_Files/") + fileName);
                            objTOCRD.CSTupload = fileName;
                            Paths.Add(4, Request.Url.GetLeftPart(UriPartial.Authority) + Request.ApplicationPath + "/Document/GST_Files/" + fileName);
                        }
                    }
                    else if (!string.IsNullOrEmpty(hdnCSTFile.Value))
                    {
                        objTOCRD.CSTupload = Path.GetFileName(hdnCSTFile.Value);
                        Paths.Add(4, Request.Url.GetLeftPart(UriPartial.Authority) + Request.ApplicationPath + "/Document/GST_Files/" + Path.GetFileName(hdnCSTFile.Value));
                    }
                    else
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please upload CST Image.',3);", true);
                        return;
                    }
                }

                if (CustType == 1)
                {
                    objTOCRD.Status = 2;
                    objTOCRD.CreatedDate = DateTime.Now;
                    objTOCRD.CreatedBy = Session["UserID"] != null ? Convert.ToInt32(Session["UserID"]) : 1;
                }
                else
                {
                    objTOCRD.Status = 1;
                    objTOCRD.CreatedDate = DateTime.Now;
                    objTOCRD.CreatedBy = 1;
                }

                ctx.TOCRDs.Add(objTOCRD);

                int TCRD1Count = ctx.GetKey("TCRD1", "TCRD1ID", "", 0, 0).FirstOrDefault().Value;

                TCRD1 objPrimTCRD1 = new TCRD1();
                objPrimTCRD1.TCRD1ID = TCRD1Count++;
                objPrimTCRD1.ParentID = objTOCRD.ParentID;
                objPrimTCRD1.TCustID = objTOCRD.TCustID;
                objPrimTCRD1.AddressType = "P";
                objPrimTCRD1.Address1 = txtPrimAddress1.Text;
                objPrimTCRD1.Address2 = txtPrimAddress2.Text;
                objPrimTCRD1.Landmark = txtPrimLandMark.Text;
                objPrimTCRD1.CityID = CityID;
                objPrimTCRD1.District = txtPrimDistrict.Text;
                objPrimTCRD1.StateID = StateID;
                objPrimTCRD1.CountryID = CountryID;
                objPrimTCRD1.PinCode = txtPrimPinCode.Text;
                objPrimTCRD1.OfficalEmail = txtPrimOfficeEmail.Text;
                objPrimTCRD1.OfficalPhone = txtPrimOfficePhoneNo.Text;
                objPrimTCRD1.ContactPerson = txtPrimContactPerson.Text;
                objPrimTCRD1.MobileNo = txtPrimMobileNo.Text;
                objPrimTCRD1.EmailID = txtPrimEmail.Text;
                objPrimTCRD1.Web = txtPrimWebSite.Text;
                objTOCRD.TCRD1.Add(objPrimTCRD1);

                if (!string.IsNullOrEmpty(txtSecAddress1.Text))
                {
                    CityID = Int32.TryParse(hdnSecCity.Value, out CityID) ? CityID : 0;
                    StateID = Int32.TryParse(hdnSecState.Value, out StateID) ? StateID : 0;
                    CountryID = Int32.TryParse(hdnSecCountry.Value, out CountryID) ? CountryID : 0;

                    if (CityID == 0 || StateID == 0 || CountryID == 0)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select proper Secondary City.',3);", true);
                        return;
                    }
                    TCRD1 objSecTCRD1 = new TCRD1();
                    objSecTCRD1.TCRD1ID = TCRD1Count++;
                    objSecTCRD1.ParentID = objTOCRD.ParentID;
                    objSecTCRD1.TCustID = objTOCRD.TCustID;
                    objSecTCRD1.AddressType = "S";
                    objSecTCRD1.Address1 = txtSecAddress1.Text;
                    objSecTCRD1.Address2 = txtSecAddress2.Text;
                    objSecTCRD1.Landmark = txtSecLandMark.Text;
                    objSecTCRD1.CityID = CityID;
                    objSecTCRD1.District = txtSecDistrict.Text;
                    objSecTCRD1.StateID = StateID;
                    objSecTCRD1.CountryID = CountryID;
                    objSecTCRD1.PinCode = txtSecPinCode.Text;
                    objSecTCRD1.OfficalEmail = txtSecOfficeEmail.Text;
                    objSecTCRD1.OfficalPhone = txtSecOfficePhoneNo.Text;
                    objSecTCRD1.ContactPerson = txtSecContactPerson.Text;
                    objSecTCRD1.MobileNo = txtSecMobileNo.Text;
                    objSecTCRD1.EmailID = txtSecEmail.Text;
                    objSecTCRD1.Web = txtSecWebSite.Text;
                    objTOCRD.TCRD1.Add(objSecTCRD1);
                }

                ctx.SaveChanges();

                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "alert('Record submitted successfully.',1); window.location.href='MyAccount.aspx';", true);

                Int32 IndentToSAP = Convert.ToInt32(ConfigurationManager.AppSettings["IndentToSAP"]);

                int TID = objTOCRD.TCustID;
                Decimal TParentID = objTOCRD.ParentID;

                Thread t = new Thread(() => { Thread.Sleep(IndentToSAP); SendPurchaseinSAP(TID, TParentID, CustType, Paths); });
                t.Name = Guid.NewGuid().ToString();
                t.Start();
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',3);", true);
        }
    }

    private static void SendPurchaseinSAP(Int32 TID, Decimal TParentID, Int32 CustType, Dictionary<int, string> Paths)
    {
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                #region SAPSync

                TOCRD objTOCRD = ctx.TOCRDs.FirstOrDefault(x => x.TCustID == TID && x.ParentID == TParentID);
                if (objTOCRD != null)
                {
                    OCRD objOCRD = ctx.OCRDs.FirstOrDefault(x => x.CustomerID == TParentID);
                    OCFG objOCFG = ctx.OCFGs.FirstOrDefault();

                    DT_GST_RES Response = new DT_GST_RES();
                    SI_SynchOut_VendorPortal_GSTService _proxy = new SI_SynchOut_VendorPortal_GSTService();
                    _proxy.Url = objOCFG.SAPGSTLink;
                    _proxy.Timeout = 3000000;
                    string WebSeriveUserID_Maintain = objOCFG.UserID;
                    string WebSerivePassword_Maintain = objOCFG.Password;
                    _proxy.Credentials = new NetworkCredential(WebSeriveUserID_Maintain, WebSerivePassword_Maintain);


                    DT_GST_REQ Request = new DT_GST_REQ();
                    DT_GST_REQITEM[] D1 = new DT_GST_REQITEM[1];

                    Request = new DT_GST_REQ();
                    D1 = new DT_GST_REQITEM[1];

                    D1[0] = new DT_GST_REQITEM();

                    TCRD1 objPrimTCRD1 = objTOCRD.TCRD1.FirstOrDefault(x => x.AddressType == "P");

                    var objOCTY = ctx.OCTies.FirstOrDefault(x => x.CityID == objPrimTCRD1.CityID);

                    D1[0].YSRN = objTOCRD.TCustID.ToString();
                    D1[0].AGKOA = "C";
                    D1[0].NEW_EXISTING = "E";
                    D1[0].BUKRS = "1000";
                    D1[0].LIFNR = objOCRD.CustomerCode;
                    D1[0].NAME1 = objOCRD.CustomerName;
                    D1[0].J_1IPANNO = objTOCRD.PAN;
                    D1[0].PAN_VERIFY = "";
                    D1[0].STCD3 = objTOCRD.GST;
                    D1[0].GST_VERIFY = "";
                    D1[0].STCD5 = "";
                    D1[0].MSMED_VERIFY = "";
                    D1[0].STR_SUPPL1 = objPrimTCRD1.Address1;
                    D1[0].LOCATION = objPrimTCRD1.Address2;
                    D1[0].CITY1 = objOCTY.CityName;
                    D1[0].CITY2 = objPrimTCRD1.District;
                    D1[0].REGIO = objOCTY.OCST.StateDesc;
                    D1[0].BEZEI = objOCTY.OCST.StateName;
                    D1[0].COUNTRY = objOCTY.OCST.OCRY.CountryDesc;
                    D1[0].LANDX = objOCTY.OCST.OCRY.CountryName;
                    D1[0].POST_CODE1 = objPrimTCRD1.PinCode;
                    D1[0].SMTP_ADDR = objPrimTCRD1.OfficalEmail;
                    D1[0].TEL_NUMBER = objPrimTCRD1.OfficalPhone;
                    D1[0].MOB_NUMBER = objPrimTCRD1.MobileNo;
                    D1[0].BUS_NATURE = "";
                    D1[0].OTH_NATURE = "";
                    D1[0].J_1IEXPRN = "";
                    D1[0].EXCISE_VERIFY = "";
                    D1[0].J_1ISERN = "";
                    D1[0].SERV_TAX_VERYFY = "";
                    D1[0].J_1ILSTNO = objTOCRD.VAT;
                    D1[0].LST_VERIFY = "";
                    D1[0].J_1ICSTNO = objTOCRD.CST;
                    D1[0].CST_VERIFY = "";
                    D1[0].KOINH = "";
                    D1[0].BANKA = "";
                    D1[0].BANKN = "";
                    D1[0].BRNCH = "";
                    D1[0].ACCT_TYPE = "";
                    D1[0].SWIFT = "";
                    D1[0].BANKLZ = "";
                    D1[0].BANK_VERIFY = "";
                    D1[0].VP_INSERT_DT = DateTime.Now.Date.ToString("yyyyMMdd");
                    D1[0].VP_INSERT_TIME = DateTime.Now.ToString("hhMMss");
                    D1[0].STATUS = "I";

                    if (Paths.Any(x => x.Key == 1))
                        D1[0].PAN_PATH = Paths.FirstOrDefault(x => x.Key == 1).Value;

                    if (Paths.Any(x => x.Key == 2))
                        D1[0].GST_PATH = Paths.FirstOrDefault(x => x.Key == 2).Value;

                    if (Paths.Any(x => x.Key == 3))
                        D1[0].LST_PATH = Paths.FirstOrDefault(x => x.Key == 3).Value;

                    if (Paths.Any(x => x.Key == 4))
                        D1[0].CST_PATH = Paths.FirstOrDefault(x => x.Key == 4).Value;

                    if (CustType == 1)
                    {
                        D1[0].PAN_VERIFY = "X";
                        D1[0].GST_VERIFY = "X";

                        if (Paths.Any(x => x.Key == 3))
                            D1[0].LST_VERIFY = "X";
                        if (Paths.Any(x => x.Key == 4))
                            D1[0].CST_VERIFY = "X";

                        objTOCRD.Status = 2;
                    }
                    else
                    {
                        D1[0].PAN_VERIFY = "";
                        D1[0].GST_VERIFY = "";
                        D1[0].LST_VERIFY = "";
                        D1[0].CST_VERIFY = "";

                        objTOCRD.Status = 1;
                    }

                    Request.GST_HEAD = D1;
                    Request.FLAG_C = "I";
                    try
                    {
                        Response = _proxy.SI_SynchOut_VendorPortal_GST(Request);
                        objTOCRD.SAPFlag = Response.FLAG;
                        objTOCRD.SAPMessage = Response.MESSAGE;

                    }
                    catch (Exception ex)
                    {
                        objTOCRD.SAPFlag = Response.FLAG;
                        objTOCRD.SAPMessage = Common.GetString(ex);
                    }
                    ctx.SaveChanges();
                }

                #endregion
            }
        }
        catch (Exception)
        {

        }
    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        Response.Redirect("MyAccount.aspx");
    }

    #endregion
}