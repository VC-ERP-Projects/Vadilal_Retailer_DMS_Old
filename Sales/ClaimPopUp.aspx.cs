using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Sales_ClaimPopUp : System.Web.UI.Page
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
                if (Request.QueryString["customerid"] != null && Request.QueryString["customerid"] != "")
                {

                    int parentclaimid = Convert.ToInt32(Request.QueryString["parentclaimid"].ToString());
                    decimal customerid = Convert.ToDecimal(Request.QueryString["customerid"].ToString());

                    using (DDMSEntities ctx = new DDMSEntities())
                    {
                        OCLMRQ objOCMLRQ = ctx.OCLMRQs.FirstOrDefault(x => x.ParentClaimID == parentclaimid && x.CustomerID == customerid);
                        lblCustomer.Text = "Customer : " + ctx.OCRDs.Where(x => x.CustomerID == objOCMLRQ.CustomerID).Select(x => x.CustomerCode + " # " + x.CustomerName).FirstOrDefault();
                        lblAppMode.Text = "Reason : " + ctx.ORSNs.Where(x => x.SAPReasonItemCode == objOCMLRQ.ReasonCode).Select(x => x.SAPReasonItemCode + " # " + x.ReasonName).FirstOrDefault();
                        lblMonth.Text = "Claim Month : " + objOCMLRQ.FromDate.ToString("MM/yyyy");
                        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
                        SqlCommand Cm = new SqlCommand();
                        Cm.Parameters.Clear();
                        Cm.CommandType = CommandType.StoredProcedure;
                        Cm.CommandText = "GetClaimPopDetail";
                        Cm.Parameters.AddWithValue("@ParentClaimID", parentclaimid);
                        Cm.Parameters.AddWithValue("@CustomerID", customerid);
                        DataSet ds = objClass.CommonFunctionForSelect(Cm);
                        gvCommon.DataSource = ds.Tables[0];
                        gvCommon.DataBind();
                    }
                }
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + Common.GetString(ex) + "',2);", true);
            }
        }
    }

    protected void gvCommon_PreRender(object sender, EventArgs e)
    {
        if (gvCommon.Rows.Count > 0)
        {
            gvCommon.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvCommon.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }
}