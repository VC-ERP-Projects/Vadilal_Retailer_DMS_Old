using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;


public partial class Popup : System.Web.UI.Page
{

    #region Declaration

    #endregion

    #region PageLoad

    protected void Page_Load(object sender, EventArgs e)
    {
        try
        {
            var CustomerID = Request.QueryString["CustomerID"].ToString();
            DateTime FromDate = Common.DateTimeConvert(Request.QueryString["FromDate"].ToString());
            DateTime Todate = Common.DateTimeConvert(Request.QueryString["ToDate"].ToString());
            int DisCust = Convert.ToInt32(Request.QueryString["DisCust"].ToString());

            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();

            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "GetDetailDealerSummary";

            Cm.Parameters.AddWithValue("@FromDate", FromDate);
            Cm.Parameters.AddWithValue("@ToDate", Todate);
            Cm.Parameters.AddWithValue("@CustomerID", CustomerID);
            Cm.Parameters.AddWithValue("@DisCust", DisCust);

            DataSet ds = objClass.CommonFunctionForSelect(Cm);
            gvDelearSummary.DataSource = ds.Tables[0];
            gvDelearSummary.DataBind();

        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + Common.GetString(ex) + "',2);", true);
        }



    }

    #endregion

    #region Griedview Events

    protected void gvDelearSummary_PreRender(object sender, EventArgs e)
    {
        if (gvDelearSummary.Rows.Count > 0)
        {
            gvDelearSummary.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvDelearSummary.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }

    public override void VerifyRenderingInServerForm(Control control)
    {
        /* Confirms that an HtmlForm control is rendered for the specified ASP.NET
           server control at run time. */
    }

    #endregion

    #region Button Events

    protected void btnExport_Click(object sender, EventArgs e)
    {
        Response.Clear();
        Response.Buffer = true;
        Response.ClearContent();
        Response.ClearHeaders();
        Response.Charset = "";
        string FileName = "GrossDetailDealerSummary" + DateTime.Now + ".xls";
        StringWriter strwritter = new StringWriter();
        HtmlTextWriter htmltextwrtter = new HtmlTextWriter(strwritter);
        Response.Cache.SetCacheability(HttpCacheability.NoCache);
        Response.ContentType = "application/vnd.ms-excel";
        Response.AddHeader("Content-Disposition", "attachment;filename=" + FileName);
        gvDelearSummary.GridLines = GridLines.Both;
        gvDelearSummary.RenderControl(htmltextwrtter);
        Response.Write(strwritter.ToString());
        Response.End();
    }

    #endregion

}