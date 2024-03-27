using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Objects.SqlClient;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Task_TaskStatus : System.Web.UI.Page
{
    #region Declaration

    protected int UserID;
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
                int CustType = Convert.ToInt32(Session["Type"]);
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

                    UserName = ctx.OEMPs.Where(x => x.EmpID == UserID && x.ParentID == ParentID).Select(x => x.EmpCode + "," + x.Name).FirstOrDefault().ToString();
                    if (Session["Lang"] != null && Session["Lang"].ToString() == "gujarati")
                    {
                        try
                        {
                            var xml = XDocument.Load(Server.MapPath("../Document/forlanguage.xml"));
                            var unit = xml.Descendants("employee_master");
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
        ScriptManager scriptManager = ScriptManager.GetCurrent(this.Page);
        scriptManager.RegisterPostBackControl(this.btnExport);
        hdnLoginUserID.Value = UserID.ToString();

        if (!IsPostBack)
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                var Status = ctx.OTSTs.Where(x => x.Active).ToList();
                ddlStatus.DataSource = Status;
                ddlStatus.DataBind();
                ddlStatus.Items.Insert(0, new ListItem("---Select---", "0"));
            }
            txtToDate.Text = txtFromDate.Text = Common.DateTimeConvert(DateTime.Now);

            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();
            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "MECH_GetTaskStatus";
            Cm.Parameters.AddWithValue("@ParentID", ParentID);
            Cm.Parameters.AddWithValue("@UserID", UserID);
            DataSet ds = objClass.CommonFunctionForSelect(Cm);
            if (ds.Tables.Count > 0)
            {
                if (ds.Tables[0].Rows.Count > 0)
                {
                    PMO.Text = ds.Tables[0].Rows[0][1].ToString() + " : " + ds.Tables[0].Rows[0][2].ToString();
                    PMA.Text = ds.Tables[0].Rows[1][1].ToString() + " : " + ds.Tables[0].Rows[1][2].ToString();
                    PMR.Text = ds.Tables[0].Rows[2][1].ToString() + " : " + ds.Tables[0].Rows[2][2].ToString();
                    PMP.Text = ds.Tables[0].Rows[3][1].ToString() + " : " + ds.Tables[0].Rows[3][2].ToString();
                    PMRA.Text = ds.Tables[0].Rows[4][1].ToString() + " : " + ds.Tables[0].Rows[4][2].ToString();
                    PMI.Text = ds.Tables[0].Rows[5][1].ToString() + " : " + ds.Tables[0].Rows[5][2].ToString();
                    PMC.Text = ds.Tables[0].Rows[6][1].ToString() + " : " + ds.Tables[0].Rows[6][2].ToString();
                }
                if (ds.Tables[1].Rows.Count > 0)
                {
                    BMO.Text = ds.Tables[1].Rows[0][1].ToString() + " : " + ds.Tables[1].Rows[0][2].ToString();
                    BMA.Text = ds.Tables[1].Rows[1][1].ToString() + " : " + ds.Tables[1].Rows[1][2].ToString();
                    BMR.Text = ds.Tables[1].Rows[2][1].ToString() + " : " + ds.Tables[1].Rows[2][2].ToString();
                    BMP.Text = ds.Tables[1].Rows[3][1].ToString() + " : " + ds.Tables[1].Rows[3][2].ToString();
                    BMRA.Text = ds.Tables[1].Rows[4][1].ToString() + " : " + ds.Tables[1].Rows[4][2].ToString();
                    BMI.Text = ds.Tables[1].Rows[5][1].ToString() + " : " + ds.Tables[1].Rows[5][2].ToString();
                    BMC.Text = ds.Tables[1].Rows[6][1].ToString() + " : " + ds.Tables[1].Rows[6][2].ToString();
                }
                if (ds.Tables[2].Rows.Count > 0)
                {
                    AMO.Text = ds.Tables[2].Rows[0][1].ToString() + " : " + ds.Tables[2].Rows[0][2].ToString();
                    AMA.Text = ds.Tables[2].Rows[1][1].ToString() + " : " + ds.Tables[2].Rows[1][2].ToString();
                    AMR.Text = ds.Tables[2].Rows[2][1].ToString() + " : " + ds.Tables[2].Rows[2][2].ToString();
                    AMP.Text = ds.Tables[2].Rows[3][1].ToString() + " : " + ds.Tables[2].Rows[3][2].ToString();
                    AMRA.Text = ds.Tables[2].Rows[4][1].ToString() + " : " + ds.Tables[2].Rows[4][2].ToString();
                    AMI.Text = ds.Tables[2].Rows[5][1].ToString() + " : " + ds.Tables[2].Rows[5][2].ToString();
                    AMC.Text = ds.Tables[2].Rows[6][1].ToString() + " : " + ds.Tables[2].Rows[6][2].ToString();
                }
            }
        }
    }

    protected void gvTaskDetail_PreRender(object sender, EventArgs e)
    {

    }
    #endregion

    #region Button_Click

    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<dynamic> GetTaskDetails(string strFromDate, string strToDate, string TAGID, string CustId, string MechanicId, string UserId)
    {
        List<dynamic> result = new List<dynamic>();
        try
        {
            DateTime FromDate, ToDate;
            if (string.IsNullOrEmpty(strFromDate) || string.IsNullOrEmpty(strToDate))
            {
                FromDate = Convert.ToDateTime("01/01/2001");
                ToDate = Convert.ToDateTime(DateTime.Now);
            }
            else
            {
                FromDate = Convert.ToDateTime(strFromDate);
                ToDate = Convert.ToDateTime(strToDate);
            }
            Decimal CustID = Decimal.TryParse(CustId, out CustID) ? CustID : 0;
            Int32 MechEmpID = Int32.TryParse(MechanicId, out MechEmpID) ? MechEmpID : 0;
            Int32 LoginUserID = Int32.TryParse(UserId, out LoginUserID) ? LoginUserID : 0;

            Decimal ParentId = 1000010000000000;
            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();
            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "MECH_GetTaskStatusDetail";
            Cm.Parameters.AddWithValue("@ParentID", ParentId);
            Cm.Parameters.AddWithValue("@EmpID", LoginUserID);
            Cm.Parameters.AddWithValue("@SUserID", MechEmpID);
            Cm.Parameters.AddWithValue("@FromDate", FromDate);
            Cm.Parameters.AddWithValue("@ToDate", ToDate);
            Cm.Parameters.AddWithValue("@TAGID", TAGID.Trim());
            Cm.Parameters.AddWithValue("@MechanicID", MechEmpID);
            Cm.Parameters.AddWithValue("@CustID", CustID);
            Cm.Parameters.AddWithValue("@IsExport", 0);

            DataSet ds = objClass.CommonFunctionForSelect(Cm);
            DataTable dt;

            if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
            {
                dt = ds.Tables[0];
                result.Add(JsonConvert.SerializeObject(dt));
            }
            else
                result.Add("ERROR=No Result Found.");
        }
        catch (Exception ex)
        {
            result.Add("ERROR=" + "" + Common.GetString(ex));
        }
        return result;
    }

    protected void btnExport_Click(object sender, EventArgs e)
    {
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                string TAGID = hdnTaskType.Value + ddlStatus.SelectedValue;
                string CustID = !string.IsNullOrEmpty(txtCustCode.Text) ? txtCustCode.Text.Split("-".ToArray()).Last() : "0";
                string MechEmpID = !string.IsNullOrEmpty(txtCode.Text) ? txtCode.Text.Split("-".ToArray()).Last() : "0";

                DateTime FromDate = Convert.ToDateTime(txtFromDate.Text);
                DateTime ToDate = Convert.ToDateTime(txtToDate.Text);
                Decimal ParentId = 1000010000000000;
                Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
                SqlCommand Cm = new SqlCommand();
                Cm.Parameters.Clear();
                Cm.CommandType = CommandType.StoredProcedure;
                Cm.CommandText = "MECH_GetTaskStatusDetail";
                Cm.Parameters.AddWithValue("@ParentID", ParentId);
                Cm.Parameters.AddWithValue("@EmpID", UserID);
                Cm.Parameters.AddWithValue("@SUserID", MechEmpID);
                Cm.Parameters.AddWithValue("@FromDate", FromDate);
                Cm.Parameters.AddWithValue("@ToDate", ToDate);
                Cm.Parameters.AddWithValue("@TAGID", TAGID.Trim());
                Cm.Parameters.AddWithValue("@MechanicID", MechEmpID);
                Cm.Parameters.AddWithValue("@CustID", CustID);
                Cm.Parameters.AddWithValue("@IsExport", 1);

                Response.Clear();
                Response.Buffer = true;
                Response.ClearContent();
                IDataReader reader = objClass.CommonFunctionForSelectDR(Cm);
                StringWriter writer = new StringWriter();

                writer.WriteLine("Task Status Report,");
                writer.WriteLine("Task Type ," + txtTaskType.Text + ",");
                writer.WriteLine("From Date ," + "'" + txtFromDate.Text + ",");
                writer.WriteLine("To Date ," + txtToDate.Text);
                writer.WriteLine("Task Status ," + ddlStatus.SelectedItem.Text);
                writer.WriteLine("Employee/ Mechanic ," + (MechEmpID != "0" ? txtCode.Text.Split('-')[0].ToString() + " - " + txtCode.Text.Split('-')[1].ToString() : "All Mechanic Employee"));
                writer.WriteLine("Customer ," + (CustID != "0" ? txtCustCode.Text.Split('-')[0].ToString() + " - " + txtCustCode.Text.Split('-')[1].ToString() : "All Customer"));
                writer.WriteLine("User ," + UserName);
                writer.WriteLine("Created On ," + "'" + DateTime.Now);

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

                Response.AddHeader("content-disposition", "attachment; filename=TaskStatus_" + DateTime.Now.ToString("ddMMyyyyhhmmss") + ".csv");
                Response.ContentType = "application/txt";
                Response.Write(writer.ToString());
                Response.Flush();
                Response.End();
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + Common.GetString(ex) + "',2);", true);

        }
    }

    #endregion

}