<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="SalesReturn.aspx.cs" Inherits="Sales_SalesReturn" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <link href="../Scripts/datatable_new/jquery.dataTables.min.css" rel="stylesheet" />
    <link href="../Scripts/datatable_new/buttons.dataTables.min.css" rel="stylesheet" />

    <script src="../Scripts/datatable_new/jquery.dataTables.min.js"></script>
    <script src="../Scripts/datatable_new/dataTables.buttons.min.js"></script>
    <script src="../Scripts/datatable_new/buttons.html5.min.js"></script>
    <script src="../Scripts/datatable_new/pdfmake.min.js"></script>
    <script src="../Scripts/datatable_new/vfs_fonts.js"></script>
    <script src="../Scripts/datatable_new/jszip.min.js"></script>

    <link href="../Scripts/colorbox/colorbox.css" rel="stylesheet" />
    <script type="text/javascript" src="../Scripts/colorbox/jquery.colorbox-min.js"></script>
    <script type="text/javascript" src="../Scripts/fixHeaderFooter.js"></script>

    <script type="text/javascript">

        $(function () {

            Relaod();
            $(".gvItem").tableHeadFixer('55vh');
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);

        });

        function EndRequestHandler2(sender, args) {
            Relaod();
        }

        function _btnCheck() {

            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');

            IsValid = $('._masterForm').data('bootstrapValidator').isValid();
            //$(".txtEnterQty").each(function (index) {
            //    if (parseFloat($(this).val()) <= 0) {
            //        ModelMsg('Select at least one quantity 2.', 3);
            //        IsValid = false;
            //        return IsValid;
            //    }
            //    else {
            //        IsValid = true;
            //        return IsValid;
            //    }
            //});
            if (Number($('.txtTRequestQty').val()) <= 0) {
                ModelMsg('Select at least one quantity.', 3);
                IsValid = false;
                return IsValid;
            }

            if (IsValid && Number($('.txtTRequestQty').val()) <= 0) {
                ModelMsg('Select at least one quantity.', 3);
                IsValid = false;
                return IsValid;
            }

            if ($(".hdnIsFullItem").val() == "1") {
                $(".txtAvailQty").each(function (index) {
                    if (parseFloat($(this).val()) != parseFloat($(".txtEnterQty").eq(index).val())) {
                        ModelMsg('This invoice contains QPS Scheme.Only full return invoice is acceptable.', 3);
                        IsValid = false;
                        return IsValid;
                    }
                });

            }

            return IsValid;
        }

        function Relaod() {

            // var table = $('.gvItem').DataTable();
            var aryJSONColTable = [];
            aryJSONColTable.push({ "width": "40px", "aTargets": 0 });
            aryJSONColTable.push({ "width": "300px", "aTargets": 1 });
            aryJSONColTable.push({ "width": "40px", "aTargets": 2 });
            aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 3 });
            aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyCenter", "aTargets": 4 });
            aryJSONColTable.push({ "width": "50px", "sClass": "dtbodyCenter", "aTargets": 5 });
            aryJSONColTable.push({ "width": "50px", "sClass": "dtbodyRight", "aTargets": 6 });
            aryJSONColTable.push({ "width": "50px", "sClass": "dtbodyRight", "aTargets": 7 });//"sClass": "dtbodyLeft",
            aryJSONColTable.push({ "width": "80px", "sClass": "dtbodyRight", "aTargets": 8 });
            aryJSONColTable.push({ "width": "80px", "sClass": "dtbodyRight", "aTargets": 9 });
            aryJSONColTable.push({ "width": "80px", "sClass": "dtbodyRight", "aTargets": 10 });

            $('.gvItem').DataTable({
                bFilter: false,
                scrollCollapse: true,
                "sExtends": "collection",
                scrollX: true,
                scrollY: '50vh',
                responsive: true,
                "bPaginate": false,
                ordering: false,
                "bInfo": false,
                "autoWidth": false,
                destroy: true,
                "aoColumnDefs": aryJSONColTable,
            });

            $('.dataTables_scrollFoot').css('overflow', 'auto');
            $($.fn.dataTable.tables(true)).DataTable().columns.adjust();

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
        }

        function Checkvalidation() {
            if (Number(Container.find('.txtEnterQty').val() >= 0)) {
                ModelMsg('Wastage Quantity must be a greater than Zero', 3);
                return false;
            }
            return true;
        }

        function CheckItemVal(txt) {
            var Container = $(txt).parent().parent();

            var txtval = Container.find('.txtItem').val().trim();
            if (txtval == "-" || txtval == " - " || txtval == "") {
                Container.find('.txtItem').val('');
            }
        }

        function ChangeQuantity(txt) {
            var EnterQty = 0;

            if (txt != undefined) {

                if ($(txt).val() == "" || isNaN(parseInt($(txt).val()))) {
                    $(txt).val("0");
                }
                var Container = $(txt).parent().parent();
                var Data = Container.find('.lblUnitID').text().split(',');

                if (txt.className.indexOf('ddlReason') >= 0)
                    EnterQty = Container.find('.txtEnterQty').val();
                else if ($(txt).val() == "" || isNaN(parseInt($(txt).val()))) {
                    $(txt).val("0");
                    EnterQty = 0;
                }
                else
                    EnterQty = $(txt).val();

                var AvlQty = Number(Container.find('.txtAvailQty').val());
                if (EnterQty > AvlQty) {
                    ModelMsg('Total packet must be less than or equal to available invoice qty!', 3);
                    $(txt).val("0");
                    EnterQty = 0;
                }

                Container.find('.lblPrice').val((Number(Data[1]) - ((Number(Data[1]) * Number(Container.find('.hdnItemScheme').val())) / 100)).toFixed(2));

                Container.find('.txtTotalQty').val(EnterQty * Number(Data[3]));

                Container.find('.lblSubTotal').val((Number(Container.find('.lblPrice').val()) * EnterQty).toFixed(2));
                Container.find('.lblTax').val(((EnterQty * (Number(Data[2]) - ((Number(Data[2]) * Number(Container.find('.hdnItemScheme').val())) / 100)))).toFixed(2));

                Container.find('.hdnSubTotal').val((Number(Container.find('.lblSubTotal').val()) -
                    ((Number(Container.find('.lblSubTotal').val()) * (Number(Container.find('.hdnScheme').val()))) / 100)));
                Container.find('.hdnTax').val((Number(Container.find('.lblTax').val()) -
                    ((Number(Container.find('.lblTax').val()) * (Number(Container.find('.hdnScheme').val()))) / 100)));

                Container.find('.lblTotalPrice').val((Number(Container.find('.lblSubTotal').val()) + Number(Container.find('.lblTax').val())).toFixed(2));
            }

            var main = $('.gvItem');
            var AllRows = $(main).find('tbody').find('tr');

            var RequestQty = 0, TotalQty = 0, SubTotal = 0, Tax = 0, TotalPrice = 0, hdnTotal = 0, hdnTax = 0, TotalInvQty = 0, TotalReturnQty = 0, TotalAvailQty = 0;

            for (var i = 0; i < AllRows.length; i++) {

                RequestQty += Number($(AllRows[i]).find('.txtEnterQty').val());
                TotalQty += Number($(AllRows[i]).find('.txtTotalQty').val());
                SubTotal += Number($(AllRows[i]).find('.lblSubTotal').val());
                Tax += Number($(AllRows[i]).find('.lblTax').val());
                TotalPrice += Number($(AllRows[i]).find('.lblTotalPrice').val());

                hdnTotal += Number($(AllRows[i]).find('.hdnSubTotal').val());
                hdnTax += Number($(AllRows[i]).find('.hdnTax').val());
                TotalInvQty += Number($(AllRows[i]).find('.txtInvQty').val());
                TotalReturnQty += Number($(AllRows[i]).find('.txtTotalReturn').val());
                TotalAvailQty += Number($(AllRows[i]).find('.txtAvailQty').val());

            }

            var FooterContainer = $(main).find('.table-header-gradient');
            FooterContainer.find('.txtTRequestQty').val('');
            FooterContainer.find('.txtTTotalQty').val('');
            FooterContainer.find('.lblTSubTotal').val('');
            FooterContainer.find('.lblTTax').val('');
            FooterContainer.find('.lblTPrice').val('');
            FooterContainer.find('.txtTotalAvailQty').val('');
            FooterContainer.find('.txtAlreadyreturnQty').val('');
            FooterContainer.find('.txtTotalInvoiceQty').val('');



            FooterContainer.find('.txtTRequestQty').val(RequestQty);
            FooterContainer.find('.txtTTotalQty').val(TotalQty);
            FooterContainer.find('.lblTSubTotal').val(SubTotal.toFixed(2));
            FooterContainer.find('.lblTTax').val(Tax.toFixed(2));
            FooterContainer.find('.lblTPrice').val(TotalPrice.toFixed(2));

            FooterContainer.find('.txtTotalAvailQty').val(TotalAvailQty);
            FooterContainer.find('.txtAlreadyreturnQty').val(TotalReturnQty);
            FooterContainer.find('.txtTotalInvoiceQty').val(TotalInvQty);

            isNaN(SubTotal) ? SubTotal = 0 : 0;
            isNaN(Tax) ? Tax = 0 : 0;
            isNaN(TotalPrice) ? TotalPrice = 0 : 0;

            $('.txtScheme').val(Number(Number(SubTotal) - Number(hdnTotal)).toFixed(2));

            $('.txtSubTotal').val(Number(hdnTotal).toFixed(2));
            $('.txtTax').val(Number(hdnTax).toFixed(2));

            summary();


        }

        function summary() {

            var Total = Number($('.txtSubTotal').val()) + Number($('.txtTax').val());

            $('.txtRounding').val(Number(Math.round(Total) - Total).toFixed(2));

            $('.txtTotal').val(Number(Total + Number($('.txtRounding').val())).toFixed(2));
        }

        function autoCompleteMat_OnClientPopulating(sender, args) {
            Relaod();
            var CustID = 0;
            var ItemID = 0;

            var str = $('.txtCustomer').val().split('-');
            if (str.length > 2) {
                CustID = str[2].trim();
            }
            else {
                CustID = 0;
            }

            var str = $('.txtItem').val().split('-');
            if (str.length > 1) {
                ItemID = str[0].trim();
            }
            else {
                ItemID = 0;
            }
            sender.set_contextKey(CustID + "-" + ItemID);
        }

        function OpenInvoices(returnNo) {
            $.colorbox({
                width: '80%',
                height: '80%',
                iframe: true,
                href: '../Reports/ViewReport.aspx?ReturnNo=' + returnNo + '&ReturnIsOld=false'
            });
        }

        function AllAvailReturn() {
            var main = $('.gvItem');
            var FooterContainer = $(main).find('.table-header-gradient');
            //var AvailQty = FooterContainer.find('.txtTotalAvailQty').val();
            //alert(AvailQty);
            var RetQty = 0;
            var TotalReturnQty = 0;
            var AllRows = $(main).find('tbody').find('tr');
            for (var i = 0; i < AllRows.length; i++) {
                $(AllRows[i]).find('.txtEnterQty').val($(AllRows[i]).find('.txtAvailQty').val());
                RetQty += Number($(AllRows[i]).find('.txtAvailQty').val());
            }
            $('.txtEnterQty').change();
            if (RetQty == 0) {
                ModelMsg('Already Return All Qty.!', 3);
            }
        }
    </script>
    <style>
        .input-group-addon {
            font-size: 1.1rem !important;
            font-weight: bold;
            text-align: right;
        }

        .search {
            background-color: lightyellow !important;
        }

        .CompletionListClass {
            font-size: 10px !important;
        }

        #page-content-wrapper {
            overflow: hidden;
        }

        .form-control {
            padding: 6px 4px !important;
        }

        .dataTables_scrollHeadInner {
            width: auto;
        }

        .dataTables_scrollBody {
            overflow-x: hidden !important;
        }

        .dataTables_scroll {
            overflow: auto;
        }

        table.dataTable thead th.dtbodySrNo {
            padding: 5px 10px !important;
        }

        .dtbodyRight {
            text-align: right !important;
            padding-right: 5px !important;
        }

        .dtbodyCenter {
            text-align: center !important;
        }

        div.dataTables_wrapper {
            margin: 0 auto;
        }

        .table > tfoot > tr > th {
            height: 25px !important;
        }

        .lblTTax, .lblTPrice, .txtTRequestQty, .lblTSubTotal, .txtTotalAvailQty, .txtAlreadyreturnQty, .txtTotalInvoiceQty {
            background: linear-gradient(to bottom, rgba(245,246,246,1) 0%,rgba(219,220,226,1) 3%,rgba(184,186,198,1) 59%,rgba(221,223,227,1) 100%,rgba(245,246,246,1) 100%);
        }

        .table > thead > tr > th, .table > tbody > tr > th, .table > tfoot > tr > th, .table > thead > tr > td, .table > tbody > tr > td, .table > tfoot > tr > td {
            /*padding-left: 4px !important;*/
            /*padding: 0px 0 0 4px !important;*/
            padding: 0px;
            vertical-align: middle !important;
            /*white-space: nowrap;*/
            /*overflow-x: scroll;*/
        }

        .tdleftalign {
            margin-left: 2px !important;
        }

        .tdrightalign {
            margin-right: 2px !important;
        }

        .CustName {
            /*overflow: auto;*/
            white-space: nowrap;
            overflow-x: scroll;
            padding-left: 4px !important;
        }

            .CustName::-webkit-scrollbar {
                display: none;
            }
        /*table > thead > tr > th, .table > tbody > tr > th, .table > tfoot > tr > th, .table > thead > tr > td, .table > tbody > tr > td, .table > tfoot > tr > td::-webkit-scrollbar {
                display: none;
            }*/

        /* Hide scrollbar for IE, Edge and Firefox */
        .CustName {
            -ms-overflow-style: none; /* IE and Edge */
            scrollbar-width: none; /* Firefox */
        }

        .lblPrice, .txtAvailQty, .txtEnterQty, .txtTotalQty, .lblSubTotal, .txtTTotalQty, .lblTSubTotal, .lblTax, .lblTTax, .lblTotalPrice, .lblTPrice, .txtTRequestQty, .txtTotalReturn, .txtInvQty,
        .txtTotalAvailQty, .txtAlreadyreturnQty, .txtTotalInvoiceQty {
            font-size: 11px !important;
            height: 25px !important;
            text-align: right !important;
        }

        .input-group form-group, .datepick, .txtCustomer, .txtItem, .lblBillToPartyCode, .txtBill {
            height: 25px !important;
            /*font-weight: bold;*/
            font-size: 10px !important;
        }

        .ui-autocomplete {
            font-size: 10px !important;
        }
        .txtTotalQty, .txtTTotalQty {
            display:none;
        }

        @media (min-width: 768px) {
            .container {
                max-width: 100%;
            }
        }

        @media (min-width: 1200px) {
            .container {
                width: 1073px;
            }
        }

        @media (min-width: 992px) {
            .container {
                max-width: 100%;
            }
        }

        @media (min-width: 1200px) {
            .dataTables_scrollHead {
                width: 1000px !important;
            }

            .dataTables_scrollBody {
                width: 1000px !important;
            }

            .dataTables_scrollFoot {
                width: 1020px !important;
            }

            .dataTables_scrollFootInner {
                width: 1020px !important;
            }
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <input type="hidden" class="hdnIsFullItem" id="hdnIsFullItem" runat="server" />
    <div class="panel panel-default">
        <div class="panel-body _masterForm">
            <div class="row">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="Sales Return Date" runat="server" CssClass="input-group-addon" />
                        <asp:TextBox runat="server" ID="txtDate" disabled="disabled" onfocus="this.blur();" CssClass="datepick form-control" />
                    </div>
                    <div class="input-group form-group">
                        <asp:Label Text="Invoice Number" ID="lblBill" runat="server" CssClass="input-group-addon" />
                        <asp:TextBox runat="server" ID="txtBill" AutoPostBack="true" OnTextChanged="txtTemplate_TextChanged" CssClass="form-control txtBill"
                            Style="background-color: lightyellow;" TabIndex="3" />
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtBill" runat="server" ServicePath="../WebService.asmx"
                            UseContextKey="true" ServiceMethod="GetSaleBillForReturnNew" MinimumPrefixLength="1" CompletionInterval="100"
                            EnableCaching="true" CompletionSetCount="1" TargetControlID="txtBill" OnClientPopulating="autoCompleteMat_OnClientPopulating">
                        </asp:AutoCompleteExtender>
                    </div>

                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblwarehouse" Text="Warehouse" CssClass="input-group-addon" runat="server" Visible="false"></asp:Label>
                        <asp:DropDownList runat="server" ID="ddlWhs" DataValueField="WhsID" DataTextField="WhsName" CssClass="form-control" Visible="false">
                        </asp:DropDownList>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label Text="Shipped To Party" ID="lblCustomer" runat="server" CssClass="input-group-addon" />
                        <asp:TextBox runat="server" ID="txtCustomer" CssClass="txtCustomer form-control" Style="background-color: lightyellow" TabIndex="1" />
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtCustomer" runat="server" ServicePath="../WebService.asmx"
                            UseContextKey="true" ServiceMethod="GetChildCustomer" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCustomer">
                        </asp:AutoCompleteExtender>
                    </div>
                    <div class="input-group form-group">
                        <label class="input-group-addon">Bill To Party</label>
                        <input type="text" id="lblBillToPartyCode" runat="server" disabled="disabled" class="lblBillToPartyCode form-control" />
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="Item" ID="lblItem" runat="server" CssClass="input-group-addon" />
                        <asp:TextBox runat="server" ID="txtItem" CssClass="txtItem form-control" Style="background-color: lightyellow" TabIndex="2" />
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtItem" runat="server" ServicePath="../WebService.asmx"
                            UseContextKey="true" ServiceMethod="GetItemWithID" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtItem">
                        </asp:AutoCompleteExtender>
                    </div>
                    <div class="input-group form-group">
                        <asp:Button Text="Save" runat="server" CssClass="btn btn-default" ID="btnSubmit" OnClick="btnSubmit_Click" OnClientClick="return _btnCheck();" TabIndex="4" />
                        <asp:Button Text="Save & Print" runat="server" CssClass="btn btn-default" ID="btnSaveprint" OnClientClick="return _btnCheck();" OnClick="btnSaveprint_Click" TabIndex="5" />
                        <asp:Button Text="Cancel" ID="btnCancel" CssClass="btn btn-default" OnClick="btnCancel_Click" runat="server" UseSubmitBehavior="false" CausesValidation="false" TabIndex="6" />
                    </div>
                    <%-- <div class="input-group form-group">--%>
                    <%-- <asp:Label Text="Reason" ID="lblReason" runat="server" CssClass="input-group-addon" />--%>
                    <asp:DropDownList runat="server" ID="ddlReason" AutoPostBack="true" CssClass="form-control" Visible="false" DataTextField="Text" DataValueField="Value" />
                    <%--</div>--%>
                </div>
            </div>
            <div class="row" style="display: none;">
                <div class="col-lg-12 _textArea">
                    <div class="input-group form-group">
                        <asp:Label Text="Notes" ID="lblNotes" runat="server" CssClass="input-group-addon" />
                        <asp:TextBox runat="server" ID="txtNotes" TextMode="MultiLine" CssClass="form-control" Style="resize: none;" />
                    </div>
                </div>
            </div>
            <asp:TextBox runat="server" placeholder="Search here" ID="txtSearch" Visible="false" CssClass="txtSearch form-control" />
            <br />
            <input type="button" value="All Return" class="btn btn-default" style="margin-left: 636px; margin-top: -25px; padding: 4px 7px; height: 30px;" id="btnAllReturn" onclick="AllAvailReturn();" tabindex="7" />
            <br />

            <asp:GridView runat="server" ID="gvItem" CssClass="gvItem HighLightRowColor2 table" Width="70%" ShowFooter="true" ShowHeader="true" AutoGenerateColumns="false" OnPreRender="gvItems_PreRender" OnRowDataBound="gvItem_RowDataBound" HeaderStyle-CssClass="table-header-gradient" FooterStyle-CssClass="table-header-gradient" Font-Size="11px">
                <Columns>
                    <asp:TemplateField HeaderText="Sr." HeaderStyle-CssClass="dtbodyCenter">
                        <ItemTemplate>
                            <asp:Label ID="lblNo" runat="server" Text='<%# Container.DataItemIndex + 1 %>'></asp:Label>
                        </ItemTemplate>
                        <ItemStyle HorizontalAlign="Center" />
                        <HeaderStyle Width="2%" />

                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Item Code - Item Name" ItemStyle-CssClass="CustName">
                        <ItemTemplate>
                            <asp:Label ID="lblItemID" CssClass="lblItemID" runat="server" Text='<%# Eval("ItemID") %>' Style="display: none;"></asp:Label>
                            <asp:Label runat="server" ID="txtItem" Text='<%# String.Format("{0} - {1}", Eval("ItemCode"),Eval("ItemName"))  %>' />
                            <input type="hidden" id="hdnItemScheme" runat="server" class="hdnItemScheme" value='<%# Eval("ItemScheme") %>' />
                            <input type="hidden" id="hdnScheme" runat="server" class="hdnScheme" value='<%# Eval("Scheme") %>' />
                        </ItemTemplate>
                        <FooterTemplate>
                            <asp:Label ID="Label1" CssClass="lblItemID" runat="server" Text='Total'></asp:Label>
                        </FooterTemplate>
                        <HeaderStyle Width="35%" CssClass="CustName" />

                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Unit">
                        <ItemTemplate>
                            <asp:Label ID="lblUnitID" CssClass="lblUnitID" runat="server" Style="display: none;" />
                            <asp:Label ID="lblTaxID" CssClass="lblTaxID" Text='<%# Eval("TaxID") %>' runat="server" Style="display: none;" />
                            <asp:Label ID="lblSchemeID" CssClass="lblSchemeID" Text='<%# Eval("SchemeID") %>' runat="server" Style="display: none;" />
                            <asp:Label Text='<%# Eval("UnitName") %>' ID="lblUnit" runat="server" CssClass="CustName" />
                        </ItemTemplate>
                        <HeaderStyle Width="5%" CssClass="CustName" />

                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Rate">
                        <ItemTemplate>
                            <asp:TextBox ID="lblPrice" CssClass="lblPrice form-control" Text='<%# Eval("UnitPrice","{0:0.00}") %>' Enabled="false" runat="server"></asp:TextBox>
                        </ItemTemplate>
                        <HeaderStyle Width="5%" CssClass="dtbodyRight" />

                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Total Inv. Qty">
                        <ItemTemplate>
                            <asp:TextBox ID="txtInvQty" CssClass="txtInvQty form-control" Enabled="false" runat="server" Text='<%# Eval("InvoiceQty","{0:0}") %>'></asp:TextBox>
                        </ItemTemplate>
                        <FooterTemplate>
                            <asp:TextBox ID="txtTotalInvoiceQty" CssClass="txtTotalInvoiceQty form-control" Enabled="false" runat="server"></asp:TextBox>
                        </FooterTemplate>
                        <HeaderStyle Width="5%" CssClass="dtbodyRight" />

                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Already Return Qty">
                        <ItemTemplate>
                            <asp:TextBox ID="txtTotalReturn" CssClass="txtTotalReturn form-control" Text='<%# Eval("TotalReturnQty","{0:0}") %>' runat="server" Enabled="false"></asp:TextBox>
                        </ItemTemplate>
                        <FooterTemplate>
                            <asp:TextBox ID="txtAlreadyreturnQty" CssClass="txtAlreadyreturnQty form-control" Enabled="false" runat="server"></asp:TextBox>
                        </FooterTemplate>
                        <HeaderStyle Width="5%" CssClass="dtbodyRight" />

                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Avail Qty">
                        <ItemTemplate>
                            <asp:TextBox ID="txtAvailQty" CssClass="txtAvailQty form-control" Enabled="false" runat="server" Text='<%# Eval("DispatchQty","{0:0}") %>'></asp:TextBox>
                        </ItemTemplate>
                        <FooterTemplate>
                            <asp:TextBox ID="txtTotalAvailQty" CssClass="txtTotalAvailQty form-control" Enabled="false" runat="server"></asp:TextBox>
                        </FooterTemplate>
                        <HeaderStyle Width="3%" CssClass="dtbodyRight" />

                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Return Qty">
                        <ItemTemplate>
                            <asp:TextBox ID="txtEnterQty" Text="0" CssClass="txtEnterQty form-control" runat="server" onchange="ChangeQuantity(this);" onkeyup="enter(this);" onkeypress="return isNumberKeyForAmount(event);" onpaste="return false;" data-bv-stringlength="false" MaxLength="12" onBlur="SetQtyDataBlur(this);" onfocus="SetQtyDataFocus(this);" autocomplete="off" AutoCompleteType="Disabled"></asp:TextBox>
                             <asp:TextBox ID="txtTotalQty" CssClass="txtTotalQty form-control" runat="server" Enabled="false"></asp:TextBox>
                        </ItemTemplate>
                        <FooterTemplate>
                            <asp:TextBox ID="txtTRequestQty" CssClass="txtTRequestQty form-control" Enabled="false" runat="server"></asp:TextBox>
                            <asp:TextBox ID="txtTTotalQty" CssClass="txtTTotalQty form-control" Enabled="false" runat="server"></asp:TextBox>
                        </FooterTemplate>
                        <HeaderStyle Width="5%" CssClass="dtbodyRight" />

                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Total Qty" Visible="false">
                        <ItemTemplate>
                           
                        </ItemTemplate>
                        <FooterTemplate>
                            
                        </FooterTemplate>
                        <HeaderStyle CssClass="CustName" />

                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Gross Amt">
                        <ItemTemplate>
                            <asp:TextBox ID="lblSubTotal" CssClass="lblSubTotal form-control" Enabled="false" runat="server"></asp:TextBox>
                            <input type="hidden" id="hdnSubTotal" runat="server" class="hdnSubTotal" value='0' />
                        </ItemTemplate>

                        <FooterTemplate>
                            <asp:TextBox ID="lblTSubTotal" CssClass="lblTSubTotal form-control" Enabled="false" runat="server"></asp:TextBox>
                        </FooterTemplate>
                        <HeaderStyle Width="7%" CssClass="dtbodyRight" />

                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="GST Amt">
                        <ItemTemplate>
                            <asp:TextBox ID="lblTax" CssClass="lblTax form-control" runat="server" Enabled="false"></asp:TextBox>
                            <input type="hidden" id="hdnTax" runat="server" class="hdnTax" value='0' />
                        </ItemTemplate>
                        <FooterTemplate>
                            <asp:TextBox ID="lblTTax" CssClass="lblTTax form-control" Enabled="false" runat="server"></asp:TextBox>
                        </FooterTemplate>
                        <HeaderStyle Width="7%" CssClass="dtbodyRight" />

                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Net Amt">
                        <ItemTemplate>
                            <asp:TextBox ID="lblTotalPrice" CssClass="lblTotalPrice form-control" Enabled="false" runat="server"></asp:TextBox>
                        </ItemTemplate>
                        <FooterTemplate>
                            <asp:TextBox ID="lblTPrice" CssClass="lblTPrice form-control" Enabled="false" runat="server"></asp:TextBox>
                        </FooterTemplate>
                        <HeaderStyle Width="7%" CssClass="dtbodyRight" />

                    </asp:TemplateField>
                </Columns>
            </asp:GridView>

            <div id="divdata" runat="server" class="row" style="display: none;">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="Scheme Return" ID="lblScheme" CssClass="input-group-addon" runat="server" />
                        <asp:TextBox runat="server" ID="txtScheme" CssClass="txtScheme form-control" Enabled="false" />
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="Sub Total" ID="lblSubTotal" CssClass="input-group-addon" runat="server" />
                        <asp:TextBox runat="server" ID="txtSubTotal" CssClass="txtSubTotal form-control" Enabled="false" />
                    </div>
                    <div class="input-group form-group">
                        <asp:Label Text="Tax" ID="lblTax" runat="server" CssClass="input-group-addon" />
                        <asp:TextBox runat="server" ID="txtTax" CssClass="txtTax form-control" Enabled="false" />
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="Rounding" ID="lblRounding" CssClass="input-group-addon" runat="server" />
                        <asp:TextBox runat="server" ID="txtRounding" CssClass="txtRounding form-control" onkeypress="return isNumberKeyForAmount(event);" onpaste="return false;" onchange="summary();" Enabled="false" />
                    </div>
                    <div class="input-group form-group">
                        <asp:Label Text="Total" ID="lblTotal" runat="server" CssClass="input-group-addon" />
                        <asp:TextBox runat="server" ID="txtTotal" CssClass="txtTotal form-control" Enabled="false" />
                    </div>
                </div>
            </div>

        </div>
    </div>
</asp:Content>
