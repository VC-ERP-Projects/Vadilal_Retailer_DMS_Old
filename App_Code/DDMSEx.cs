using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Entity;
using System.Data.Entity.Infrastructure;
using System.Data.EntityClient;
using System.Linq;
using System.Web;

[Serializable]
public abstract class ObjectWithState
{
    public EState EState { get; set; }
}

public enum EState
{
    Added,
    Unchanged,
    Modified,
    Deleted
}

public partial class DDMSEntities : DbContext
{
    public DDMSEntities()
        : base("name=DDMSEntities")
    {
        var objectContext = (this as IObjectContextAdapter).ObjectContext;
        objectContext.CommandTimeout = 500;
        String AppName = string.Empty;

        objectContext.ObjectMaterialized += (sender, args) =>
        {
            var entity = args.Entity as ObjectWithState;
            if (entity != null)
            {
                entity.EState = EState.Unchanged;
            }
        };
        if (HttpContext.Current != null)
        {
            if (HttpContext.Current.Session != null)
            {
                if (HttpContext.Current.Session["AdminUserID"] != null)
                    AppName = "Application Name=UserID:" + HttpContext.Current.Session["AdminUserID"].ToString() + ";";
                else if (HttpContext.Current.Session["UserID"] != null)
                    AppName = "Application Name=UserID:" + HttpContext.Current.Session["UserID"].ToString() + ";";
            }
        }
        (objectContext.Connection as EntityConnection).StoreConnection.ConnectionString += ";" + AppName;
    }

    public static void ApplyChanges<TEntity>(DDMSEntities ctx, TEntity root) where TEntity : ObjectWithState
    {
        ctx.Set<TEntity>().Add(root);
        CheckForEntitiesWithoutStateInterface(ctx);
        foreach (var entry in ctx.ChangeTracker.Entries<ObjectWithState>())
        {
            ObjectWithState stateInfo = entry.Entity;
            entry.State = ConvertState(stateInfo.EState);
        }
    }

    public static EntityState ConvertState(EState state)
    {
        switch (state)
        {
            case EState.Added:
                return EntityState.Added;
            case EState.Deleted:
                return EntityState.Deleted;
            case EState.Modified:
                return EntityState.Modified;
            default:
                return EntityState.Unchanged;
        }
    }

    private static void CheckForEntitiesWithoutStateInterface(DDMSEntities ctx)
    {
        var entitiesWithoutState =
        from e in ctx.ChangeTracker.Entries()
        where !(e.Entity is ObjectWithState)
        select e;
        if (entitiesWithoutState.Any())
        {
            throw new NotSupportedException(
            "All entities must implement ObjectWithState");
        }
    }
}
