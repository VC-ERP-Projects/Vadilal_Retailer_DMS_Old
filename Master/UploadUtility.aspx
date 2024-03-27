<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="UploadUtility.aspx.cs" Inherits="Master_UploadUtility" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript">

        function downloadlveBal() {
            window.open("../Document/CSV Formats/LeaveBalUpload.csv");
        }

        function downloadMobile() {
            window.open("../Document/CSV Formats/CustMobileUpload.csv");
        }

    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel">
        <div class="panel-body">
            <div class="row">
                <div class="col-lg-12">
                    <div class="col-lg-6">
                        <div class="panel panel-default">
                            <div class="panel-heading">
                                <h3 class="panel-title"><b>Upload Leave Balance</b></h3>
                            </div>
                            <div class="panel-body">
                                <div class="row">
                                    <div class="col-lg-12">
                                        <div class="input-group form-group">
                                            <asp:Label runat="server" Text="Leave Balance" Font-Bold="true" ID="lblUpload" CssClass="input-group-addon"></asp:Label>
                                            <asp:FileUpload ID="OLVBLUpload" runat="server" CssClass="form-control" />
                                        </div>
                                    </div>
                                    <div class="col-lg-6">
                                        <br />
                                        <br />
                                        <div class="input-group form-group">
                                            <asp:Button ID="btnLBUpload" runat="server" Text="Upload Leave Balance" OnClientClick="return confirm('Are you sure want to upload Leave Balance?');" OnClick="btnLBUpload_Click" CssClass="btn btn-success" Style="display: inline" />
                                            <br />
                                            <br />
                                            <asp:Button ID="btnDownload" runat="server" Text="Download Leave Balance Format" CssClass="btn btn-info" OnClientClick="downloadlveBal(); return false;" />
                                        </div>
                                    </div>
                                    <div class="col-lg-6">
                                        <asp:GridView Font-Size="11px" ID="gvLeaveType" runat="server" CssClass="gvLeaveType table tbl nowrap" Width="100%" OnPreRender="gvLeaveType_PreRender"
                                            HeaderStyle-CssClass=" table-header-gradient" FooterStyle-CssClass=" table-header-gradient" EmptyDataText="No data found. ">
                                        </asp:GridView>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-lg-6">
                        <div class="panel panel-default">
                            <div class="panel-heading">
                                <h3 class="panel-title"><b>Upload Mobile Utility</b></h3>
                            </div>
                            <div class="panel-body">
                                <div class="row">
                                    <div class="col-lg-12">
                                        <div class="input-group form-group">
                                            <asp:Label runat="server" Text="Mobile Update" Font-Bold="true" ID="Label1" CssClass="input-group-addon"></asp:Label>
                                            <asp:FileUpload ID="fileUploadMobile" runat="server" CssClass="form-control" />
                                        </div>
                                        <br />
                                        <br />
                                        <div class="input-group form-group">
                                            <asp:Button ID="btnUploadMobile" runat="server" Text="Upload Mobile Update" OnClientClick="return confirm('Are you sure want to upload Mobile Update?');" OnClick="btnUploadMobile_Click" CssClass="btn btn-success" Style="display: inline" />
                                            <br />
                                            <br />
                                            <asp:Button ID="btnDwnloadMobile" runat="server" Text="Download Mobile Update Format" CssClass="btn btn-info" OnClientClick="downloadMobile(); return false;" />
                                        </div>
                                    </div>
                                </div>

                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-lg-12">
                    <asp:GridView ID="gvMissdata2" Font-Size="11px" runat="server" CssClass="gvMissdata2 table tbl" Width="100%" AutoGenerateColumns="false"
                        HeaderStyle-CssClass=" table-header-gradient">
                        <Columns>
                            <asp:TemplateField HeaderText="No." HeaderStyle-Width="3.5%">
                                <ItemTemplate>
                                    <asp:Label ID="lblNo" runat="server" Text='<%# Container.DataItemIndex + 1 %>'></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField DataField="CustomerCode" HeaderText="Customer Code" HeaderStyle-Width="30%" />
                            <asp:BoundField DataField="Phone" HeaderText="Mobile" HeaderStyle-Width="7%" />
                            <asp:BoundField DataField="Msg" HeaderText="ErrorMsg" HeaderStyle-Width="60%" />
                        </Columns>
                    </asp:GridView>
                </div>
            </div>
            <div class="row">
                <div class="col-lg-12">
                    <asp:GridView ID="gvMissdata" Font-Size="11px" runat="server" CssClass="gvMissdata table tbl" Width="100%" AutoGenerateColumns="false"
                        HeaderStyle-CssClass=" table-header-gradient">
                        <Columns>
                            <asp:TemplateField HeaderText="No." HeaderStyle-Width="3.5%">
                                <ItemTemplate>
                                    <asp:Label ID="lblNo" runat="server" Text='<%# Container.DataItemIndex + 1 %>'></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField DataField="Employee Code" HeaderText="Employee Code" HeaderStyle-Width="30%" />
                            <asp:BoundField DataField="Leave Type" HeaderText="Leave Type" HeaderStyle-Width="7%" />
                            <asp:BoundField DataField="Balance" HeaderText="Balance" HeaderStyle-Width="6%" />
                            <asp:BoundField DataField="ErrorMsg" HeaderText="ErrorMsg" HeaderStyle-Width="60%" />
                        </Columns>
                    </asp:GridView>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

