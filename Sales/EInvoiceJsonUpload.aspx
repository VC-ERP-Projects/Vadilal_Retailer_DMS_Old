<%@ Page Title="" Language="C#" MasterPageFile="~/MainMaster.master" AutoEventWireup="true" CodeFile="EInvoiceJsonUpload.aspx.cs" Inherits="Sales_EInvoiceJsonUpload" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" Runat="Server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" Runat="Server">
    <div class="panel panel-default">
        <div class="panel-heading">
            <h3 class="panel-title"><b>Upload E-Invoice Json Response File</b></h3>
        </div>
        <div class="panel-body">
            <div class="row">
                <div class="col-lg-6">
                    <div class="input-group form-group">
                        <asp:Label runat="server" Text="Json File" Font-Bold="true" ID="lblUpload" CssClass="input-group-addon"></asp:Label>
                        <asp:FileUpload ID="flCUpload" runat="server" CssClass="form-control" />
                    </div>
                </div>
                <div class="col-lg-6">
                    <div class="input-group form-group">
                        <asp:Button ID="btnCUpload" runat="server" Text="Upload" OnClientClick="return confirm('Are you sure want to upload?');"  OnClick="btnCUpload_Click"   CssClass="btn btn-default" Style="display: inline" />
                         
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-lg-12">
                    <asp:GridView ID="gvMissdata" runat="server" CssClass="table table-bordered table-responsive" AutoGenerateColumns="true">
                    </asp:GridView>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

