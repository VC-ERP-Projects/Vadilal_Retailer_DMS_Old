using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Data.EntityClient;

public class Connection
{
    public Connection()
    {
        //
        // TODO: Add constructor logic here
        //
    }

    #region Get Connection
    
    public string getcon()
    {
        try
        {
            string connectString = System.Configuration.ConfigurationManager.ConnectionStrings["DDMSEntities"].ToString();
            EntityConnectionStringBuilder Builder = new EntityConnectionStringBuilder(connectString);
            SqlConnectionStringBuilder builder = new SqlConnectionStringBuilder(Builder.ProviderConnectionString);
            return builder.ConnectionString;
        }
        catch (Exception ex)
        {
            throw ex;
        }

    }
    #endregion
}