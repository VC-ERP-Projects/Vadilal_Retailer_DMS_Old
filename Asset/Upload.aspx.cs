using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Asset_Upload : System.Web.UI.Page
{
    int LineID = 0;
    string UType = "";

    protected void Page_Load(object sender, EventArgs e)
    {
        if (Request.QueryString["LineID"] != null && Int32.TryParse(Request.QueryString["LineID"].ToString(), out LineID)
            && Request.QueryString["Type"] != null)
        {
            UType = Request.QueryString["Type"].ToString();
        }
    }

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        try
        {
            if (flUpload.PostedFile != null && flUpload.PostedFile.ContentLength > 0)
            {
                string newFile = Guid.NewGuid().ToString("N") + Path.GetExtension(flUpload.PostedFile.FileName);
                if (flUpload.PostedFile.ContentLength < 1024000)
                {
                    if (Session["AstConf"] != null)
                    {
                        List<AstConf> lstASTCF = Session["AstConf"] as List<AstConf>;

                        if (lstASTCF != null)
                        {
                            var dir = Path.GetTempPath();
                            if (lstASTCF.Count > 0)
                            {
                                if (!String.IsNullOrEmpty(lstASTCF[LineID].AttachFileName))
                                {
                                    if (File.Exists(Path.Combine(dir, flUpload.FileName)))
                                    {
                                        File.Delete(Path.Combine(dir, flUpload.FileName));
                                    }
                                }
                            }
                            string SavePath = Path.Combine(dir, newFile);
                            flUpload.SaveAs(SavePath);
                            lstASTCF[LineID].AttachFileName = newFile;
                            this.ClientScript.RegisterClientScriptBlock(this.GetType(), "size", "parent.$.colorbox.close();", true);
                        }
                    }
                }
                else
                {
                    ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "size", "ModelMsg('File size is greater than 1MB!',3);", true);
                    return;
                }
            }
            else
            {
                ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "size", "ModelMsg('Upload File!',3);", true);
                return;
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }
}