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

public partial class Master_ApproveLevelMaster : System.Web.UI.Page
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
                Employee = ctx.OEMPs.Where(x => x.Active && x.ParentID == ParentID && x.IsApprover).Select(x => x.EmpCode + " - " + x.Name).ToList();
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
                    var Data = (from c in ctx.OAWRKs
                                join d in ctx.OEMPs on new { c.ParentID, EmpID = c.UserID.Value } equals new { d.ParentID, d.EmpID } into pp
                                from pl in pp.DefaultIfEmpty()
                                where c.RequestTypeMenuID == Menuid && c.Active && c.ParentID == ParentID
                                select new
                                {
                                    LevelNo = c.LevelNo,
                                    c.UserID,
                                    EmpName = pl.EmpCode + " - " + pl.Name,
                                    IsManager = c.IsManager,
                                    EscDays = c.EscDays,
                                    Mandatory = c.Mandatory,
                                    IsAsk = c.IsAsk,
                                }).ToList();

                    result.Add(Data);
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
            Int32 IntNum = 0;

            if (DetailData != null)
            {
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    int Count = ctx.GetKey("OAWRK", "WORKID", "", ParentID, 0).FirstOrDefault().Value;
                    List<OAWRK> objOAWRKs = ctx.OAWRKs.Where(x => x.RequestTypeMenuID == MenuID && x.ParentID == ParentID).ToList();
                    objOAWRKs.ForEach(x => x.Active = false);

                    foreach (var data in DetailData)
                    {
                        int LevelNo = Int32.TryParse(Convert.ToString(data["LvlNo"]), out LevelNo) ? LevelNo : 0;
                        if (LevelNo > 0)
                        {
                            Boolean IsManager = data["IsManager"];
                            Boolean IsAsk = data["IsAsk"];
                            Boolean IsMandatoy = data["IsMandatoy"];

                            int? EmpID = null;
                            string AutoEmp = Convert.ToString(data["AutoEmp"]);
                            string Code = AutoEmp.Split(" - ".ToArray()).First().Trim();
                            if (!string.IsNullOrEmpty(Code))
                                EmpID = ctx.OEMPs.FirstOrDefault(x => x.ParentID == ParentID && x.EmpCode == Code && x.Active).EmpID;
                            Int32 EscDays = Int32.TryParse(Convert.ToString(data["EscDays"]), out IntNum) ? IntNum : 0;

                            if (EmpID.GetValueOrDefault(0) > 0 || IsManager || IsAsk)
                            {
                                if (!((EmpID.GetValueOrDefault(0) > 0 && IsManager) || (IsAsk && IsManager) || (IsAsk && EmpID.GetValueOrDefault(0) > 0)))
                                {
                                    OAWRK objOAWRK = objOAWRKs.FirstOrDefault(x => x.LevelNo == LevelNo);
                                    if (objOAWRK == null)
                                    {
                                        objOAWRK = new OAWRK();
                                        objOAWRK.WorkID = Count++;
                                        objOAWRK.ParentID = ParentID;
                                        objOAWRK.CreatedDate = DateTime.Now;
                                        objOAWRK.CreatedBy = UserID;
                                        ctx.OAWRKs.Add(objOAWRK);
                                    }
                                    objOAWRK.LevelNo = LevelNo;
                                    objOAWRK.UserID = EmpID;
                                    objOAWRK.RequestTypeMenuID = MenuID;
                                    objOAWRK.IsManager = IsManager;
                                    objOAWRK.EscDays = EscDays;
                                    objOAWRK.IsAsk = IsAsk;
                                    objOAWRK.Mandatory = IsMandatoy;
                                    objOAWRK.Status = 2;
                                    objOAWRK.Active = true;
                                    objOAWRK.UpdatedDate = DateTime.Now;
                                    objOAWRK.UpdatedBy = UserID;
                                }
                                else
                                {
                                    return "ERROR=Please select only one from Employee, IsManager and IsAsk";
                                }
                            }
                            else
                            {
                                return "ERROR=Atleast Select one";
                            }
                        }
                    }
                    ctx.SaveChanges();
                    return "SUCCESS=Hierarchy Inserted Successfully";
                }
            }
            else
                return "ERROR=Please select atleast one Item";
        }
        catch (Exception ex)
        {
            return "ERROR=Something is worng: " + Common.GetString(ex);
        }
    }
}