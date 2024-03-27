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

public partial class Master_EmpStoreLocMapping : System.Web.UI.Page
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
    public static List<dynamic> LoadData(string strPlantID)
    {
        List<dynamic> result = new List<dynamic>();
        try
        {
            decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);
            int UserID = Convert.ToInt32(HttpContext.Current.Session["UserID"]);
            int PlantiD = string.IsNullOrEmpty(strPlantID) ? 0 : Convert.ToInt32(strPlantID);

            List<string> Employee = new List<string>();
            List<string> StoreLoc = new List<string>();
            List<string> Plants = new List<string>();

            using (DDMSEntities ctx = new DDMSEntities())
            {
                Employee = ctx.OEMPs.Where(x => x.Active && x.ParentID == ParentID).Select(x => x.EmpCode + " - " + x.Name + " - " + SqlFunctions.StringConvert((double)x.EmpID).Trim()).ToList();
                //Only Selected plant storage location else no location. Changes as instruction by Milan Bhai                
                StoreLoc = ctx.OSTRLs.Where(x => x.Active && (x.PlantID == PlantiD)).Select(x => x.StorageLocCode + " - " + (x.StorageLocName != null ? x.StorageLocName : "") + " - " + SqlFunctions.StringConvert((double)x.StorageLocID).Trim()).ToList();
                Plants = ctx.OPLTs.Where(x => x.Active).Select(x => x.PlantCode + " - " + x.PlantName + " - " + SqlFunctions.StringConvert((double)x.PlantID).Trim()).ToList();

                result.Add(Employee);
                result.Add(StoreLoc);
                result.Add(Plants);
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
                    var Data = (from t in ctx.OELMs.Include("OSTRL")
                                where t.EmpID == EmpID && t.ParentID == ParentID && t.IsDelete == false
                                select new
                                {
                                    StoreLoc = t.OSTRL.OPLT.PlantCode + " - " + t.OSTRL.OPLT.PlantName + " # " + t.OSTRL.StorageLocCode + " - " + t.OSTRL.StorageLocName + " - " + SqlFunctions.StringConvert((double)t.StorageLocID).Trim(),
                                    Active = t.Active
                                }).ToList();

                    result.Add(Data);

                    if (Data.Count > 0)
                    {
                        var Data1 = (from t in ctx.OELMs
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
                result.Add("ERROR=" + "" + "No Storage Location found in following Employee.");
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
        AutoEmp.Text = AutoPlant.Text = txtCreatedBy.Text = txtCreatedTime.Text = txtUpdatedBy.Text = txtUpdatedTime.Text = "";
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
                    int Count = ctx.GetKey("OELM", "OELMID", "", ParentID, 0).FirstOrDefault().Value;

                    List<OELM> objOELMs = ctx.OELMs.Where(x => x.EmpID == EmpID && x.ParentID == ParentID).ToList();

                    objOELMs.ForEach(x => { x.Active = false; x.IsDelete = true; x.UpdatedDate = DateTime.Now; x.UpdatedBy = UserID; });

                    foreach (var data in DetailData)
                    {
                        int StoreLocID = Int32.TryParse(Convert.ToString(data["StoreLocID"]), out StoreLocID) ? StoreLocID : 0;
                        Boolean Active = data["Active"];
                        if (StoreLocID > 0)
                        {
                            OELM objOELM = objOELMs.FirstOrDefault(x => x.StorageLocID == StoreLocID);
                            if (objOELM == null)
                            {
                                objOELM = new OELM();
                                objOELM.OELMID = Count++;
                                objOELM.ParentID = ParentID;
                                objOELM.EmpID = EmpID;
                                objOELM.CreatedDate = DateTime.Now;
                                objOELM.CreatedBy = UserID;
                                ctx.OELMs.Add(objOELM);
                            }
                            objOELM.StorageLocID = StoreLocID;
                            objOELM.Active = Active;
                            objOELM.UpdatedDate = DateTime.Now;
                            objOELM.UpdatedBy = UserID;
                            objOELM.IsDelete = false;
                        }
                        else
                        {
                            return "ERROR=Please select proper Storage Location";
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

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        ClearAllInputs();
    }

    #endregion
}