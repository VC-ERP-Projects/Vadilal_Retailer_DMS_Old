using System;
using System.Collections.Generic;
using System.Data;
using System.Reflection;
using System.Data.Objects.DataClasses;
using System.Runtime.Serialization;

public static class CollectionExtensions
{
    public static DataSet ToDataSet<T>(this IEnumerable<T> collection, string dataTableName)
    {
        if (collection == null)
        {
            throw new ArgumentNullException("collection");
        }

        if (string.IsNullOrEmpty(dataTableName))
        {
            throw new ArgumentNullException("dataTableName");
        }

        DataSet data = new DataSet("NewDataSet");
        data.Tables.Add(FillDataTable(dataTableName, collection));
        return data;
    }

    public static DataTable ToDataTable<T>(this IEnumerable<T> collection, string dataTableName)
    {
        if (collection == null)
        {
            throw new ArgumentNullException("collection");
        }

        if (string.IsNullOrEmpty(dataTableName))
        {
            throw new ArgumentNullException("dataTableName");
        }

        return FillDataTable(dataTableName, collection);
    }

    private static DataTable FillDataTable<T>(string tableName, IEnumerable<T> collection)
    {
        PropertyInfo[] properties = typeof(T).GetProperties();

        DataTable dt = CreateDataTable<T>(tableName, collection, properties);

        IEnumerator<T> enumerator = collection.GetEnumerator();
        while (enumerator.MoveNext())
        {
            dt.Rows.Add(FillDataRow<T>(dt.NewRow(), enumerator.Current, properties));
        }

        return dt;
    }

    private static DataRow FillDataRow<T>(DataRow dataRow, T item, PropertyInfo[] properties)
    {
        foreach (PropertyInfo property in properties)
        {
            Type t = GetCoreType(property.PropertyType);
            if (t == typeof(Char) || t == typeof(Double) || t == typeof(Decimal) || t == typeof(String) || t == typeof(Boolean) || t == typeof(Int16) || t == typeof(Int32) || t == typeof(Int64) || t == typeof(DateTime) || t == typeof(DateTime) || t == typeof(TimeSpan))
                if (property.GetValue(item, null) == null)
                    dataRow[property.Name.ToString()] = DBNull.Value;
                else
                    dataRow[property.Name.ToString()] = property.GetValue(item, null);
        }

        return dataRow;
    }

    private static DataTable CreateDataTable<T>(string tableName, IEnumerable<T> collection, PropertyInfo[] properties)
    {
        DataTable dt = new DataTable(tableName);

        foreach (PropertyInfo property in properties)
        {

            Type t = GetCoreType(property.PropertyType);
            if (t == typeof(Char) || t == typeof(Double) || t == typeof(Decimal) || t == typeof(String) || t == typeof(Boolean) || t == typeof(Int16) || t == typeof(Int32) || t == typeof(Int64) || t == typeof(DateTime) || t == typeof(TimeSpan))
                dt.Columns.Add(property.Name.ToString(), t);
        }

        return dt;
    }

    public static List<T> GetEntities<T>(DataTable entityTable)
    {
        List<T> bos = new List<T>();
        T entity;
        Type entityType = typeof(T);
        if (entityTable != null)
        {
            for (int i = 0; i < entityTable.Rows.Count; i++)
            {
                entity = (T)GetEntity(entityType, entityTable.Rows[i]);
                bos.Add(entity);
            }
        }
        return bos;
    }

    public static object GetEntity(Type entityType, DataRow entityRow)
    {
        object entity = null;
        if (entityRow != null)
        {
            entity = Activator.CreateInstance(entityType);
            PropertyInfo[] properties = entityType.GetProperties();
            foreach (PropertyInfo propertyInfo in properties)
            {
                object[] attributes = propertyInfo.GetCustomAttributes(typeof(DataMemberAttribute), true);
                if (attributes.Length > 0)
                {
                    DataMemberAttribute dataColumnMapper = attributes[0] as DataMemberAttribute;
                    if (entityRow.Table.Columns.Contains(dataColumnMapper.Name))
                    {
                        if (!entityRow.IsNull(dataColumnMapper.Name))
                        {
                            propertyInfo.SetValue(entity, entityRow[dataColumnMapper.Name], null);
                        }
                    }
                }
            }
        }
        return entity;
    }

    public static List<T> ToList<T>(DataTable table)
    {
        List<T> list = new List<T>();

        T item;
        Type listItemType = typeof(T);

        for (int i = 0; i < table.Rows.Count; i++)
        {
            item = (T)Activator.CreateInstance(listItemType);
            mapRow(item, table, listItemType, i);
            list.Add(item);
        }

        return list;
    }

    private static void mapRow(object vOb, System.Data.DataTable table, Type type, int row)
    {
        for (int col = 0; col < table.Columns.Count; col++)
        {
            var columnName = table.Columns[col].ColumnName;

            var prop = type.GetProperty(columnName);
            if (prop != null)
            {
                object data = getData(prop, table.Rows[row][col]);
                prop.SetValue(vOb, data, null);
            }

        }
    }

    private static object getData(PropertyInfo prop, object value)
    {
        if (prop.PropertyType.Name.Equals("Int32"))
            return Convert.ToInt32(value);
        if (prop.PropertyType.Name.Equals("Double"))
            return Convert.ToDouble(value);
        if (prop.PropertyType.Name.Equals("DateTime"))
            return Convert.ToDateTime(value);
        if (prop.PropertyType.Name.Equals("Boolean"))
            return Convert.ToBoolean(value);

        return Convert.ToString(value).Trim();
    }

    public static DataTable ToDataTable<T>(this IList<T> items)
    {
        var tb = new DataTable(typeof(T).Name);

        PropertyInfo[] props = typeof(T).GetProperties(BindingFlags.Public | BindingFlags.Instance);

        foreach (PropertyInfo prop in props)
        {
            Type t = GetCoreType(prop.PropertyType);
            tb.Columns.Add(prop.Name, t);
        }

        foreach (T item in items)
        {
            var values = new object[props.Length];

            for (int i = 0; i < props.Length; i++)
            {
                values[i] = props[i].GetValue(item, null);
            }

            tb.Rows.Add(values);
        }

        return tb;
    }

    /// <summary>
    /// Determine of specified type is nullable
    /// </summary>
    public static bool IsNullable(Type type)
    {
        return !type.IsValueType || (type.IsGenericType && type.GetGenericTypeDefinition() == typeof(Nullable<>));
    }

    /// <summary>
    /// Return underlying type if type is Nullable otherwise return the type
    /// </summary>
    public static Type GetCoreType(Type type)
    {
        if (type != null && IsNullable(type))
        {
            if (!type.IsValueType)
            {
                return type;
            }
            else
            {
                return Nullable.GetUnderlyingType(type);
            }
        }
        else
        {
            return type;
        }
    }

    public static List<String> GetProperty(PropertyInfo[] propertyInfo)
    {
        List<String> Temp = new List<String>();
        foreach (PropertyInfo property in propertyInfo)
        {
            Type t = GetCoreType(property.PropertyType);
            if (t == typeof(Char) || t == typeof(Double) || t == typeof(Decimal) || t == typeof(String) || t == typeof(Boolean) || t == typeof(Int16) || t == typeof(Int32) || t == typeof(Int64) || t == typeof(DateTime) || t == typeof(TimeSpan))
                Temp.Add(property.Name);
        }

        return Temp;
    }

}