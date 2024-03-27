﻿using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Web;
using System.Text;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Xml.Linq;
using System.Data.Objects.SqlClient;
using System.Threading;
using System.Data.SqlClient;
using Newtonsoft.Json;
using System.Configuration;
using System.Data.Entity.Validation;
using System.Data.Objects;


public partial class Master_DIstFSSAIMaster : System.Web.UI.Page
{
    #region Declaration

    protected int UserID, CustType, Index;
    protected decimal ParentID;
    protected String AuthType;
    protected String Version;
    protected String LogoURL;
    [Serializable]
    public class FSSIValidate
    {
        public int OFSSIID { get; set; }
        public decimal FSSIForID { get; set; }
        public String FSSINO { get; set; }
        public string CustDesc { get; set; }
        public string CustomerName { get; set; }
        public String Status { get; set; }
        public string City { get; set; }
        public string Employee { get; set; }
        public String RegionDesc { get; set; }
        public String StartDate { get; set; }
        public String EndDate { get; set; }
        public String CreatedDate { get; set; }
        public string CreatedBy { get; set; }
        public String UpdatedDate { get; set; }
        public string UpdatedBy { get; set; }


        public string FSSAIImage { get; set; }
        public Boolean IsVerify { get; set; }
        public string Imagebase64 { get; set; }
        public string FSSIImagePath { get; set; }
        public string GSTIN { get; set; }
        public Int32 CreatedByUserId { get; set; }

    }
    #endregion

    #region HelperMethod

    public void ValidateUser()
    {
        if (Session["UserID"] != null && Session["ParentID"] != null &&
          Int32.TryParse(Session["UserID"].ToString(), out UserID) && Decimal.TryParse(Session["ParentID"].ToString(), out ParentID))
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                int EGID = Convert.ToInt32(Session["GroupID"]);
                CustType = Convert.ToInt32(Session["Type"]);
                Version = Convert.ToString(ConfigurationManager.AppSettings["Version"]);
                LogoURL = Common.GetLogo(ParentID);
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

                    hdnUserName.Value = ctx.OEMPs.Where(x => x.EmpID == UserID && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault().ToString();

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
        }
        else
        {
            Response.Redirect("~/Login.aspx");
        }
    }

    #endregion

