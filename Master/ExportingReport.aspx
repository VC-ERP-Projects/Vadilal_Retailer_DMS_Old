<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="ExportingReport.aspx.cs" Inherits="Master_ExportingReport" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript">

        $(function () {

            Relaod();

            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        });

        function EndRequestHandler2(sender, args) {
            Relaod();
        }

        function Relaod() {

            $('.frommindate').datepicker({
                numberOfMonths: 1,
                dateFormat: 'dd/mm/yy',
                changeMonth: true,
                changeYear: true,
                minDate: new Date(2017, 6, 1),
                onSelect: function (selected) {
                    $('.tomindate').datepicker("option", "minDate", selected);
                }
            });


            $('.tomindate').datepicker({
                numberOfMonths: 1,
                dateFormat: 'dd/mm/yy',
                changeMonth: true,
                changeYear: true,
                //"maxDate": '<%=DateTime.Now %>',
                onSelect: function (selected) {
                    $('.frommindate').datepicker("option", "maxDate", selected);
                }
            });
        }

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel panel-default">
        <div class="panel-body _masterForm">
            <div class="row" style="margin-bottom: 0px">
                <div class="col-lg-12">
                    <div class="col-lg-3">
                        <div class="input-group form-group">
                            <asp:Label ID="lblFromDate" runat="server" Text="From Date" CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtFromDate" TabIndex="1" runat="server" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="frommindate form-control"></asp:TextBox>
                        </div>
                    </div>
                    <div class="col-lg-3">
                        <div class="input-group form-group">
                            <asp:Label ID="lblToDate" runat="server" Text="To Date" CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtToDate" runat="server" TabIndex="3" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="tomindate form-control"></asp:TextBox>
                        </div>
                        <div class="input-group form-group">
                            <asp:Button Width="291" Text="Export Sale-Purchase ItemWise" ID="btnExportSPItemWise" OnClick="btnExportSPItemWise_Click" CssClass="btnExportSPItemWise btn btn-default" runat="server" />
                        </div>

                    </div>
                    <div class="col-lg-3">
                        <div class="input-group form-group">
                            <asp:Button Width="250" Text="Export Customer" ID="btnExportCust" OnClick="btnExportCust_Click" CssClass="btnExportCust btn btn-default" runat="server" />
                        </div>
                        <div class="input-group form-group">
                            <asp:Button Width="250" Text="Export Sales Register" ID="btnExportSalesReg" OnClick="btnExportSalesReg_Click" CssClass="btnExportSalesReg btn btn-default" runat="server" />
                        </div>

                        <div class="input-group form-group">
                            <asp:Button Width="250" Text="Export Sales Return Register" ID="btnExportSalesReturnReg" OnClick="btnExportSalesReturnReg_Click" CssClass="btnExportSalesReturnReg btn btn-default" runat="server" />
                        </div>
                    </div>
                    <div class="col-lg-3">
                        <div class="input-group form-group">
                            <asp:Button Width="250" Text="Export Item" ID="btnExportItem" OnClick="btnExportItem_Click" CssClass="btnExportItem btn btn-default" runat="server" />
                        </div>
                        <div class="input-group form-group">
                            <asp:Button Width="250" Text="Export Purchase Register" ID="btnExportPurchaseReg" OnClick="btnExportPurchaseReg_Click" CssClass="btnExportPurchaseReg btn btn-default" runat="server" />
                        </div>
                        <div class="input-group form-group">
                            <asp:Button Width="250" Text="Export Purchase Return Register" ID="btnExportPurchaseReturnReg" OnClick="btnExportPurchaseReturnReg_Click" CssClass="btnExportPurchaseReturnReg btn btn-default" runat="server" />
                        </div>
                    </div>
                    <%--<div class="col-lg-3">
                        <div class="input-group form-group">
                            <asp:Label ID="lblDivisionWise" runat="server" Text="Is Division Wise" CssClass="input-group-addon"></asp:Label>
                            <asp:CheckBox ID="chkIsDivisionWise" runat="server" CssClass="chkIsDivisionWise form-control" />
                        </div>
                    </div>--%>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

