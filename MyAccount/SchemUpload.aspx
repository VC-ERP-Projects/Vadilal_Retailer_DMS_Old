<%@ Page Language="C#" AutoEventWireup="true" MasterPageFile="~/OutletMaster.master" CodeFile="SchemUpload.aspx.cs" Inherits="MyAccount_SchemUpload" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript">

        function downloadmaster() {
            window.open("../Document/CSV Formats/MasterSchemeUploadFormat.csv");
        }

        function downloadmachine() {
            window.open("../Document/CSV Formats/MachineSchemeUploadFormat.csv");
        }

        function downloadparlour() {
            window.open("../Document/CSV Formats/ParlourSchemeUploadFormat.csv");
        }

        function downloadvrs() {
            window.open("../Document/CSV Formats/VRSSchemeUploadFormat.csv");
        }

    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel panel-default">
        <div class="panel-heading">
            <h3 class="panel-title"><b>Upload Scheme</b></h3>
        </div>
        <div class="panel-body">
            <div class="row">
                <div class="col-lg-6">
                    <div class="input-group form-group">
                        <asp:Label runat="server" Text="Master Scheme" Font-Bold="true" ID="lblUpload" CssClass="input-group-addon"></asp:Label>
                        <asp:FileUpload ID="flCUpload" runat="server" CssClass="form-control" />
                    </div>
                </div>
                <div class="col-lg-6">
                    <div class="input-group form-group">
                        <asp:Button ID="btnCUpload" runat="server" Text="Upload Master" OnClientClick="return confirm('Are you sure want to upload Master Scheme?');" OnClick="btnCUpload_Click" CssClass="btn btn-default" Style="display: inline" />
                        &nbsp; &nbsp; &nbsp; &nbsp;
                        <asp:Button ID="btnDownload" runat="server" Text="Download Master Scheme Format" CssClass="btn btn-default" OnClientClick="downloadmaster(); return false;" />
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-lg-6">
                    <div class="input-group form-group">
                        <asp:Label runat="server" Text="Machine Scheme" Font-Bold="true" ID="lblMachineUpload" CssClass="input-group-addon"></asp:Label>
                        <asp:FileUpload ID="flMachineUpload" runat="server" CssClass="form-control" />
                    </div>
                </div>
                <div class="col-lg-6">
                    <div class="input-group form-group">
                        <asp:Button ID="btnMachineUpload" runat="server" Text="Upload Machine" OnClientClick="return confirm('Are you sure want to upload Machine Scheme?');" OnClick="btnMachineUpload_Click" CssClass="btn btn-default" Style="display: inline" />
                        &nbsp; &nbsp; &nbsp; &nbsp;
                        <asp:Button ID="btnMachineDownload" runat="server" Text="Download Machine Scheme Format" CssClass="btn btn-default" OnClientClick="downloadmachine(); return false;" />
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-lg-6">
                    <div class="input-group form-group">
                        <asp:Label runat="server" Text="Parlour Scheme" Font-Bold="true" ID="lblParlour" CssClass="input-group-addon"></asp:Label>
                        <asp:FileUpload ID="flParlourUpload" runat="server" CssClass="form-control" />
                    </div>
                </div>
                <div class="col-lg-6">
                    <div class="input-group form-group">
                        <asp:Button ID="btnParlourUpload" runat="server" Text="Upload Parlour" OnClientClick="return confirm('Are you sure want to upload Parlour Scheme?');" OnClick="btnParlourUpload_Click" CssClass="btn btn-default" Style="display: inline" />
                        &nbsp; &nbsp; &nbsp; &nbsp;
                        <asp:Button ID="btnParlourDownload" runat="server" Text="Download Parlour Scheme Format" CssClass="btn btn-default" OnClientClick="downloadparlour(); return false;" />
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-lg-6">
                    <div class="input-group form-group">
                        <asp:Label runat="server" Text="VRS Scheme" Font-Bold="true" ID="lblVRS" CssClass="input-group-addon"></asp:Label>
                        <asp:FileUpload ID="flVRSUpload" runat="server" CssClass="form-control" />
                    </div>
                </div>
                <div class="col-lg-6">
                    <div class="input-group form-group">
                        <asp:Button ID="btnVRSUpload" runat="server" Text="Upload VRS" OnClientClick="return confirm('Are you sure want to upload VRS Scheme?');" OnClick="btnVRSUpload_Click" CssClass="btn btn-default" Style="display: inline" />
                        &nbsp; &nbsp; &nbsp; &nbsp;
                        <asp:Button ID="btnVRSDownload" runat="server" Text="Download VRS Scheme Format" CssClass="btn btn-default" OnClientClick="downloadvrs(); return false;" />
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
