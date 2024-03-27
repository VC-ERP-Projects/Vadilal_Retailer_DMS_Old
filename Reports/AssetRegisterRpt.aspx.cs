using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;
using System.IO;
using System.Text;
using System.Web.UI.HtmlControls;
using System.Globalization;

public partial class Reports_AssetRegisterRpt : System.Web.UI.Page
{

    #region Declaration

    protected int UserID, CustType;
    protected decimal ParentID;
    protected String AuthType, UserName;

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

                    UserName = ctx.OEMPs.Where(x => x.EmpID == UserID && x.ParentID == ParentID).Select(x => x.EmpCode + "," + x.Name).FirstOrDefault().ToString();
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
        txtAcqToDate.Text = txtAcqFromDate.Text = Common.DateTimeConvert(DateTime.Now);
        txtLgmTodate.Text = txtLgmFromDate.Text = Common.DateTimeConvert(DateTime.Now);
        txtSyncTo.Text = txtSyncFrom.Text = Common.DateTimeConvert(DateTime.Now);
        txtServiceTo.Text = txtServiceFrom.Text = Common.DateTimeConvert(DateTime.Now);
        txtSalesTo.Text = Common.DateTimeConvert(DateTime.Now);
        txtSalesFrom.Text = Common.DateTimeConvert(DateTime.Now.AddYears(-1));
        txtAssetModel.Text = "";
        txtAssetCode.Text = "";
        txtSize.Text = "";
        txtSerialNo.Text = "";
        txtRSDLocation.Text = "";
    }

    #endregion

    protected void Page_Load(object sender, EventArgs e)
    {
       // ValidateUser();

        if (!IsPostBack)
        {
            ClearAllInputs();
        }
        ScriptManager scriptManager = ScriptManager.GetCurrent(this.Page);
        scriptManager.RegisterPostBackControl(this.btnGo);
        using (DDMSEntities ctx = new DDMSEntities())
        {
            ddlAssetType.DataTextField = "AssetTypeName";
            ddlAssetType.DataValueField = "AssetTypeID";
            ddlAssetType.DataSource = ctx.OASTies.Where(x => x.Active == true).ToList();
            ddlAssetType.SelectedValue = "4";
            ddlAssetType.DataBind();
            ddlAssetType.Items.Insert(0, new ListItem("---All---", "0"));
            acetxtAssetModel.ContextKey = (CustType + 1).ToString();
        }
    }

    protected void btnGo_Click(object sender, EventArgs e)
    {
        try
        {
            Int32 LyingAt = Convert.ToInt32(ddlLying.SelectedValue);
            string AssetTypeId = Convert.ToString(ddlAssetType.SelectedValue);
            Decimal AssetModelId = Decimal.TryParse(txtAssetModel.Text.Split("-".ToArray()).Last().Trim(), out AssetModelId) ? AssetModelId : 0;
            Decimal AssetCodeId = Decimal.TryParse(txtAssetCode.Text.Split("-".ToArray()).Last().Trim(), out AssetCodeId) ? AssetCodeId : 0;
            string AssetSizeId = txtSize.Text.Trim() != "" ? txtSize.Text.Trim() : "0";
            string SerialNumber = txtSerialNo.Text.Trim() != "" ? txtSerialNo.Text.Trim() : "0";
            string AcqDateFrom = string.IsNullOrEmpty(txtAcqFromDate.Text) ? "" : Convert.ToDateTime(txtAcqFromDate.Text).ToString("yyyyMMdd");
            string AcqDateTo = string.IsNullOrEmpty(txtAcqToDate.Text) ? "" : Convert.ToDateTime(txtAcqToDate.Text).ToString("yyyyMMdd");
            string LGMDateFrom = string.IsNullOrEmpty(txtLgmFromDate.Text) ? "" : Convert.ToDateTime(txtLgmFromDate.Text).ToString("yyyyMMdd");
            string LGMDateTo = string.IsNullOrEmpty(txtLgmTodate.Text) ? "" : Convert.ToDateTime(txtLgmTodate.Text).ToString("yyyyMMdd");
            string RSDLocation = string.IsNullOrEmpty(txtRSDLocation.Text) ? "0" : txtRSDLocation.Text.Split("-".ToArray()).Last().Trim();

            string LastSyncFrom = string.IsNullOrEmpty(txtSyncFrom.Text) ? "" : Convert.ToDateTime(txtSyncFrom.Text).ToString("yyyyMMdd");
            string LastSyncTo = string.IsNullOrEmpty(txtSyncTo.Text) ? "" : Convert.ToDateTime(txtSyncTo.Text).ToString("yyyyMMdd");
            string LastServiceFrom = string.IsNullOrEmpty(txtServiceFrom.Text) ? "" : Convert.ToDateTime(txtServiceFrom.Text).ToString("yyyyMMdd");
            string LastServiceTo = string.IsNullOrEmpty(txtServiceTo.Text) ? "" : Convert.ToDateTime(txtServiceTo.Text).ToString("yyyyMMdd");
            string Salefrom = string.IsNullOrEmpty(txtSalesFrom.Text) ? "" : Convert.ToDateTime(txtSalesFrom.Text).ToString("yyyyMMdd");
            string Saleto = string.IsNullOrEmpty(txtSalesTo.Text) ? "" : Convert.ToDateTime(txtSalesTo.Text).ToString("yyyyMMdd");
            string RSDMechanic = string.IsNullOrEmpty(txtRSDMechanic.Text) ? "" : txtRSDMechanic.Text.Split("-".ToArray()).Last().Trim();
            string RSDEmployee = string.IsNullOrEmpty(txtRSDEmployee.Text) ? "" : txtRSDMechanic.Text.Split("-".ToArray()).Last().Trim();
            string Employee = !string.IsNullOrEmpty(txtEmployee.Text) ? txtEmployee.Text.Split("-".ToArray()).Last().Trim() : "0";
            string ParentRegion = !string.IsNullOrEmpty(txtParentRegion.Text) ? txtParentRegion.Text.Split("-".ToArray()).Last().Trim() : "0";
            string ParentCode = !string.IsNullOrEmpty(txtParentCode.Text) ? txtParentCode.Text.Split("-".ToArray()).Last().Trim() : "0";
            string CustomerRegion = !string.IsNullOrEmpty(txtCustomerRegion.Text) ? txtCustomerRegion.Text.Split("-".ToArray()).Last().Trim() : "0";
            string Customer = string.IsNullOrEmpty(txtCustomer.Text) ? "" : txtCustomer.Text.Split("-".ToArray()).Last().Trim();
            string AdditionalIdentifier = Convert.ToString(ddlSales.SelectedValue);
            string PlantRegion = !string.IsNullOrEmpty(txtPlantRegion.Text) ? txtPlantRegion.Text.Split("-".ToArray()).Last().Trim() : "0";
            string Plant = string.IsNullOrEmpty(txtPlant.Text) ? "0" : txtPlant.Text.Split("-".ToArray()).Last().Trim();
            string location = string.IsNullOrEmpty(txtStorageLocation.Text) ? "0" : txtStorageLocation.Text.Split("-".ToArray()).Last().Trim();
            if (LyingAt == 9)
            {
                Salefrom = "";
                Saleto = "";
                AdditionalIdentifier = "0";
            }
            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();

            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "AssetRegister";

            Cm.Parameters.AddWithValue("@ReportFor", LyingAt);
            Cm.Parameters.AddWithValue("@AssetTypeId", AssetTypeId);
            Cm.Parameters.AddWithValue("@AssetModel", Convert.ToString(AssetModelId));
            Cm.Parameters.AddWithValue("@AssetCode", Convert.ToString(AssetCodeId));
            Cm.Parameters.AddWithValue("@AssetSize", AssetSizeId);
            Cm.Parameters.AddWithValue("@AssetSerialNo", SerialNumber);
            Cm.Parameters.AddWithValue("@AcDateFrom", AcqDateFrom);
            Cm.Parameters.AddWithValue("@AcDateTo", AcqDateTo);
            Cm.Parameters.AddWithValue("@LGMDateFrom", LGMDateFrom);
            Cm.Parameters.AddWithValue("@LGMDateTo", LGMDateTo);
            Cm.Parameters.AddWithValue("@StorageLocation", RSDLocation);
            Cm.Parameters.AddWithValue("@LastSyncDatefrom", LastSyncFrom);
            Cm.Parameters.AddWithValue("@LastSyncDateto", LastSyncTo);
            Cm.Parameters.AddWithValue("@LastServiceDatefrom", LastServiceFrom);
            Cm.Parameters.AddWithValue("@LastServiceDateto", LastServiceTo);
            Cm.Parameters.AddWithValue("@Salefrom", Salefrom);
            Cm.Parameters.AddWithValue("@Saleto", Saleto);
            Cm.Parameters.AddWithValue("@RsdMechanic", RSDMechanic);
            Cm.Parameters.AddWithValue("@RSDEmployee", RSDEmployee);
            Cm.Parameters.AddWithValue("@Employee", Employee);
            Cm.Parameters.AddWithValue("@ParentRegion", ParentRegion);
            Cm.Parameters.AddWithValue("@ParentCode", ParentCode);
            Cm.Parameters.AddWithValue("@CustomerRegion", CustomerRegion);
            Cm.Parameters.AddWithValue("@Customer", Customer);
            Cm.Parameters.AddWithValue("@AdditionalIdentifier", AdditionalIdentifier);
            Cm.Parameters.AddWithValue("@PlantRegion", PlantRegion);
            Cm.Parameters.AddWithValue("@Plant", Plant);
            Cm.Parameters.AddWithValue("@location", location);
            DataSet ds = objClass.CommonFunctionForSelect(Cm);
            Response.Clear();
            Response.Buffer = true;
            Response.ClearContent();
            IDataReader reader = objClass.CommonFunctionForSelectDR(Cm);
            StringWriter writer = new StringWriter();

            writer.WriteLine("Asset Register ,");
            writer.WriteLine("Lying At ," + ddlLying.SelectedItem.Text);
            writer.WriteLine("Asset Type ," + ddlAssetType.SelectedItem.Text);
            writer.WriteLine("Asset Model ," + ((txtAssetModel.Text != "0" && txtAssetModel.Text.Trim() != "" && txtAssetModel.Text.Contains("-")) ? txtAssetModel.Text.Split('-')[1].ToString() : "All"));
            writer.WriteLine("Acquisition From , " + (txtAcqFromDate.Text) + " To , " + (txtAcqToDate.Text));
            writer.WriteLine("Asset Serial No ," + (txtSerialNo.Text));
            writer.WriteLine("LGM Date From , " + (txtLgmFromDate.Text) + " To , " + (txtLgmTodate.Text));
            writer.WriteLine("RSD Location , " + (txtRSDLocation.Text));
            writer.WriteLine("Last Sync Date From , " + (txtSyncFrom.Text) + " To , " + (txtSyncTo.Text));
            writer.WriteLine("Asset Code ," + ((txtAssetCode.Text != "0" && txtAssetCode.Text.Trim() != "" && txtAssetCode.Text.Contains("-")) ? txtAssetCode.Text.Split('-')[1].ToString() : "All"));
            writer.WriteLine("Last Service Date From , " + (txtServiceFrom.Text) + " To , " + (txtServiceTo.Text));
            writer.WriteLine("Asset Size (CFT) ," + txtSize.Text);
            writer.WriteLine("RSD Employee , " + ((txtRSDEmployee.Text != "0" && txtRSDEmployee.Text.Trim() != "" && txtRSDEmployee.Text.Contains("-")) ? txtRSDEmployee.Text.Split('-')[1].ToString() : "All"));
            writer.WriteLine("RSD Mechanic , " + ((txtRSDMechanic.Text != "0" && txtRSDMechanic.Text.Trim() != "" && txtRSDMechanic.Text.Contains("-")) ? txtRSDMechanic.Text.Split('-')[1].ToString() : "All"));
            if (ddlLying.SelectedValue != "9")
            {
                writer.WriteLine("Parent Option , " + (ddlParent.SelectedItem.Text));
                if (ddlParent.SelectedValue == "1")
                {
                    writer.WriteLine("Employee , " + ((txtEmployee.Text != "0" && txtEmployee.Text.Trim() != "" && txtEmployee.Text.Contains("-")) ? txtEmployee.Text.Split('-')[1].ToString() : "All"));
                    writer.WriteLine("Region of Parent , " + ((txtParentRegion.Text != "0" && txtParentRegion.Text.Trim() != "" && txtParentRegion.Text.Contains("-")) ? txtParentRegion.Text.Split('-')[1].ToString() : "All"));
                    writer.WriteLine("Parent Code , " + ((txtParentCode.Text != "0" && txtParentCode.Text.Trim() != "" && txtParentCode.Text.Contains("-")) ? txtParentCode.Text.Split('-')[1].ToString() : "All"));
                    writer.WriteLine("Region of Customer , " + ((txtCustomerRegion.Text != "0" && txtCustomerRegion.Text.Trim() != "" && txtCustomerRegion.Text.Contains("-")) ? txtCustomerRegion.Text.Split('-')[1].ToString() : "All"));
                    writer.WriteLine("Customer , " + ((txtCustomer.Text != "0" && txtCustomer.Text.Trim() != "" && txtCustomer.Text.Contains("-")) ? txtCustomer.Text.Split('-')[1].ToString() : "All"));
                    writer.WriteLine("Sales/Deposit , " + (ddlSales.SelectedItem.Text));
                    writer.WriteLine("Sales From Date , " + (txtSalesFrom.Text) + " To , " + (txtSalesTo.Text));
                }
            }
            if (ddlLying.SelectedValue == "9")
            {
                writer.WriteLine("Plant Region , " + ((txtPlantRegion.Text != "0" && txtPlantRegion.Text.Trim() != "" && txtPlantRegion.Text.Contains("-")) ? txtPlantRegion.Text.Split('-')[1].ToString() : "All"));
                writer.WriteLine("Plant , " + ((txtPlant.Text != "0" && txtPlant.Text.Trim() != "" && txtPlant.Text.Contains("-")) ? txtPlant.Text.Split('-')[1].ToString() : "All"));
                writer.WriteLine("Storage Location , " + ((txtStorageLocation.Text != "0" && txtStorageLocation.Text.Trim() != "" && txtStorageLocation.Text.Contains("-")) ? txtStorageLocation.Text.Split('-')[1].ToString() : "All"));
            }
            writer.WriteLine("Run Date/Time , " + DateTime.Now);
            if (ds.Tables[0].Rows.Count > 0)
            {
                do
                {

                    writer.WriteLine(string.Join(",", Enumerable.Range(0, reader.FieldCount).Select(reader.GetName).ToList()));
                    int count = 0;
                    while (reader.Read())
                    {
                        writer.WriteLine(string.Join(",", Enumerable.Range(0, reader.FieldCount).Select(reader.GetValue).ToList()));
                        if (++count % 100 == 0)
                        {
                            writer.Flush();
                        }
                    }
                }

                while (reader.NextResult());
            }
            Response.AddHeader("content-disposition", "attachment; filename=Asset_Register" + "_" + DateTime.Now.ToString("ddMMyyyyhhmmss") + ".csv");
            Response.ContentType = "application/txt";
            Response.Write(writer.ToString());
            Response.Flush();
            Response.End();
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + Common.GetString(ex) + "',2);", true);
        }
    }

}