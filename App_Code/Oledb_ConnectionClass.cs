using System;
using System.Data;
using System.Configuration;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Data.SqlClient;
using System.Collections;
using System.Data.EntityClient;

public class Oledb_ConnectionClass
{
    #region Common Varialble

    static string connectString = System.Configuration.ConfigurationManager.ConnectionStrings["DDMSEntities"].ToString();
    static public EntityConnectionStringBuilder Builder = new EntityConnectionStringBuilder(connectString);
    public SqlConnectionStringBuilder builder = new SqlConnectionStringBuilder(Builder.ProviderConnectionString);
    //public String ServerName = System.Configuration.ConfigurationManager.AppSettings["ServerName"];
    //public String DatabaseName = System.Configuration.ConfigurationManager.AppSettings["DatabaseName"];
    //public String UserID = System.Configuration.ConfigurationManager.AppSettings["UserID"];
    //public String Password = System.Configuration.ConfigurationManager.AppSettings["Password"];
    public SqlConnection Cn = new SqlConnection();
    public SqlCommand Cm = new SqlCommand();

    public int Insert = 1;
    public int Update = 2;
    public int Delete = 3;
    public int Select = 4;
    public int DeleteTempararyAllSubDetails = 5;
    public int UpdateUserName = 6;

    #endregion

    #region Common Connection Check

    public Boolean CheckConnection()
    {
        Cn = new SqlConnection(builder.ConnectionString);
        if (Cn.State == ConnectionState.Closed)
        {
            try
            {
                OpenConnection();
                return true;
            }
            catch
            {
                return false;
            }
        }
        else
        {
            CloseConnection();
            return false;
        }
    }

    #endregion

    #region Common Connection Open

    public void OpenConnection()
    {
        Cn.Open();
    }

    #endregion

    #region Common Connection Close

    public void CloseConnection()
    {
        Cn.Close();
    }

    #endregion

    #region Common Insert Update Delete By Query

    public Boolean InsertUpdateDeleteQuery(String Query)
    {
        CloseConnection();
        try
        {
            if (CheckConnection())
            {
                Cm = new SqlCommand(Query, Cn);
                Cm.ExecuteNonQuery();
                CloseConnection();
                return true;
            }
            else
            {
                CloseConnection();
                return false;
            }
        }
        catch
        {
            CloseConnection();
            return false;
        }
    }

    #endregion

    #region Common Select By Query

    public DataSet SelectQuery(String Query)
    {
        CloseConnection();
        SqlDataAdapter Adpt = new SqlDataAdapter();
        DataSet Ds = new DataSet();
        try
        {
            if (CheckConnection())
            {
                Adpt = new SqlDataAdapter(Query, Cn);
                Adpt.Fill(Ds);
                CloseConnection();
                return Ds;
            }
            else
            {
                CloseConnection();
                return Ds;
            }

        }
        catch
        {
            CloseConnection();
            return Ds;
        }
    }

    #endregion

    #region Common Insert Update Delete By Procedure

    public DataSet CommonFunctionForSelect(SqlCommand SqlCm)
    {
        DataSet DS = null;
        try
        {
            Cm = SqlCm;
            SqlParameter ParamVal = new SqlParameter("@ReturnVal", SqlDbType.Int);
            ParamVal.Direction = ParameterDirection.ReturnValue;
            Cm.Parameters.Add(ParamVal);
            CheckConnection();
            Cm.Connection = Cn;
            Cm.CommandTimeout = 0;
            SqlDataAdapter SQLDA = new SqlDataAdapter();
            DS = new DataSet();
            SQLDA = new SqlDataAdapter(Cm);
            SQLDA.Fill(DS);
        }
        catch (Exception)
        {
        }
        finally
        {
            CloseConnection();
        }
        return DS;
    }

    public int CommonFunctionForInsertUpdateDelete(SqlCommand SqlCm)
    {
        Cm = SqlCm;
        SqlParameter ParamVal = new SqlParameter("@ReturnVal", SqlDbType.Int);
        ParamVal.Direction = ParameterDirection.ReturnValue;
        Cm.Parameters.Add(ParamVal);
        CheckConnection();
        Cm.Connection = Cn;
        Cm.ExecuteNonQuery();
        CloseConnection();
        return Convert.ToInt32(ParamVal.Value.ToString());
    }

    public SqlDataReader CommonFunctionForSelectDR(SqlCommand SqlCm)
    {
        SqlDataReader sdr = null;
        try
        {
            Cm = SqlCm;
            SqlParameter ParamVal = new SqlParameter("@ReturnVal", SqlDbType.Int);
            ParamVal.Direction = ParameterDirection.ReturnValue;
            Cm.Parameters.Add(ParamVal);
            CheckConnection();
            Cm.Connection = Cn;
            Cm.CommandTimeout = 0;
            sdr = Cm.ExecuteReader();
        }
        catch (Exception)
        {
        }
        finally
        {
        }
        return sdr;
    }
    #endregion


}
