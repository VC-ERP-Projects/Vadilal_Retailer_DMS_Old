using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Objects.SqlClient;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Task_TaskEscalationMatrix : System.Web.UI.Page
{
    #region Declaration

    protected int UserID;
    protected decimal ParentID;
    protected String AuthType;

    #endregion

    #region Helper Method

    private void ClearAllInputs()
    {
        using (DDMSEntities ctx = new DDMSEntities())
        {
            ddlProbType.Items.Clear();
            ddlProbType.DataSource = null;
            ddlProbType.DataBind();
            var ProbType = ctx.OPLMs.Where(x => x.Active && x.TaskTypeID == 2).ToList();
            ddlProbType.DataSource = ProbType;
            ddlProbType.DataBind();

            txtRegion.Text = txtLocation.Text = "";
            hdnMatrixID.Value = "0";
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
                            var unit = xml.Descendants("employee_master");
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

    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<dynamic> GetData()
    {
        List<dynamic> result = new List<dynamic>();
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                List<String> MechHrchy = ctx.OGRPs.OrderBy(x => x.EmpGroupName).Where(x => x.ParentID == 1000010000000000).Select(x => x.EmpGroupName + " # " + SqlFunctions.StringConvert((double)x.EmpGroupID).Trim()).ToList();
                List<String> FStaffHrchy = ctx.OGRPs.OrderBy(x => x.EmpGroupName).Where(x => x.ParentID == 1000010000000000).Select(x => x.EmpGroupName + " # " + SqlFunctions.StringConvert((double)x.EmpGroupID).Trim()).ToList();
                result.Add(MechHrchy);
                result.Add(FStaffHrchy);
            }
        }
        catch (Exception ex)
        {
            result.Add("ERROR#" + "" + Common.GetString(ex));
        }
        return result;
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

    #region ButtonClick

    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static string SaveData(string hidJsonInputMaterial, string hidJsonInputHeader)
    {
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);
                int UserID = Convert.ToInt32(HttpContext.Current.Session["UserID"]);
                var LineData = JsonConvert.DeserializeObject<dynamic>(hidJsonInputMaterial.ToString());
                var HeaderData = JsonConvert.DeserializeObject<dynamic>(hidJsonInputHeader.ToString());

                Int32 ProbType = Convert.ToInt32(Convert.ToString(HeaderData["ProbType"]));
                Int32 RegionID = Convert.ToInt32(Convert.ToString(HeaderData["RegionID"]));
                Int32 LocationID = Convert.ToInt32(Convert.ToString(HeaderData["LocationID"]));
                Int32 MatrixID = Convert.ToInt32(Convert.ToString(HeaderData["MatrixID"]));

                if (ProbType > 0 && RegionID > 0 && LocationID > 0)
                {
                    if (LineData != null)
                    {
                        if (MatrixID == 0 && ctx.OTEMs.Any(x => x.ProblemID == ProbType && x.StateID == RegionID && x.StorageLocID == LocationID))
                            return "ERROR=This Combinition of Configuration already exist, Please search and Modify it !";

                        int Count = ctx.GetKey("OTEM", "MatrixID", "", ParentID, 0).FirstOrDefault().Value;
                        var objOTEM = ctx.OTEMs.FirstOrDefault(x => x.MatrixID == MatrixID);
                        if (objOTEM == null)
                        {
                            objOTEM = new OTEM();
                            objOTEM.MatrixID = Count++;
                            objOTEM.ParentID = ParentID;
                            objOTEM.CreatedDate = DateTime.Now;
                            objOTEM.CreatedBy = UserID;
                            ctx.OTEMs.Add(objOTEM);
                        }
                        objOTEM.StorageLocID = LocationID;
                        objOTEM.StateID = RegionID;
                        objOTEM.ProblemID = ProbType;
                        objOTEM.UpdatedBy = UserID;
                        objOTEM.UpdatedDate = DateTime.Now;

                        List<TEM1> objTEM1s = objOTEM.TEM1.ToList();
                        objTEM1s.ForEach(x => x.Active = false);

                        int CountTEM1 = ctx.GetKey("TEM1", "TEMP1ID", "", ParentID, 0).FirstOrDefault().Value;
                        foreach (var data in LineData)
                        {
                            int LvlNo = Int32.TryParse(Convert.ToString(data["LvlNo"]), out LvlNo) ? LvlNo : 0;
                            int InCityFromHr = Int32.TryParse(Convert.ToString(data["InCityFromHr"]), out InCityFromHr) ? InCityFromHr : 0;
                            int InCityToHr = Int32.TryParse(Convert.ToString(data["InCityToHr"]), out InCityToHr) ? InCityToHr : 0;
                            int OutCityFromHr = Int32.TryParse(Convert.ToString(data["OutCityFromHr"]), out OutCityFromHr) ? OutCityFromHr : 0;
                            int OutCityToHr = Int32.TryParse(Convert.ToString(data["OutCityToHr"]), out OutCityToHr) ? OutCityToHr : 0;
                            int MechHrchy = Int32.TryParse(Convert.ToString(data["MechHrchy"]), out MechHrchy) ? MechHrchy : 0;
                            int FStaffHrchy = Int32.TryParse(Convert.ToString(data["FStaffHrchy"]), out FStaffHrchy) ? FStaffHrchy : 0;

                            TEM1 objTEM1 = objTEM1s.FirstOrDefault(x => x.LevelNo == LvlNo);
                            if (objTEM1 == null)
                            {
                                objTEM1 = new TEM1();
                                objTEM1.TEMP1ID = CountTEM1++;
                                objTEM1.MatrixID = objOTEM.MatrixID;
                                objTEM1.ParentID = ParentID;
                                ctx.TEM1.Add(objTEM1);
                            }
                            objTEM1.LevelNo = LvlNo;
                            objTEM1.InCityFromHr = InCityFromHr;
                            objTEM1.InCityToHr = InCityToHr;
                            objTEM1.OutCityFromHr = OutCityFromHr;
                            objTEM1.OutCityToHr = OutCityToHr;
                            objTEM1.MechHrchy = MechHrchy;
                            objTEM1.FStaffHrchy = FStaffHrchy;
                            objTEM1.EmaiIDs = Convert.ToString(data["Emails"]);
                            objTEM1.Active = true;
                        }
                    }
                }
                else
                    return "ERROR=Please Enter Region and Location Both !";

                ctx.SaveChanges();
                return "SUCCESS=Configuration Saved Successfully !";
            }
        }
        catch (Exception ex)
        {
            return "ERROR=Something is worng: " + Common.GetString(ex);
        }
    }

    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<dynamic> GetDetail(string strProbType, string strRegionID, string strLocationID)
    {
        List<dynamic> result = new List<dynamic>();
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                Int32 ProbType = Convert.ToInt32(strProbType);
                Int32 RegionID = Convert.ToInt32(strRegionID);
                Int32 LocationID = Convert.ToInt32(strLocationID);
                dynamic DetailData = "";
                var OTEMS = ctx.OTEMs.FirstOrDefault(x => x.ProblemID == ProbType && x.StateID == RegionID && x.StorageLocID == LocationID);
                if (OTEMS != null)
                {
                    DetailData = OTEMS.TEM1.Select(x =>
                                    new
                                    {
                                        LvlNo = x.LevelNo,
                                        InCityFromHr = x.InCityFromHr,
                                        InCityToHr = x.InCityToHr,
                                        OutCityFromHr = x.OutCityFromHr,
                                        OutCityToHr = x.OutCityToHr,
                                        Emails = x.EmaiIDs,
                                        MechHrchy = x.OGRP.EmpGroupName + " # " + x.OGRP.EmpGroupID,
                                        FStaffHrchy = x.OGRP1.EmpGroupName + " # " + x.OGRP1.EmpGroupID,
                                        MatrixID = x.MatrixID,
                                        CreatedDate = OTEMS.CreatedDate.ToString(),
                                        UpdatedDate = OTEMS.UpdatedDate.ToString(),
                                        CreatedBy = ctx.OEMPs.Where(y => y.EmpID == OTEMS.CreatedBy).Select(y => y.EmpCode + " # " + y.Name).FirstOrDefault(),
                                        UpdatedBy = ctx.OEMPs.Where(y => y.EmpID == OTEMS.UpdatedBy).Select(y => y.EmpCode + " # " + y.Name).FirstOrDefault(),
                                    }).ToList();
                }
                result.Add(DetailData);
            }
        }
        catch (Exception ex)
        {
            result.Add("ERROR#" + "" + Common.GetString(ex));
        }
        return result;
    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        ClearAllInputs();
    }

    #endregion

    protected void btnSendNoti_Click(object sender, EventArgs e)
    {
        using (DDMSEntities ctx = new DDMSEntities())
        {
            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();
            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "MECH_SendNoti";
            DataSet ds = objClass.CommonFunctionForSelect(Cm);
            DataTable dt;
            Boolean NotiSend = true;
            Boolean IsExclude = false;
            if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
            {
                dt = ds.Tables[0];
                List<DataRow> list = dt.AsEnumerable().ToList();
                foreach (var item in list)
                {
                    NotiSend = true;
                    IsExclude = false;
                    Decimal NextEmpID = Convert.ToInt16(item[0].ToString());

                    for (int i = 0; i <= 1; i++)
                    {
                        OGCM objOGCM = ctx.OGCMs.FirstOrDefault(x => x.EmpID == NextEmpID && x.ParentID == ParentID && x.IsActive);
                        NextEmpID = Convert.ToInt16(item[1].ToString());

                        if (objOGCM != null && NotiSend && !IsExclude)
                        {
                            WebRequest tRequest = WebRequest.Create("https://fcm.googleapis.com/fcm/send");
                            tRequest.Method = "post";
                            tRequest.ContentType = "application/json";
                            var data = new
                            {
                                to = objOGCM.Token,
                                notification = new
                                {
                                    body = item[2].ToString(),
                                    title = item[3].ToString(),
                                    sound = "Enabled"
                                }
                            };
                            JavaScriptSerializer serializer = new JavaScriptSerializer();
                            string json = serializer.Serialize(data);
                            Byte[] byteArray = Encoding.UTF8.GetBytes(json);
                            tRequest.Headers.Add(string.Format("Authorization: key={0}", item[4].ToString()));
                            tRequest.Headers.Add(string.Format("Sender: id={0}", item[5].ToString()));
                            tRequest.ContentLength = byteArray.Length;
                            using (Stream dataStream = tRequest.GetRequestStream())
                            {
                                dataStream.Write(byteArray, 0, byteArray.Length);
                                using (WebResponse tResponse = tRequest.GetResponse())
                                {
                                    using (Stream dataStreamResponse = tResponse.GetResponseStream())
                                    {
                                        using (StreamReader tReader = new StreamReader(dataStreamResponse))
                                        {
                                            var Result = tReader.ReadToEnd();
                                            if (!string.IsNullOrEmpty(Result))
                                            {
                                                GCM1 objGCM1 = new GCM1();
                                                objGCM1.ParentID = ParentID;
                                                objGCM1.DeviceID = objOGCM.DeviceID;
                                                objGCM1.CreatedDate = DateTime.Now;
                                                objGCM1.CreatedBy = UserID;
                                                objGCM1.Body = item[2].ToString();
                                                objGCM1.Title = item[3].ToString();
                                                objGCM1.UnRead = true;
                                                objGCM1.IsDeleted = false;
                                                if (Result.IndexOf("\"success\":", StringComparison.CurrentCultureIgnoreCase) > 0)
                                                    objGCM1.SentOn = true;
                                                else
                                                    objGCM1.SentOn = false;
                                                ctx.GCM1.Add(objGCM1);
                                                ctx.SaveChanges();
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}