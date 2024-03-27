<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="PurchaseReturn.aspx.cs" Inherits="Purchase_PurchaseReturn" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">

    <link href="../Scripts/datatable/jquery.dataTables.min.css" rel="stylesheet" />
    <script src="../Scripts/datatable/jquery.dataTables.min.js"></script>

    <script type="text/javascript">

        $(function () {
            Relaod();
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        });

        function EndRequestHandler2(sender, args) {
            Relaod();
        }

        function _btnCheck() {

            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');

            IsValid = $('._masterForm').data('bootstrapValidator').isValid();

            if (IsValid && Number($('.txtTTotalQty').val()) <= 0) {
                ModelMsg('Select at least one quantity.', 3);
                IsValid = false;
            }
            return IsValid;
        }

        function Relaod() {
            $(".txtSearch").keyup(function () {
                var word = this.value;
                $(".gvItem > tbody tr").each(function () {
                    var itmdata = $(this).find(".txtItem").val();

                    if (($(this).find("td").text().toUpperCase().indexOf(word.toUpperCase()) >= 0) || (itmdata.toUpperCase().indexOf(word.toUpperCase()) >= 0))
                        $(this).show();
                    else
                        $(this).hide();
                });
            });

            $('#tabs a').click(function (e) {
                e.preventDefault();
                $(this).tab('show');
            });

            $('.gvItem').DataTable({
                destroy: true,
                paging: false,
                sorting: false,
                ordering: false,
                info: true,
                //scrollCollapse: true,
                searching: false,
                fixedHeader: {
                    header: true,
                    footer: true,
                }
            });
        }

        function Checkvalidation() {

            if (Number(Container.find('.txtEnterQty').val() >= 0)) {
                ModelMsg('Purchase Return Quantity must be a greater than Zero', 3);
                return false;
            }
            return true;
        }

        function ChangeQuantity(txt) {
            var EnterQty = 0;
            if (txt != undefined) {

                if ($(txt).val() == "" || isNaN(parseInt($(txt).val()))) {
                    $(txt).val("0");
                }
                var Container = $(txt).parent().parent();
                var Data = Container.find('.ddlUnit').val().split(',');
                var Nos = Number(1 / Number(Data[3])).toFixed(2);
                EnterQty = Container.find('.txtEnterQty').val();

                var AvlQty = Number(Container.find('.txtAvailQty').val());
                if (EnterQty > AvlQty) {
                    ModelMsg('Total packet must be less than or equal to Warehouse/ Order qty!', 3);
                    $(txt).val("0");
                    EnterQty = 0;
                }

                Container.find('.lblUnitPrice').val(Number(Data[1]).toFixed(2));
                Container.find('.lblPrice').val(Number(Data[1]).toFixed(2));
                Container.find('.txtTotalQty').val(EnterQty * Number(Data[3]));
                Container.find('.lblSubTotal').val((Number(Container.find('.lblPrice').val()) * EnterQty).toFixed(2));
                Container.find('.lblTax').val(((EnterQty * Number(Data[2]))).toFixed(2));
                Container.find('.lblTotalPrice').val((Number(Container.find('.lblSubTotal').val()) + Number(Container.find('.lblTax').val())).toFixed(2));

                AddFunction(Container.find('.lblNo').text(), Data[0], Container.find('.ddlUnit option:selected').text().trim(), Container.find('.lblPrice').val(), Data[2], Container.find('.txtEnterQty').val() == undefined ? 0 : Container.find('.txtEnterQty').val(), Data[3], Container.find('.txtTotalQty').val(), Container.find('.lblSubTotal').val(), Container.find('.lblTax').val(), Container.find('.lblTotalPrice').val(), Container.find('.ddlReason').val(), Container.find('.hdnROW').val());
            }
            var main = $('.gvItem');
            var AllRows = $(main).find('tbody').find('tr');
            var AvailQty = 0, RequestQty = 0, DispatchQty = 0, TotalQty = 0, SubTotal = 0, Tax = 0, TotalPrice = 0;
            for (var i = 0; i < AllRows.length; i++) {

                if (txt == undefined) {

                    var Data = new Array();
                    //if ($('.ddlType').val() == "1") {
                    //    if ($(AllRows[i]).find('.lblUnitID').text() != null)
                    //        Data = $(AllRows[i]).find('.lblUnitID').text().split(',');
                    //}
                    //else {
                    //    if ($(AllRows[i]).find('.ddlUnit').val() != null)
                    //        Data = $(AllRows[i]).find('.ddlUnit').val().split(',');
                    //}

                    if ($(AllRows[i]).find('.ddlUnit').val() != null)
                        Data = $(AllRows[i]).find('.ddlUnit').val().split(',');

                    EnterQty = $(AllRows[i]).find('.txtEnterQty').val();

                    if (Data.length == 4) {
                        var Nos = Number(1 / Number(Data[3])).toFixed(2);
                        $(AllRows[i]).find('.lblPrice').val(Number(Data[1]).toFixed(2));
                        $(AllRows[i]).find('.txtTotalQty').val(EnterQty * Number(Data[3]));
                        $(AllRows[i]).find('.lblSubTotal').val((Number($(AllRows[i]).find('.lblPrice').val()) * EnterQty).toFixed(2));
                        $(AllRows[i]).find('.lblTax').val((EnterQty * Number(Data[2])).toFixed(2));
                        if ($('.ddlType').val() == "1") {
                            $(AllRows[i]).find('.txtAvailQty').val((Number($(AllRows[i]).find('.hdnAvailQty').val())));
                        }
                        else {
                            $(AllRows[i]).find('.txtAvailQty').val((Number($(AllRows[i]).find('.hdnAvailQty').val()) * Nos));
                        }
                        $(AllRows[i]).find('.lblTotalPrice').val((Number($(AllRows[i]).find('.lblSubTotal').val()) + Number($(AllRows[i]).find('.lblTax').val())).toFixed(2));
                    }
                }

                AvailQty += Number($(AllRows[i]).find('.txtAvailQty').val());
                RequestQty += Number($(AllRows[i]).find('.txtEnterQty').val());

                TotalQty += Number($(AllRows[i]).find('.txtTotalQty').val());
                SubTotal += Number($(AllRows[i]).find('.lblSubTotal').val());

                Tax += Number($(AllRows[i]).find('.lblTax').val());
                TotalPrice += Number($(AllRows[i]).find('.lblTotalPrice').val());
            }
            var FooterContainer = $(main).find('.table-header-gradient');

            FooterContainer.find('.txtTAvailQty').val(AvailQty);
            FooterContainer.find('.txtTRequestQty').val(RequestQty);
            FooterContainer.find('.txtTDispatchQty').val(DispatchQty);
            FooterContainer.find('.txtTTotalQty').val(TotalQty);
            FooterContainer.find('.lblTSubTotal').val(SubTotal.toFixed(2));
            FooterContainer.find('.lblTTax').val(Tax.toFixed(2));
            FooterContainer.find('.lblTPrice').val(TotalPrice.toFixed(2));
            isNaN(SubTotal) ? SubTotal = 0 : 0;
            isNaN(Tax) ? Tax = 0 : 0;
            isNaN(TotalPrice) ? TotalPrice = 0 : 0;

            $('.txtSubTotal').val(SubTotal.toFixed(2));
            $('.txtTax').val(Tax.toFixed(2));
            $('body').animate({ scrollTop: $(window).width() }, 1000);
            summary();
        }

        function summary() {

            var Total = Number($('.txtSubTotal').val()) + Number($('.txtTax').val());

            $('.txtRounding').val(Number(Math.round(Total) - Total).toFixed(2));

            $('.txtTotal').val(Number(Total + Number($('.txtRounding').val())).toFixed(2));
        }

        function AddFunction(LineID, UnitID, UnitName, UnitPrice, PriceTax, Quantity, MapQty, TotalQty, SubTotal, Tax, Total, ReasonID, RANKNO) {
            $.ajax({
                url: 'PurchaseReturn.aspx/AddRecord',
                type: 'POST',
                contentType: "application/json; charset=utf-8",
                data: "{'LineID':'" + LineID + "','UnitID':'" + UnitID + "','UnitName':'" + UnitName + "','UnitPrice':'" + UnitPrice + "','PriceTax':'" + PriceTax + "','Quantity':'" + Quantity + "','MapQty':'" + MapQty + "','TotalQty':'" + TotalQty + "','SubTotal':'" + SubTotal + "','Tax':'" + Tax + "','Total':'" + Total + "','ReasonID':'" + ReasonID + "','RANKNO':'" + RANKNO + "'}",
                dataType: "json",
                success: function (data) {
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    ModelMsg('Something is wrong...', 3);
                }
            });
        }

        function autoCompleteMat_OnClientPopulating(sender, args) {

            var DistID = '<%= ParentID%>';
            var key = DistID + '#';

            $('.gvItem').find('.lblItemID').each(function () {
                key += $(this).text() + ",";
            });

            key = key.substring(0, key.length - 1);

            sender.set_contextKey(key);
        }

        function CheckItemVal(txt) {
            var Container = $(txt).parent().parent();

            var txtval = Container.find('.txtItem').val().trim();
            if (txtval == "-" || txtval == " - " || txtval == "") {
                Container.find('.txtItem').val('');
            }
        }

    </script>
    <style>
        .lblPrice, .txtAvailQty, .ddlUnit, .txtEnterQty, .txtTotalQty, .lblSubTotal, .lblTax, .lblTotalPrice, .ddlReason, .txtTAvailQty, .txtTRequestQty, .txtTTotalQty, .lblTSubTotal, .lblTTax, .lblTPrice {
            height: 20px;
            padding: 0px 5px;
            font-size: 11px;
            text-align: right;
        }

        .txtItem {
            height: 28px;
            padding: 6px 5px;
            font-size: 11px;
        }

        .table > thead > tr > th, .table > tbody > tr > th, .table > tfoot > tr > th, .table > thead > tr > td, .table > tbody > tr > td, .table > tfoot > tr > td {
            padding: 5px;
            font-size: 11px;
        }

        .lblRight {
            text-align: right;
        }

        .hideClass {
            display: none;
        }

        table.dataTable thead .sorting_asc:after {
            display: none;
        }

        table.dataTable {
            margin-top: 0 !important;
        }

        .gvItemWrapper {
            max-height: 54vh;
            width: 100%;
            overflow: hidden auto;
        }

            .gvItemWrapper table {
                border-collapse: separate !important;
                border-top: none;
                border-bottom: none;
            }

                .gvItemWrapper table thead tr th {
                    border-left: none;
                    border-top: 1px solid #111 !important;
                }

                    .gvItemWrapper table thead tr th:last-child {
                        border-right: none;
                    }

                .gvItemWrapper table thead tr th {
                    position: sticky !important;
                    top: 0px;
                    background: linear-gradient(to bottom, rgba(245,246,246,1) 0%,rgba(219,220,226,1) 3%,rgba(184,186,198,1) 59%,rgba(221,223,227,1) 100%,rgba(245,246,246,1) 100%);
                }

                .gvItemWrapper table tbody tr td:first-child {
                    border-left: none;
                }

                .gvItemWrapper table tbody tr td:last-child {
                    border-right: none;
                }

                .gvItemWrapper table tfoot tr td:first-child {
                    border-left: none;
                }

                .gvItemWrapper table tfoot tr td:last-child {
                    border-right: none;
                }

                .gvItemWrapper table tbody tr td {
                    border-left: none;
                }

                .gvItemWrapper table tfoot tr td {
                    position: sticky !important;
                    bottom: 0px;
                    border-left: none;
                    background: linear-gradient(to bottom, rgba(245,246,246,1) 0%,rgba(219,220,226,1) 3%,rgba(184,186,198,1) 59%,rgba(221,223,227,1) 100%,rgba(245,246,246,1) 100%);
                }

            .gvItemWrapper .dataTables_info {
                display: none;
            }

        .netamt {
            width: 22%;
            display: inline-block;
        }
    </style>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel panel-default">
        <div class="panel-body _masterForm">
            <div class="row" style="margin-bottom: 6px">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="Vendor" ID="lblVendor" runat="server" CssClass="input-group-addon" />
                        <asp:TextBox runat="server" ID="txtVendor" TabIndex="1" AutoPostBack="true" OnTextChanged="txtTemplate_TextChanged" CssClass="form-control" Style="background-color: rgb(250, 255, 189);" />
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtVendor" runat="server" ServicePath="../WebService.asmx"
                            UseContextKey="true" ServiceMethod="GetActiveVendor" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtVendor">
                        </asp:AutoCompleteExtender>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtBill" runat="server" ServicePath="../WebService.asmx"
                            UseContextKey="true" ServiceMethod="GetActiveInward" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtVendor">
                        </asp:AutoCompleteExtender>
                    </div>
                    <div class="input-group form-group" style="display: none;">
                        <asp:Label Text="Template" ID="Label1" runat="server" CssClass="input-group-addon" />
                        <asp:TextBox runat="server" ID="txtTemplate" TabIndex="3" OnTextChanged="txtTemplate_TextChanged" AutoPostBack="true" CssClass="form-control" />
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="ACEtxtName" runat="server" ServicePath="../WebService.asmx"
                            UseContextKey="true" ServiceMethod="GetActiveSITM" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtTemplate">
                        </asp:AutoCompleteExtender>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label Text="Invoice Date" ID="lblInvoiceDate" CssClass="input-group-addon" runat="server" />
                        <asp:TextBox runat="server" ID="txtInvoiceDate" TabIndex="4" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="datepick form-control" Enabled="false" />
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="Received Date" runat="server" CssClass="input-group-addon" />
                        <asp:TextBox runat="server" ID="txtReceivedDate" disabled="disabled" TabIndex="2" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="datepick form-control" />
                    </div>
                    <div class="input-group form-group">
                        <asp:Label Text="Return Date" runat="server" CssClass="input-group-addon" />
                        <asp:TextBox runat="server" ID="txtDate" disabled="disabled" TabIndex="5" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="datepick form-control" />
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label runat="server" ID="lblDivision" Text="Division" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox runat="server" TabIndex="3" ID="txtDivision" CssClass="form-control" Enabled="false" />
                    </div>
                    <div class="input-group form-group">
                        <asp:Button Text="Submit" runat="server" CssClass="btn btn-default" TabIndex="7" ID="btnSubmit" OnClick="btnSubmit_Click" OnClientClick="return _btnCheck();" />
                        <asp:Button Text="Cancel" ID="btnCancel" Style="margin-left: 5px" CssClass="btn btn-default" TabIndex="8" OnClick="btnCancel_Click" runat="server" UseSubmitBehavior="false" CausesValidation="false" />
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group" style="display: none;">
                        <asp:Label Text="Type" ID="lblType" runat="server" CssClass="input-group-addon" />
                        <asp:DropDownList runat="server" TabIndex="1" CssClass="ddlType form-control" ID="ddlType" Enabled="false" AutoPostBack="true" OnSelectedIndexChanged="ddlType_SelectedIndexChanged">
                            <asp:ListItem Text="Against Bill" Value="1" Selected="True" />
                            <asp:ListItem Text="Other" Value="2" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group" style="display: none;">
                        <asp:Label ID="lblwarehouse" Text="Warehouse" CssClass="input-group-addon" runat="server"></asp:Label>
                        <asp:DropDownList runat="server" ID="ddlWhs" TabIndex="6" DataValueField="WhsID" DataTextField="WhsName" CssClass="form-control"
                            AutoPostBack="True" OnSelectedIndexChanged="txtTemplate_TextChanged">
                        </asp:DropDownList>
                    </div>
                </div>
            </div>
            <div class="row" style="margin-bottom: 8px">
                <div class="col-lg-8">
                </div>
                <div class="col-lg-4">
                    <asp:TextBox runat="server" placeholder="Search here" TabIndex="6" CssClass="txtSearch form-control" />
                </div>
            </div>

            <div class="gvItemWrapper">
                <asp:GridView runat="server" ID="gvItem" CssClass="gvItem HighLightRowColor2 table" ShowFooter="true" ShowHeader="true" AutoGenerateColumns="false" OnPreRender="gvItems_PreRender" OnRowDataBound="gvItem_RowDataBound" HeaderStyle-CssClass="table-header-gradient" FooterStyle-CssClass="table-header-gradient">
                    <Columns>
                        <asp:TemplateField HeaderText="Sr." HeaderStyle-Width="3px" HeaderStyle-CssClass="lblRight" ItemStyle-HorizontalAlign="Right">
                            <ItemTemplate>
                                <%#Container.DataItemIndex+1 %>
                            </ItemTemplate>
                            <HeaderStyle Width="3%" />
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Item Code & Name">
                            <ItemTemplate>
                                <input type="hidden" id="hdnROW" class="hdnROW" value='<%# Eval("RANKNO") %>' runat="server" />
                                <asp:Label ID="lblNo" CssClass="lblNo" runat="server" Text='<%# Container.DataItemIndex %>' Style="display: none;"></asp:Label>
                                <asp:Label ID="lblItemID" CssClass="lblItemID" runat="server" Text='<%# Eval("ItemID") %>' Style="display: none;"></asp:Label>
                                <asp:Label runat="server" ID="txtItem" AutoPostBack="true" CssClass="txtItem" Text='<%#Eval("ItemName")!=null? String.Format("{0} - {1}", Eval("ItemCode"),Eval("ItemName")):string.Empty  %>' onfocus="CheckItemVal(this);" />
                                <%--<asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtItem" runat="server" ServicePath="../WebService.asmx" OnClientPopulating="autoCompleteMat_OnClientPopulating" UseContextKey="true" ServiceMethod="GetActiveMaterialByPlant" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtItem">
                                </asp:AutoCompleteExtender>--%>
                            </ItemTemplate>
                            <HeaderStyle Width="20%" />
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Unit">
                            <ItemTemplate>
                                <asp:Label Text='<%# Eval("UnitID") %>' ID="lblUnitID" CssClass="lblUnitID" runat="server" Style="display: none;" />
                                <asp:Label Text='<%# Eval("UnitName") %>' ID="lblUnit" runat="server" Visible="false" />
                                <asp:DropDownList runat="server" ID="ddlUnit" CssClass="ddlUnit form-control" DataValueField="Value" DataTextField="Key" onchange="ChangeQuantity(this);">
                                </asp:DropDownList>
                            </ItemTemplate>
                            <HeaderStyle Width="8%" />
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Rate" HeaderStyle-CssClass="lblRight" ItemStyle-HorizontalAlign="Right">
                            <ItemTemplate>
                                <asp:TextBox ID="lblPrice" Text='<%# Eval("UnitPrice","{0:0.00}") %>' CssClass="lblPrice form-control" Enabled="false" runat="server"></asp:TextBox>
                            </ItemTemplate>
                            <FooterTemplate>
                                <asp:Label runat="server" Text="Total" />
                            </FooterTemplate>
                            <FooterStyle CssClass="lblRight" />
                            <HeaderStyle Width="6%" />
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Invoice Qty" HeaderStyle-CssClass="lblRight" ItemStyle-HorizontalAlign="Right">
                            <ItemTemplate>
                                <input type="hidden" id="hdnAvailQty" value='<%# Eval("AvailQty") %>' class="hdnAvailQty" runat="server" />
                                <asp:TextBox ID="txtAvailQty" CssClass="txtAvailQty form-control" Enabled="false" runat="server" Text=' <%# Eval("AvailQty")%>'></asp:TextBox>
                            </ItemTemplate>
                            <FooterTemplate>
                                <asp:TextBox ID="txtTAvailQty" CssClass="txtTAvailQty form-control" Enabled="false" runat="server"></asp:TextBox>
                            </FooterTemplate>
                            <HeaderStyle Width="6%" />
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Return Qty" HeaderStyle-CssClass="lblRight" ItemStyle-HorizontalAlign="Right">
                            <ItemTemplate>
                                <asp:TextBox ID="txtEnterQty" CssClass="txtEnterQty form-control" runat="server" Text='<%# Eval("Quantity","{0:0}") %>' onchange="ChangeQuantity(this);" onkeyup="enter(this);" onkeypress="return isNumberKey(event);" onpaste="return false;" data-bv-stringlength="false" MaxLength="12" onBlur="SetQtyDataBlur(this);" onfocus="SetQtyDataFocus(this);" autocomplete="off" AutoCompleteType="Disabled"></asp:TextBox>
                            </ItemTemplate>
                            <FooterTemplate>
                                <asp:TextBox ID="txtTRequestQty" CssClass="txtTRequestQty form-control" Enabled="false" runat="server"></asp:TextBox>
                            </FooterTemplate>
                            <HeaderStyle Width="5%" />
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Total Qty"  HeaderStyle-CssClass="lblRight" ItemStyle-HorizontalAlign="Right">
                            <ItemTemplate>
                                <asp:TextBox ID="txtTotalQty" CssClass="txtTotalQty form-control" runat="server" Enabled="false" Text='<%# Eval("TotalQty","{0:0.00}") %>'></asp:TextBox>
                            </ItemTemplate>
                            <FooterTemplate>
                                <asp:TextBox ID="txtTTotalQty" CssClass="txtTTotalQty form-control" Enabled="false" runat="server"></asp:TextBox>
                            </FooterTemplate>
                            <HeaderStyle Width="5%" />
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Gross Amt" HeaderStyle-CssClass="lblRight" ItemStyle-HorizontalAlign="Right">
                            <ItemTemplate>
                                <asp:TextBox ID="lblSubTotal" CssClass="lblSubTotal form-control" Enabled="false" runat="server" Text='<%# Eval("SubTotal","{0:0.00}") %>'></asp:TextBox>
                            </ItemTemplate>
                            <FooterTemplate>
                                <asp:TextBox ID="lblTSubTotal" CssClass="lblTSubTotal form-control" Enabled="false" runat="server"></asp:TextBox>
                            </FooterTemplate>
                            <HeaderStyle Width="6%" />
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="GST" HeaderStyle-CssClass="lblRight" ItemStyle-HorizontalAlign="Right">
                            <ItemTemplate>
                                <asp:TextBox ID="lblTax" CssClass="lblTax form-control" runat="server" Enabled="false" Text='<%# Eval("Tax","{0:0.00}") %>'></asp:TextBox>
                            </ItemTemplate>
                            <FooterTemplate>
                                <asp:TextBox ID="lblTTax" CssClass="lblTTax form-control" Enabled="false" runat="server"></asp:TextBox>
                            </FooterTemplate>
                            <HeaderStyle Width="6%" />
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Net Amount" HeaderStyle-CssClass="lblRight" ItemStyle-HorizontalAlign="Right">
                            <ItemTemplate>
                                <asp:TextBox ID="lblTotalPrice" CssClass="lblTotalPrice form-control" Enabled="false" runat="server" Text='<%# Eval("Total","{0:0.00}") %>'></asp:TextBox>
                            </ItemTemplate>
                            <FooterTemplate>
                                <asp:TextBox ID="lblTPrice" CssClass="lblTPrice form-control" Enabled="false" runat="server"></asp:TextBox>
                            </FooterTemplate>
                            <HeaderStyle Width="6%" />
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Reason">
                            <ItemTemplate>
                                <asp:DropDownList runat="server" ID="ddlReason" onchange="ChangeQuantity(this);" CssClass="ddlReason form-control" DataValueField="Value" DataTextField="Text">
                                </asp:DropDownList>
                            </ItemTemplate>
                            <HeaderStyle Width="10%" />
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>

            <div id="divdata" runat="server" class="row" style="margin-bottom: 0">
                <div class="col-lg-12 tableDataInfo"></div>
                <div class="col-lg-4" style="display: none;">
                    <div class="input-group form-group">
                        <asp:Label Text="Sub Total" ID="lblSubTotal" CssClass="input-group-addon" runat="server" />
                        <asp:TextBox runat="server" ID="txtSubTotal" CssClass="txtSubTotal form-control" Enabled="false" />
                    </div>
                    <div class="input-group form-group">
                        <asp:Label Text="Tax" ID="lblTax" runat="server" CssClass="input-group-addon" />
                        <asp:TextBox runat="server" ID="txtTax" CssClass="txtTax form-control" Enabled="false" />
                    </div>
                </div>
                <div class="col-lg-7 _textArea">
                    <div class="input-group form-group">
                        <asp:Label Text="Notes" ID="lblNotes" runat="server" CssClass="input-group-addon" />
                        <asp:TextBox runat="server" ID="txtNotes" TabIndex="8" TextMode="MultiLine" CssClass="form-control" Style="resize: none;" />
                    </div>
                </div>
                <div class="netamt">
                    <div class="input-group form-group">
                        <asp:Label Text="Rounding" ID="lblRounding" CssClass="input-group-addon lblRight" runat="server" />
                        <asp:TextBox runat="server" ID="txtRounding" CssClass="txtRounding form-control lblRight" onkeypress="return isNumberKeyForAmount(event);" onpaste="return false;" onchange="summary();" Enabled="false" />
                    </div>
                    <div class="input-group form-group">
                        <asp:Label Text="Net Amount" ID="lblTotal" runat="server" CssClass="input-group-addon lblRight" />
                        <asp:TextBox runat="server" ID="txtTotal" CssClass="txtTotal form-control lblRight" Enabled="false" />
                    </div>
                </div>
                <div class="col-lg-1">
                </div>
            </div>
        </div>
    </div>
</asp:Content>
