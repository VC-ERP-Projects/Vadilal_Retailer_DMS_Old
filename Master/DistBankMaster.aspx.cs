using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Master_DistBankMaster : System.Web.UI.Page
{
    #region Declaration
    protected int UserID, CustType;
    protected decimal ParentID;
    protected String AuthType;
    protected string pagename;
    protected String Version;

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
                Version = Convert.ToString(ConfigurationManager.AppSettings["Version"]);
                int lIndex = Request.ServerVariables["script_name"].ToString().LastIndexOf('/');
                pagename = Request.ServerVariables["script_name"].ToString().Substring(lIndex + 1);
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
                            var unit = xml.Descendants("change_password");
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
    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        if (!IsPostBack)
            GetBankDetails();
    }
    protected void GetBankDetails()
    {
        try
        {
            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();

            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "GetCustomerBankDetails";
            Cm.Parameters.AddWithValue("@ParentId", ParentID);
            DataSet DS = objClass.CommonFunctionForSelect(Cm);
            if (DS.Tables[0] != null && DS.Tables[0].Rows.Count > 0)
            {
                txtAccountNo.Text = DS.Tables[0].Rows[0]["AccountNo"].ToString();
                txtBankName.Text = DS.Tables[0].Rows[0]["BankName"].ToString();
                txtBranchName.Text = DS.Tables[0].Rows[0]["BranchName"].ToString();
                txtIFSCCode.Text = DS.Tables[0].Rows[0]["IFSCCode"].ToString();
                hdnBankId.Value = DS.Tables[0].Rows[0]["BankId"].ToString();
                txtUpdateBy.Text = DS.Tables[0].Rows[0]["UpdatedBy"].ToString();
                txtUpdatedDate.Text = DS.Tables[0].Rows[0]["UpdatedDate"].ToString();
                txtJurisdiction.Text = DS.Tables[0].Rows[0]["Jurisdiction"].ToString();
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',3);", true);
        }
    }
    protected void saveData_Click(object sender, EventArgs e)
    {
        try
        {
            //if (!ValidateIFSCCode(txtIFSCCode.Text.Trim()))
            //{
            //    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please enter valid ifsc code.',3);", true);
            //    return;
            //}
            Int32 BankId = Int32.TryParse(txtBankName.Text.Split("#".ToArray()).Last().Trim(), out BankId) ? BankId : 0;
            if (BankId == 0)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please enter valid ifsc code.',3);", true);
                return;
            }
            using (DDMSEntities ctx = new DDMSEntities())
            {
                DBNK objCtg = ctx.DBNKs.FirstOrDefault(x => x.CustomerId == ParentID);
                if (objCtg != null)
                {
                    objCtg.BankId = BankId;
                    objCtg.AccountNo = Convert.ToString(txtAccountNo.Text);
                    objCtg.BranchName = txtBranchName.Text;
                    objCtg.IFSCCode = txtIFSCCode.Text;
                    objCtg.UpdatedBy = UserID;
                    objCtg.IsActive = true;
                    objCtg.Jurisdiction = txtJurisdiction.Text;
                    objCtg.UpdatedDate = System.DateTime.Now;
                }
                else
                {
                    DBNK objectCTG = new DBNK();
                    objectCTG.BankId = BankId;
                    objectCTG.CustomerId = ParentID;
                    objectCTG.AccountNo = Convert.ToString(txtAccountNo.Text);
                    objectCTG.BranchName = txtBranchName.Text;
                    objectCTG.IFSCCode = txtIFSCCode.Text;
                    objectCTG.CreatedBy = UserID;
                    objectCTG.CreatedDate = System.DateTime.Now;
                    objectCTG.UpdatedBy = UserID;
                    objectCTG.IsActive = true;
                    objectCTG.UpdatedDate = System.DateTime.Now;
                    objectCTG.Jurisdiction = txtJurisdiction.Text;
                    ctx.DBNKs.Add(objectCTG);
                }
                ctx.SaveChanges();
                GetBankDetails();
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Record Added Successfully',1);", true);
               // clearcontrols();
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',3);", true);
        }
    }
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<DicData> SearchBank(string prefixText)
    {

        List<DicData> dicData = new List<DicData>();
        using (var ctx = new DDMSEntities())
        {
            Int32 UserID = Convert.ToInt32(HttpContext.Current.Session["UserID"]);
            decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);
            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();
            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "GetBankMaster";
            Cm.Parameters.AddWithValue("@Prefix", prefixText);
            DataSet ds = objClass.CommonFunctionForSelect(Cm);
            if (ds.Tables.Count > 0)
            {
                if (ds.Tables[0].Rows.Count > 0)
                {
                    return ds.Tables[0].AsEnumerable()
                                .Select(r => new DicData { Text = r.Field<string>("Data"), Value = 0 })
                                .ToList();
                }
            }
            return dicData;
        }
    }

    public bool ValidateIFSCCode(string ifscCode)
    {
        System.Text.RegularExpressions.Regex regx = new System.Text.RegularExpressions.Regex("^[A-Za-z]{4}[0-9]{7}$");
        return regx.Matches(ifscCode).Count > 0 ? regx.Matches(ifscCode)[0].Success : false;
    }
    protected void clearcontrols()
    {
        txtAccountNo.Text = "";
        txtBankName.Text = "";
        txtBranchName.Text = "";
        txtIFSCCode.Text = "";
        txtUpdateBy.Text = "";
        txtUpdatedDate.Text = "";
        hdnBankId.Value = "0";
    }
}