using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Reports_TaskFulfillment : System.Web.UI.Page
{
    #region Declaration

    protected int UserID, CustType;
    protected decimal ParentID;
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
                var UserType = Session["UserType"].ToString();
                int lIndex = Request.ServerVariables["script_name"].ToString().LastIndexOf('/');
                string pagename = Request.ServerVariables["script_name"].ToString().Substring(lIndex + 1);
                int menuid = ctx.OMNUs.FirstOrDefault(x => x.PageName == pagename && (UserType == "b" ? true : x.MenuType == UserType)).MenuID;
                var Auth = ctx.GRP1.Include("OMNU").FirstOrDefault(x => x.MenuID == menuid && x.EmpGroupID == EGID && x.ParentID == ParentID);
                if (Auth == null || Auth.AuthorizationType == "N")
                    Response.Redirect("~/AccessError.aspx");
                else if (!(CustType == 1 ? Auth.OMNU.Company : CustType == 2 ? Auth.OMNU.CMS : CustType == 3 ? Auth.OMNU.DMS : CustType == 4 ? Auth.OMNU.SS : false))
                    Response.Redirect("~/AccessError.aspx");
                else
                {
                    AuthType = Auth.AuthorizationType;
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

    public void ClearAllInputes()
    {
        using (DDMSEntities ctx = new DDMSEntities())
        {
            txtFromDate.Text = txtToDate.Text = Common.DateTimeConvert(DateTime.Now);
            var location = ctx.OTTies.Where(x => x.Active).ToList();
            ddlTaskType.DataSource = location;
            ddlTaskType.DataBind();
            ddlTaskType.Items.Insert(0, new ListItem("---Select---", "0"));
        }
        gvtask.DataSource = null;
        gvtask.DataBind();
    }

    protected void ddlTaskType_SelectedIndexChanged(object sender, EventArgs e)
    {
        var TaskID = Convert.ToInt32(ddlTaskType.SelectedValue);
        using (DDMSEntities ctx = new DDMSEntities())
        {
            var location = ctx.OTTies.Where(x => x.Active && x.TaskTypeID == TaskID).ToList();
            ddlTaskType.DataSource = location;
            ddlTaskType.DataBind();
            ddlTaskType.Items.Insert(0, new ListItem("---Select---", "0"));
        }
    }
    #endregion

    #region PageLoad

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();

        if (!IsPostBack)
        {
            ClearAllInputes();
        }
        ScriptManager scriptManager = ScriptManager.GetCurrent(this.Page);
        scriptManager.RegisterPostBackControl(this.btnExport);
    }

    #endregion

    #region ButtonClick

    protected void btnGenerat_Click(object sender, EventArgs e)
    {
        try
        {
            if (Session["UserID"] != null && Session["ParentID"] != null &&
            Int32.TryParse(Session["UserID"].ToString(), out UserID) && Decimal.TryParse(Session["ParentID"].ToString(), out ParentID))
            {
                Int32.TryParse(Session["UserID"].ToString(), out UserID);
                Decimal.TryParse(Session["ParentID"].ToString(), out ParentID);
            }
            SqlCommand Cm = new SqlCommand();
            gvtask.DataSource = null;
            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();

            Int32 SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;
            Int32 CityID = Int32.TryParse(txtCity.Text.Split("-".ToArray()).Last().Trim(), out CityID) ? CityID : 0;
            string SerialNumber = !string.IsNullOrEmpty(txtAssetSerialNo.Text) ? txtAssetSerialNo.Text : "0";
            Decimal DealerID = Decimal.TryParse(txtDealerCode.Text.Split("-".ToArray()).Last().Trim(), out DealerID) ? DealerID : 0;
            Int32 TaskType = 0;
            int.TryParse(ddlTaskType.SelectedValue, out TaskType);
            DateTime StartDate = Convert.ToDateTime(txtFromDate.Text);
            DateTime EndDate = Convert.ToDateTime(txtToDate.Text);
            Int32 MechEmpID = Int32.TryParse(txtMechEmp.Text.Split("-".ToArray()).Last().Trim(), out MechEmpID) ? MechEmpID : 0;

            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "MECH_Task_Fulfilment_Report";

            Cm.Parameters.AddWithValue("@ParentID", ParentID);
            Cm.Parameters.AddWithValue("@SUserID", SUserID);
            Cm.Parameters.AddWithValue("@TaskType", TaskType);
            Cm.Parameters.AddWithValue("@DueDateFrom", StartDate);
            Cm.Parameters.AddWithValue("@DueDateTo", EndDate);
            Cm.Parameters.AddWithValue("@Location", txtlocation.Text);
            Cm.Parameters.AddWithValue("@EmpID", UserID);
            Cm.Parameters.AddWithValue("@CityID", CityID);
            Cm.Parameters.AddWithValue("@DealerID", DealerID);
            Cm.Parameters.AddWithValue("@SerialNumber", SerialNumber);
            Cm.Parameters.AddWithValue("@MechanicID", MechEmpID);

            DataSet ds = objClass.CommonFunctionForSelect(Cm);
            if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
            {
                gvtask.DataSource = ds.Tables[0];
                gvtask.DataBind();
            }
            else
            {
                gvtask.DataSource = null;
                gvtask.DataBind();
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + Common.GetString(ex) + "',2);", true);
        }
    }
    protected void btnExport_Click(object sender, EventArgs e)
    {
        try
        {
            if (Session["UserID"] != null && Session["ParentID"] != null &&
            Int32.TryParse(Session["UserID"].ToString(), out UserID) && Decimal.TryParse(Session["ParentID"].ToString(), out ParentID))
            {
                Int32.TryParse(Session["UserID"].ToString(), out UserID);
                Decimal.TryParse(Session["ParentID"].ToString(), out ParentID);
            }
            SqlCommand Cm = new SqlCommand();
            gvtask.DataSource = null;
            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();

            Int32 SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;
            Int32 CityID = Int32.TryParse(txtCity.Text.Split("-".ToArray()).Last().Trim(), out CityID) ? CityID : 0;
            string SerialNumber = !string.IsNullOrEmpty(txtAssetSerialNo.Text) ? txtAssetSerialNo.Text : "0";
            Decimal DealerID = Decimal.TryParse(txtDealerCode.Text.Split("-".ToArray()).Last().Trim(), out DealerID) ? DealerID : 0;
            Int32 TaskType = 0;
            int.TryParse(ddlTaskType.SelectedValue, out TaskType);
            DateTime StartDate = Convert.ToDateTime(txtFromDate.Text);
            DateTime EndDate = Convert.ToDateTime(txtToDate.Text);
            Int32 MechEmpID = Int32.TryParse(txtMechEmp.Text.Split("-".ToArray()).Last().Trim(), out MechEmpID) ? MechEmpID : 0;

            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "MECH_Task_Fulfilment_Report";

            Cm.Parameters.AddWithValue("@ParentID", ParentID);
            Cm.Parameters.AddWithValue("@SUserID", SUserID);
            Cm.Parameters.AddWithValue("@TaskType", TaskType);
            Cm.Parameters.AddWithValue("@DueDateFrom", StartDate);
            Cm.Parameters.AddWithValue("@DueDateTo", EndDate);
            Cm.Parameters.AddWithValue("@Location", txtlocation.Text);
            Cm.Parameters.AddWithValue("@EmpID", UserID);
            Cm.Parameters.AddWithValue("@CityID", CityID);
            Cm.Parameters.AddWithValue("@DealerID", DealerID);
            Cm.Parameters.AddWithValue("@SerialNumber", SerialNumber);
            Cm.Parameters.AddWithValue("@MechanicID", MechEmpID);

            DataSet ds = objClass.CommonFunctionForSelect(Cm);
            if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
            {
                Response.Clear();
                Response.Buffer = true;
                Response.ClearContent();
                Response.ClearHeaders();

                IDataReader reader = objClass.CommonFunctionForSelectDR(Cm);
                StringWriter writer = new StringWriter();

                writer.WriteLine("Task Fulfillment Report");
                writer.WriteLine("Task Fulfill Date From $" + StartDate + "$" + "To $" + EndDate);
                writer.WriteLine("Employee/Mechanic $" + (!string.IsNullOrEmpty(txtCode.Text) ? txtCode.Text.Split('-')[0].ToString() + "-" + txtCode.Text.Split('-')[1].ToString() : "All"));
                writer.WriteLine("RSD Location $" + (!string.IsNullOrEmpty(txtlocation.Text) ? txtlocation.Text : "All"));
                writer.WriteLine("Asset Serial Number $ " + (!string.IsNullOrEmpty(txtAssetSerialNo.Text) ? txtAssetSerialNo.Text : "All"));
                writer.WriteLine("Customer $" + (!string.IsNullOrEmpty(txtDealerCode.Text) ? txtDealerCode.Text.Split('-')[0].ToString() + "-" + txtDealerCode.Text.Split('-')[1].ToString() : "All"));
                writer.WriteLine("Task Type $" + (ddlTaskType.SelectedValue != "0" ? ddlTaskType.SelectedItem.Text : "All"));
                do
                {
                    writer.WriteLine(string.Join("$", Enumerable.Range(0, reader.FieldCount).Select(reader.GetName).ToList()));
                    int count = 0;
                    while (reader.Read())
                    {
                        writer.WriteLine(string.Join("$", Enumerable.Range(0, reader.FieldCount).Select(reader.GetValue).ToList()));
                        if (++count % 100 == 0)
                        {
                            writer.Flush();
                        }
                    }
                }
                while (reader.NextResult());
                Response.ContentType = "application/txt";
                Response.AddHeader("content-disposition", "attachment; filename=DataExport_TaskFullfillment_Report" + "_" + DateTime.Now.ToString("ddMMyyyyhhmmss") + ".csv");

                Response.Write(writer.ToString());
                Response.Flush();
                Response.End();


            }
            else
            {

            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + Common.GetString(ex) + "',2);", true);
        }
    }
    #endregion

    #region Griedview Events

    protected void gvtask_PreRender(object sender, EventArgs e)
    {
        if (gvtask.Rows.Count > 0)
        {
            gvtask.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvtask.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }

    #endregion
}