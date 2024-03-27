using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Entity.Validation;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public class MasterDemo
{
    public int MasterDemoID { get; set; }
    public string Name { get; set; }
    public int RegionID { get; set; }
    public string RegionName { get; set; }
    public int PlantID { get; set; }
    public string PlantName { get; set; }
    public int CustGroupID { get; set; }
    public string CustGroupName { get; set; }
    public string CustGroupDesc { get; set; }
    public double DistributorID { get; set; }
    public string DistributorCode { get; set; }
    public double DealerID { get; set; }
    public string DealerCode { get; set; }
    public DateTime CreatedDate { get; set; }
    public int CreatedBy { get; set; }
    public DateTime UpdatedDate { get; set; }
    public int UpdatedBy { get; set; }
    public bool Active { get; set; }
}

public partial class Master_MasterDemo : System.Web.UI.Page
{

    #region Declaration

    protected int UserID;
    protected decimal ParentID;
    protected int AuthType;

    #endregion

    #region Helper Method

    private void ClearAllInputs()
    {
        if (chkMode.Checked)
        {
            txtNo.Enabled = ACEtxtName.Enabled = false;
            txtName.Text = "";
            txtRegion.Text = "";
            txtPlant.Text = "";
            txtCustGroup.Text = "";
            txtDistributor.Text = "";
            txtDealer.Text = "";
            txtCreatedBy.Text = "";
            txtCreatedTime.Text = "";
            txtUpdatedBy.Text = "";
            txtUpdatedTime.Text = "";
            btnSubmit.Text = "Submit";
            txtNo.Style.Remove("background-color");
            txtNo.Text = "Auto Generated";
            txtName.Focus();
        }
        else
        {
            txtNo.Enabled = ACEtxtName.Enabled = true;
            txtNo.Text = "";
            txtName.Text = "";
            txtRegion.Text = "";
            txtPlant.Text = "";
            txtCustGroup.Text = "";
            txtDistributor.Text = "";
            txtDealer.Text = "";
            txtCreatedBy.Text = "";
            txtCreatedTime.Text = "";
            txtUpdatedBy.Text = "";
            txtUpdatedTime.Text = "";
            btnSubmit.Text = "Submit";
            txtNo.Style.Add("background-color", "rgb(250, 255, 189);");
            txtNo.Focus();
        }
        lblName.Text = "Name";
        ViewState["MstID"] = null;
    }

