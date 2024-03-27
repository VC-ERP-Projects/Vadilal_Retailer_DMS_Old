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

public partial class Master_ItemSortOrderMapping : System.Web.UI.Page
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
            int UserID = Convert.ToInt16(HttpContext.Current.Session["UserID"]);

            using (DDMSEntities ctx = new DDMSEntities())
            {
                var Groups = ctx.OITGs.Where(x => x.Active && x.OITMs.Count > 0).Select(x => x.ItemSubGroupName).Distinct().ToList();
                result.Add(Groups);
            }
        }
        catch (Exception ex)
        {
            result.Add("ERROR#" + "" + Common.GetString(ex));
        }
        return result;
    }

    private void ClearAllInputs()
    {
        txtItemGroupCode.Text = "";
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

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<dynamic> GetDetail(string strGroupCode)
    {
        List<dynamic> result = new List<dynamic>();
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                if (!string.IsNullOrEmpty(strGroupCode))
                {
                    var Data = (from c in ctx.OITMs
                                where c.Active && c.OITG.ItemSubGroupName == strGroupCode
                                select new
                                {
                                    CodeID = c.ItemID,
                                    Type = "I",
                                    Code = c.ItemCode,
                                    Name = c.ItemName,
                                    Group = c.OITB.ItemGroupName,
                                    SortOrder = c.ItemSortOrder
                                }).OrderBy(x => x.SortOrder).ThenBy(x => x.Name).ToList();

                    result.Add(Data);
                }
                else
                {
                    var Data = (from c in ctx.OITGs
                                where c.Active && c.OITMs.Count > 0
                                select new
                                {
                                    CodeID = 0,
                                    Type = "G",
                                    Code = "",
                                    Name = c.ItemSubGroupName,
                                    Group = "",
                                    SortOrder = c.SortOrder
                                }).Distinct().OrderBy(x => x.SortOrder).ThenBy(x => x.Name).ToList();

                    result.Add(Data);
                }
            }
        }
        catch (Exception ex)
        {
            result.Add("ERROR=" + "" + Common.GetString(ex));
        }
        return result;
    }

    protected void btnClear_Click(object sender, EventArgs e)
    {
        ClearAllInputs();
    }

    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static string SaveData(string hidJsonInputMaterial)
    {
        try
        {
            var DetailData = JsonConvert.DeserializeObject<dynamic>(hidJsonInputMaterial.ToString());

            if (DetailData != null)
            {
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    foreach (var data in DetailData)
                    {
                        string strType = Convert.ToString(data["Type"]);
                        string strName = Convert.ToString(data["Name"]);
                        int CodeID = Convert.ToInt32(Convert.ToString(data["CodeID"]));
                        int SortOrder = Int32.TryParse(Convert.ToString(data["SortOrder"]), out SortOrder) ? SortOrder : 0;
                        if (strType == "G")
                        {
                            ctx.OITGs.Where(x => x.ItemSubGroupName == strName).ToList().ForEach(x => x.SortOrder = SortOrder);
                        }
                        else if (strType == "I")
                        {
                            OITM objOITM = ctx.OITMs.FirstOrDefault(x => x.ItemID == CodeID);
                            if (objOITM != null)
                            {
                                objOITM.ItemSortOrder = SortOrder;
                            }
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

}