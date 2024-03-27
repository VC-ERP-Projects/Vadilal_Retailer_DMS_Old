<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ClaimImage.aspx.cs" Inherits="Sales_ClaimImage" %>

<!DOCTYPE html>


<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <style type="text/css">
        table tbody td {
            padding: 5px 10px !important;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="panel">
            <div class="panel-body">
                <div class="row">
                    <table id="tblimage">
                        <tr>
                            <td>
                                <asp:DataList ID="rptImage" runat="server" RepeatDirection="Horizontal" RepeatColumns="4">
                                    <ItemTemplate>
                                        <a runat="server" target="_blank" href='<%#Eval("ImageName")%>'>
                                            <%--<asp:Image ID="Image1" Height="100px" Width="100px" runat="server" ImageUrl='<%#Eval("ImageName")%>'></asp:Image>--%>
                                            <asp:Label ID="lblfile" runat="server" Text='<%# Eval("ClaimImgName") %>'></asp:Label>
                                        </a>
                                    </ItemTemplate>
                                </asp:DataList>
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
