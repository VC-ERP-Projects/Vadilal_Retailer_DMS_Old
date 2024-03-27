<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="AccessError.aspx.cs" Inherits="AccessError" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="main-content-form">
        <fieldset>
            <legend>Error Was Found</legend>
            <div id="divAccessError" runat="server" visible="false">
                <center>
                <img src="Images/acesserror.png" style="width: 30%;"/>
                </center>
            </div>
            <div id="div404" runat="server" visible="false">
                <center>
                <img src="Images/404error.png" style="width: 50%;"/>
                </center> 
            </div>
            <div id="div403" runat="server" visible="false">
                <center>
                    <img src="Images/403error.png" style="width: 50%;"/>
                </center>
                <%--The request is for something forbidden. Authorization will not help.--%>
            </div>
            <div id="div500" runat="server" visible="false">
                <center>
                    <img src="Images/servererror.jpg" style="width: 20%;"/><h1>500 Internal Server Error</h1>
                </center>
            </div>
            <br />
            <center>
            <h5 style="font-weight:bold">Go To Our&nbsp&nbsp<asp:LinkButton Text="Home Page" ID="lnkHome" PostBackUrl="~/Home.aspx" runat="server" style="color:blue;text-decoration:underline"/></h5>
                </center>
        </fieldset>
    </div>
</asp:Content>
