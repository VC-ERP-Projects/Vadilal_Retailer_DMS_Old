<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Reminder.aspx.cs" Inherits="Reports_Reminder" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <link href="../Scripts/BootStrapCSS/bootstrap-theme.css" rel="stylesheet" type="text/css" />
    <link href="../Scripts/BootStrapCSS/bootstrap.min.css" rel="stylesheet" type="text/css" />

    <link href="../Scripts/BootStrapCSS/index.css" rel="stylesheet" type="text/css" />
    <script src="../Scripts/jquery-1.9.1.js" type="text/javascript"></script>
    <script src="../Scripts/Bootstrap/bootstrap.js" type="text/javascript"></script>
    <title>Vadilal House Vadilal Enterprises Ltd.</title>
</head>
<body>
    <form id="form1" runat="server">
        <div id="page-content-wrapper" style="padding: 0px">
            <div class="container-fluid">
                <ul class="list-group">
                    <asp:ListView runat="server" ID="lvData">
                        <ItemTemplate>
                            <li class="list-group-item">
                                <b><%# Eval("Subject") %></b>
                                <br />
                                <%# Eval("MessageBody") %></li>
                        </ItemTemplate>
                    </asp:ListView>
                </ul>
            </div>
        </div>
    </form>
</body>
</html>
