<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="ShipmentCreation.aspx.cs" Inherits="Reports_ShipmentCreation" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript">

        $(function () {
            ReLoadFn();
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        });

        function EndRequestHandler2(sender, args) {
            ReLoadFn();
        }

        function ReloadRadio() {
            if ($('.chkCheck').length == $('.chkCheck:checked').length)
                $('.chkhead').prop('checked', true);
            else
                $('.chkhead').prop('checked', false);
        }

        function ReLoadFn() {

            $(".txtgvItemSearch").keyup(function () {
                var word = this.value;
                $(".gvOrder > tbody tr").not(':first').each(function () {
                    if ($(this).find("td").text().toUpperCase().indexOf(word.toUpperCase()) >= 0)
                        $(this).show();
                    else
                        $(this).hide();

                });
            });
        }

        function ClickHead(chk) {
            if ($(chk).is(':checked')) {
                $('.chkCheck').prop('checked', true);
            }
            else {
                $('.chkCheck').prop('checked', false);
            }
        }

        function _btnCheck() {
            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');

            IsValid = $('._masterForm').data('bootstrapValidator').isValid();
        }

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel">
        <div class="panel-body _masterForm">
            <div class="row">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblFromDate" runat="server" Text="From Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtFromDate" runat="server" TabIndex="1" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="fromdate form-control"></asp:TextBox>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="lblShipNo" runat="server" Text="Shipment Number" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtShipmentNo" runat="server" TabIndex="3" CssClass="form-control" Enabled="false" Text="Auto Generated"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblToDate" runat="server" Text="To Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtToDate" runat="server" TabIndex="3" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="todate form-control"></asp:TextBox>
                    </div>

                    <div class="input-group form-group">
                        <asp:Label ID="lblStartDT" runat="server" Text="Start Date/Time" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtStartDateTime" runat="server" TabIndex="3" CssClass="form-control" Enabled="false"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group" id="divvehicle" runat="server">
                        <asp:Label Text="Vehicle No." ID="lblVehicle" runat="server" CssClass="input-group-addon" />
                        <asp:TextBox runat="server" ID="txtVehicle" TabIndex="6" CssClass="form-control" Style="background-color: rgb(250, 255, 189);" />
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtVehicle" runat="server" ServicePath="../WebService.asmx"
                            UseContextKey="true" ServiceMethod="GetActiveVehicle" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtVehicle">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-lg-12">
                    <asp:Button ID="btnSearch" runat="server" Text="Search" TabIndex="5" CssClass="btn btn-default" OnClientClick="return _btnCheck();" OnClick="btnSearch_Click" />
                    <asp:Button ID="btnGenerat" runat="server" Text="Generate" TabIndex="6" CssClass="btn btn-info" OnClick="btnGenerat_Click" />
                </div>
            </div>
            <div class="row">
                <div class="col-lg-12">
                    <asp:GridView runat="server" ID="gvShipment" CssClass="table" AutoGenerateColumns="false" Font-Size="11px" HeaderStyle-CssClass="table-header-gradient" EmptyDataText="No data found.">
                        <Columns>
                            <asp:TemplateField HeaderText="Sr.">
                                <ItemTemplate>
                                    <asp:HiddenField ID="hdnSaleID" runat="server" Value='<%# Eval("SaleID") %>' />
                                    <asp:Label ID="lblNo" runat="server" Text='<%# Container.DataItemIndex + 1 %>' />
                                </ItemTemplate>
                                <HeaderStyle Width="3%" />
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Check">
                                <HeaderTemplate>
                                    <input type="checkbox" name="chkhead" class="chkhead" id="chkhead" runat="server" onchange="ClickHead(this);" />
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <input type="checkbox" name="chkCheck" class="chkCheck" id="chkcheck" runat="server" onchange="ReloadRadio();" />
                                </ItemTemplate>
                                <HeaderStyle Width="3%" />
                                <ItemStyle HorizontalAlign="Left" />
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Invoice">
                                <ItemTemplate>
                                    <asp:Label ID="lblInv" Text='<%# Eval("InvoiceNumber") %>' runat="server"></asp:Label>
                                </ItemTemplate>
                                <HeaderStyle Width="6%" />
                                <ItemStyle HorizontalAlign="Left" />
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Date">
                                <ItemTemplate>
                                    <asp:Label ID="lblDate" Text='<%# Eval("Date","{0:dd/MM/yyyy}") %>' runat="server"></asp:Label>
                                </ItemTemplate>
                                <HeaderStyle Width="6%" />
                                <ItemStyle HorizontalAlign="Left" />
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Qty">
                                <ItemTemplate>
                                    <asp:Label ID="lblQty" Text='<%# Eval("Qty","{0:0}") %>' runat="server"></asp:Label>
                                </ItemTemplate>
                                <ItemStyle HorizontalAlign="Right" Width="3%" />
                                <HeaderStyle Width="5%" />
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Net Amount">
                                <ItemTemplate>
                                    <asp:Label ID="lblTotal" runat="server" Text='<%# Eval("Total","{0:0.00}") %>'></asp:Label>
                                </ItemTemplate>
                                <HeaderStyle Width="8%" />
                                <ItemStyle HorizontalAlign="Right" />
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Distributor Code">
                                <ItemTemplate>
                                    <asp:Label ID="lblCustCode" Text='<%# Eval("CustomerCode") %>' runat="server"></asp:Label>
                                </ItemTemplate>
                                <HeaderStyle Width="10%" />
                                <ItemStyle HorizontalAlign="Left" />
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Distributor Name">
                                <ItemTemplate>
                                    <asp:Label ID="lblCustName" Text='<%# Eval("CustomerName") %>' runat="server"></asp:Label>
                                </ItemTemplate>
                                <HeaderStyle Width="30%" />
                                <ItemStyle HorizontalAlign="Left" />
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="City">
                                <ItemTemplate>
                                    <asp:Label ID="lblCity" Text='<%# Eval("City") %>' runat="server"></asp:Label>
                                </ItemTemplate>
                                <HeaderStyle Width="10%" />
                                <ItemStyle HorizontalAlign="Left" />
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Vehicle">
                                <ItemTemplate>
                                    <asp:Label ID="lblVehicle" Text='<%# Eval("VehicleNumber") %>' runat="server"></asp:Label>
                                </ItemTemplate>
                                <HeaderStyle Width="10%" />
                                <ItemStyle HorizontalAlign="Left" />
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