    #region PageLoad

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        if (!IsPostBack)
        {
            //LoadData();
            //ClearAllInputs();

        }
    }

    #endregion

    #region AjaxMethods

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<dynamic> LoadData(int Type)
    {
        List<dynamic> result = new List<dynamic>();
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();
        int UserID = Convert.ToInt32(HttpContext.Current.Session["UserID"]);

        String PaerntId = Convert.ToString(HttpContext.Current.Session["ParentID"]);

        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "GetFSSIDataForCustomer";
        Cm.Parameters.AddWithValue("@Type", Type);
        Cm.Parameters.AddWithValue("@ParentId", PaerntId);

        DataSet ds = objClass.CommonFunctionForSelect(Cm);
        if (ds.Tables.Count > 0)
        {
            List<FSSIValidate> CallData = ds.Tables[0].AsEnumerable().Select
             (x => new FSSIValidate
             {
                 OFSSIID = x.Field<int>("OFSSIID"),
                 FSSIForID = x.Field<decimal>("FSSIForID"),
                 FSSINO = x.Field<String>("FSSINO"),
                 CustDesc = x.Field<String>("CustDesc"),
                 CustomerName = x.Field<String>("CustomerName"),

                 Status = x.Field<String>("Status"),
                 RegionDesc = x.Field<String>("RegionDesc"),
                 City = x.Field<String>("CityName"),
                 StartDate = x.Field<String>("StartDate"),
                 EndDate = x.Field<String>("EndDate"),
                 CreatedDate = x.Field<String>("CreatedDate"),
                 CreatedBy = x.Field<String>("CreatedBy"),
                 UpdatedDate = x.Field<String>("UpdatedDate"),
                 UpdatedBy = x.Field<String>("UpdatedBy"),
                 Imagebase64 = x.Field<String>("Imagebase64"),
                 FSSIImagePath = x.Field<String>("FSSIImagePath"),
                 FSSAIImage = x.Field<String>("FSSAIImage"),
                 GSTIN = x.Field<String>("GSTIN"),
                 CreatedByUserId = x.Field<Int32>("CreatedByUserid")

             }).ToList();
            result.Add(CallData);
        }
        return result;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<DicData> GetDistributorCurrHierarchy(string prefixText)
    {
        List<DicData> result = new List<DicData>();

        try
        {
            List<string> items = new List<string>();
            prefixText = !string.IsNullOrEmpty(prefixText) ? prefixText : "*";

            int UserID = Convert.ToInt32(HttpContext.Current.Session["UserID"]);
            decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);

            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();

            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "GetMasterDataForCurrHierarchyReports";

            Cm.Parameters.AddWithValue("@Type", "Distributor");
            Cm.Parameters.AddWithValue("@UserID", UserID);
            Cm.Parameters.AddWithValue("@ParentID", ParentID);
            Cm.Parameters.AddWithValue("@Prefix", prefixText);
            Cm.Parameters.AddWithValue("@Count", 0);
            Cm.Parameters.AddWithValue("@StateID", 0);
            Cm.Parameters.AddWithValue("@CityID", 0);
            Cm.Parameters.AddWithValue("@PlantID", 0);
            Cm.Parameters.AddWithValue("@SSID", 0);
            Cm.Parameters.AddWithValue("@DistID", 0);

            DataSet ds = objClass.CommonFunctionForSelect(Cm);

            return ds.Tables[0].AsEnumerable()
                        .Select(r => new DicData { Text = r.Field<string>("Data"), Value = 0 })
                        .ToList();
        }
        catch (Exception ex)
        { }

        return result;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<DicData> GetSSCurrHierarchy(string prefixText)
    {
        List<DicData> result = new List<DicData>();

        try
        {
            List<string> items = new List<string>();
            prefixText = !string.IsNullOrEmpty(prefixText) ? prefixText : "*";
            int UserID = Convert.ToInt32(HttpContext.Current.Session["UserID"]);
            decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);

            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();

            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "GetMasterDataForCurrHierarchyReports";

            Cm.Parameters.AddWithValue("@Type", "SS");
            Cm.Parameters.AddWithValue("@UserID", UserID);
            Cm.Parameters.AddWithValue("@ParentID", ParentID);
            Cm.Parameters.AddWithValue("@Prefix", prefixText);
            Cm.Parameters.AddWithValue("@Count", 0);
            Cm.Parameters.AddWithValue("@StateID", 0);
            Cm.Parameters.AddWithValue("@CityID", 0);
            Cm.Parameters.AddWithValue("@PlantID", 0);
            Cm.Parameters.AddWithValue("@SSID", 0);
            Cm.Parameters.AddWithValue("@DistID", 0);

            DataSet ds = objClass.CommonFunctionForSelect(Cm);

            return ds.Tables[0].AsEnumerable()
                        .Select(r => new DicData { Text = r.Field<string>("Data"), Value = 0 })
                        .ToList();
        }
        catch (Exception ex)
        { }

        return result;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<DicData> GetVehicle(string prefixText)
    {
        List<DicData> result = new List<DicData>();

        try
        {
            using (var ctx = new DDMSEntities())
            {
                prefixText = !string.IsNullOrEmpty(prefixText) ? prefixText : "*";
                int UserID = Convert.ToInt32(HttpContext.Current.Session["UserID"]);
                decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);

                if (prefixText == "*")
                {
                    result = (from v in ctx.OVCLs
                              where v.Active
                              orderby v.CreatedDate
                              select new DicData
                              {
                                  Value = 1,
                                  Text = v.VehicleNumber// + " - " + SqlFunctions.StringConvert((Double)v.VehicleID).Trim()
                              }).Distinct().Take(20).ToList();
                }
                else
                {
                    result = (from v in ctx.OVCLs
                              where v.Active && v.VehicleNumber.Contains(prefixText)
                              orderby v.CreatedDate
                              select new DicData
                              {
                                  Value = 1,
                                  Text = v.VehicleNumber //+ " - " + SqlFunctions.StringConvert((Double)v.VehicleID).Trim()
                              }).Distinct().Take(20).ToList();
                }
            }
        }
        catch (Exception ex)
        { }

        return result;
    }

    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<dynamic> GetCustomerDetail(string CustID, int ddlType)
    {
        List<dynamic> result = new List<dynamic>();
        try
        {
            if (!string.IsNullOrEmpty(CustID))
            {
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    if (ddlType == 5)
                    {
                        //string[] VCodes = CustID.Split("-".ToArray());
                        //var vehicle = VCodes.Take(VCodes.Count() - 1).ToArray();
                        //var VehicleCode = string.Join("", vehicle);

                        OVCL objOVCL = ctx.OVCLs.FirstOrDefault(x => x.VehicleNumber.Trim() == CustID.Trim());
                        if (objOVCL != null)
                        {
                            var VehicleData = new
                            {
                                CustomerCode = objOVCL.VehicleNumber,
                                CustomerID = objOVCL.VehicleID,
                                Status = objOVCL.Active ? "Y" : "N",
                                City = "",
                                Employee = "",
                                StateName = ""
                            };
                            result.Add(VehicleData);
                        }
                    }
                    else
                    {
                        decimal CustomerID = decimal.TryParse(CustID, out CustomerID) ? CustomerID : 0;
                        if (CustomerID > 0)
                        {
                            OCRD objOCRD = ctx.OCRDs.FirstOrDefault(x => x.CustomerID == CustomerID);
                            if (objOCRD != null)
                            {
                                string CityName = "";
                                string StateName = "";
                                int RouteID = ctx.RUT1.FirstOrDefault(x => x.CustomerID == objOCRD.CustomerID && x.Active && !x.IsDeleted) != null ? ctx.RUT1.FirstOrDefault(x => x.CustomerID == objOCRD.CustomerID && x.Active && !x.IsDeleted).RouteID : 0;
                                string EmployeeName = "";

                                if (ctx.CRD1.FirstOrDefault(x => x.CustomerID == objOCRD.CustomerID && x.CityID > 0) != null)
                                {
                                    CityName = ctx.CRD1.FirstOrDefault(x => x.CustomerID == objOCRD.CustomerID).OCTY.CityName;
                                }

                                if (ctx.CRD1.FirstOrDefault(x => x.CustomerID == objOCRD.CustomerID && x.StateID > 0) != null)
                                {
                                    StateName = ctx.CRD1.FirstOrDefault(x => x.CustomerID == objOCRD.CustomerID).OCST.GSTStateCode + " - " + ctx.CRD1.FirstOrDefault(x => x.CustomerID == objOCRD.CustomerID).OCST.StateName;
                                }
                                if (RouteID > 0)
                                {
                                    var objORUT = ctx.ORUTs.FirstOrDefault(x => x.RouteID == RouteID);
                                    if (objORUT.Active && objORUT.PrefSalesPersonID.HasValue)
                                    {
                                        EmployeeName = ctx.OEMPs.FirstOrDefault(x => x.EmpID == objORUT.PrefSalesPersonID).EmpCode + " - " + ctx.OEMPs.FirstOrDefault(x => x.EmpID == objORUT.PrefSalesPersonID).Name;
                                    }
                                }
                                var CustData = new
                                {
                                    CustomerCode = objOCRD.CustomerCode,
                                    CustomerID = objOCRD.CustomerID,
                                    Status = objOCRD.Active ? "Y" : "N",
                                    City = CityName,
                                    StateName = StateName,
                                    Employee = EmployeeName
                                };
                                result.Add(CustData);
                            }
                        }
                    }
                }
            }
            else
                result.Add("ERROR=" + "" + "Please select proper code.");
        }
        catch (Exception ex)
        {
            result.Add("ERROR=" + "" + Common.GetString(ex));
        }
        return result;
    }

    #endregion

    #region Button Events

    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<dynamic> LoadReport(string strIsHistory, string Type)
    {
        List<dynamic> result = new List<dynamic>();

        try
        {
            int UserID = Convert.ToInt32(HttpContext.Current.Session["UserID"]);

            String PaerntId = Convert.ToString(HttpContext.Current.Session["ParentID"]);

            int QPSType = int.TryParse(Type, out QPSType) ? QPSType : 0;
            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();

            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "GetDistFSSIReport";
            Cm.Parameters.AddWithValue("@IsHistory", strIsHistory.ToLower() == "true" ? "1" : "0");
            Cm.Parameters.AddWithValue("@Type", QPSType);
            Cm.Parameters.AddWithValue("@ParentId", PaerntId);

            DataSet DS = objClass.CommonFunctionForSelect(Cm);

            DataTable dt;
            if (DS.Tables[0] != null && DS.Tables[0].Rows.Count > 0)
            {
                dt = DS.Tables[0];
                result.Add(JsonConvert.SerializeObject(dt));
            }
        }
        catch (Exception ex)
        {
            result.Add("ERROR=" + "" + Common.GetString(ex));
        }

        return result;

    }

    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static string SaveData(string hidJsonInputFSSI, int Type, int IsAnyRowDeleted, string DeletedIDs)
    {
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                int count = 0;
                Decimal CustomerId = 0;
                String PaerntId = Convert.ToString(HttpContext.Current.Session["ParentID"]);
                if (Type > 0)
                {

                    int UserID = Convert.ToInt32(HttpContext.Current.Session["UserID"]);
                    var FSSIListData = JsonConvert.DeserializeObject<dynamic>(hidJsonInputFSSI.ToString());

                    if (!string.IsNullOrEmpty(DeletedIDs))
                    {
                        List<string> isDeletedIds = DeletedIDs.Trim().Split(",".ToArray()).ToList();
                        List<int> IDs = new List<int>();
                        foreach (var item in isDeletedIds)
                        {
                            int Id = Int32.TryParse(item, out Id) ? Id : 0;
                            IDs.Add(Id);
                        }
                        ctx.OFSSIs.Where(x => IDs.Any(y => y == x.OFSSIID)).ToList().ForEach(x => { x.IsDeleted = true; x.UpdatedBy = UserID; x.UpdatedDate = DateTime.Now; });
                        ctx.SaveChanges();
                    }
                    string directoryPath = HttpContext.Current.Server.MapPath("~/Images/FSSAIImage");
                    bool IsValid = true;
                    string FSSIErrorMsg = "";
                    string Email = "", DistEmail = "";
                    foreach (var item in FSSIListData)
                    {
                        int OFSSIID = int.TryParse(Convert.ToString(item["OFSSIID"]), out OFSSIID) ? OFSSIID : 0;
                        decimal FSSIForID = decimal.TryParse(Convert.ToString(PaerntId), out FSSIForID) ? FSSIForID : 0; // decimal.TryParse(Convert.ToString(item["FSSIForID"]), out FSSIForID) ? FSSIForID : 0;
                        CustomerId = FSSIForID;

                        Type = ctx.OCRDs.FirstOrDefault(x => x.CustomerID == FSSIForID).Type;
                        string FSSINo = Convert.ToString(item["FSSINo"]);
                        DateTime FromDate = Convert.ToDateTime(Convert.ToString(item["FromDate"]));
                        DateTime ToDate = Convert.ToDateTime(Convert.ToString(item["ToDate"]));
                        bool IsInclude = Convert.ToBoolean(Convert.ToString(item["IsInclExcl"]));
                        bool IsDeleted = Convert.ToBoolean(Convert.ToString(item["IsDeleted"]));
                        string VehicleNumber = Convert.ToString(item["VehicleCode"]);
                        string CustName = Convert.ToString(item["CustName"]);
                        string GSTIN = ctx.OCRDs.FirstOrDefault(x => x.CustomerID == FSSIForID).GSTIN;
                        string imgext = Convert.ToString(item["ImgName"]);
                        string ext = "", imageName="", imgPath="";
                        if (imgext != "null")
                        {
                            ext = imgext.ToString().Substring(imgext.IndexOf("."), imgext.Length - imgext.IndexOf("."));
                            imageName = System.Guid.NewGuid().ToString().Replace("-", "") + ext;
                            imgPath = Path.Combine(directoryPath, imageName);
                        }
                        String CompanyLogo = Convert.ToString(item["CompanyLogo"]);
                        var objOVCL = ctx.OVCLs.Where(x => x.VehicleNumber.Trim() == VehicleNumber.Trim()).OrderBy(x => x.CreatedDate).FirstOrDefault();
                        DistEmail = ctx.OCRDs.Where(x => x.CustomerID == CustomerId).FirstOrDefault().EMail1;
                        FSSIForID = Type == 5 ? 1 : FSSIForID;

                        if (FSSIForID > 0)
                        {
                            count++;
                            OFSSI objOFSSI = ctx.OFSSIs.FirstOrDefault(x => x.OFSSIID == OFSSIID);
                            if (Type != 5)
                            {
                                if (ctx.OFSSIs.Any(x => x.FSSIForID == FSSIForID && !x.IsDeleted && x.FSSINO != FSSINo && x.VerifyIs != 2) && Convert.ToString(item["IsChange"]) == "1")
                                {
                                    var IsOFSSIExist = ctx.OFSSIs.Any(x => x.FSSIForID == FSSIForID && !x.IsDeleted &&
                                                       ((EntityFunctions.TruncateTime(x.StartDate) <= EntityFunctions.TruncateTime(FromDate) && EntityFunctions.TruncateTime(x.EndDate) >= EntityFunctions.TruncateTime(ToDate))
                                                    || (EntityFunctions.TruncateTime(FromDate) <= EntityFunctions.TruncateTime(x.StartDate) && EntityFunctions.TruncateTime(ToDate) >= EntityFunctions.TruncateTime(x.EndDate))
                                                    || (EntityFunctions.TruncateTime(x.StartDate) <= EntityFunctions.TruncateTime(FromDate) && EntityFunctions.TruncateTime(FromDate) <= EntityFunctions.TruncateTime(x.EndDate))
                                                    || (EntityFunctions.TruncateTime(x.StartDate) <= EntityFunctions.TruncateTime(ToDate) && EntityFunctions.TruncateTime(ToDate) <= EntityFunctions.TruncateTime(x.EndDate))));

                                    if (IsOFSSIExist && OFSSIID == 0)
                                    {
                                        IsValid = false;
                                        FSSIErrorMsg = "Same entry available for " + CustName + " at row : " + count;
                                    }
                                }
                                if (IsValid && OFSSIID > 0 && Convert.ToString(item["IsChange"]) == "1" && !string.IsNullOrEmpty(FSSINo) && ctx.OFSSIs.Any(x => x.OFSSIID == OFSSIID && x.FSSIForID == FSSIForID && x.FSSINO == FSSINo && x.StartDate == FromDate && x.EndDate == ToDate && !x.IsDeleted))
                                {
                                    item["IsChange"] = "0";
                                    IsValid = true;
                                }
                                if (IsValid && !string.IsNullOrEmpty(FSSINo) && ctx.OFSSIs.Any(x => x.FSSIForID == FSSIForID && x.FSSINO == FSSINo && x.StartDate == FromDate && x.EndDate == ToDate && !x.IsDeleted && x.VerifyIs != 2) && Convert.ToString(item["IsChange"]) == "1")
                                {
                                    IsValid = false;
                                    FSSIErrorMsg = "Same entry available for " + CustName + " at row : " + count;
                                }
                                if (IsValid && !string.IsNullOrEmpty(FSSINo) && ctx.OFSSIs.Any(x => !x.IsDeleted && x.FSSINO == FSSINo && x.FSSIForID != FSSIForID) && Convert.ToString(item["IsChange"]) == "1")
                                {
                                    decimal PCustId = ctx.OFSSIs.FirstOrDefault(x => !x.IsDeleted && x.FSSINO == FSSINo && x.FSSIForID != FSSIForID).FSSIForID;
                                    if (ctx.OCRDs.Any(x => x.GSTIN != GSTIN && x.CustomerID == PCustId))
                                    {
                                        IsValid = false;
                                        FSSIErrorMsg = FSSINo + " is already exist so Please enter another FSSAI number at row : " + count;
                                    }
                                }
                                if (IsValid && !string.IsNullOrEmpty(FSSINo) && ctx.OFSSIs.Any(x => !x.IsDeleted && x.FSSINO == FSSINo && x.VehicleParentID != null && x.VehicleNumber != null))
                                {
                                    IsValid = false;
                                    FSSIErrorMsg = FSSINo + " is already exist so Please enter another FSSAI number at row : " + count;
                                }
                                 
                                //if (IsValid && !string.IsNullOrEmpty(FSSINo) && ctx.OFSSIs.Any(x => x.FSSIForID == FSSIForID && !x.IsDeleted && x.FSSINO != null && FSSINo == "Applied-For"))
                                //{
                                //    IsValid = false;
                                //    FSSIErrorMsg = "FSSAI No is already exist so you can not Applied for registration at row : " + count;
                                //}
                            }

                            if (IsValid)
                            {
                                if (objOFSSI == null && Convert.ToString(item["IsChange"]) == "1")
                                {
                                    objOFSSI = new OFSSI()
                                    {
                                        CreatedBy = UserID,
                                        CreatedDate = DateTime.Now
                                    };
                                    if (FSSINo != "Applied-For")
                                    {
                                        objOFSSI.VerifyIs = 0;
                                    }
                                    else
                                    {
                                        objOFSSI.VerifyIs = 1;
                                        objOFSSI.VerifyBy = 1;
                                        objOFSSI.VerifyDateTime = DateTime.Now;
                                    }
                                    ctx.OFSSIs.Add(objOFSSI);
                                }
                                if (objOFSSI != null)
                                {
                                    if (OFSSIID > 0)
                                    {
                                        objOFSSI.VerifyIs = ctx.OFSSIs.Where(x => x.OFSSIID == OFSSIID).FirstOrDefault().VerifyIs;
                                        objOFSSI.VerifyBy = ctx.OFSSIs.Where(x => x.OFSSIID == OFSSIID).FirstOrDefault().VerifyBy;
                                        objOFSSI.VerifyDateTime = ctx.OFSSIs.Where(x => x.OFSSIID == OFSSIID).FirstOrDefault().VerifyDateTime;

                                    }

                                    objOFSSI.Type = Type;
                                    objOFSSI.FSSIForID = FSSIForID;

                                    objOFSSI.FSSINO = FSSINo;
                                    objOFSSI.StartDate = FromDate;
                                    objOFSSI.EndDate = ToDate;
                                    objOFSSI.IsDeleted = IsDeleted;

                                    objOFSSI.FSSAIImage = imageName;
                                    objOFSSI.Imagebase64 = CompanyLogo;
                                    if (CompanyLogo != "")
                                    {
                                        if (CompanyLogo != "null")
                                        {
                                            byte[] imageBytes = Convert.FromBase64String(CompanyLogo.Split(',')[1].ToString());
                                            File.WriteAllBytes(imgPath, imageBytes);
                                        }
                                    }
                                    int RouteId = ctx.RUT1.FirstOrDefault(x => x.CustomerID == CustomerId && x.Active == true).RouteID;
                                    var PreSalesId = ctx.ORUTs.FirstOrDefault(x => x.RouteID == RouteId).PrefSalesPersonID;
                                    var RegionId = ctx.CRD1.FirstOrDefault(x => x.CustomerID == CustomerId).StateID;

                                    Oledb_ConnectionClass objClass13 = new Oledb_ConnectionClass();
                                    SqlCommand Cmd3 = new SqlCommand();
                                    Cmd3.Parameters.Clear();
                                    Cmd3.CommandType = CommandType.StoredProcedure;
                                    Cmd3.CommandText = "CheckHierarchyManagerId";
                                    Cmd3.Parameters.AddWithValue("@IsHeirarchy", false);
                                    Cmd3.Parameters.AddWithValue("@ClaimLevel", -1);
                                    Cmd3.Parameters.AddWithValue("@EmpId", PreSalesId);
                                    Cmd3.Parameters.AddWithValue("@ReasonId", 12);
                                    Cmd3.Parameters.AddWithValue("@RegionId", RegionId);
                                    DataSet dsdata2 = objClass13.CommonFunctionForSelect(Cmd3);
                                    if (dsdata2.Tables.Count > 0)
                                    {
                                        if (dsdata2.Tables[0].Rows.Count > 0)
                                        {
                                            objOFSSI.FwdTo = Convert.ToInt16(dsdata2.Tables[0].Rows[0]["HierarchyManagerId"].ToString());
                                            StringBuilder sb = new StringBuilder();
                                            string CustCode = ctx.OCRDs.Where(x => x.CustomerID == CustomerId).FirstOrDefault().CustomerCode;
                                            string CustomerName = ctx.OCRDs.Where(x => x.CustomerID == CustomerId).FirstOrDefault().CustomerName;

                                            Email = ctx.OEMPs.Where(x => x.EmpID == objOFSSI.FwdTo).FirstOrDefault().WorkEmail;
                                            sb.Append("Dear Team <br/><br/>");
                                            sb.Append(CustCode + " # " + CustomerName + " has entered his FSSAI new period so please verify the same.<br/></br>");
                                            sb.Append("Thanks & Regards");
                                            //sb.Append("<br/></br>" + Email);   // DistEmail
                                            Common.SendMail("FSSAI Number To be Verify", sb.ToString(), "vimal.lakum@vc-erp.com", "jigneshkhajanchi@vadilalgroup.com", null, null);
                                        }
                                    }
                                    if (Convert.ToString(item["IsChange"]) == "1")
                                    {
                                        objOFSSI.UpdatedBy = UserID;
                                        objOFSSI.UpdatedDate = DateTime.Now;
                                    }
                                }
                                else
                                {
                                    IsValid = false;
                                    FSSIErrorMsg = "Please refresh the page & try again.";
                                }
                            }
                        }
                    }
                    if (count == 0 && IsAnyRowDeleted == 0)
                    {
                        return "WARNING=Please enter atleast one record";
                    }
                    if (IsValid)
                    {
                        ctx.SaveChanges();
                        return "SUCCESS=FSSAI Data Added Successfully \n\n Email Sent T0 : " + Email + "   \n " + DistEmail;
                    }
                    else
                        return "WARNING=" + FSSIErrorMsg;
                }
                else
                {
                    return "ERROR=Please select proper Type";
                }
            }
        }
        catch (Exception ex)
        {
            return "ERROR=Something is wrong: " + Common.GetString(ex);
        }
    }
    #endregion
}