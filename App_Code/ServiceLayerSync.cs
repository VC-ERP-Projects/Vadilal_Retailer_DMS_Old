using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Security;
using System.Security.Cryptography.X509Certificates;
using System.Web;

/// <summary>
/// Summary description for ServiceLayerSync
/// </summary>
public class ServiceLayerSync
{
    private static CookieCollection CookieData = new CookieCollection();
    public Dictionary<int, string> SAPGetToken(string GSTIN, string GSTID, string GSTPWD)
    {
        var result = this.Interact4("GET", GSTIN, GSTID, GSTPWD);
        return result;
    }

    public Dictionary<int, string> Interact4(string method, string GSTIN = "", string GSTID = "", string GSTPWD = "", string body = "", bool saveCookie = false)
    {
        Oledb_ConnectionClass objCon = new Oledb_ConnectionClass();
        Oledb_ConnectionClass objClass1 = new Oledb_ConnectionClass();
        SqlCommand Cmd = new SqlCommand();
        Cmd.Parameters.Clear();
        Cmd.CommandType = CommandType.StoredProcedure;
        Cmd.CommandText = "usp_GetEInvoiceLink";
        DataSet dsdata = objClass1.CommonFunctionForSelect(Cmd);
        var result = new Dictionary<int, string>();
        DataTable oRecordSet = new DataTable();
        oRecordSet = dsdata.Tables[0];

        // 1  oRecordSet = objCon.ByQueryReturnDataTable("Select * from Schema.\"@LICENSEMST\" where  \"Name\" = 'EI' ");
        if (oRecordSet.Rows.Count > 0)
        {
            var httpRequest = (HttpWebRequest)WebRequest.Create("" + oRecordSet.Rows[0]["U_AuthLink"].ToString() + "");
            httpRequest.Method = method.ToUpper();
            httpRequest.ServicePoint.Expect100Continue = false;
            httpRequest.ContentType = "application/json";
            httpRequest.Headers.Add("aspid", "" + Convert.ToString(oRecordSet.Rows[0]["U_Aspid"]) + "");
            httpRequest.Headers.Add("password", "" + Convert.ToString(oRecordSet.Rows[0]["U_AspPwd"]) + "");
            httpRequest.Headers.Add("Gstin", GSTIN);
            httpRequest.Headers.Add("user_name", GSTID);//"" + oRecordset.Fields.Item("U_User_nm").Value + "");
            httpRequest.Headers.Add("eInvPwd", GSTPWD); //"" + oRecordset.Fields.Item("U_EInvPwd").Value + "");

            ServicePointManager.ServerCertificateValidationCallback += RemoteSSLTLSCertificateValidate;

            if (!string.IsNullOrEmpty(body))
            {
                using (var requestStream = httpRequest.GetRequestStream())
                {
                    var writer = new StreamWriter(requestStream);
                    writer.Write(body);
                    writer.Close();
                }
            }

            try
            {
                var WebResponse = (HttpWebResponse)httpRequest.GetResponse();
                using (var response = new StreamReader(WebResponse.GetResponseStream()))
                {
                    result.Add(1, response.ReadToEnd());
                }
                if (saveCookie)
                {
                    CookieData = WebResponse.Cookies;
                }
            }
            catch (WebException ex)
            {
                using (var stream = ex.Response.GetResponseStream())
                using (var reader = new StreamReader(stream))
                {
                    result.Add(2, reader.ReadToEnd());
                }
            }
            catch (Exception ex)
            {
                result.Add(3, ex.ToString());
            }
        }
        return result;
    }

    public Dictionary<int, string> SAPAddToEInvoice(string Data, string Token, string GSTIN, string GSTID)
    {
        var result = this.Interact1("POST", Data, Token, "", false, GSTIN, GSTID);
        return result;
        }

