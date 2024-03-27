using System;
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

public partial class Master_Branding_Checker_Master : System.Web.UI.Page
{
    #region Declaration

    protected int UserID, CustType, Index;
    protected decimal ParentID;
    protected String AuthType;
    protected String Version;

    [Serializable]
    public class CheckerValidate
    {
        public int EmpID { get; set; }
        public int CheckID { get; set; }
        public string EmpCode { get; set; }
        public string EmpName { get; set; }
        public string IsActive { get; set; }
        public string CreatedBy { get; set; }
        public string CreatedDate { get; set; }
        public string UpdatedBy { get; set; }
        public string UpdatedDate { get; set; }
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
        //ValidateUser();
        //if (!IsPostBack)
        //{
        //    ClearAllInputs();
        //}
    }
    #endregion
    #region AjaxMethods
    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<dynamic> GetEmployeeDetail(int EmpID)
    {
        List<dynamic> result = new List<dynamic>();
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
                SqlCommand Cm = new SqlCommand();

                Cm.Parameters.Clear();
                Cm.CommandType = CommandType.StoredProcedure;
                Cm.CommandText = "GetEmployeeData";
                Cm.Parameters.AddWithValue("@EmpID", EmpID);

                DataSet ds = objClass.CommonFunctionForSelect(Cm);
                if (ds.Tables.Count > 0)
                {
                    List<CheckerValidate> CallData = ds.Tables[0].AsEnumerable().Select
                     (x => new CheckerValidate
                     {
                         //EmpID = x.Field<int>("EmpID"),
                         // EmpCode = x.Field<String>("EmpCode"),
                         EmpName = x.Field<String>("EmpName"),
                         IsActive = x.Field<String>("IsActive"),
                         CreatedDate = x.Field<String>("CreatedDate"),
                         CreatedBy = x.Field<String>("CreatedBy"),
                         UpdatedDate = x.Field<String>("UpdatedDate"),
                         UpdatedBy = x.Field<String>("UpdatedBy")

                     }).ToList();
                    result.Add(CallData);
                }
            }
        }
        catch (Exception ex)
        {
            result.Add("ERROR=" + "" + Common.GetString(ex));
        }
        return result;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<dynamic> LoadEmployee(string prefixText)
    {
        List<dynamic> result = new List<dynamic>();

        try
        {
            List<string> items = new List<string>();

            using (DDMSEntities ctx = new DDMSEntities())
            {
                if (prefixText == "*")
                {
                    items = (from c in ctx.OEMPs
                             where c.ParentID == 1000010000000000
                             select c.EmpCode + " # " + c.Name + " # " + SqlFunctions.StringConvert((double)c.EmpID).Trim()).Distinct().ToList();
                }
                else
                {
                    items = (from c in ctx.OEMPs
                             where c.ParentID == 1000010000000000 && (c.EmpCode.Contains(prefixText) || c.Name.Contains(prefixText))
                             select c.EmpCode + " # " + c.Name + " # " + SqlFunctions.StringConvert((double)c.EmpID).Trim()).Distinct().ToList();
                }
                result.Add(items);
            }
        }
        catch (Exception ex)
        {
            result.Add("ERROR=" + "" + Common.GetString(ex));
        }
        return result;
    }


    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<dynamic> LoadData()
    {
        List<dynamic> result = new List<dynamic>();
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();

        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "GetBrandCheckerData";
        //Cm.Parameters.AddWithValue("@Type", Type);

        DataSet ds = objClass.CommonFunctionForSelect(Cm);
        if (ds.Tables.Count > 0)
        {
            List<CheckerValidate> CallData = ds.Tables[0].AsEnumerable().Select
             (x => new CheckerValidate
             {
                 CheckID = x.Field<int>("CheckID"),
                 EmpName = x.Field<String>("Employee"),
                 IsActive = x.Field<String>("IsActive"),
                 CreatedDate = x.Field<String>("CreatedDate"),
                 CreatedBy = x.Field<String>("CreatedBy"),
                 UpdatedDate = x.Field<String>("UpdatedDate"),
                 UpdatedBy = x.Field<String>("UpdatedBy")
             }).ToList();
            result.Add(CallData);
        }
        return result;
    }
    //[WebMethod]
    //[ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    //public static List<dynamic> LoadData()
    //{
    //    List<dynamic> result = new List<dynamic>();
    //    try
    //    {
    //        using (DDMSEntities ctx = new DDMSEntities())
    //        {
    //            var Data = (from x in ctx.OBRCHKMs
    //                        join y in ctx.OEMPs
    //                        on x.EmpID equals y.EmpID
    //                        where !x.IsDeleted
    //                        select new
    //                        {
    //                            CheckerID = x.CheckID,
    //                            EmpCode = y.EmpCode,
    //                            EmpName = y.Name,
    //                            IsActive = x.IsActive,
    //                            IsDeleted = x.IsDeleted,
    //                            CreatedBy = ctx.OEMPs.FirstOrDefault(J => J.EmpID == x.EmpID).Name,
    //                            CreatedDate = x.CreatedDate,
    //                            UpdatedBy = x.UpdatedBy,
    //                            UpdatedDate = x.UpdatedDate
    //                        }).ToList();

    //            var CheckerData = Data.Select(x => new
    //            {
    //                CheckerID = x.CheckerID,
    //                EmpName = x.EmpCode + " - " + x.EmpName,
    //                IsActive = x.IsActive,
    //                IsDeleted = x.IsDeleted,
    //                CreatedBy = x.CreatedBy,
    //                CreatedDate = x.CreatedDate.ToString("dd-MMM-yyyy HH:mm"),
    //                UpdatedBy = x.UpdatedBy,
    //                UpdatedDate = x.UpdatedDate.ToString("dd-MMM-yyyy HH:mm")
    //            }).ToList();
    //            result.AddRange(CheckerData);
    //        }

    //    }
    //    catch (Exception ex)
    //    {
    //        // return (ex);
    //    }
    //    return result;
    //}
    #endregion

    #region Button Events
    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<dynamic> LoadReport(string strIsHistory)
    {
        List<dynamic> result = new List<dynamic>();

        try
        {
            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();

            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "GetCheckerData";
            Cm.Parameters.AddWithValue("@IsHistory", strIsHistory.ToLower() == "true" ? "1" : "0");

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
    public static string SaveData(string hidJsonInputEmp, int IsAnyRowDeleted, string DeletedIDs)
    {
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                int count = 0;
                int UserID = Convert.ToInt32(HttpContext.Current.Session["UserID"]);
                var BrndChkrData = JsonConvert.DeserializeObject<dynamic>(hidJsonInputEmp.ToString());

                if (!string.IsNullOrEmpty(DeletedIDs))
                {
                    List<string> isDeletedIds = DeletedIDs.Trim().Split("/,".ToArray()).ToList();
                    List<int> IDs = new List<int>();
                    foreach (var item in isDeletedIds)
                    {
                        int Id = Int32.TryParse(item, out Id) ? Id : 0;
                        IDs.Add(Id);
                    }
                    ctx.OBRCHKMs.Where(x => IDs.Any(y => y == x.CheckID)).ToList().ForEach(x => { x.IsDeleted = true; x.IsActive = false; x.UpdatedBy = UserID; x.UpdatedDate = DateTime.Now; });
                    ctx.SaveChanges();
                }
                bool IsValid = true;
                string BrandErrorMsg = "";

                foreach (var item in BrndChkrData)
                {
                    int EmpID = int.TryParse(Convert.ToString(item["EmpID"]), out EmpID) ? EmpID : 0;
                    int CheckID = int.TryParse(Convert.ToString(item["CheckID"]), out CheckID) ? CheckID : 0;
                    bool IsActive = Convert.ToBoolean(Convert.ToString(item["IsActive"]));
                    bool IsDeleted = Convert.ToBoolean(Convert.ToString(item["IsDeleted"]));
                    OEMP objOEMP = ctx.OEMPs.FirstOrDefault(x => x.EmpID == EmpID);
                    if (CheckID > 0 && Convert.ToString(item["IsChange"]) == "1")
                    {
                        var objOBRCHKM = ctx.OBRCHKMs.Where(x => x.CheckID == CheckID).First();
                        objOBRCHKM.EmpID = EmpID;
                        objOBRCHKM.IsActive = IsActive;
                        objOBRCHKM.UpdatedBy = UserID;
                        objOBRCHKM.UpdatedDate = DateTime.Now;
                        objOBRCHKM.IsDeleted = IsDeleted;
                        ctx.SaveChanges();
                    }
                    else if (EmpID > 0 && Convert.ToString(item["IsChange"]) == "1")
                    {
                        count++;
                        OBRCHKM objOBRCHKM = ctx.OBRCHKMs.FirstOrDefault(x => x.EmpID == EmpID);
                        if (IsValid)
                        {
                            if (objOBRCHKM == null)
                            {
                                objOBRCHKM = new OBRCHKM()
                                {
                                    EmpID = EmpID,
                                    IsActive = IsActive,
                                    CreatedBy = UserID,
                                    CreatedDate = DateTime.Now,
                                    UpdatedBy = UserID,
                                    UpdatedDate = DateTime.Now,
                                    IsDeleted = IsDeleted
                                };
                                ctx.OBRCHKMs.Add(objOBRCHKM);
                                //ctx.SaveChanges();
                            }
                            else
                            {
                                objOBRCHKM.IsActive = IsActive;
                                if (objOBRCHKM != null && Convert.ToString(item["IsChange"]) == "1")
                                {
                                    //objOBRCHKM.IsActive = IsActive;
                                    objOBRCHKM.UpdatedBy = UserID;
                                    objOBRCHKM.UpdatedDate = DateTime.Now;
                                }
                            }
                        }
                        else
                        {
                            IsValid = false;
                            BrandErrorMsg = "Please refresh the page & try again.";
                        }
                    }
                    ctx.SaveChanges();
                }
                if (IsValid)
                {

                    return "SUCCESS=Data Added Successfully";
                }
                else
                    return "WARNING=" + BrandErrorMsg;
                // }

            }
        }
        catch (Exception ex)
        {
            return "ERROR=Something is wrong: " + Common.GetString(ex);
        }
    }

    #endregion
}
