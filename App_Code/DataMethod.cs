using System;
using System.Collections.Generic;
using System.Text;
using System.Data;
using System.Data.OleDb;
using System.Data.Sql;
using System.Data.SqlClient;

public class DataMethod
{
    #region Variable Declaration
    SqlConnection con = new SqlConnection();
    OleDbConnection oleCon = new OleDbConnection();
    SqlTransaction trans;
    OleDbTransaction oleTrans;
    Boolean Transaction = false;
    DataTable dt;
    DataSet ds;
    SqlDataAdapter sqlda;
    OleDbDataAdapter olda;
    Connection c;
    #endregion

    #region Properties
    private static string _ConnectionString;

    /// <summary>
    /// Connection String: If this property is not set explicitly, it will be automatically taken from clsGlobal.ConnectionString variable
    /// </summary>
    public static string ConnectionString
    {
        get { return _ConnectionString; }
        set { _ConnectionString = value; }
    }
    #endregion

    /// <summary>
    /// Default class Construction
    /// </summary>
    public DataMethod()
    {
        try
        {
            c = new Connection();
            ConnectionString = c.getcon();
            if (ConnectionString == null || ConnectionString == "")
            {
                throw new Exception("DataMethods: ConnectionString is empty. Please set ConnectionString first. You have to set in Web.Confing File");
            }
            else
            {
                if (ConnectionString.ToUpper().Contains("OLEDB"))
                    oleCon.ConnectionString = ConnectionString;
                else
                    con.ConnectionString = ConnectionString;
            }
        }
        catch
        {
            throw;
        }
    }

    #region Connection Related Methods
    /// <summary>
    /// Method is used for begin Transaction
    /// </summary>
    /// <returns></returns>
    public Boolean BeginTrans()
    {
        try
        {
            if (!Transaction)
            {
                if (ConnectionString.ToUpper().Contains("OLEDB"))
                {
                    oleCon.Open();
                    oleTrans = oleCon.BeginTransaction();
                }
                else
                {
                    con.Open();
                    trans = con.BeginTransaction();
                }

                Transaction = true;
                return true;
            }
            else
                return true;

        }
        catch
        {
            if (!Transaction)
                CloseConnection();
            throw;
        }
    }

    /// <summary>
    /// Method is used for rollback Transaction...
    /// </summary>
    /// <returns></returns>
    public Boolean RollBackTrans()
    {
        try
        {
            if (Transaction)
            {
                if (ConnectionString.ToUpper().Contains("OLEDB"))
                {
                    oleTrans.Rollback();
                    CloseConnection();
                }
                else
                {
                    trans.Rollback();
                    CloseConnection();
                }
                Transaction = false;
                return true;
            }
            else
                return false;

        }
        catch
        {
            if (!Transaction)
                CloseConnection();
            throw;
        }
    }

    /// <summary>
    /// method is used for commit the transaction...
    /// </summary>
    /// <returns></returns>
    public Boolean CommitTrans()
    {
        try
        {
            if (Transaction)
            {
                if (ConnectionString.ToUpper().Contains("OLEDB"))
                {
                    oleTrans.Commit();
                    CloseConnection();
                }
                else
                {
                    trans.Commit();
                    CloseConnection();
                }
                Transaction = false;
                return true;
            }
            else
                return false;

        }
        catch
        {
            if (!Transaction)
                CloseConnection();
            throw;
        }
    }

    /// <summary>
    /// Try to close the database connection if only if it's not closed.
    /// </summary>
    public void CloseConnection()
    {
        try
        {
            if (ConnectionString.ToUpper().Contains("OLEDB"))
            {
                if (oleCon.State != ConnectionState.Closed)
                    oleCon.Close();
            }
            else
            {
                if (con.State != ConnectionState.Closed)
                    con.Close();
            }
        }
        catch
        {
            throw;
        }
    }
    #endregion

