<%@ WebHandler Language="C#" Class="ImageHandler" %>

using System;
using System.Web;
using System.Linq;

public class ImageHandler : IHttpHandler
{

    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "text/plain";
        try
        {
            string subPath = "~/Document/MsgBroadcastUpload/"; // your code goes here

            bool exists = System.IO.Directory.Exists(HttpContext.Current.Server.MapPath(subPath));

            if (!exists)
                System.IO.Directory.CreateDirectory(HttpContext.Current.Server.MapPath(subPath));
            string str = context.Request["messageid"];
            int msgid = Convert.ToInt32(str);
            string fileName = "";
            foreach (string s in context.Request.Files)
            {
                HttpPostedFile file = context.Request.Files[s];
                fileName = file.FileName;
                string fileExtension = file.ContentType;

                if (!string.IsNullOrEmpty(fileName))
                {
                    fileExtension = System.IO.Path.GetExtension(fileName);
                    string ext = System.IO.Path.GetExtension(file.FileName);
                    if (ext.ToLower() == ".jpg" || ext.ToLower() == ".png" || ext.ToLower() == ".gif" || ext.ToLower() == ".jpeg" || ext.ToLower() == ".pdf")
                    {
                        using (DDMSEntities ctx = new DDMSEntities())
                        {
                            // remove from folder
                            var objOMSG = ctx.OMSGs.Where(a => a.MessageID == msgid).FirstOrDefault();
                            if (!string.IsNullOrEmpty(objOMSG.ImageUpload))
                            {
                                string filePath = HttpContext.Current.Server.MapPath("~/Document/MsgBroadcastUpload/") + objOMSG.ImageUpload;
                                if (System.IO.File.Exists(filePath))
                                {
                                    System.IO.File.Delete(filePath);
                                }
                            }
                            fileName = System.IO.Path.Combine(Guid.NewGuid().ToString("N") + System.IO.Path.GetExtension(file.FileName));
                            file.SaveAs(HttpContext.Current.Server.MapPath("~/Document/MsgBroadcastUpload/") + fileName);
                            //Paths.Add(1, HttpContext.Current.Request.Url.GetLeftPart(UriPartial.Authority) + HttpContext.Current.Request.ApplicationPath + "/Document/MsgBroadcastUpload/" + fileName);


                            objOMSG.ImageUpload = fileName;
                            objOMSG.UpdatedDate = DateTime.Now;
                            ctx.SaveChanges();
                        }
                        return;
                    }
                    else
                    {
                        return;
                    }
                }
            }
            return;
        }
        catch (Exception ac)
        {
            return;
        }
    }

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }

}