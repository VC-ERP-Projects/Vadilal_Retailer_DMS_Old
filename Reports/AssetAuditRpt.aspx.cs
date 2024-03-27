using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Reports_AssetAuditRpt : System.Web.UI.Page
{
    #region Declaration

    protected int UserID = 0;
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
        txtFromDate.Text = txtToDate.Text = Common.DateTimeConvert(DateTime.Now);
        //gvtaskstatus.DataSource = null;
        //gvtaskstatus.DataBind();
    }

    #endregion 
    #region Page load
    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();

        if (!IsPostBack)
        {
            ClearAllInputes();
            using (DDMSEntities ctx = new DDMSEntities())
            {
                var Status = ctx.OTSTs.Where(x => x.Active).ToList();
                ddlStatus.DataSource = Status;
                ddlStatus.DataBind();
                ddlStatus.Items.Insert(0, new ListItem("All", "0"));
            }
            hdnLoginUserID.Value = UserID.ToString();
            ScriptManager scriptManager = ScriptManager.GetCurrent(this.Page);
            scriptManager.RegisterPostBackControl(this.btnExport);
        }
    }
    #endregion
    #region Button_Click

    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<dynamic> GetAssetAuditDetails(string strFromDate, string strToDate, string TAGID, string AssetId, string MechanicId, string UserId, string CustomerCode)//, string UserId
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
            using (DDMSEntities ctx = new DDMSEntities())
            {
                
                Int32 AssetID;
                if (AssetId == "")
                {
                    AssetID = 0;
                }
                else
                {
                    OAST ObjAst = ctx.OASTs.FirstOrDefault(x => x.SerialNumber == AssetId);
                    AssetID = Int32.TryParse(ObjAst.AssetID.ToString(), out AssetID) ? AssetID : 0;
                }
                Decimal CustID = Decimal.TryParse(CustomerCode, out CustID) ? CustID : 0;
                //Int32 AssetID = Int32.TryParse(ObjAst.AssetID.ToString(), out AssetID) ? AssetID : 0;
                Int32 MechEmpID = Int32.TryParse(MechanicId, out MechEmpID) ? MechEmpID : 0;
                Int32 LoginUserID = Int32.TryParse(UserId, out LoginUserID) ? LoginUserID : 0;
                //Int32 LoginUserID = 1576;

            Decimal ParentId = 1000010000000000;
            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();
            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "GetTaskAuditAssetReport";
            Cm.Parameters.AddWithValue("@ParentID", ParentId);
            Cm.Parameters.AddWithValue("@EmpID", LoginUserID);//LoginUserID "1576"
            Cm.Parameters.AddWithValue("@SUserID", MechEmpID);
            Cm.Parameters.AddWithValue("@FromDate", FromDate);
            Cm.Parameters.AddWithValue("@ToDate", ToDate);
            Cm.Parameters.AddWithValue("@TAGID",TAGID.Trim());
            Cm.Parameters.AddWithValue("@MechanicID", MechEmpID);
            Cm.Parameters.AddWithValue("@AssetId", AssetID);
            Cm.Parameters.AddWithValue("@IsExport", 0);
            Cm.Parameters.AddWithValue("@CustID", CustID);

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
                string UserId = Session["UserID"].ToString();
                string TAGID = ddlTaskType.SelectedValue.ToString() + ddlStatus.SelectedValue;
                //string AssetID = !string.IsNullOrEmpty(txtAssetSerialNo) ? txtAssetSerialNo.Text.Split("/".ToArray()).First() : "0";                 
                string MechEmpID = !string.IsNullOrEmpty(txtCode.Text) ? txtCode.Text.Split("-".ToArray()).Last() : "0";
                string CustID = !string.IsNullOrEmpty(txtDealerCode.Text) ? txtDealerCode.Text.Split("-".ToArray()).Last() : "0";
                Int32 LoginUserID = Int32.TryParse(UserId, out LoginUserID) ? LoginUserID : 0;
                string AssetID = !string.IsNullOrEmpty(txtAssetSerialNo.Text) ? txtAssetSerialNo.Text.Split("-".ToArray()).Last() : "0";
               Int32 AssetId;
                if (AssetID == "0")
                {
                    AssetId = 0;
                }
                else
                {
                    OAST ObjAst = ctx.OASTs.FirstOrDefault(x => x.SerialNumber == AssetID);
                    AssetId = Int32.TryParse(ObjAst.AssetID.ToString(), out AssetId) ? AssetId : 0;
                }
                
                DateTime FromDate = Convert.ToDateTime(txtFromDate.Text);
                DateTime ToDate = Convert.ToDateTime(txtToDate.Text);
                Decimal ParentId = 1000010000000000;
                Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
                SqlCommand Cm = new SqlCommand();
                Cm.Parameters.Clear();
                Cm.CommandType = CommandType.StoredProcedure;
                Cm.CommandText = "GetTaskAuditAssetReport";
                Cm.Parameters.AddWithValue("@ParentID", ParentId);
                Cm.Parameters.AddWithValue("@EmpID", LoginUserID);//LoginUserID "1576"
                Cm.Parameters.AddWithValue("@SUserID", MechEmpID);
                Cm.Parameters.AddWithValue("@FromDate", FromDate);
                Cm.Parameters.AddWithValue("@ToDate", ToDate);
                Cm.Parameters.AddWithValue("@TAGID", TAGID.Trim());
                Cm.Parameters.AddWithValue("@MechanicID", MechEmpID);
                Cm.Parameters.AddWithValue("@AssetId", AssetId);
                Cm.Parameters.AddWithValue("@IsExport", 1);
                Cm.Parameters.AddWithValue("@CustID", CustID);
                Response.Clear();
                Response.Buffer = true;
                Response.ClearContent();
                IDataReader reader = objClass.CommonFunctionForSelectDR(Cm);
                StringWriter writer = new StringWriter();

                writer.WriteLine("Task Status Report,");
                writer.WriteLine("Task Type ," + ddlTaskType.SelectedItem.ToString() + ",");
                writer.WriteLine("From Date ," + "'" + txtFromDate.Text + ",");
                writer.WriteLine("To Date ," + txtToDate.Text);
                writer.WriteLine("Task Status ," + ddlStatus.SelectedItem.Text);
                //writer.WriteLine("Employee/ Mechanic ," + (MechEmpID != "0" ? txtCode.Text.Split('-')[0].ToString() + " - " + txtCode.Text.Split('-')[1].ToString() : "All Mechanic Employee"));
                writer.WriteLine("Customer ," + (CustID != "0" ? txtDealerCode.Text.Split('-')[0].ToString() + " - " + txtDealerCode.Text.Split('-')[1].ToString() : "All Customer"));
                writer.WriteLine("Asset Serial Number  ," + (AssetID != "0" ? txtAssetSerialNo.Text.Split('-')[0].ToString() + " - " + txtAssetSerialNo.Text.Split('-')[1].ToString() : "All Assest"));
                //writer.WriteLine("User ," + UserName);
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

                Response.AddHeader("content-disposition", "attachment; filename=AuditAssetStatus_" + DateTime.Now.ToString("ddMMyyyyhhmmss") + ".csv");
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