    /// <summary>
    /// Execute an insert, update or delete Proedure. Returns number of affected rows.
    /// </summary>
    /// <param name="Query"></param>
    /// <returns></returns>
    public Boolean ProcExecuteNonQuery(string proc, SqlParameter[] par)
    {
        try
        {
            if (ConnectionString.ToUpper().Contains("OLEDB"))
            {
                OleDbCommand cmd = new OleDbCommand();

                cmd.Connection = oleCon;

                if (Transaction)
                {
                    cmd.Transaction = oleTrans;
                }
                else
                {
                    oleCon.Open();
                }
                if (par != null)
                {
                    for (int i = 0; i < par.Length; i++)
                    {
                        cmd.Parameters.Add(par[i]);
                    }
                }
                cmd.CommandText = proc;
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.ExecuteNonQuery();

                if (!Transaction)
                    CloseConnection();
                return true;
            }
            else
            {
                SqlCommand cmd = new SqlCommand();

                cmd.Connection = con;
                if (Transaction)
                {
                    cmd.Transaction = trans;
                }
                else
                {
                    con.Open();
                }
                if (par != null)
                {
                    for (int i = 0; i < par.Length; i++)
                    {
                        cmd.Parameters.Add(par[i]);

                    }
                }
                cmd.CommandText = proc;
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.ExecuteNonQuery();


                if (!Transaction)
                    CloseConnection();
                return true;
            }

        }
        catch
        {
            if (!Transaction)
                CloseConnection();
            throw;
            return false;
        }
    }

    /// <summary>
    /// Execute an insert, update or delete Proedure. Returns number of affected rows.
    /// </summary>
    /// <param name="Query"></param>
    /// <returns></returns>
    public int ProcExecuteNonQueryIdentity(string proc, SqlParameter[] par)
    {
        try
        {
            int ReturnValue;
            if (ConnectionString.ToUpper().Contains("OLEDB"))
            {
                OleDbCommand cmd = new OleDbCommand();

                cmd.Connection = oleCon;

                if (Transaction)
                {
                    cmd.Transaction = oleTrans;
                }
                else
                {
                    oleCon.Open();
                }
                if (par != null)
                {
                    for (int i = 0; i < par.Length; i++)
                    {
                        cmd.Parameters.Add(par[i]);
                    }
                }
                cmd.Parameters.Add("@t_return", OleDbType.VarChar, 50);
                cmd.CommandText = proc;
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters["@t_return"].Direction = ParameterDirection.Output;
                cmd.ExecuteNonQuery();
                ReturnValue = Convert.ToInt32(cmd.Parameters["@t_return"].Value.ToString());

                if (!Transaction)
                    CloseConnection();
                return ReturnValue ;
            }
            else
            {
                SqlCommand cmd = new SqlCommand();

                cmd.Connection = con;
                if (Transaction)
                {
                    cmd.Transaction = trans;
                }
                else
                {
                    con.Open();
                }
                if (par != null)
                {
                    for (int i = 0; i < par.Length; i++)
                    {
                        cmd.Parameters.Add(par[i]);

                    }
                }
                cmd.Parameters.Add("@t_return", SqlDbType.VarChar, 50);
                cmd.CommandText = proc;
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters["@t_return"].Direction = ParameterDirection.Output;
                cmd.ExecuteNonQuery();
                ReturnValue = Convert.ToInt32(cmd.Parameters["@t_return"].Value.ToString());


                if (!Transaction)
                    CloseConnection();
                return ReturnValue;
            }

        }
        catch
        {
            if (!Transaction)
                CloseConnection();
            throw;
            return -1;
        }
    }

    /// <summary>
    /// Execute procedure and returns scalar value
    /// </summary>
    /// <param name="Query"></param>
    /// <returns></returns>
    public Object ProcExecuteScalar(string proc, SqlParameter[] par)
    {
        try
        {
            if (ConnectionString.ToUpper().Contains("OLEDB"))
            {
                OleDbCommand cmd = new OleDbCommand();

                cmd.Connection = oleCon;

                if (Transaction)
                {
                    cmd.Transaction = oleTrans;
                }
                else
                {
                    oleCon.Open();
                }
                if (par != null)
                {
                    for (int i = 0; i < par.Length; i++)
                    {
                        cmd.Parameters.Add(par[i]);
                    }
                }
                cmd.CommandText = proc;
                cmd.CommandType = CommandType.StoredProcedure;

                Object result = new Object();
                result = cmd.ExecuteScalar();

                if (!Transaction)
                    CloseConnection();
                return result;
            }
            else
            {
                SqlCommand cmd = new SqlCommand();

                cmd.Connection = con;
                if (Transaction)
                {
                    cmd.Transaction = trans;
                }
                else
                {
                    con.Open();
                }
                if (par != null)
                {
                    for (int i = 0; i < par.Length; i++)
                    {
                        cmd.Parameters.Add(par[i]);
                    }
                }
                cmd.CommandText = proc;
                cmd.CommandType = CommandType.StoredProcedure;

                Object result = new Object();
                result = cmd.ExecuteScalar();

                if (!Transaction)
                    CloseConnection();
                return result;
            }

        }
        catch
        {
            if (!Transaction)
                CloseConnection();
            throw;
        }
    }

