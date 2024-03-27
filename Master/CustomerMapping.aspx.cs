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

public partial class Master_CustomerMapping : System.Web.UI.Page
{
    #region Declaration

    protected int UserID, CustType, Index;
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
                var Distributors = ctx.OCRDs.Where(x => x.Active && x.CGRP.CustGroupName == "D001" && x.Type == 2).OrderBy(x => x.CustomerName).Select(x => x.CustomerCode + " - " + x.CustomerName).ToList();
                var Dealers = (from c in ctx.OCRDs
                               join d in ctx.OCRDs on new { c.ParentID } equals new { ParentID = d.CustomerID }
                               where d.CGRP.CustGroupName == "D001" && c.Type == 3 && c.Active && d.Active
                               select c.CustomerCode + " - " + c.CustomerName).ToList();

                result.Add(Distributors);
                result.Add(Dealers);
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
        txtParentCode.Text = txtCustCode.Text = "";
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
    public static List<dynamic> GetDetail(string strParent, string strCustomer)
    {
        List<dynamic> result = new List<dynamic>();
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                Decimal Parent = 0;
                Decimal Customer = 0;
                if (!string.IsNullOrEmpty(strParent) || !string.IsNullOrEmpty(strCustomer))
                {
                    if (!string.IsNullOrEmpty(strParent))
                        Parent = ctx.OCRDs.FirstOrDefault(x => x.CustomerCode == strParent).CustomerID;

                    if (!string.IsNullOrEmpty(strCustomer))
                        Customer = ctx.OCRDs.FirstOrDefault(x => x.CustomerCode == strCustomer).CustomerID;

                    decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);

                    var Data = (from c in ctx.OCRDs
                                join d in ctx.OCTMs on c.CustomerID equals d.CustomerID into a
                                from y in a.DefaultIfEmpty()
                                join cb in ctx.OEMPs on new { y.CreatedBy, ParentID } equals new { CreatedBy = cb.EmpID, cb.ParentID } into c1
                                from cb1 in c1.DefaultIfEmpty()
                                join ub in ctx.OEMPs on new { y.UpdatedBy, ParentID } equals new { UpdatedBy = ub.EmpID, ub.ParentID } into c2
                                from ub1 in c2.DefaultIfEmpty()
                                where (Parent == 0 || c.ParentID == Parent) && (Customer == 0 || c.CustomerID == Customer) && c.Active
                                select new OCTMData
                                {
                                    Customer = c.CustomerCode + " - " + c.CustomerName,
                                    CustomerID = c.CustomerID,
                                    EmailID = y.EmailID,
                                    CreatedBy = cb1.EmpCode + " # " + cb1.Name,
                                    CreatedDate = y.CreatedDate,
                                    UpdatedBy = ub1.EmpCode + " # " + ub1.Name,
                                    UpdatedDate = y.UpdatedDate
                                }).ToList().Select(x => new
                                {
                                    x.Customer,
                                    EmailID = x.EmailID != null ? x.EmailID.Trim() : "",
                                    x.CustomerID,
                                    CreatedBy = x.CreatedBy != null ? x.CreatedBy.ToString() : "",
                                    CreatedDate = x.CreatedDate != null ? x.CreatedDate.Value.ToString("dd/MM/yyyy HH:mm") : "",
                                    UpdatedBy = x.UpdatedBy != null ? x.UpdatedBy : "",
                                    UpdatedDate = x.UpdatedDate != null ? x.UpdatedDate.Value.ToString("dd/MM/yyyy HH:mm") : ""
                                }).OrderBy(x => x.EmailID).ThenBy(x => x.Customer).ToList();
                    result.Add(Data);
                }
                else
                    result.Add("ERROR=Select atleast one parameter");
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
            decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);
            int UserID = Convert.ToInt32(HttpContext.Current.Session["UserID"]);

            var DetailData = JsonConvert.DeserializeObject<dynamic>(hidJsonInputMaterial.ToString());

            if (DetailData != null)
            {
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    int Count = ctx.GetKey("OCTM", "OCTMID", "", ParentID, 0).FirstOrDefault().Value;
                    foreach (var data in DetailData)
                    {
                        Decimal CustomerID = Decimal.TryParse(Convert.ToString(data["Customer"]), out CustomerID) ? CustomerID : 0;
                        string EmailID = Convert.ToString(data["EmailID"]).Trim();
                        if (CustomerID > 0)
                        {
                            OCTM objOCTM = ctx.OCTMs.FirstOrDefault(x => x.CustomerID == CustomerID);
                            if (objOCTM == null && !string.IsNullOrEmpty(EmailID))
                            {
                                objOCTM = new OCTM();
                                objOCTM.OCTMID = Count++;
                                objOCTM.ParentID = ParentID;
                                objOCTM.CustomerID = CustomerID;
                                objOCTM.EmailID = EmailID;
                                objOCTM.CreatedDate = DateTime.Now;
                                objOCTM.CreatedBy = UserID;
                                objOCTM.Active = true;
                                objOCTM.UpdatedDate = DateTime.Now;
                                objOCTM.UpdatedBy = UserID;
                                ctx.OCTMs.Add(objOCTM);
                            }
                            else if (objOCTM != null && objOCTM.EmailID != EmailID)
                            {
                                objOCTM.EmailID = EmailID;
                                objOCTM.UpdatedDate = DateTime.Now;
                                objOCTM.UpdatedBy = UserID;
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