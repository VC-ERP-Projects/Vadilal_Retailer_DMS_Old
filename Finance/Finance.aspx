﻿<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="Finance.aspx.cs" Inherits="Finance_Finance" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript">
        $(function () {
            $("#wrapper").toggleClass("toggled");
            $("#menu-toggle").hide();
            setTimeout(function () {
                $("#UpdatePanel1").unbind("click");
            }, 500);
        });
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
</asp:Content>

