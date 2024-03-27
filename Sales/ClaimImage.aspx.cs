using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Net;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Sales_ClaimImage : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            if (Request.QueryString["IsDownload"].ToString() == "0")
            {
                BindGrid();
            }
            else
            {

                string ClaimId = Request.QueryString["ClaimId"].ToString();
                string ParentId = Request.QueryString["ParentId"].ToString();

                // Write the file to the Response
                const int bufferLength = 10000;
                byte[] buffer = new Byte[bufferLength];
                int length = 0;
                Stream download = null;
                try
                {
                    Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
                    SqlCommand Cm = new SqlCommand();

                    Cm.Parameters.Clear();
                    Cm.CommandType = CommandType.StoredProcedure;
                    Cm.CommandText = "usp_GetClaimDocmentForDownload";
                    Cm.Parameters.AddWithValue("@ParentId", ParentId);
                    Cm.Parameters.AddWithValue("@ParentClaimId", ClaimId);
                    DataSet ds = objClass.CommonFunctionForSelect(Cm);
                    if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                    {
                        for (int i = 0; i < ds.Tables[0].Rows.Count; i++)
                        {

                            string filePath1 = System.Web.Hosting.HostingEnvironment.MapPath(@"~/Document/ClaimDocument/" );
                            string fname;
                            //+ ds.Tables[0].Rows[i]["ImageName"].ToString()
                            fname = ds.Tables[0].Rows[i]["ImageName"].ToString();
                             
                            if (fname != string.Empty)
                            {
                                WebClient req = new WebClient();
                                HttpResponse response = HttpContext.Current.Response;
                                string filePath = Path.Combine(filePath1, fname);
                                response.Clear();
                                response.ClearContent();
                                response.ClearHeaders();
                                response.Buffer = true;
                                response.AddHeader("Content-Disposition", "attachment;filename=" + fname);
                                byte[] data = req.DownloadData(filePath);
                                response.BinaryWrite(data);
                                response.End();
                            }
                            //Response.ContentType = "application/pdf";
                            //Response.AppendHeader("Content-Disposition", "attachment; filename=MyFile.pdf");
                            //Response.TransmitFile(Server.MapPath("~/Document/ClaimDocument/" + ds.Tables[0].Rows[i]["ImageName"]));
                            //Response.End();
                            //Response.ContentType = "application/pdf";
                            //Response.AppendHeader("Content-Disposition", "attachment; filename=MyFile.pdf");
                            //download = new FileStream(Server.MapPath("~/Document/ClaimDocument/" + ds.Tables[0].Rows[i]["ImageName"]),
                            //                                         FileMode.Open,
                            //                                         FileAccess.Read);


                            //do
                            //{
                            //    if (Response.IsClientConnected)
                            //    {
                            //        length = download.Read(buffer, 0, bufferLength);
                            //        Response.OutputStream.Write(buffer, 0, length);
                            //        buffer = new Byte[bufferLength];
                            //    }
                            //    else
                            //    {
                            //        length = -1;
                            //    }
                            //}
                            //while (length > 0);
                            //Response.Flush();
                            //Response.End();

                        }
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "$.colorbox.close();", true);

                    }
                }
                finally
                {
                    if (download != null)
                        download.Close();
                }
            }
        }
    }
    private void BindGrid()
    {
        string ClaimId = Request.QueryString["ClaimId"].ToString();
        string ParentId = Request.QueryString["ParentId"].ToString();
        int IsParentClaim = int.TryParse(Request.QueryString["IsParentClaim"].ToString(), out IsParentClaim) ? IsParentClaim : 0;
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();
        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "ClaimImageList";
        Cm.Parameters.AddWithValue("@ParentId", ParentId);
        Cm.Parameters.AddWithValue("@ClaimId", ClaimId);
        Cm.Parameters.AddWithValue("@IsParentClaim", IsParentClaim);
        DataSet Ds = objClass.CommonFunctionForSelect(Cm);
        if (Ds.Tables.Count > 0)
        {
            if (Ds.Tables[0].Rows.Count > 0)
            {
                rptImage.DataSource = Ds.Tables[0];
                rptImage.DataBind();
            }

        }
        else
        {
            rptImage.DataSource = null;
            rptImage.DataBind();
        }

    }
}