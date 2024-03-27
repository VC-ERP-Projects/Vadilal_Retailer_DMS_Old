using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Newtonsoft.Json;
using System.Data;
using System.Web.Services;
using System.Web.Script.Services;
using System.Data.Objects.SqlClient;
using System.Xml.Linq;
using System.IO;
using System.Data.Objects;

public partial class Master_NotificationLevelMaster : System.Web.UI.Page
{
    #region Property

    protected int UserID;
    protected decimal ParentID;
    protected String AuthType;
    public int SaleID;

    #endregion

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        if (!IsPostBack)
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
        }
        else
        {
            Response.Redirect("~/Login.aspx");
        }

    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<dynamic> LoadData()
    {
        List<dynamic> result = new List<dynamic>();

        try
        {
            decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);
            List<string> Employee = new List<string>();
            using (DDMSEntities ctx = new DDMSEntities())
            {
                Employee = ctx.OEMPs.Where(x => x.Active && x.ParentID == ParentID).Select(x => x.EmpCode + " - " + x.Name).ToList();
                result.Add(Employee);
            }
        }
        catch (Exception ex)
        {
            result.Add("ERROR#" + "" + Common.GetString(ex));
        }
        return result;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<dynamic> GetDetail(string strMenuid)
    {
        List<dynamic> result = new List<dynamic>();
        try
        {
            int Menuid;
            if (Int32.TryParse(strMenuid, out Menuid) && Menuid > 0)
            {
                decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);

                using (DDMSEntities ctx = new DDMSEntities())
                {
                    var ExcEmpCode = "";
                    if (ctx.OSMS.Any(x => x.RequestTypeMenuID == Menuid && x.ParentID == ParentID && !string.IsNullOrEmpty(x.ExcEmp)))
                    {
                        var ExcEmp = ctx.OSMS.FirstOrDefault(x => x.RequestTypeMenuID == Menuid && x.ParentID == ParentID).ExcEmp;
                        int[] ExcIds = Array.ConvertAll(ExcEmp.Split(','), s => int.Parse(s));
                        foreach (int Codes in ExcIds)
                        {
                            ExcEmpCode += ctx.OEMPs.FirstOrDefault(x => x.EmpID == Codes && x.ParentID == ParentID).EmpCode;
                            ExcEmpCode += ",";
                        }
                    }

                    var Data = (from C in ctx.OSMS
                                join D in ctx.OEMPs on new { C.ParentID, EmpID = C.UserID.Value } equals new { D.ParentID, D.EmpID } into pp
                                from pl in pp.DefaultIfEmpty()
                                where C.RequestTypeMenuID == Menuid && C.ParentID == ParentID && C.Active
                                select new
                                {
                                    LevelNo = C.LevelNo,
                                    C.UserID,
                                    EmpName = pl.EmpCode + " - " + pl.Name,
                                    IsManager = C.IsManager,
                                    IsCustomer = C.IsCustomer,
                                }).ToList();

                    result.Add(Data);
                    result.Add(ExcEmpCode);
                }
            }
            else
            {
                result.Add("ERROR=" + "" + "No detail found in following RequestMenu ID.");
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
    public static string SaveData(string hidJsonInputMaterial, string hidJsonInputHeader)
    {
        try
        {
            decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);
            int UserID = Convert.ToInt32(HttpContext.Current.Session["UserID"]);
            var DetailData = JsonConvert.DeserializeObject<dynamic>(hidJsonInputMaterial.ToString());
            var HeaderData = JsonConvert.DeserializeObject<dynamic>(hidJsonInputHeader.ToString());
            Int32 MenuID = Convert.ToInt32(Convert.ToString(HeaderData["RequestType"]));
            string ExcEmp = Convert.ToString(HeaderData["ExcEmp"]);

            if (DetailData != null)
            {
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    int Count = ctx.GetKey("OSMS", "SMSID", "", ParentID, 0).FirstOrDefault().Value;
                    List<OSM> objOSMS = ctx.OSMS.Where(x => x.RequestTypeMenuID == MenuID && x.ParentID == ParentID).ToList();
                    objOSMS.ForEach(x => x.Active = false);

                    foreach (var data in DetailData)
                    {
                        int LevelNo = Int32.TryParse(Convert.ToString(data["LvlNo"]), out LevelNo) ? LevelNo : 0;
                        if (LevelNo > 0)
                        {
                            Boolean IsManager = data["IsManager"];
                            Boolean IsCustomer = data["IsCustomer"];

                            int? EmpID = null;
                            string AutoEmp = Convert.ToString(data["AutoEmp"]);
                            string Code = AutoEmp.Split(" - ".ToArray()).First().Trim();
                            if (!string.IsNullOrEmpty(Code))
                                EmpID = ctx.OEMPs.FirstOrDefault(x => x.ParentID == ParentID && x.EmpCode == Code && x.Active).EmpID;


                            if (EmpID.GetValueOrDefault(0) > 0 || IsManager)
                            {
                                if (!(EmpID.GetValueOrDefault(0) > 0 && IsManager))
                                {
                                    OSM objOSM = objOSMS.FirstOrDefault(x => x.LevelNo == LevelNo);
                                    if (objOSM == null)
                                    {
                                        objOSM = new OSM();
                                        objOSM.SMSID = Count++;
                                        objOSM.ParentID = ParentID;
                                        objOSM.CreatedDate = DateTime.Now;
                                        objOSM.CreatedBy = UserID;
                                        objOSM.Notification = true;
                                        objOSM.SMS = false;
                                        objOSM.Email = false;
                                        ctx.OSMS.Add(objOSM);
                                    }
                                    objOSM.LevelNo = LevelNo;
                                    objOSM.UserID = EmpID;
                                    objOSM.RequestTypeMenuID = MenuID;
                                    objOSM.IsManager = IsManager;
                                    objOSM.IsCustomer = IsCustomer;
                                    objOSM.Status = 2;
                                    objOSM.Active = true;
                                    objOSM.UpdatedDate = DateTime.Now;
                                    objOSM.UpdatedBy = UserID;
                                    var EmpCodes = "";
                                    if (!string.IsNullOrEmpty(ExcEmp))
                                    {
                                        string[] ExcCodes = ExcEmp.Split(',');
                                        foreach (string Codes in ExcCodes)
                                        {
                                            if (!string.IsNullOrEmpty(Codes) && ctx.OEMPs.Any(x => x.EmpCode == Codes && x.ParentID == ParentID))
                                            {
                                                EmpCodes += ctx.OEMPs.FirstOrDefault(x => x.EmpCode == Codes && x.ParentID == ParentID).EmpID;
                                                EmpCodes += ",";
                                            }
                                        }
                                    }
                                    objOSM.ExcEmp = EmpCodes.TrimEnd(',');
                                }
                                else
                                {
                                    return "ERROR= Please select only one from Employee, IsManager";
                                }
                            }
                            else
                            {
                                return "ERROR= Atleast Select one";
                            }
                        }
                    }
                    ctx.SaveChanges();

                    return "SUCCESS= Hierarchy Inserted Successfully";
                }
            }
            else
                return "ERROR= Please select atleast one Item";
        }
        catch (Exception ex)
        {
            return "ERROR=Something is worng: " + Common.GetString(ex);
        }
    }
}