<%@ Page Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="Imagename.aspx.cs" Inherits="MyAccount_Imagename" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server"></asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
   
        <asp:Label runat="server"><strong style="text-decoration:underline;font-size: 30px;color: darkgoldenrod;font-family: cursive; ">Upload Master</strong></asp:Label>
   
    <div class="ui-grid-b" style="margin-top: 8%">
        <div class="ui-block-a">
            <fieldset>
                <legend>File Upload</legend>
                <asp:FileUpload ID="flCUpload" runat="server"  Style="width: 50%; margin-top: 10px; margin-bottom: 6px" /><br />
                <asp:Button ID="btnCUpload" runat="server" Text="Submit" OnClick="btnCUpload_Click" />
                <asp:Button ID="btnCDwonload" runat="server" Text="Download Profile"   />
            </fieldset>
        </div>
   

    </div>
    <div style="overflow-x: auto">
        <asp:GridView ID="GridView1" runat="server" HeaderStyle-CssClass="table-header" AllowPaging="True">
        </asp:GridView>
    </div>
</asp:Content>

