using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.EntityClient;
using System.Data.Objects;
using System.Data.Objects.SqlClient;
using System.Data.SqlClient;
using System.Linq;
using System.Net;
using System.Threading;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;

public partial class Login : System.Web.UI.Page
{

    private void SetTopItems(Decimal ParentID)
    {
        try
        {
            //Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            //SqlCommand Cm = new SqlCommand();
            //Cm.Parameters.Clear();
            //Cm.CommandType = CommandType.StoredProcedure;
            //Cm.CommandText = "SetTopItems";
            //Cm.Parameters.AddWithValue("@TemplateID", 2);
            //Cm.Parameters.AddWithValue("@ParentID", ParentID);

            //objClass.CommonFunctionForInsertUpdateDelete(Cm);

            using (DDMSEntities ctx = new DDMSEntities())
            {
                var WareHouse = ctx.OWHS.Any(x => x.ParentID == ParentID && x.Active);
                var itms = ctx.SITMs.Any(x => x.ParentID == ParentID);
                var tmp = ctx.OTMPs.Any(x => x.ParentID == ParentID && x.Active);
                var gcm = ctx.OGCMs.Any(x => x.ParentID == ParentID && x.IsActive);

                if (WareHouse == false && itms == false && tmp == false && gcm == false)
                {
                    OGCM objOGCM = ctx.OGCMs.FirstOrDefault(x => x.ParentID == ParentID);
                    if (objOGCM == null)
                    {
                        objOGCM = new OGCM();
                        objOGCM.DeviceID = 1;
                        objOGCM.ParentID = ParentID;
                        objOGCM.EmpID = 1;
                        objOGCM.RegisteredDate = DateTime.Now;
                        ctx.OGCMs.Add(objOGCM);
                    }
                    objOGCM.IsActive = true;
                    objOGCM.LastLogin = DateTime.Now;

                    // For Template
                    List<OTMP> LocalOTMP = ctx.OTMPs.Where(x => x.ParentID == 1000010000000000 && x.Active).ToList();
                    foreach (OTMP data in LocalOTMP)
                    {
                        OTMP objOTMP = new OTMP();
                        objOTMP.TemplateID = data.TemplateID;
                        objOTMP.ParentID = ParentID;
                        objOTMP.TemplateName = data.TemplateName;
                        objOTMP.CreatedDate = data.CreatedDate;
                        objOTMP.CreatedBy = data.CreatedBy;
                        objOTMP.UpdatedDate = data.UpdatedDate;
                        objOTMP.UpdatedBy = data.UpdatedBy;
                        objOTMP.IsDefault = data.IsDefault;
                        objOTMP.Active = data.Active;
                        objOTMP.SyncStatus = data.SyncStatus;
                        objOTMP.DivisionlID = data.DivisionlID;
                        ctx.OTMPs.Add(objOTMP);
                    }


                    //For SITM
                    List<SITM> LocalSitm = ctx.SITMs.Where(x => x.ParentID == 1000010000000000).ToList();

                    foreach (SITM dataSitm in LocalSitm)
                    {
                        SITM objsitm = new SITM();

                        objsitm.TemplateID = dataSitm.TemplateID;
                        objsitm.SITMID = dataSitm.SITMID;
                        objsitm.ParentID = ParentID;
                        objsitm.TemplateID = dataSitm.TemplateID;
                        objsitm.ItemID = dataSitm.ItemID;
                        objsitm.Priority = dataSitm.Priority;
                        objsitm.SyncStatus = dataSitm.SyncStatus;
                        objsitm.MinStock = dataSitm.MinStock;
                        objsitm.MaxStock = dataSitm.MaxStock;
                        objsitm.Days = dataSitm.Days;
                        ctx.SITMs.Add(objsitm);

                    }

                    //For Warehouse
                    List<OWH> LocalWhs = ctx.OWHS.Where(x => x.ParentID == 1000010000000000 && x.Active).ToList();
                    CRD1 objCRD1 = ctx.CRD1.FirstOrDefault(x => x.CustomerID == ParentID);

                    foreach (OWH datawhs in LocalWhs)
                    {
                        OWH objwhs = new OWH();
                        objwhs.WhsID = datawhs.WhsID;
                        objwhs.ParentID = ParentID;
                        objwhs.WhsName = datawhs.WhsName;
                        objwhs.Type = datawhs.Type;
                        objwhs.Length = datawhs.Length;
                        objwhs.Height = datawhs.Height;
                        objwhs.Width = datawhs.Width;
                        objwhs.NetArea = datawhs.NetArea;
                        objwhs.GrossArea = datawhs.GrossArea;
                        objwhs.RCCType = datawhs.RCCType;
                        objwhs.ROOFType = datawhs.ROOFType;
                        objwhs.OwnerShip = datawhs.OwnerShip;
                        objwhs.CreatedDate = datawhs.CreatedDate;
                        objwhs.CreatedBy = datawhs.CreatedBy;
                        objwhs.UpdatedDate = datawhs.UpdatedDate;
                        objwhs.UpdatedBy = datawhs.UpdatedBy;
                        objwhs.CityID = objCRD1.CityID;
                        objwhs.StateID = objCRD1.StateID;
                        objwhs.CountryID = objCRD1.CountryID;
                        objwhs.IsDefault = datawhs.IsDefault;
                        objwhs.Active = datawhs.Active;
                        objwhs.SyncStatus = datawhs.SyncStatus;
                        objwhs.WhsCode = datawhs.WhsCode;
                        ctx.OWHS.Add(objwhs);
                    }
                    ctx.SaveChanges();

                }
            }
        }
        catch (Exception)
        {

        }
        finally
        {

        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        Decimal ParentID;
        int UserID;
        GetLocation();
        if (Session["UserID"] != null && Int32.TryParse(Session["UserID"].ToString(), out UserID) && Session["ParentID"] != null && Decimal.TryParse(Session["ParentID"].ToString(), out ParentID))
        {

            using (DDMSEntities ctx = new DDMSEntities())
            {
                var Emp = ctx.OEMPs.Include("OCRD").FirstOrDefault(x => x.EmpID == UserID && x.ParentID == ParentID && x.Active);
                if (Emp != null && Emp.EmpID > 0)
                {
                    if (Emp.EmpGroupID.HasValue)
                    {
                        if (ctx.TOCRDs.Any(x => x.ParentID == Emp.OCRD.CustomerID && x.Active && x.Status == 2) || Emp.OCRD.Type == 1)
                        {
                            Session["Type"] = Emp.OCRD.Type;
                            Session["UserID"] = Emp.EmpID;
                            Session["UserType"] = Emp.UserType;
                            Session["GroupID"] = Emp.EmpGroupID;
                            //Session["IsDistLogin"] = 0;
                            Session["ParentID"] = Emp.OCRD.CustomerID;
                            Session["OutletPID"] = Emp.OCRD.ParentID;
                            if (Emp.OCRD.Type == 2)//After Distributor Name change it is not reflecting their name..It is showing before OEMP's UserName.
                                Session["FirstName"] = Emp.OCRD.CustomerCode + " # " + Emp.OCRD.CustomerName;
                            else
                                Session["FirstName"] = Emp.UserName + " # " + Emp.Name;
                            Session["Lang"] = "English";

                            var Password = Common.DecryptNumber(Emp.UserName, Emp.Password);
                            if (Emp.UserName == Password)
                            {
                                Session["LoginFlag"] = 2;
                                Response.Redirect("~/MyAccount/ChangePassword.aspx?flag=true");
                            }
                            else
                            {
                                var DayCloseData = ctx.CheckDayClose(DateTime.Now, Emp.OCRD.CustomerID).FirstOrDefault();
                                if (!String.IsNullOrEmpty(DayCloseData))
                                {
                                    Session["LoginFlag"] = 3;
                                    Response.Redirect("~/Sales/DayClose.aspx");
                                }
                                else
                                {
                                    Session["LoginFlag"] = 1;
                                    Response.Redirect("~/Home.aspx");
                                }
                            }
                        }
                        else if (ctx.TOCRDs.Any(x => x.ParentID == Emp.OCRD.CustomerID && x.Active && x.Status == 1))
                        {
                            this.ClientScript.RegisterStartupScript(this.GetType(), "", "alert('Your GST Request is not confirm! Please contact Vadilal Team.');", true);
                        }
                        else if (Emp.OCRD.Type == 2 || Emp.OCRD.Type == 4)
                        {
                            Response.Redirect("~/MyAccount/MyProfile.aspx?DocNo=" + 0 + "&DocKey=" + Emp.OCRD.CustomerID.ToString());
                        }
                    }
                    else
                        this.ClientScript.RegisterStartupScript(this.GetType(), "", "ModelMsg('This user is not associated with any group or outlet!',3);", true);
                }
            }
            try
            {
                var cookie = Request.Cookies["DDMS"];
                if (cookie != null)
                {
                    if (cookie.Values["CustomerCode"] != null)
                    {
                        chkRemember.Checked = true;
                        CheckLogin(cookie.Values["CustomerCode"], cookie.Values["UserName"], cookie.Values["Password"]);

                    }
                }
            }
            catch (Exception)
            {
            }
            this.Form.DefaultButton = this.btnlogin.UniqueID;

        }
    }

    protected void btnlogin_Click(object sender, EventArgs e)
    {
        if (Page.IsValid)
        {
            try
            {
                if (String.IsNullOrEmpty(txtUsername.Text) && String.IsNullOrEmpty(txtPassword.Text))
                {
                    this.ClientScript.RegisterStartupScript(this.GetType(), "", "ModelMsg('UserName And Password are required!',3);", true);
                    return;
                }
                CheckLogin(txtDCode.Text, txtUsername.Text, txtPassword.Text);


            }
            catch (Exception ex)
            {
                this.ClientScript.RegisterStartupScript(this.GetType(), "", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
            }
        }
    }

    private void CheckLogin(string CustomerCode, string UserName, string Password)
    {
        
        using (DDMSEntities ctx = new DDMSEntities())
        {
            OCRD Cust = null;
            OEMP Emp = null;
            var Pwd = Common.EncryptNumber(UserName, Password);
            var IsDistLogin = false;
            if (CustomerCode.Contains("##") && CustomerCode.Contains("1000010000000000"))
            {
                CustomerCode = CustomerCode.Split("##".ToArray()).Last().Trim();
                Cust = ctx.OCRDs.FirstOrDefault(x => x.CustomerCode == CustomerCode && (x.Type == 2 || x.Type == 4));
                if (Cust == null)
                {
                    this.ClientScript.RegisterStartupScript(this.GetType(), "", "ModelMsg('Your Code Not Found, Contact to DMS Team Only',3);", true);
                    return;
                }
                Emp = ctx.OEMPs.FirstOrDefault(x => x.UserName == UserName && x.Password == Pwd && x.ParentID == 1000010000000000 && x.Active);
                IsDistLogin = true;
            }
            else
            {
                Cust = ctx.OCRDs.FirstOrDefault(x => x.CustomerCode == CustomerCode && (x.Type == 1 || x.Type == 2 || x.Type == 4));
                if (Cust == null)
                {
                    this.ClientScript.RegisterStartupScript(this.GetType(), "", "ModelMsg('Your Code Not Found, Contact to DMS Team Only',3);", true);
                    return;
                }
                else if (!Cust.Active)
                {
                    this.ClientScript.RegisterStartupScript(this.GetType(), "", "ModelMsg('Your code is In-active, Contact to Marketing Dept Only.',3);", true);
                    return;
                }

                if (ctx.AOCRDs.Any(x => x.CustomerID == Cust.CustomerID))
                {
                    AOCRD objAOCRD = ctx.AOCRDs.FirstOrDefault(x => x.CustomerID == Cust.CustomerID);
                    if (!objAOCRD.Active)
                    {
                        this.ClientScript.RegisterStartupScript(this.GetType(), "", "ModelMsg('DMS Status is In-active for your code, Contact to Marketing Dept Only.',3);", true);
                        return;
                    }
                }

                if (new Int32[] { 2, 4 }.Contains(Cust.Type))
                {
                    if (!ctx.RUT1.Any(x => x.CustomerID == Cust.CustomerID && x.Active == true && x.IsDeleted == false && x.ORUT.Active))
                    {
                        this.ClientScript.RegisterStartupScript(this.GetType(), "", "ModelMsg('Beat is not maintain for your code so, Please contact to Local Mktg Staff.',3);", true);
                        return;
                    }
                }

                Emp = ctx.OEMPs.FirstOrDefault(x => x.UserName == UserName && x.Password == Pwd && x.ParentID == Cust.CustomerID && x.Active);
            }
            //Ticket No:7673
            if (Cust.Type == 2 || Cust.Type == 4)
            {

                var DisOrSSDMSObj = ctx.TOCRDs.FirstOrDefault(x => x.ParentID == Cust.CustomerID && x.Active);
                if (DisOrSSDMSObj != null)
                {
                    if (DisOrSSDMSObj.Status == 2)
                    {
                        string DisOrSSSAPgst = Cust.GSTIN;
                        string DMSStatus = string.Empty;
                        string SAPStatus = string.Empty;


                        if ((Cust.GSTIN == "") || string.IsNullOrEmpty(Cust.GSTIN))
                            SAPStatus = "UN-REGISTER";
                        else if (Cust.CompositeScheme)
                            SAPStatus = "COMPOSITE";
                        else
                            SAPStatus = "GST REGISTER";

                        if (!DisOrSSDMSObj.CompositeScheme)
                            DMSStatus = "UN-REGISTER";
                        else if (DisOrSSDMSObj.VAT == "1")
                            DMSStatus = "COMPOSITE";
                        else
                            DMSStatus = "GST REGISTER";
                        if (DisOrSSDMSObj.GST != DisOrSSSAPgst && DMSStatus != SAPStatus)
                        {
                            this.ClientScript.RegisterStartupScript(this.GetType(), "", "ModelMsg('GST number and Status both are mismatch between DMS and SAP. <br>So, Please contact to Marketing Dept only.',3);", true);
                            return;
                        }

                        if (DisOrSSDMSObj.GST != DisOrSSSAPgst)
                        {
                            this.ClientScript.RegisterStartupScript(this.GetType(), "", "ModelMsg('GST number is mismatch between DMS and SAP. <br>So, Please contact to Marketing Dept only.',3);", true);
                            return;
                        }

                        if (DMSStatus != SAPStatus)
                        {
                            this.ClientScript.RegisterStartupScript(this.GetType(), "", "ModelMsg('GST Status is mismatch between DMS and SAP. <br>So, Please contact to Marketing Dept only.',3);", true);
                            return;
                        }

                    }
                }

                if (Cust.Type == 2)/// Added condition temporary for testing one imp ticket.by jigneshbhai ..27-03-2021
                {
                    var dfwCust = ctx.OCRDs.Where(x => x.ParentID == Cust.CustomerID && x.CustomerCode.ToLower().Contains("dfw")).Select(x => new
                    {
                        x.CustomerID,
                        x.CustomerCode,
                        x.Active
                    }).ToList();

                    if (dfwCust != null && dfwCust.Count > 0)
                    {
                        Int32 cndist = dfwCust.Count(x => x.Active);
                        if (cndist > 1)
                        {
                            this.ClientScript.RegisterStartupScript(this.GetType(), "", "ModelMsg('DFW.... Dealer Code for Default Pricing Group found Multiple. <br>So, Please contact to Marketing Dept only.',3);", true);
                            return;
                        }
                        else if (cndist == 1)
                        {
                            // Start As per T900012726 # Error in Invoice Creation
                            // Put validation for DFW customer's pricing group entry not found
                            var DFWCustomerID = dfwCust.FirstOrDefault().CustomerID;
                            var objOGCRD = ctx.OGCRDs.FirstOrDefault(x => x.CustomerID == DFWCustomerID && x.PriceListID != null && x.DivisionlID == 3);
                            if (objOGCRD == null)
                            {
                                this.ClientScript.RegisterStartupScript(this.GetType(), "", "ModelMsg('I/C Pricing group not assign in this DFW.... <br>Dealer : " + dfwCust.FirstOrDefault().CustomerCode + " ',3);", true);
                                return;
                            }
                            // End As per T900012726 # Error in Invoice Creation
                        }
                        else
                        {
                            this.ClientScript.RegisterStartupScript(this.GetType(), "", "ModelMsg('" + dfwCust.FirstOrDefault().CustomerCode + " Dealer Code for Default Pricing Group is In-Active found. <br>So, Please contact to Marketing Dept only.',3);", true);
                            return;
                        }
                    }
                    else
                    {
                        this.ClientScript.RegisterStartupScript(this.GetType(), "", "ModelMsg('DFW.... Dealer Code for Default Pricing Group is not found. <br>So, Please contact to Marketing Dept only.',3);", true);
                        return;
                    }
                }
            }
            if (Emp != null && Emp.EmpID > 0)
            {
                if (!String.IsNullOrEmpty(Emp.Password2) && !String.IsNullOrEmpty(Emp.Password3) && !String.IsNullOrEmpty(Emp.Password4))
                {
                    var ServerMacAddress = Common.DecryptNumber(Constant.AuthKey, Emp.Password2);
                    var LocalMacAddress = Common.DecryptNumber(Constant.AuthKey, Emp.Password3);

                    var Date = Common.DecryptNumber(Constant.AuthKey, Emp.Password4);
                    DateTime EDDate = Common.DateTimeConvert(Date);

                    if (true)
                    //if ((Common.GetMACAddress().Contains(LocalMacAddress) || Common.GetMACAddress().Contains(ServerMacAddress)) && EDDate >= DateTime.Now)
                    {
                        if (Emp.EmpGroupID.HasValue)
                        {
                            if (IsDistLogin || (ctx.TOCRDs.Any(x => x.ParentID == Cust.CustomerID && x.Active && x.Status == 2)) || Cust.Type == 1)
                            {
                                Session["Type"] = Cust.Type;
                                Session["UserID"] = IsDistLogin ? 1 : Emp.EmpID;
                                Session["UserType"] = Emp.UserType;
                                Session["IsDistLogin"] = IsDistLogin;
                                Session["ParentID"] = Cust.CustomerID;
                                Session["OutletPID"] = Cust.ParentID;
                                Session["GroupID"] = IsDistLogin ? 1 : Emp.EmpGroupID;
                                Session["FirstName"] = (IsDistLogin || (Cust.Type == 2 || Cust.Type == 4)) ? Cust.CustomerCode + " # " + Cust.CustomerName : Emp.UserName + " # " + Emp.Name;
                                Session["Lang"] = "English";
                                var myCookie = new HttpCookie("DDMS");
                                if (chkRemember.Checked)
                                {
                                    myCookie.Values.Add("CustomerCode", Cust.CustomerCode);
                                    myCookie.Values.Add("UserName", UserName);
                                    myCookie.Values.Add("Password", Password);
                                }
                                myCookie.Expires = DateTime.Now.AddMonths(1);
                                Response.Cookies.Add(myCookie);

                                Thread ts = new Thread(() => SetTopItems(Cust.CustomerID));
                                ts.Name = "xyz";
                                ts.Start();

                                if (UserName == Password)
                                {
                                    Session["LoginFlag"] = 2;
                                    Response.Redirect("~/MyAccount/ChangePassword.aspx?flag=true");
                                }
                                else
                                {
                                    var DayCloseData = ctx.CheckDayClose(DateTime.Now, Cust.CustomerID).FirstOrDefault();
                                    if (!String.IsNullOrEmpty(DayCloseData))
                                    {
                                        Session["LoginFlag"] = 3;
                                        Response.Redirect("~/Sales/DayClose.aspx");
                                    }
                                    else
                                    {
                                        Session["LoginFlag"] = 1;
                                        Response.Redirect("~/Home.aspx");
                                    }
                                }
                            }
                            else if (ctx.TOCRDs.Any(x => x.ParentID == Cust.CustomerID && x.Active && x.Status == 1))
                            {
                                this.ClientScript.RegisterStartupScript(this.GetType(), "", "alert('GST Form not verify, Contact To Mktg Dept Only');", true);
                            }
                            else if (Cust.Type == 2 || Cust.Type == 4)
                            {
                                Response.Redirect("~/MyAccount/MyProfile.aspx?DocNo=" + 0 + "&DocKey=" + Cust.CustomerID.ToString());
                            }

                        }
                        else
                            this.ClientScript.RegisterStartupScript(this.GetType(), "", "ModelMsg('This user is not associated with any group or outlet!',3);", true);
                    }
                    else
                        this.ClientScript.RegisterStartupScript(this.GetType(), "", "ModelMsg('You are not authorized to login! Please contact Customer Care: 07966168911,88',3);", true);
                }
                else
                    this.ClientScript.RegisterStartupScript(this.GetType(), "", "ModelMsg('You are not authorized to login. Please contact Customer Care: 07966168911,88',3);", true);
            }
            else
            {
                var Super = ctx.OEMPs.FirstOrDefault(x => x.UserName == "SUPERUSER" && x.ParentID == 1 && x.Password == Pwd && x.Active);
                if (Super != null && Cust.CustomerID > 0)
                {
                    //if (ctx.TOCRDs.Any(x => x.ParentID == Cust.CustomerID && x.Active && x.Status == 2) || Cust.Type == 1)
                    //{
                    Session["Type"] = Cust.Type;
                    Session["UserID"] = Super.EmpID;
                    Session["UserType"] = Super.UserType;
                    Session["ParentID"] = Cust.CustomerID;
                    Session["OutletPID"] = Cust.ParentID;
                    Session["IsDistLogin"] = IsDistLogin;
                    Session["GroupID"] = Super.EmpGroupID;
                    Session["FirstName"] = Super.UserName + " # " + Super.Name;
                    Session["Lang"] = "English";
                    var myCookie = new HttpCookie("DDMS");
                    if (chkRemember.Checked)
                    {
                        myCookie.Values.Add("CustomerCode", Cust.CustomerCode);
                        myCookie.Values.Add("UserName", UserName);
                        myCookie.Values.Add("Password", Password);
                    }
                    myCookie.Expires = DateTime.Now.AddMonths(1);
                    Response.Cookies.Add(myCookie);

                    Thread ts = new Thread(() => SetTopItems(Cust.CustomerID));
                    ts.Name = "xyz";
                    ts.Start();

                    if (UserName == Password)
                    {
                        Session["LoginFlag"] = 2;
                        Response.Redirect("~/MyAccount/ChangePassword.aspx?flag=true");
                    }
                    else
                    {
                        var DayCloseData = ctx.CheckDayClose(DateTime.Now, Cust.CustomerID).FirstOrDefault();
                        if (!String.IsNullOrEmpty(DayCloseData))
                        {
                            Session["LoginFlag"] = 3;
                            Response.Redirect("~/Sales/DayClose.aspx");
                        }
                        else
                        {
                            Session["LoginFlag"] = 1;
                            Response.Redirect("~/Home.aspx");
                        }
                    }
                    //}
                    //else if (ctx.TOCRDs.Any(x => x.ParentID == Cust.CustomerID && x.Active && x.Status == 1))
                    //{
                    //    this.ClientScript.RegisterStartupScript(this.GetType(), "", "alert('Your GST Request is not confirm! Please contact Vadilal Team.');", true);
                    //}
                    //else if (Cust.Type == 2)
                    //{
                    //    Response.Redirect("~/MyAccount/MyProfile.aspx?DocNo=" + 0 + "&DocKey=" + Cust.CustomerID.ToString());
                    //}

                }
                else
                {
                    this.ClientScript.RegisterStartupScript(this.GetType(), "", "ModelMsg('Password Wrong, Enter Correct Password',3);", true);
                }
            }
        }
    }

    protected void ForgetPassword_Click(object sender, EventArgs e)
    {
        if (String.IsNullOrEmpty(txtDCode.Text))
        {
            this.ClientScript.RegisterStartupScript(this.GetType(), "", "ModelMsg('Please enter Customer Code',3);", true);
            return;
        }
        else
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                if (ctx.OCRDs.Any(x => x.CustomerCode == txtDCode.Text.Trim() && x.Active && new[] { 2, 4 }.Contains(x.Type)))
                {
                    Response.Redirect("~/ForgotPassword.aspx?CD=" + txtDCode.Text.Trim());
                }
                else
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Customer Code does not Exist !',3);", true);
                    return;
                }
            }

        }
    }

    [WebMethod]
    public static string GetMessageBroadcastList()
    {
        List<dynamic> result = new List<dynamic>();
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                DateTime dt = DateTime.Now.Date;
                var data = ctx.OMSGs.Where(x => x.Active && x.ApplicableFor == "D" &&
                    EntityFunctions.TruncateTime(x.ApplicableFromDate) <= dt && EntityFunctions.TruncateTime(x.ApplicableToDate) >= dt).OrderByDescending(x => x.CreatedDate).Select(x =>
                    new
                    {
                        Subject = x.Subject,
                        MessageBody = string.IsNullOrEmpty(x.MessageBody) ? "" : x.MessageBody,
                        ImageUpload = string.IsNullOrEmpty(x.ImageUpload) ? "" : "/Document/MsgBroadcastUpload/" + x.ImageUpload
                    }).ToList();
                result.Add(data);
            }
            string strmsg = JsonConvert.SerializeObject(result,
                           new JsonSerializerSettings
                           {
                               ReferenceLoopHandling = ReferenceLoopHandling.Ignore
                           });
            return strmsg;
        }
        catch (Exception ex)
        {
            return "";
        }
    }
    public void GetLocation()
    {

        string ipAddress = HttpContext.Current.Request.UserHostAddress.ToString();
       // lblIP.Text = ipAddress.ToString();
        string APIKey = "A15FBD605A84806EE36D00D0642AA735";
        string url = string.Format("http://api.ip2location.io/?ip={1}&key={0}&format=json", APIKey, ipAddress);
        using (WebClient client = new WebClient())
        {
            string json = client.DownloadString(url);
            Location location = new JavaScriptSerializer().Deserialize<Location>(json);
            List<Location> locations = new List<Location>();
            locations.Add(location);
          //  lblLocation.Text = "अगर आपका स्टेट  नेम " + location.region_name.ToString() + " नहीं हे तो DMS Team (Mob. 9909909414)     या    लोकल सेल्स स्टाफ को बताए ।";
        }
        //return "reg";
    }
}
public class Location
{
    public string ip { get; set; }
    public string country_name { get; set; }
    public string country_code { get; set; }
    public string city_name { get; set; }
    public string region_name { get; set; }
    public string zip_code { get; set; }
    public string Latitude { get; set; }
    public string Longitude { get; set; }
    public string time_zone { get; set; }
}