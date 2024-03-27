using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Reports_AttendenceDetails : System.Web.UI.Page
{
    #region Decalration

    protected int UserID;
    protected decimal ParentID;

    #endregion

    public void ValidateUser()
    {
        if (Session["UserID"] != null && Session["ParentID"] != null &&
         Int32.TryParse(Session["UserID"].ToString(), out UserID) && Decimal.TryParse(Session["ParentID"].ToString(), out ParentID))
        {
        }
        else
        {
            Response.Redirect("~/Login.aspx");
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        if (!IsPostBack)
        {
            try
            {
                if (Request.QueryString["EntryID"] != null && Request.QueryString["EntryID"] != "")
                {

                    int EntryNo = Convert.ToInt32(Request.QueryString["EntryID"].ToString());
                    using (DDMSEntities ctx = new DDMSEntities())
                    {
                        OENT objOENT = ctx.OENTs.FirstOrDefault(x => x.ParentID == ParentID && x.EntryID == EntryNo);

                        txtFromDate.Text = Common.DateTimeConvert(objOENT.InDate);
                        txtCode.Text = objOENT.OEMP.EmpCode + " # " + objOENT.OEMP.Name;

                        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
                        SqlCommand Cm = new SqlCommand();
                        Cm.Parameters.Clear();
                        Cm.CommandType = CommandType.StoredProcedure;
                        Cm.CommandText = "GetAttendenceDetail";

                        Cm.Parameters.AddWithValue("@ParentID", ParentID);
                        Cm.Parameters.AddWithValue("@EntryID", EntryNo);
                        DataSet ds = objClass.CommonFunctionForSelect(Cm);
                        gvDetail.DataSource = ds.Tables[0];
                        gvDetail.DataBind();

                        gvData.DataSource = ds.Tables[1];
                        gvData.DataBind();
                    }
                }
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + Common.GetString(ex) + "',2);", true);
            }
        }
    }
    protected void gvDetail_PreRender(object sender, EventArgs e)
    {
        if (gvDetail.Rows.Count > 0)
        {
            gvDetail.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvDetail.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }
}