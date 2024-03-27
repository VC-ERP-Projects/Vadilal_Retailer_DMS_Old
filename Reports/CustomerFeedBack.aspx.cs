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


public partial class CustomerFeedBack : System.Web.UI.Page
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

    private void ClearAllInputs()
    {
        txtFromDate.Text = txtToDate.Text = Common.DateTimeConvert(DateTime.Now);
        txtCode.Text = txtRegion.Text = txtfeedtakenby.Text = txtBeatEmp.Text = "";
    }

    #endregion

    #region Page Load

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        if (!IsPostBack)
        {
            ClearAllInputs();
        }
        ScriptManager scriptManager = ScriptManager.GetCurrent(this.Page);
        scriptManager.RegisterPostBackControl(this.btnGenerat);
    }

    #endregion


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
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Your session time out. Please login again.',2);", true);
                return;
            }

            Int32 SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;
            DateTime StartDate = Convert.ToDateTime(txtFromDate.Text);
            DateTime EndDate = Convert.ToDateTime(txtToDate.Text);
            Int32 RegionID = Int32.TryParse(txtRegion.Text.Split("-".ToArray()).Last().Trim(), out RegionID) ? RegionID : 0;
            Int32 BeatEmpID = Int32.TryParse(txtBeatEmp.Text.Split("-".ToArray()).Last().Trim(), out BeatEmpID) ? BeatEmpID : 0;
            Int32 FeedbackTakenByEmpID = Int32.TryParse(txtfeedtakenby.Text.Split("-".ToArray()).Last().Trim(), out FeedbackTakenByEmpID) ? FeedbackTakenByEmpID : 0;

            if (SUserID == 0 && RegionID == 0 && BeatEmpID == 0 && FeedbackTakenByEmpID == 0)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select at least one parameter.',3);ChangelabelFor();", true);
                return;
            }

            string UserCode;
            using (DDMSEntities ctx = new DDMSEntities())
            {
                UserCode = ctx.OEMPs.Where(x => x.EmpID == UserID && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault().ToString();
            }
            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();
            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "CustomerFeedbackReport";

            Cm.Parameters.AddWithValue("@ParentID", ParentID);
            Cm.Parameters.AddWithValue("@EmpID", UserID);
            Cm.Parameters.AddWithValue("@SUserID", SUserID);
            Cm.Parameters.AddWithValue("@FromDate", StartDate);
            Cm.Parameters.AddWithValue("@ToDate", EndDate);
            Cm.Parameters.AddWithValue("@BeatEmpID", BeatEmpID);
            Cm.Parameters.AddWithValue("@Type", ddlReport.SelectedValue);
            Cm.Parameters.AddWithValue("@FeedbackTakenByEmpID", FeedbackTakenByEmpID);
            Cm.Parameters.AddWithValue("@FeedbackOf", ddlFeedbackOf.SelectedValue);
            Cm.Parameters.AddWithValue("@RegionID", RegionID);

            Response.Clear();
            Response.Buffer = true;
            Response.ClearContent();
            IDataReader reader = objClass.CommonFunctionForSelectDR(Cm);
            StringWriter writer = new StringWriter();

            writer.WriteLine("Customer Feedback Report");
            writer.WriteLine("Report Option," + (ddlReport.SelectedItem));
            writer.WriteLine("Employee," + ((txtCode.Text.Split('-').Length > 2) ? txtCode.Text.Split('-')[0].ToString() + "-" + txtCode.Text.Split('-')[1].ToString() : (txtCode.Text.Split('-').Length > 0 && txtCode.Text != "" && SUserID > 0) ? txtCode.Text : "All"));
            writer.WriteLine("Feedback Taken By," + ((txtfeedtakenby.Text.Split('-').Length > 2) ? txtfeedtakenby.Text.Split('-')[0].ToString() + "-" + txtfeedtakenby.Text.Split('-')[1].ToString() : (txtfeedtakenby.Text.Split('-').Length > 0 && txtfeedtakenby.Text != "" && FeedbackTakenByEmpID > 0) ? txtfeedtakenby.Text : "All"));
            writer.WriteLine("Beat Employee," + ((txtBeatEmp.Text.Split('-').Length > 2) ? txtBeatEmp.Text.Split('-')[0].ToString() + "-" + txtBeatEmp.Text.Split('-')[1].ToString() : (txtBeatEmp.Text.Split('-').Length > 0 && txtBeatEmp.Text != "" && BeatEmpID > 0) ? txtBeatEmp.Text : "All"));
            writer.WriteLine("Feedback Of," + ddlFeedbackOf.SelectedItem.Text);
            if (ddlFeedbackOf.SelectedValue == "3")
                writer.WriteLine("Region of Dealer," + ((txtRegion.Text.Split('-').Length > 2) ? txtRegion.Text.Split('-')[0].ToString() + "-" + txtRegion.Text.Split('-')[1].ToString() : (txtRegion.Text.Split('-').Length > 0 && txtRegion.Text != "" && RegionID > 0) ? txtRegion.Text : "All"));
            if(ddlFeedbackOf.SelectedValue == "4")
                writer.WriteLine("Region of Super Stockist," + ((txtRegion.Text.Split('-').Length > 2) ? txtRegion.Text.Split('-')[0].ToString() + "-" + txtRegion.Text.Split('-')[1].ToString() : (txtRegion.Text.Split('-').Length > 0 && txtRegion.Text != "" && RegionID > 0) ? txtRegion.Text : "All"));
            if(ddlFeedbackOf.SelectedValue == "2")
                writer.WriteLine("Region of Distributor," + ((txtRegion.Text.Split('-').Length > 2) ? txtRegion.Text.Split('-')[0].ToString() + "-" + txtRegion.Text.Split('-')[1].ToString() : (txtRegion.Text.Split('-').Length > 0 && txtRegion.Text != "" && RegionID > 0) ? txtRegion.Text : "All"));
            
            writer.WriteLine("From Date ," + StartDate.ToString("dd/MM/yyyy") + "," + " To Date ," + EndDate.ToString("dd/MM/yyyy"));

            writer.WriteLine("User ID," + UserCode);
            writer.WriteLine("Run Date/Time," + DateTime.Now.ToString("dd/MM/yyyy hh:mm:ss tt"));
            writer.WriteLine("IP Address," + ((hdnIPAdd.Value == "undefined") ? "" : hdnIPAdd.Value));

            do
            {
                string ColumnName = string.Empty;
                if (ddlFeedbackOf.SelectedValue == "2")
                    ColumnName = string.Join(",", Enumerable.Range(0, reader.FieldCount).Select(reader.GetName).ToList()).Replace("CustomerName", "Distributor Name").Replace("CustomerCode", "Distributor Code");
                else if(ddlFeedbackOf.SelectedValue == "4")
                    ColumnName = string.Join(",", Enumerable.Range(0, reader.FieldCount).Select(reader.GetName).ToList()).Replace("CustomerName", "Super Stockiest Name").Replace("CustomerCode", "Super Stockiest Code");
                else
                    ColumnName = string.Join(",", Enumerable.Range(0, reader.FieldCount).Select(reader.GetName).ToList()).Replace("CustomerName", "Dealer Name").Replace("CustomerCode", "Dealer Code").Replace("Current Parent Name", "Current Distributor Name").Replace("Current Parent Code", "Current Dist.Code");
                
                writer.WriteLine(ColumnName);
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

            Response.AddHeader("content-disposition", "attachment; filename=Customer Feedback Report" + "_" + DateTime.Now.ToString("ddMMyyyyhhmmss") + ".csv");
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