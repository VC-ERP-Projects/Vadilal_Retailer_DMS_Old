﻿<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="Purchase.aspx.cs" Inherits="Purchase_Purchase" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" Runat="Server">
    <script>
        $(function () {
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