    /// <summary>
    /// Execute procedure and returns DataTable
    /// </summary>
    /// <param name="Query"></param>
    /// <returns></returns>
    public DataTable ProcGetDataDT(string proc, SqlParameter[] par)
    {
        try
        {
            if (ConnectionString.ToUpper().Contains("OLEDB"))
            {
                OleDbCommand cmd = new OleDbCommand();

                cmd.Connection = oleCon;

                if (Transaction)
                {
                    cmd.Transaction = oleTrans;
                }
                else
                {
                    oleCon.Open();
                }
                if (par != null)
                {
                    for (int i = 0; i < par.Length; i++)
                    {
                        cmd.Parameters.Add(par[i]);
                    }
                }
                cmd.CommandText = proc;
                cmd.CommandType = CommandType.StoredProcedure;
                olda = new OleDbDataAdapter();
                olda.SelectCommand = cmd;
                dt = new DataTable();
                olda.Fill(dt);

                if (!Transaction)
                {
                    CloseConnection();
                }
                return dt;
            }
            else
            {
                SqlCommand cmd = new SqlCommand();

                cmd.Connection = con;
                if (Transaction)
                {
                    cmd.Transaction = trans;
                }
                else
                {
                    con.Open();
                }
                if (par != null)
                {
                    for (int i = 0; i < par.Length; i++)
                    {
                        cmd.Parameters.Add(par[i]);
                    }
                }
                cmd.CommandText = proc;
                cmd.CommandType = CommandType.StoredProcedure;
                sqlda = new SqlDataAdapter();
                sqlda.SelectCommand = cmd;
                dt = new DataTable();
                sqlda.Fill(dt);

                if (!Transaction)
                {
                    CloseConnection();
                }
                return dt;
            }

        }
        catch
        {
            if (!Transaction)
                CloseConnection();
            throw;
        }
    }

    /// <summary>
    /// Execute procedure and returns DataTable
    /// </summary>
    /// <param name="Query"></param>
    /// <returns></returns>
    public DataTable GetData(string proc)
    {
        try
        {           
                SqlCommand cmd = new SqlCommand();

                cmd.Connection = con;
                if (Transaction)
                {
                    cmd.Transaction = trans;
                }
                else
                {
                    con.Open();
                }               
                cmd.CommandText = proc;
                cmd.CommandType = CommandType.Text;
                sqlda = new SqlDataAdapter();
                sqlda.SelectCommand = cmd;
                dt = new DataTable();
                sqlda.Fill(dt);

                if (!Transaction)
                {
                    CloseConnection();
                }
                return dt;
            

        }
        catch
        {
            if (!Transaction)
                CloseConnection();
            throw;
        }
    }

    /// <summary>
    /// Execute procedure and returns DataSet
    /// </summary>
    /// <param name="Query"></param>
    /// <returns>DataSet</returns>
    public DataSet ProcGetDataDS(string proc, SqlParameter[] par)
    {
        try
        {
            if (ConnectionString.ToUpper().Contains("OLEDB"))
            {
                OleDbCommand cmd = new OleDbCommand();

                cmd.Connection = oleCon;

                if (Transaction)
                {
                    cmd.Transaction = oleTrans;
                }
                else
                {
                    oleCon.Open();
                }
                if (par != null)
                {
                    for (int i = 0; i < par.Length; i++)
                    {
                        cmd.Parameters.Add(par[i]);
                    }
                }
                cmd.CommandText = proc;
                cmd.CommandType = CommandType.StoredProcedure;
                olda = new OleDbDataAdapter();
                olda.SelectCommand = cmd;
                ds = new DataSet();
                olda.Fill(ds);

                if (!Transaction)
                {
                    CloseConnection();
                }
                return ds;
            }
            else
            {
                SqlCommand cmd = new SqlCommand();

                cmd.Connection = con;
                if (Transaction)
                {
                    cmd.Transaction = trans;
                }
                else
                {
                    con.Open();
                }
                if (par != null)
                {
                    for (int i = 0; i < par.Length; i++)
                    {
                        cmd.Parameters.Add(par[i]);
                    }
                }
                cmd.CommandText = proc;
                cmd.CommandType = CommandType.StoredProcedure;
                sqlda = new SqlDataAdapter();
                sqlda.SelectCommand = cmd;
                ds = new DataSet();
                sqlda.Fill(ds);

                if (!Transaction)
                {
                    CloseConnection();
                }
                return ds;
            }

        }
        catch
        {
            if (!Transaction)
                CloseConnection();
            throw;
        }
    }
}