    public Dictionary<int, string> Interact1(string method, string body = "", string Token = "", string Url = "", bool saveCookie = false, string GSTIN = "", string GSTID = "")
    {
        var result = new Dictionary<int, string>();
        DataTable oRecordSet;
        oRecordSet = new DataTable();
        Oledb_ConnectionClass objCon = new Oledb_ConnectionClass();
        Oledb_ConnectionClass objClass1 = new Oledb_ConnectionClass();
        SqlCommand Cmd = new SqlCommand();
        Cmd.Parameters.Clear();
        Cmd.CommandType = CommandType.StoredProcedure;
        Cmd.CommandText = "usp_GetEInvoiceLink";
        DataSet dsdata = objClass1.CommonFunctionForSelect(Cmd);
        oRecordSet = dsdata.Tables[0];

        var httpRequest = (HttpWebRequest)WebRequest.Create("" + oRecordSet.Rows[0]["U_PostLink"].ToString() + "" + Url);
        httpRequest.Method = method.ToUpper();
        httpRequest.ServicePoint.Expect100Continue = false;
        httpRequest.ContentType = "application/json";
        httpRequest.Headers.Add("aspid", "" + Convert.ToString(oRecordSet.Rows[0]["U_Aspid"]) + "");
        httpRequest.Headers.Add("password", "" + Convert.ToString(oRecordSet.Rows[0]["U_AspPwd"]) + "");
        httpRequest.Headers.Add("Gstin", GSTIN);
        httpRequest.Headers.Add("AuthToken", Token);
        httpRequest.Headers.Add("user_name", GSTID);//"" + oRecordset.Fields.Item("U_User_nm").Value + "");

        ServicePointManager.ServerCertificateValidationCallback += RemoteSSLTLSCertificateValidate;

        if (!string.IsNullOrEmpty(body))
        {
            using (var requestStream = httpRequest.GetRequestStream())
            {
                var writer = new StreamWriter(requestStream);
                writer.Write(body);
                writer.Close();
            }
        }

        try
        {
            var WebResponse = (HttpWebResponse)httpRequest.GetResponse();
            using (var response = new StreamReader(WebResponse.GetResponseStream()))
            {
                result.Add(1, response.ReadToEnd());
            }
            if (saveCookie)
            {
                CookieData = WebResponse.Cookies;
            }
        }
        catch (WebException ex)
        {
            using (var stream = ex.Response.GetResponseStream())
            using (var reader = new StreamReader(stream))
            {
                result.Add(2, reader.ReadToEnd());
            }
        }
        catch (Exception ex)
        {
            result.Add(3, ex.ToString());
        }
        return result;
    }


    public Dictionary<int, string> SAPGetIRN(string Data, string Token, string GSTIN, string GSTID)
    {
        string url = "";
        var result = this.Interact3("GET", Data, "", Token, url, false, GSTIN, GSTID);
        return result;
    }

    public Dictionary<int, string> Interact3(string method, string Data = "", string body = "", string Token = "", string Url = "", bool saveCookie = false, string GSTIN = "", string GSTID = "")
    {
        var result = new Dictionary<int, string>();
        System.Data.DataTable oRecordSet;
        oRecordSet = new System.Data.DataTable();
        Oledb_ConnectionClass objCon = new Oledb_ConnectionClass();
        Oledb_ConnectionClass objClass1 = new Oledb_ConnectionClass();
        SqlCommand Cmd = new SqlCommand();
        Cmd.Parameters.Clear();
        Cmd.CommandType = CommandType.StoredProcedure;
        Cmd.CommandText = "usp_GetEInvoiceLink";
        DataSet dsdata = objClass1.CommonFunctionForSelect(Cmd);
        oRecordSet = dsdata.Tables[0];

        var httpRequest = (HttpWebRequest)WebRequest.Create("" + oRecordSet.Rows[0]["U_PostLink"].ToString() + "/irn/" + Data);
        httpRequest.Method = method.ToUpper();
        httpRequest.ServicePoint.Expect100Continue = false;
        httpRequest.ContentType = "application/json";
        httpRequest.Headers.Add("aspid", "" + Convert.ToString(oRecordSet.Rows[0]["U_Aspid"]) + "");
        httpRequest.Headers.Add("password", "" + Convert.ToString(oRecordSet.Rows[0]["U_AspPwd"]) + "");
        httpRequest.Headers.Add("Gstin", GSTIN);
        httpRequest.Headers.Add("AuthToken", Token);
        httpRequest.Headers.Add("user_name", GSTID);

        ServicePointManager.ServerCertificateValidationCallback += RemoteSSLTLSCertificateValidate;

        if (!string.IsNullOrEmpty(body))
        {
            using (var requestStream = httpRequest.GetRequestStream())
            {
                var writer = new StreamWriter(requestStream);
                writer.Write(body);
                writer.Close();
            }
        }

        try
        {
            var WebResponse = (HttpWebResponse)httpRequest.GetResponse();
            using (var response = new StreamReader(WebResponse.GetResponseStream()))
            {
                result.Add(1, response.ReadToEnd());
            }
            if (saveCookie)
            {
                CookieData = WebResponse.Cookies;
            }
        }
        catch (WebException ex)
        {
            using (var stream = ex.Response.GetResponseStream())
            using (var reader = new StreamReader(stream))
            {
                result.Add(2, reader.ReadToEnd());
            }
        }
        catch (Exception ex)
        {
            result.Add(3, ex.ToString());
        }
        return result;
    }
    private static bool RemoteSSLTLSCertificateValidate(object sender, X509Certificate certificate, X509Chain chain, SslPolicyErrors sslPolicyErrors)
    {
        return true;
    }
}