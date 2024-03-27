using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Reports_BeatDisplayUtility : System.Web.UI.Page
{
    #region Declaration

    protected int UserID;
    public int CustType;
    public decimal ParentID;
    protected String AuthType;

    #endregion

    #region Helper Method

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
                            var unit = xml.Descendants("reports");
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

    public void ClearAllInputs()
    {

    }

    #endregion

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
    }

    [WebMethod]
    public static List<string> GetEmpHierarchy(int EmpID)
    {
        List<string> result = new List<string>();
        try
        {
            Decimal ParentId = 1000010000000000;
            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();
            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.Text;
            Cm.CommandText = "SELECT * FROM dbo.[Fn_ManagerList](@ParentID,@EmpID)";
            Cm.Parameters.AddWithValue("@ParentID", ParentId);
            Cm.Parameters.AddWithValue("@EmpID", EmpID);

            DataSet ds = objClass.CommonFunctionForSelect(Cm);
            if (ds.Tables[0].Rows.Count > 0)
            {
                List<string> data = (from DataRow row in ds.Tables[0].Rows
                                     select new
                                     {
                                         Emp = row["EmpCode"].ToString() + " # " + row["EmpName"].ToString()
                                     }).Select(x => x.Emp).ToList();
                return data;
            }
            return result;
        }
        catch (Exception ex)
        {
            result.Add("No Result Found");
        }
        return result;
    }

    protected void btnGenerat_Click(object sender, EventArgs e)
    {
        Decimal CustCode = Decimal.TryParse(txtCustCode.Text.Split("-".ToArray()).Last().Trim(), out CustCode) ? CustCode : 0;
        if (CustCode != 0)
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                var Parent = (from a in ctx.OCRDs
                              join b in ctx.OCRDs on a.CustomerID equals b.ParentID
                              where (b.CustomerID == CustCode)
                              select new { a.CustomerID, a.CustomerCode, CustomerName = a.CustomerName.Replace("-", "") }).FirstOrDefault();
                if (Parent.CustomerID == 1000010000000000)
                {
                    var Plant = (from a in ctx.OGCRDs
                                 join b in ctx.OPLTs on a.PlantID equals b.PlantID
                                 where (a.CustomerID == CustCode) //&& b.PlantID != null && a.PriceListID != null && a.DivisionlID != null
                                 select b.PlantCode + " - " + b.PlantName).Distinct().FirstOrDefault();
                    txtParent.Text = Plant;
                }
                else
                    txtParent.Text = Parent.CustomerCode + " - " + Parent.CustomerName;
            }
        }
        else
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select Customer!',3);", true);
            return;
        }
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();

        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "GetDealerRoute";

        Cm.Parameters.AddWithValue("@ParentID", ParentID);
        Cm.Parameters.AddWithValue("@EmpID", UserID);
        Cm.Parameters.AddWithValue("@CustomerID", CustCode);

        DataSet ds = objClass.CommonFunctionForSelect(Cm);
        gvdata.DataSource = ds.Tables[0];
        gvdata.DataBind();
    }

    protected void gvdata_PreRender(object sender, EventArgs e)
    {
        if (gvdata.Rows.Count > 0)
        {
            gvdata.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvdata.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }
}