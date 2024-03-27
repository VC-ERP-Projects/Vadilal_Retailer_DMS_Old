<%@ Page Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="MasterReport.aspx.cs" Inherits="Reports_MasterReport" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" Runat="Server">
    <script type="text/javascript" language="javascript">
        $(document).ready(function () {
            $("#wrapper").toggleClass("toggled");
            $("#menu-toggle").hide();
            setTimeout(function () {
                $("#UpdatePanel1").unbind("click");
            }, 500);
        });
     </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" Runat="Server">
</asp:Content>
