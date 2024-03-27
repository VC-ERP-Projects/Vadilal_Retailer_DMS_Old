<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="MISReports.aspx.cs" Inherits="Reports_MISReports" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel">
        <div class="panel-body">
            <div class="row _masterForm">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Button Text="Unique Dealer Count Export" ID="btnExportUniqDlr" CssClass="btn btn-info" runat="server" OnClick="btnExportUniqDlr_Click" />
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

