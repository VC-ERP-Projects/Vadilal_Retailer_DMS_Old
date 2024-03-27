using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Data.OleDb;
using System.IO;
using System.Configuration;
using System.Data.SqlClient;
using System.Transactions;
using System.Collections.Specialized;
using System.Net;
using System.Data.Entity.Validation;
using System.Data.EntityClient;

public partial class MyAccount_Imagename : System.Web.UI.Page
{
    DDMSEntities ctx;
    #region pageload
    protected void Page_Load(object sender, EventArgs e)
    {
        ctx = new DDMSEntities();
        ScriptManager scriptManager = ScriptManager.GetCurrent(this.Page);
        scriptManager.RegisterPostBackControl(btnCDwonload);
        scriptManager.RegisterPostBackControl(btnCUpload);
    }
    #endregion

    #region Button_Click
    protected void btnCUpload_Click(object sender, EventArgs e)
    {
        if (flCUpload.HasFile)
        {
            
            try
            {

                string fileName = Path.GetFileName(flCUpload.FileName);
                string fname = Path.GetFileNameWithoutExtension(flCUpload.FileName);

                string serverPath = Server.MapPath("~/Document/UploadedFiles/Images");

                if (!Directory.Exists(serverPath))
                {
                    Directory.CreateDirectory(serverPath);  
                }

                string destinationPath = Path.Combine(serverPath, fileName);
                flCUpload.SaveAs(destinationPath);

                string ext = Path.GetExtension(flCUpload.PostedFile.FileName);
                if (ext.ToLower() == ".jpg")
                {

                    var objOITM = ctx.OITMs.FirstOrDefault(x => x.ItemCode == fname);

                            if (objOITM != null)
                            {
                                string conString = System.Configuration.ConfigurationManager.ConnectionStrings["DDMSEntities"].ConnectionString;   
                                EntityConnection entityConnection = new EntityConnection(conString);
                                string sqlConn = entityConnection.StoreConnection.ConnectionString;                               
                                string query = "update OITM set Image=" + fname + " where ItemCode =" + fname + "";
                                SqlConnection con = new SqlConnection(sqlConn);
                                if (con.State == System.Data.ConnectionState.Closed)
                                {
                                    con.Open();
                                }
                                SqlCommand cmd = new SqlCommand();
                                cmd.CommandType = CommandType.Text;
                                cmd.CommandText = query;
                                cmd.Connection = con;
                                cmd.ExecuteNonQuery();
                                ctx.SaveChanges();
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Process completed.',1);", true);
                            }                            
                    }          
            }

            catch(Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
            }
            ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('File format must be a jpg.',3);", true);          
        }
    }
    #endregion

}
