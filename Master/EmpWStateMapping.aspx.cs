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

public partial class Master_EmpWStateMapping : System.Web.UI.Page
{
    #region Declaration

    protected int UserID, CustType;
    protected decimal ParentID;
    protected String AuthType;

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
            int UserID = Convert.ToInt32(HttpContext.Current.Session["UserID"]);
            List<string> Employee = new List<string>();
            List<string> State = new List<string>();
            using (DDMSEntities ctx = new DDMSEntities())
            {
                Employee = ctx.OEMPs.Where(x => x.Active && x.ParentID == ParentID).Select(x => x.EmpCode + " - " + x.Name + " - " + SqlFunctions.StringConvert((double)x.EmpID).Trim()).ToList();
                State = ctx.OCSTs.Where(x => x.Active).Select(x => x.GSTStateCode + " - " + x.StateName + " - " + SqlFunctions.StringConvert((double)x.StateID).Trim()).ToList();

                result.Add(Employee);
                result.Add(State);
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
    public static List<dynamic> GetDetail(string strEmpID)
    {
        List<dynamic> result = new List<dynamic>();
        try
        {
            int EmpID;
            if (Int32.TryParse(strEmpID, out EmpID) && EmpID > 0)
            {
                decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    var Data = (from t in ctx.OESMs.Include("OCST")
                                where t.EmpID == EmpID && t.ParentID == ParentID && t.IsDelete == false
                                select new
                                {
                                    State = t.OCST.GSTStateCode + " - " + t.OCST.StateName + " - " + SqlFunctions.StringConvert((double)t.StateID).Trim(),
                                    Active = t.Active
                                }).ToList();

                    result.Add(Data);

                    if (Data.Count > 0)
                    {
                        var Data1 = (from t in ctx.OESMs
                                     join s in ctx.OEMPs on new { t.CreatedBy, t.ParentID } equals new { CreatedBy = s.EmpID, s.ParentID }
                                     join s1 in ctx.OEMPs on new { t.UpdatedBy, t.ParentID } equals new { UpdatedBy = s1.EmpID, s1.ParentID }
                                     where t.EmpID == EmpID && t.ParentID == ParentID
                                     select new
                                     {
                                         CreatedBy = s.EmpCode + " # " + s.Name,
                                         t.CreatedDate,
                                         UpdatedBy = s1.EmpCode + " # " + s1.Name,
                                         t.UpdatedDate
                                     }).ToList().Select(x => new
                                     {
                                         CreatedBy = x.CreatedBy,
                                         CreatedDate = x.CreatedDate.ToString("dd/MM/yyyy HH:mm"),
                                         UpdatedBy = x.UpdatedBy,
                                         UpdatedDate = x.UpdatedDate.ToString("dd/MM/yyyy HH:mm")
                                     }).FirstOrDefault();

                        result.Add(Data1.CreatedBy);
                        result.Add(Data1.CreatedDate);
                        result.Add(Data1.UpdatedBy);
                        result.Add(Data1.UpdatedDate);
                    }
                    else
                    {
                        result.Add("");
                        result.Add("");
                        result.Add("");
                        result.Add("");
                    }
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

    private void ClearAllInputs()
    {
        AutoEmp.Text = txtCreatedBy.Text = txtCreatedTime.Text = txtUpdatedBy.Text = txtUpdatedTime.Text = "";
    }

    #endregion

    #region PageLoad

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        if (!IsPostBack)
        {
            ClearAllInputs();
        }
    }

    #endregion

    #region Button Click

    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static string SaveData(string hidJsonInputMaterial, string EmpId)
    {
        try
        {
            decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);
            int UserID = Convert.ToInt32(HttpContext.Current.Session["UserID"]);
            var DetailData = JsonConvert.DeserializeObject<dynamic>(hidJsonInputMaterial.ToString());
            Int32 EmpID = Convert.ToInt32(EmpId);

            if (DetailData != null)
            {
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    int Count = ctx.GetKey("OESM", "OESMID", "", ParentID, 0).FirstOrDefault().Value;

                    List<OESM> objOESMs = ctx.OESMs.Where(x => x.EmpID == EmpID && x.ParentID == ParentID).ToList();

                    objOESMs.ForEach(x => { x.Active = false; x.IsDelete = true; x.UpdatedDate = DateTime.Now; x.UpdatedBy = UserID; });

                    foreach (var data in DetailData)
                    {
                        int StateID = Int32.TryParse(Convert.ToString(data["StateID"]), out StateID) ? StateID : 0;
                        Boolean Active = data["Active"];
                        if (StateID > 0)
                        {
                            OESM objOESM = objOESMs.FirstOrDefault(x => x.StateID == StateID);
                            if (objOESM == null)
                            {
                                objOESM = new OESM();
                                objOESM.OESMID = Count++;
                                objOESM.ParentID = ParentID;
                                objOESM.EmpID = EmpID;
                                objOESM.CreatedDate = DateTime.Now;
                                objOESM.CreatedBy = UserID;
                                ctx.OESMs.Add(objOESM);
                            }
                            objOESM.StateID = StateID;
                            objOESM.Active = Active;
                            objOESM.UpdatedDate = DateTime.Now;
                            objOESM.UpdatedBy = UserID;
                            objOESM.IsDelete = false;
                        }
                    }
                    ctx.SaveChanges();
                    return "SUCCESS=Mapping Inserted Successfully";
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

 
    #endregion

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        ClearAllInputs();
    }
}