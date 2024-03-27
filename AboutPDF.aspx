<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="AboutPDF.aspx.cs" Inherits="About_PDF" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript">

        $(document).ready(function () {
            if (sessionStorage.getItem("pdfid") == "master") {
                $('#<% = iframe.ClientID %>').attr("src", "Document/DMS_USERMANUAL.pdf#page=7");
                } else if (sessionStorage.getItem("pdfid") == "inventory") {
                    $('#<% = iframe.ClientID %>').attr("src", "Document/DMS_USERMANUAL.pdf#page=15");
                } else if (sessionStorage.getItem("pdfid") == "purchase") {
                    $('#<% = iframe.ClientID %>').attr("src", "Document/DMS_USERMANUAL.pdf#page=18");
                } else if (sessionStorage.getItem("pdfid") == "sales") {
                    $('#<% = iframe.ClientID %>').attr("src", "Document/DMS_USERMANUAL.pdf#page=19");
                } else if (sessionStorage.getItem("pdfid") == "bp") {
                    $('#<% = iframe.ClientID %>').attr("src", "Document/DMS_USERMANUAL.pdf#page=11");
                } else if (sessionStorage.getItem("pdfid") == "crm") {
                    $('#<% = iframe.ClientID %>').attr("src", "Document/DMS_USERMANUAL.pdf#page=21");
                } else if (sessionStorage.getItem("pdfid") == "hrms") {
                    $('#<% = iframe.ClientID %>').attr("src", "Document/DMS_USERMANUAL.pdf#page=13");
                } else if (sessionStorage.getItem("pdfid") == "utility") {
                    $('#<% = iframe.ClientID %>').attr("src", "Document/DMS_USERMANUAL.pdf#page=23");
                } else if (sessionStorage.getItem("pdfid") == "admin") {
                    $('#<% = iframe.ClientID %>').attr("src", "Document/DMS_USERMANUAL.pdf#page=5");
                } else {
                    $('#<% = iframe.ClientID %>').attr("src", "Document/DMS_USERMANUAL.pdf#page=24");
                }
        });

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="main-content-form">
        <fieldset>
            <legend>About DMS</legend>
            <iframe width="100%" height="450px" runat="server" id="iframe"></iframe>
        </fieldset>
    </div>
</asp:Content>

