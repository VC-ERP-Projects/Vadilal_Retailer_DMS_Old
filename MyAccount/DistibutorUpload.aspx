<%@ Page Language="C#" AutoEventWireup="true" MasterPageFile="~/OutletMaster.master" CodeFile="DistibutorUpload.aspx.cs" Inherits="MyAccount_DistibutorUpload" %>


<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <style>
        .wrapper {
            /* margin-top: 80px;*/
            margin-bottom: 80px;
        }

        .form-signin {
            max-width: 90%;
            padding: 15px 35px 45px;
            margin: 0 auto;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel panel-default" style="max-width: 500px;margin-left:28%">
        <div class="panel-heading">
            <h3 class="panel-title">Upload</h3>
        </div>
        <div class="form-signin _masterForm">
            <div class="row">
                <div class="col-lg-12">
                    <div class="input-group form-group">
                        <asp:Label runat="server" Text="Upload File" ID="lblUpload" CssClass="input-group-addon"></asp:Label>
                        <asp:FileUpload ID="flCUpload" runat="server" CssClass="form-control" />
                    </div>
                </div>
                <div class="col-lg-12">
                    <div class="input-group form-group">
                        <asp:Button ID="btnCUpload" runat="server" Text="Submit" OnClick="btnCUpload_Click" CssClass="btn btn-default" Style="display: inline" />
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