    public void ValidateUser()
    {
        if (Session["UserID"] != null && Session["ParentID"] != null &&
          Int32.TryParse(Session["UserID"].ToString(), out UserID) && Decimal.TryParse(Session["ParentID"].ToString(), out ParentID))
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                int EGID = Convert.ToInt32(Session["GroupID"]);
                AuthType = Convert.ToInt32(Session["Type"]);

                int lIndex = Request.ServerVariables["script_name"].ToString().LastIndexOf('/');
                string pagename = Request.ServerVariables["script_name"].ToString().Substring(lIndex + 1);
                var Auth = ctx.GRP1.Include("OMNU").FirstOrDefault(x => x.OMNU.PageName == pagename && x.EmpGroupID == EGID && x.ParentID == ParentID);

                if (Auth == null || Auth.AuthorizationType == "N")
                    Response.Redirect("~/AccessError.aspx");
                else if (!(AuthType == 1 ? Auth.OMNU.Company : AuthType == 2 ? Auth.OMNU.CMS : AuthType == 3 ? Auth.OMNU.DMS : AuthType == 4 ? Auth.OMNU.SS : false))
                    Response.Redirect("~/AccessError.aspx");
                else
                {
                    var UserType = Session["UserType"].ToString();
                    if (Auth.OMNU.MenuType.ToUpper() == "B" || UserType.ToUpper() == "B" || UserType.ToUpper() == Auth.OMNU.MenuType.ToUpper()) { }
                    else
                        Response.Redirect("~/AccessError.aspx");

                    if (Session["Lang"] != null && Session["Lang"].ToString() == "gujarati")
                    {
                        try
                        {
                            var xml = XDocument.Load(Server.MapPath("../Document/forlanguage.xml"));
                            var unit = xml.Descendants("employee_grp_master");
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

    #region Page Load

    protected void Page_Load(object sender, EventArgs e)
    {

        ValidateUser();
        if (!IsPostBack)
        {
            ClearAllInputs();
            LoadData();
        }
    }

    #endregion

    #region Button Click

    protected void btnSubmitClick(object sender, EventArgs e)
    {
        try
        {
            if (Page.IsValid)
            {
                int MstID = 0;
                if (ViewState["MstID"] != null && Int32.TryParse(ViewState["MstID"].ToString(), out MstID))
                {
                    UpdateById(MstID);
                }
                else
                {
                    var resultJsonString = GetDataList();
                    var jsonResultList = JsonConvert.DeserializeObject<List<MasterDemo>>(resultJsonString);
                    var nameChecked = jsonResultList.Find(x => x.Name == txtName.Text);
                    if (nameChecked != null && nameChecked.Name != null)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same name is not allowed!',3);", true);
                        return;
                    }
                    else
                    {
                        InsertData();
                    }
                }

                ClearAllInputs();
            }
        }
        catch (DbEntityValidationException ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + ex.EntityValidationErrors.FirstOrDefault().ValidationErrors.FirstOrDefault().ErrorMessage + "',2);", true);
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }

    }

    protected void btnCancelClick(object sender, EventArgs e)
    {
        Response.Redirect("MasterDemo.aspx");
    }

    #endregion

    #region Change Event
    protected void txtNo_TextChanged(object sender, EventArgs e)
    {
        try
        {
            if (!chkMode.Checked && !string.IsNullOrEmpty(txtNo.Text))
            {
                var word = txtNo.Text.Split("-".ToArray());
                if (word.Length >= 1)
                {
                    int MasterDemoID = Convert.ToInt32(word.First().Trim());
                    var resultJsonString = GetDataById(MasterDemoID);
                    var jsonResultList = JsonConvert.DeserializeObject<List<MasterDemo>>(resultJsonString);
                    if (jsonResultList != null)
                    {
                        foreach (var item in jsonResultList)
                        {
                            txtNo.Text = item.MasterDemoID.ToString();
                            txtName.Text = item.Name;
                            chkIsActive.Checked = item.Active;
                            //txtRegion.Text = item.RegionID.ToString();
                            //txtPlant.Text = item.PlantID.ToString();
                            //txtCustGroup.Text = item.CustGroupID.ToString();
                            //txtDistributor.Text = item.DistributorID.ToString();
                            //txtDealer.Text = item.DealerID.ToString();
                            txtCreatedBy.Text = item.CreatedBy.ToString();
                            txtCreatedTime.Text = item.CreatedDate.ToString("dd/MM/yyyy HH:mm");
                            txtUpdatedBy.Text = item.UpdatedBy.ToString();
                            txtUpdatedTime.Text = item.UpdatedDate.ToString("dd/MM/yyyy HH:mm");

                            ViewState["MstID"] = item.MasterDemoID;
                        }
                        LoadData();
                    }
                }
                else
                {
                    ScriptManager.RegisterStartupScript(this, GetType(), "ModelMsg", "ModelMsg('Select proper data!',3);", true);
                    ClearAllInputs();
                }
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select proper data!',3);", true);
                ClearAllInputs();
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
        txtName.Focus();
    }
    protected void chkMode_Checked(object sender, EventArgs e)
    {
        try
        {
            ClearAllInputs();

        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }

    protected void EditDeleteOnclick(object sender, EventArgs e)
    {
        LinkButton button = (LinkButton)sender;
        var CommandName = (string)button.Attributes["data-myData"];
        var selectedID = (string)button.Attributes["data-ID"];
        if (CommandName == "Delete")
        {
            int MasterDemoID = Convert.ToInt32(selectedID);
            DeleteDataById(MasterDemoID);
            LoadData();
        }
        if (CommandName == "Edit")
        {
            int MasterDemoID = Convert.ToInt32(selectedID);
            UpdateById(MasterDemoID);
            LoadData();
        }

    }

    #endregion

    #region Select/InsertUpdate functions

    private void InsertData()
    {
        using (DDMSEntities ctx = new DDMSEntities())
        {
            try
            {
                string Name = txtName.Text;
                int RegionID = Int32.TryParse(txtRegion.Text.Split("-".ToArray()).First().Trim(), out RegionID) ? RegionID : 0;
                string RegionName = ctx.OCSTs.FirstOrDefault(x => x.StateID == RegionID).StateName;
                int PlantID = Int32.TryParse(txtPlant.Text.Split("-".ToArray()).First().Trim(), out PlantID) ? PlantID : 0;
                string PlantName = ctx.OPLTs.FirstOrDefault(x => x.PlantID == PlantID).PlantName;
                int CustGroupID = Int32.TryParse(txtCustGroup.Text.Split("#".ToArray()).First().Trim(), out CustGroupID) ? CustGroupID : 0;
                string CustGroupName = txtCustGroup.Text.Split("#".ToArray()).First().Trim();
                string CustGroupDesc = ctx.CGRPs.Where(x => x.CustGroupName == CustGroupName).Select(x => x.CustGroupName + " # " + x.CustGroupDesc).FirstOrDefault();
                Decimal DistributorID = Decimal.TryParse(txtDistributor.Text.Split("-".ToArray()).Last().Trim(), out DistributorID) ? DistributorID : 0;
                string DistributorCode = ctx.OCRDs.Where(x => x.CustomerID == DistributorID && x.Type == 2 && x.Active).Select(x => x.CustomerCode + " # " + x.CustomerName).FirstOrDefault();
                Decimal DealerID = Decimal.TryParse(txtDealer.Text.Split("-".ToArray()).Last().Trim(), out DealerID) ? DealerID : 0;
                string DealerCode = ctx.OCRDs.Where(x => x.CustomerID == DealerID && x.Type == 3 && x.Active).Select(x => x.CustomerCode + " # " + x.CustomerName).FirstOrDefault();
                int CreatedBy = UserID;
                int UpdatedBy = UserID;
                bool Active = chkIsActive.Checked;

                Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
                SqlCommand Cm = new SqlCommand();

                Cm.Parameters.Clear();
                Cm.CommandType = CommandType.StoredProcedure;
                Cm.CommandText = "InsertUpdateMasterDemoData";

                Cm.Parameters.AddWithValue("@Name", Name);
                Cm.Parameters.AddWithValue("@RegionID", RegionID);
                Cm.Parameters.AddWithValue("@RegionName", RegionName);
                Cm.Parameters.AddWithValue("@PlantID", PlantID);
                Cm.Parameters.AddWithValue("@PlantName", PlantName);
                Cm.Parameters.AddWithValue("@CustGroupID", CustGroupID);
                Cm.Parameters.AddWithValue("@CustGroupName", CustGroupName);
                Cm.Parameters.AddWithValue("@CustGroupDesc", CustGroupDesc);
                Cm.Parameters.AddWithValue("@DistributorID", DistributorID);
                Cm.Parameters.AddWithValue("@DistributorCode", DistributorCode);
                Cm.Parameters.AddWithValue("@DealerID", DealerID);
                Cm.Parameters.AddWithValue("@DealerCode", DealerCode);
                Cm.Parameters.AddWithValue("@CreatedBy", CreatedBy);
                Cm.Parameters.AddWithValue("@UpdatedBy", UpdatedBy);
                Cm.Parameters.AddWithValue("@Active", Active);

                int ReturnValue = objClass.CommonFunctionForInsertUpdateDelete(Cm);
                Console.WriteLine("Reponse Data === >" + ReturnValue);
                if (ReturnValue >= 0)
                {
                    LoadData();
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Data Submitted Successfully !',1);", true);
                }
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
                throw;
            }
        }
    }

    private void UpdateById(int Id)
    {
        using (DDMSEntities ctx = new DDMSEntities())
        {
            try
            {
                string Name = txtName.Text;
                int RegionID = Int32.TryParse(txtRegion.Text.Split("-".ToArray()).First().Trim(), out RegionID) ? RegionID : 0;
                string RegionName = ctx.OCSTs.FirstOrDefault(x => x.StateID == RegionID).StateName;
                int PlantID = Int32.TryParse(txtPlant.Text.Split("-".ToArray()).First().Trim(), out PlantID) ? PlantID : 0;
                string PlantName = ctx.OPLTs.FirstOrDefault(x => x.PlantID == PlantID).PlantName;
                int CustGroupID = Int32.TryParse(txtCustGroup.Text.Split("#".ToArray()).First().Trim(), out CustGroupID) ? CustGroupID : 0;
                string CustGroupName = txtCustGroup.Text.Split("#".ToArray()).First().Trim();
                string CustGroupDesc = ctx.CGRPs.Where(x => x.CustGroupName == CustGroupName).Select(x => x.CustGroupName + " # " + x.CustGroupDesc).FirstOrDefault();
                Decimal DistributorID = Decimal.TryParse(txtDistributor.Text.Split("-".ToArray()).Last().Trim(), out DistributorID) ? DistributorID : 0;
                string DistributorCode = ctx.OCRDs.Where(x => x.CustomerID == DistributorID && x.Type == 2 && x.Active).Select(x => x.CustomerCode + " # " + x.CustomerName).FirstOrDefault();
                Decimal DealerID = Decimal.TryParse(txtDealer.Text.Split("-".ToArray()).Last().Trim(), out DealerID) ? DealerID : 0;
                string DealerCode = ctx.OCRDs.Where(x => x.CustomerID == DealerID && x.Type == 3 && x.Active).Select(x => x.CustomerCode + " # " + x.CustomerName).FirstOrDefault();
                int CreatedBy = UserID;
                int UpdatedBy = UserID;
                bool Active = chkIsActive.Checked;

                Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
                SqlCommand Cm = new SqlCommand();

                Cm.Parameters.Clear();
                Cm.CommandType = CommandType.StoredProcedure;
                Cm.CommandText = "InsertUpdateMasterDemoData";

                Cm.Parameters.AddWithValue("@MasterDemoID", Id);
                Cm.Parameters.AddWithValue("@Name", Name);
                Cm.Parameters.AddWithValue("@RegionID", RegionID);
                Cm.Parameters.AddWithValue("@RegionName", RegionName);
                Cm.Parameters.AddWithValue("@PlantID", PlantID);
                Cm.Parameters.AddWithValue("@PlantName", PlantName);
                Cm.Parameters.AddWithValue("@CustGroupID", CustGroupID);
                Cm.Parameters.AddWithValue("@CustGroupName", CustGroupName);
                Cm.Parameters.AddWithValue("@CustGroupDesc", CustGroupDesc);
                Cm.Parameters.AddWithValue("@DistributorID", DistributorID);
                Cm.Parameters.AddWithValue("@DistributorCode", DistributorCode);
                Cm.Parameters.AddWithValue("@DealerID", DealerID);
                Cm.Parameters.AddWithValue("@DealerCode", DealerCode);
                Cm.Parameters.AddWithValue("@CreatedBy", CreatedBy);
                Cm.Parameters.AddWithValue("@UpdatedBy", UpdatedBy);
                Cm.Parameters.AddWithValue("@Active", Active);

                int ReturnValue = objClass.CommonFunctionForInsertUpdateDelete(Cm);
                Console.WriteLine("Reponse Data === >" + ReturnValue);
                if (ReturnValue >= 0)
                {
                    LoadData();
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Data Updated Successfully !',1);", true);
                }
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
                throw;
            }
        }
    }

    public static String GetDataById(int Id)
    {
        try
        {
            string jsonstring = "";
            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();
            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "GetMasterDemoByID";

            Cm.Parameters.AddWithValue("@MasterDemoID", Id);

            DataSet ds = objClass.CommonFunctionForSelect(Cm);
            if (ds.Tables.Count > 0)
            {
                jsonstring = JsonConvert.SerializeObject(ds.Tables[0]);
            }
            else
            {
                jsonstring = "ERROR=No Result Found.";
            }
            return jsonstring;
        }
        catch (Exception ex)
        {
            throw;
        }
    }

    private void DeleteDataById(int Id)
    {
        try
        {
            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();
            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "DeleteMasterDemoByID";

            Cm.Parameters.AddWithValue("@MasterDemoID", Id);
            int ReturnValue = objClass.CommonFunctionForInsertUpdateDelete(Cm);
            Console.WriteLine("Reponse Data === >" + ReturnValue);
            if (ReturnValue >= 0)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Data Deleted Successfully !',1);", true);
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('No record found !',1);", true);
            }
        }
        catch (Exception ex)
        {
            throw;
        }
    }

    public static String GetDataList()
    {
        try
        {
            string jsonstring = "";
            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();

            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "GetMasterDemoList";

            DataSet ds = objClass.CommonFunctionForSelect(Cm);
            if (ds.Tables.Count > 0)
            {
                jsonstring = JsonConvert.SerializeObject(ds.Tables[0]);
            }
            else
            {
                jsonstring = "ERROR=No Result Found.";
            }
            return jsonstring;
        }
        catch (Exception ex)
        {
            throw;
        }
    }

    private void LoadData()
    {
        try
        {
            string jsonstring = "";
            gvMasterDemoData.DataSource = null;
            gvMasterDemoData.DataBind();

            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();
            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "GetMasterDemoList";

            DataSet ds = objClass.CommonFunctionForSelect(Cm);
            if (ds.Tables.Count > 0)
            {
                jsonstring = JsonConvert.SerializeObject(ds.Tables[0]);
                var jsonResultList = JsonConvert.DeserializeObject<List<MasterDemo>>(jsonstring);
                if (jsonResultList != null)
                {
                    var DataList = new List<MasterDemo>();
                    foreach (var item in jsonResultList)
                    {
                        DataList.Add(item);
                    }
                    gvMasterDemoData.DataSource = DataList;
                    gvMasterDemoData.DataBind();
                }
            }
            else
            {
                jsonstring = "ERROR=No Result Found.";
            }
        }
        catch (Exception ex)
        {
            throw;
        }
    }
    #endregion

}