<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="TaskConfigUpload.aspx.cs" Inherits="Task_TaskConfigUpload" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <link href="../Scripts/datatable_new/jquery.dataTables.min.css" rel="stylesheet" />
    <link href="../Scripts/datatable_new/buttons.dataTables.min.css" rel="stylesheet" />

    <script src="../Scripts/datatable_new/jquery.dataTables.min.js"></script>
    <script src="../Scripts/datatable_new/vfs_fonts.js"></script>
    <script src="../Scripts/datatable_new/jszip.min.js"></script>
    <script type="text/javascript">
        $(document).ready(function () {
            Relaod();
        });

        function Relaod() {
            $('.autoadjust').each(function () {
                h(this);
            }).on('keydown blur change', function () {
                h(this);
            });
            function h(e) {
                $(e).css({ 'height': 'auto', 'overflow-y': 'hidden' }).height(e.scrollHeight);
            }
            $('.gvMissdataPDU').DataTable({
                bFilter: false,
                scrollCollapse: true,
                "stripeClasses": ['odd-row', 'even-row'],
                destroy: true,
                scrollY: '45vh',
                scrollX: true,
                responsive: true,
                "autoWidth": true,
                "aaSorting": [],
                dom: 'Bfrtip',
                "bPaginate": false
            });
            $('.gvMissdataAEM').DataTable({
                bFilter: false,
                scrollCollapse: true,
                "stripeClasses": ['odd-row', 'even-row'],
                destroy: true,
                scrollY: '45vh',
                scrollX: true,
                responsive: true,
                "autoWidth": true,
                "aaSorting": [],
                dom: 'Bfrtip',
                "bPaginate": false
            });
        }

        function downloadPrevDays() {
            window.open("../Document/CSV Formats/PreventiveDaysFormat.csv?r=6");
        }

        function downloadEmpAssetMap() {
            window.open("../Document/CSV Formats/AssetEmpMappingFormat.csv?r=6");
        }

    </script>
    <style type="text/css">
        .input-group-addon {
            font-size: smaller !important;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="col-lg-6">
        <div class="panel panel-default">
            <div class="panel-heading">
                <h3 class="panel-title"><b>Preventive Master Days Upload</b></h3>
            </div>
            <div class="panel-body">
                <div class="input-group form-group">
                    <asp:Label runat="server" Text="File Upload" Font-Bold="true" ID="lblPDUpload" CssClass="input-group-addon"></asp:Label>
                    <asp:FileUpload ID="flPDUpload" runat="server" CssClass="form-control" />
                </div>
                <div class="input-group form-group">
                    <asp:Button ID="btnPDUpload" runat="server" Text="Upload Data" OnClick="btnPDUpload_Click" CssClass="btn btn-success" />
                    &nbsp;
                    <asp:Button ID="btnPDDownload" runat="server" Text="Sample Download" CssClass="btn btn-info" OnClientClick="downloadPrevDays(); return false;" />
                </div>
                <h6 class="panel-title" style="font-size: 14px;"><b>File Upload Status</b></h6>
                <div class="col-lg-12">
                    <div class="col-lg-4">
                        <div class="input-group form-group">
                            <asp:Label runat="server" Text="Total Records : " Font-Bold="true" ID="lblTtlRecords" CssClass="input-group-addon"></asp:Label>
                            <asp:Label runat="server" ID="txtTtlRecords" CssClass="input-group-addon"></asp:Label>
                        </div>
                    </div>
                    <div class="col-lg-4">
                        <div class="input-group form-group">
                            <asp:Label runat="server" Text="Successful Uploaded : " Font-Bold="true" ID="lblSuccRecords" CssClass="input-group-addon"></asp:Label>
                            <asp:Label runat="server" ID="txtSucsRecords" CssClass="input-group-addon"></asp:Label>
                        </div>
                    </div>
                    <div class="col-lg-4">
                        <div class="input-group form-group">
                            <asp:Label runat="server" Text="Fail to Upload : " Font-Bold="true" ID="lblFailRecords" CssClass="input-group-addon"></asp:Label>
                            <asp:Label runat="server" ID="txtFailRecords" CssClass="input-group-addon"></asp:Label>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <br />
        <div class="row">
            <div class="col-lg-12">
                <asp:GridView ID="gvMissdataPDU" runat="server" Width="100%" CssClass="gvMissdataPDU table tbl" OnPreRender="gvMissdataPDU_PreRender" ShowHeader="true" HeaderStyle-CssClass="table-header-gradient" AutoGenerateColumns="false" Font-Size="12px">
                    <Columns>
                        <asp:TemplateField HeaderText="No." HeaderStyle-Width="2px" ItemStyle-Width="2px">
                            <ItemTemplate>
                                <asp:Label ID="lblNo" runat="server" Text='<%# Container.DataItemIndex + 1 %>'></asp:Label>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="AssetCode" HeaderText="Asset Serial No." HeaderStyle-Width="70px" ItemStyle-Width="70px" />
                        <asp:BoundField DataField="ErrorMsg" HeaderText="ErrorMsg" HeaderStyle-Width="200px" ItemStyle-Width="200px" />
                    </Columns>
                </asp:GridView>
            </div>
        </div>
    </div>
    <div class="col-lg-6">
        <div class="panel panel-default">
            <div class="panel-heading">
                <h3 class="panel-title"><b>Audit / Non Register Mechanic - Master Mapping Upload</b></h3>
            </div>
            <div class="panel-body">
                <div class="input-group form-group">
                    <asp:Label runat="server" Text="File Upload" Font-Bold="true" ID="lblEmpUpload" CssClass="input-group-addon"></asp:Label>
                    <asp:FileUpload ID="flEmpUpload" runat="server" CssClass="form-control" />
                </div>
                <div class="input-group form-group">
                    <asp:Button ID="btnEmpUpload" runat="server" Text="Upload Data" OnClick="btnEmpUpload_Click" CssClass="btn btn-success" Style="display: inline" />
                    &nbsp;
                        <asp:Button ID="btnEmpDownload" runat="server" Text="Sample Download" CssClass="btn btn-info" OnClientClick="downloadEmpAssetMap(); return false;" />
                </div>
                <h6 class="panel-title" style="font-size: 14px;"><b>File Upload Status</b></h6>
                <div class="col-lg-12">
                    <div class="col-lg-4">
                        <div class="input-group form-group">
                            <asp:Label runat="server" Text="Total Records : " Font-Bold="true" ID="lblEMttlRecords" CssClass="input-group-addon"></asp:Label>
                            <asp:Label runat="server" ID="txtEMttlRcrds" CssClass="input-group-addon"></asp:Label>
                        </div>
                    </div>
                    <div class="col-lg-4">
                        <div class="input-group form-group">
                            <asp:Label runat="server" Text="Successful Uploaded : " Font-Bold="true" ID="lblEMScsRcrds" CssClass="input-group-addon"></asp:Label>
                            <asp:Label runat="server" ID="txtEMSuccessRcrds" CssClass="input-group-addon"></asp:Label>
                        </div>
                    </div>
                    <div class="col-lg-4">
                        <div class="input-group form-group">
                            <asp:Label runat="server" Text="Fail to Upload : " Font-Bold="true" ID="lblFailRcrds" CssClass="input-group-addon"></asp:Label>
                            <asp:Label runat="server" ID="txtEMFailRcrds" CssClass="input-group-addon"></asp:Label>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <br />
        <div class="row">
            <div class="col-lg-12">
                <asp:GridView ID="gvMissdataAEM" runat="server" Width="100%" CssClass="gvMissdataAEM table tbl" OnPreRender="gvMissdataAEM_PreRender" ShowHeader="true" HeaderStyle-CssClass="table-header-gradient" AutoGenerateColumns="false" Font-Size="12px">
                    <Columns>
                        <asp:TemplateField HeaderText="No." HeaderStyle-Width="2px" ItemStyle-Width="2px">
                            <ItemTemplate>
                                <asp:Label ID="lblNo" runat="server" Text='<%# Container.DataItemIndex + 1 %>'></asp:Label>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="AssetCode" HeaderText="Asset Serial No." HeaderStyle-Width="60px" ItemStyle-Width="60px" />
                        <asp:BoundField DataField="ErrorMsg" HeaderText="ErrorMsg" HeaderStyle-Width="250px" ItemStyle-Width="250px" />
                    </Columns>
                </asp:GridView>
            </div>
        </div>
    </div>
    <%--<asp:Button ID="btnSendNoti" runat="server" Text="Escalation Notif" OnClick="btnSendNoti_Click" CssClass="btn btn-success" Style="display: inline" />--%>
</asp:Content>

