<%@ Page Title="" Language="C#" MasterPageFile="~/MainMaster.master" AutoEventWireup="true" CodeFile="SaleDirect.aspx.cs" Inherits="Sales_SaleDirect" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <link href="../Scripts/colorbox/colorbox.css" rel="stylesheet" />
    <script type="text/javascript" src="../Scripts/colorbox/jquery.colorbox-min.js"></script>
    <script type="text/javascript" src="../Scripts/fixHeaderFooter.js"></script>

    <style>
        .table > tfoot {
            /*position: -webkit-sticky;*/
            position: sticky;
            bottom: 0;
            z-index: 4;
            /*inset-block-end: 0;*/
        }

            /*.table > tbody > tr > td,*/
            .table > thead > tr > th, .table > tbody > tr > th, .table > tfoot > tr > th, .table > thead > tr > td, .table > tfoot > tr > td {
                line-height: 0.428571 !important;
                inset-block-start: 0;
            }

        div#Material {
            width: 100% !important;
        }

        .dataTables_scrollBody {
            max-height: 50vh !important;
        }

        td .form-control {
            padding: 3px 12px !important;
        }

        table#tblMaterialDetail tbody tr td {
            padding: 1px !important;
        }



        .ui-autocomplete {
            height: 125px !important;
        }

        .ui-autocomplete {
            font-size: 10px !important;
        }

        .req:after {
            content: "*";
            color: red;
        }

        .search {
            background-color: lightyellow;
            height: 30%;
        }

        table#tblMaterialDetail {
            width: 100%;
            margin-top: 0px !important;
            margin-bottom: 0px !important;
            position: relative;
        }

            table#tblMaterialDetail tbody {
                width: 100%;
                height: 30%;
            }

            table#tblMaterialDetail thead tr {
                position: relative;
            }

            table#tblMaterialDetail tfoot tr {
                position: relative;
                width: 100%;
            }

        .border-la {
            float: left;
            width: 100%;
            height: 1px;
            padding-right: 10px;
            background: #000;
        }

        table#tblMaterialDetail tbody tr td {
            padding: 3px !important;
            width: 100%;
            vertical-align: middle !important;
        }

        .txtSrNo, .tdSrNo {
            text-align: center;
        }

        .tdPrice, .tdAvailable, .tdOrderQty, .tdTotalQty, .tdSubTotal, .tdTax, .tdTotalPrice, .txtReqQty, .tdQuantity, .tdLowerLimit, .tdHigherLimit, .tdOccurance .lblFootTotalPrice, .lblFootTax, .lblFootSubTotal, .lblFootDispatch, .lblFootOrder, .lblFootAvailable, .txtTotalQty, .txtGrossAmount, .tdOccurance, .tdDiscount, .tdStock {
            text-align: right;
        }

        .form-control {
            font-size: 11px !important;
        }

        .ddlUnit {
            height: 30%;
            text-align: left !important;
            padding: 6px 0px !important;
        }

        .txtReqQty {
            height: 30% !important;
        }

        .input-group-addon {
            font-size: 11px !important;
            font-weight: bold;
            text-align: right;
        }

        .input-group form-group, .txtDScheme, .txtVRSDiscount, .txtMachineScheme, .txtMScheme, .txtQScheme, .txtSubTotal, .txtTotal, .txtTax, .txtRounding, .txtPaid, .txtPending, .datepick, .lblBillToPartyCode, .chkbox, .txtMobileNo, .txtGSTIN, .chkExist, .chkTmp, .txtTotalQty, .txtGrossAmount, .txtTotalDiscoun, .txtNotes {
            height: 25px !important;
            font-weight: bold;
            font-size: 12px !important;
        }

        .txtVRSDiscount, .txtMachineScheme, .txtMScheme, .txtQScheme, .txtSubTotal, .txtTotal, .txtTax, .txtRounding, .txtPaid, .txtPending, .chkbox, .txtDScheme, .txtTotalDiscoun {
            text-align: right !important;
            font-weight: bold;
        }

        .input-group {
            margin-top: -4px !important;
        }

        .table {
            font-size: 11px !important;
            max-width: 100% !important;
            margin-bottom: 20px !important;
        }


        input[type=radio], input[type=checkbox] {
            margin: -5px 0 0;
        }

        /*.dataTables_scrollBody {
            max-height: 56vh !important;
        }*/

        .row {
            margin-right: -15px;
            margin-left: -15px;
            margin-bottom: 0px !important;
        }

        table#tblSchemeDetail {
            width: auto !important;
            margin-top: 0px !important;
            margin-bottom: 0px !important;
            position: relative;
            font-size: 11px !important;
        }

        table#tblMaterialDetail tbody tr td {
            padding: 3px;
            line-height: 1.42857143;
            vertical-align: middle;
            border-top: 1px solid #ddd;
        }

        .tdSchemeName, .tdSchemeItemName, .tdBasedOn {
            /*overflow: auto;*/
            white-space: nowrap;
            overflow-x: scroll;
        }

            .tdSchemeName::-webkit-scrollbar {
                display: none;
            }

            .tdSchemeItemName::-webkit-scrollbar {
                display: none;
            }

            .tdBasedOn::-webkit-scrollbar {
                display: none;
            }
        /*table > thead > tr > th, .table > tbody > tr > th, .table > tfoot > tr > th, .table > thead > tr > td, .table > tbody > tr > td, .table > tfoot > tr > td::-webkit-scrollbar {
                display: none;
            }*/

        /* Hide scrollbar for IE, Edge and Firefox */
        .tdSchemeName, .tdSchemeItemName, .tdBasedOn {
            -ms-overflow-style: none; /* IE and Edge */
            scrollbar-width: none; /* Firefox */
        }


        /* 08-Sep-2022*/

        .input-group-addon {
            /*font-size: 1.1rem !important;*/
            font-weight: bold;
            text-align: right;
        }



        .input-group form-group, .txtDScheme, .txtVRSDiscount, .txtMachineScheme, .txtMScheme, .txtQScheme, .txtSubTotal, .txtTotal, .txtTax, .txtRounding, .txtPaid, .txtPending, .datepick, .lblBillToPartyCode, .chkbox, .txtMobileNo, .txtGSTIN, .chkExist, .chkTmp, .txtTotalQty, .txtGrossAmount, .txtTotalDiscoun {
            height: 22px !important;
            FONT-WEIGHT: 400;
            /*font-size: 1.1rem !important;*/
            font-size: 11px !important;
        }



        .side-bar-amount .input-group.form-group {
            width: 100%;
            display: flex;
        }

        /*  .table {
            font-size: 1.1rem !important;
        }*/

        .btn {
            display: inline-block;
            padding: 3px 12px;
            margin-bottom: 0;
            font-size: 1.1rem;
        }

        .input-group-addon {
            padding: 3px 5px;
        }

        .tab-content {
            border: 1px solid #ddd;
            border-top: 0;
        }

        .nav > li > a {
            position: relative;
            display: block;
            padding: 4px 15px;
        }

        table#tblSchemeDetail {
            font-size: 11px !important;
        }

        #ui-id-1 {
            width: 380px !important;
        }

        .ui-autocomplete {
            height: auto !important;
            overflow-x: auto;
            width: 510px !important;
        }

        table.fixed {
            table-layout: fixed;
        }
        /*td, th {
            padding: 0 !important;
            padding-right: 7px !important;
        }*/
    </style>
    <script type="text/javascript">

        $(document).ready(function () {
            $("#tblMaterialDetail").tableHeadFixer('70vh');
            $("#tblSchemeDetail").tableHeadFixer('70vh');
        });

        $(function () {
            document.onkeydown = function (event) {
                if (event.ctrlKey && event.keyCode == 83) //CTRL+S
                {
                    $("#btnSubmit").click();
                }

                if (event.ctrlKey && event.keyCode == 80) //CTRL+H
                {
                    $("#btnSavePrint").click();

                }
            };
        });
    </script>

    <script type="text/javascript">
        var IsEdit = false;

        var OrderID = '<%= OrderID%>';
        var OrderType = '<%= Type%>';
        var CustID = '<%= CustomerID%>';
        var CustType = '<%= CustType %>';
        var isFSSAI = true;
        var availableCustomer_temp = [];
        var availableCustomer = [];
        var availableTemplate = [];
        var availableVehicle = [];
        var availableOrderForm = [];
        var availableItems = [];
        function hideModal() {
            isFSSAI = false;
            return false;
        }
        $(document).ready(function () {

            $('#CountRowMaterial').val(0);
            $('#CountRowScheme').val(0);

            //$('#txtMachineScheme').text(0);

            //ClearControls();

            $("#txtPaid").on('change keyup paste', function (event) {
                summary();
            });

            $("#txtDate").datepicker({
                dateFormat: 'dd/MM/yy',
                changeMonth: true, changeYear: true,
                yearRange: "2000:2090",
                beforeShow: function () {
                    setTimeout(function () {
                        $('.ui-datepicker').css('z-index', 99999999999999);
                    }, 0);
                }
            }).on("change", function (e) { FillData(); });

            var today = '<%=DateTime.Now.ToShortDateString()%>';

            $('#txtDate').val(today);

            if (OrderID != 0 && OrderType != "") {
                FillOrder();
            }
            else {
                FillData();
            }

            //AddMoreRowMaterial();
        });

        function FillOrder() {
            if (!isFSSAI) {
                return false;
            }
            var cnt = 1;
            $("#tblMaterialDetail > tbody > tr").each(function () {
                if (cnt > 0) {
                    $(this).remove();       // remove other rows except first row.
                }
                cnt++;
            });
            $('#CountRowMaterial').val(0);

            $.ajax({
                url: 'SaleDirect.aspx/GetOrder',
                type: 'POST',
                dataType: 'json',
                async: false,
                contentType: 'application/json; charset=utf-8',
                data: JSON.stringify({ orderid: OrderID, type: OrderType, custid: CustID }),
                success: function (result) {
                    if (result == "") {
                        //event.preventDefault();
                        return false;
                    }
                    else if (result.d[0].indexOf("ERROR=") >= 0) {
                        var ErrorMsg = result.d[0].split('=')[1].trim();
                        alert(ErrorMsg);
                        window.location.replace("../Sales/SalesOrderData.aspx");
                        return false;
                    }
                    else {
                        $("#hdnOrderID").val(OrderID);
                        $("#hdnOrderType").val(OrderType);
                        $("#hdnOrderCustID").val(CustID);
                        $("#AutoCustomer").val(result.d[0]);
                        $("#AutoVehicle").val(result.d[1]);
                        $("#txtGSTIN").val(result.d[2]);
                        $("#body_txtNotes").val(result.d[3]);
                        $("#txtMobile").val(result.d[4]);
                        $('#chkTemp').prop('checked', result.d[5]);
                        $("#AutoOrderForm").val(result.d[6]);

                        if ($("#AutoOrderForm").val() == "")
                            $("#AutoOrderForm").attr('disabled', false);
                        else
                            $("#AutoOrderForm").attr('disabled', true);

                        $("#AutoCustomer").attr('disabled', true);
                        $("#chkExisting").attr('disabled', true);
                        $("#chkTemp").attr('disabled', true);
                        $("#txtDate").attr('disabled', true);

                        var vehicle = result.d[7];
                        var orderform = result.d[8];
                        var warehouse = result.d[9];

                        availableOrderForm = [];
                        availableVehicle = [];

                        for (var i = 0; i < orderform.length; i++) {
                            availableOrderForm.push(orderform[i]);
                        }

                        for (var i = 0; i < vehicle.length; i++) {
                            availableVehicle.push(vehicle[i]);
                        }

                        $("#AutoOrderForm").autocomplete({
                            source: availableOrderForm,
                            minLength: 0,
                            scroll: true
                        });

                        $("#AutoVehicle").autocomplete({
                            source: availableVehicle,
                            minLength: 0,
                            scroll: true,
                            select: function (Data, SelectionArray) {

                                if (CustType == "4" && SelectionArray.item.value.trim().indexOf("SELF LIFT") == -1) {
                                    $("#btnSavePrint").attr('disabled', 'disabled');
                                }
                                else {
                                    $("#btnSavePrint").removeAttr('disabled');
                                }
                            }
                        });

                        $("#ddlWhs option[value!='0']").remove();

                        for (var i = 0; i < warehouse.length; i++) {
                            $("#ddlWhs").append('<option value="' + warehouse[i].Value + '">' + warehouse[i].Text + '</option>');
                        }

                        GetItemCustomerWise(result.d[0]);

                        cnt = 1;
                        var QPSEligible = false;
                        for (var i = 0; i < result.d[10].length; i++) {

                            AddMoreRowMaterial();
                            //debugger
                            //console.log(1);
                            //console.log(result.d[10][i].ItemCode);
                            //console.log(1);
                            $('#AutoMatCodes' + cnt).val(result.d[10][i].ItemCode);
                            GetItemDetailsByCode(result.d[10][i].ItemCode, cnt);
                            console.log(result.d[10][i]);
                            if (result.d[10][i].IsQPS == 1) {
                                QPSEligible = true;
                            }
                            else {
                                QPSEligible = false;
                            }
                            //$('#tdPrice' + cnt).text(result.d[10][i].PRICE);
                            $('#txtReqQty' + cnt).val(result.d[10][i].Quantity);
                            $('#hdnMainID' + cnt).val(result.d[10][i].MainID);
                            //$('#hdnMaterialTaxID' + cnt).val(result.d[10][i].TaxID);
                            $('#hdnOrderQty' + cnt).val(result.d[10][i].Quantity);
                            $('#tdOrderQty' + cnt).text(result.d[10][i].Quantity);
                            CalculateSum(cnt);
                            //$('#hdnDiscountPrice' + cnt).val(result.d[10][i].Price);
                            //$('#hdnDiscountTax' + cnt).val(result.d[10][i].Tax);
                            //$('#hdnDiscountSubTotal' + cnt).val(result.d[10][i].SubTotal);
                            //$('#hdnDiscountTotal' + cnt).val(result.d[10][i].Total);
                            cnt++;
                        }
                        console.log(QPSEligible);
                        if (QPSEligible == true) {
                            
                            Confirm();
                           
                            ApplyScheme('');
                             

                        }
                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    alert('Something is wrong...' + XMLHttpRequest.responseText);
                    event.preventDefault();
                    return false;
                }
            });
            //$('#txtMScheme').val(0);
            //$('#txtQScheme').val(0);
            //$('#txtMachineScheme').val(0);
            // AddMoreRowMaterial();
        }

        function fnValidateGSTIN(txt) {

            var gstval = $(txt).val();
            if (gstval != "") {

                var panPat = /^[0-9]{2}[A-Za-z]{5}[0-9]{4}[A-Za-z]{1}[0-9a-zA-Z]{1}[a-zA-Z]{1}[0-9a-zA-Z]{1}$/;

                if (gstval.search(panPat) == -1) {
                    ModelMsg("Invalid GSTIN No", 3);
                    $(txt).val("");
                    return false;
                }
            }
        }

        function FillData() {
            if (!isFSSAI) {
                return false;
            }
            $.ajax({
                url: 'SaleDirect.aspx/LoadData',
                type: 'POST',
                dataType: 'json',
                data: JSON.stringify({ Date: $('#txtDate').val() }),
                async: false,
                contentType: 'application/json; charset=utf-8',
                success: function (result) {

                    if (result.d == "") {
                        event.preventDefault();
                        return false;
                    }
                    else if (result.d[0].indexOf("ERROR#") >= 0) {
                        var ErrorMsg = result.d[0].split('#')[1].trim();
                        ModelMsg(ErrorMsg, 3);
                        event.preventDefault();

                        var today = '<%=DateTime.Now.ToShortDateString()%>';

                        $('#txtDate').val(today);
                        return false;

                    }
                    else {


                        var customer = result.d[0];
                        var template = result.d[1];
                        var vehicle = result.d[2];
                        var orderform = result.d[3];
                        var warehouse = result.d[4];
                        var tempcustomer = result.d[5];

                        availableCustomer_temp = [];
                        availableCustomer = [];
                        availableTemplate = [];
                        availableVehicle = [];
                        availableOrderForm = [];

                        for (var i = 0; i < tempcustomer.length; i++) {
                            availableCustomer_temp.push(tempcustomer[i]);
                        }

                        for (var i = 0; i < customer.length; i++) {
                            availableCustomer.push(customer[i]);
                        }

                        for (var i = 0; i < template.length; i++) {
                            availableTemplate.push(template[i]);
                        }

                        for (var i = 0; i < vehicle.length; i++) {
                            availableVehicle.push(vehicle[i]);
                        }

                        for (var i = 0; i < orderform.length; i++) {
                            availableOrderForm.push(orderform[i]);
                        }

                        $("#ddlWhs option[value!='0']").remove();

                        for (var i = 0; i < warehouse.length; i++) {
                            $("#ddlWhs").append('<option value="' + warehouse[i].Value + '">' + warehouse[i].Text + '</option>');
                        }

                        $("#AutoCustomer").autocomplete({
                            source: availableCustomer,
                            minLength: 0,
                            scroll: true
                        });
                        $("#AutoCustomer").on('change keyup', function () {
                            var data = $("#AutoCustomer").val();
                            //if (data == "") {
                            //ClearControls();
                            //}
                        });

                        $('#AutoCustomer').on('change', function () {
                            $('#AutoCustomer').val(this.value);
                            //if (this.value != "") {
                            GetItemCustomerWise(this.value);
                            //}
                        }).change();

                        $('#AutoCustomer').on('autocompleteselect', function (e, ui) {
                            $('#AutoCustomer').val(ui.item.value);
                            GetItemCustomerWise(ui.item.value);
                        });

                        $("#AutoTemplate").autocomplete({
                            source: availableTemplate,
                            minLength: 0,
                            scroll: true
                        });

                        $("#AutoVehicle").autocomplete({
                            source: availableVehicle,
                            minLength: 0,
                            scroll: true,
                            select: function (Data, SelectionArray) {

                                if (CustType == "4" && SelectionArray.item.value.trim().indexOf("SELF LIFT") == -1) {
                                    $("#btnSavePrint").attr('disabled', 'disabled');
                                }
                                else {
                                    $("#btnSavePrint").removeAttr('disabled');
                                }
                            }
                        });

                        $("#AutoOrderForm").autocomplete({
                            source: availableOrderForm,
                            minLength: 0,
                            scroll: true
                        });
                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    alert('Something is wrong...' + XMLHttpRequest.responseText);
                    event.preventDefault();
                    return false;
                }
            });
        }


        function GetItemCustomerWise(custCode) {
            if (!isFSSAI) {
                return false;
            }
            var AutoCompleteItems = [];
            $('#CountRowMaterial').val(0);
            $('#tblMaterialDetail tbody > tr').remove();
            AddMoreRowMaterial();
            CalculateSum();

            if (custCode != "") {

                var customerCode = custCode.split(' - ')[0].trim();
                var ddlWhs = $("select[name='ddlWhs']").val();
                var chktemp = $('#chkTemp').is(':checked');
                var chkexisting = $('#chkExisting').is(':checked');

                $.ajax({
                    url: 'SaleDirect.aspx/LoadItemsCustomerWise',
                    type: 'POST',
                    dataType: 'json',
                    async: false,
                    contentType: 'application/json; charset=utf-8',
                    data: JSON.stringify({ CustomerCode: customerCode, WareHouse: ddlWhs, ChkTemp: chktemp, chkExisting: chkexisting }),

                    success: function (result) {
                        if (result == "") {
                            event.preventDefault();
                            return false;
                        }
                        else if (result.d[0].indexOf("ERROR=") >= 0) {

                            $('#AutoCustomer').val('');
                            availableItems = [];
                            var table = document.getElementById("tblMaterialDetail");


                            //open: function (event, ui) {
                            //    var txttopposition = $("#AutoMatCodes1").position().top;
                            //    var bottomPosition = $(document).height();
                            //    var $input = $(event.target),
                            //        $results = $input.autocomplete("widget"),
                            //         inputHeight = $input.height(),
                            //         top = txttopposition,
                            //       // top = parseInt(txttopposition) <= 140 ? txttopposition + 210 : parseInt(bottomPosition) >= 800 ? $("#AutoMatCodes1").position().top : table.offsetHeight, // $('#AutoCustName' + ind).position().top,// ind >= 6 ? $('#AutoCustName' + ind).position().top : table.offsetHeight, //$results.position().top,
                            //        height = $results.height(),
                            //        newTop = parseInt(txttopposition) <= 140 ? txttopposition + 210 : parseInt(bottomPosition) >= 800 ? top - height : top; //top - height;//ind >= 6 ? top - height : top;
                            //    $results.css("top", top + "px");
                            //}
                            // });

                            var ErrorMsg = result.d[0].split('=')[1].trim();
                            ModelMsg(ErrorMsg, 3);
                            return false;
                        }
                        else {
                            var items = result.d[0];

                            availableItems = [];

                            for (var i = 0; i < items.length; i++) {
                                availableItems.push(items[i]);
                            }

                            //var table = document.getElementById("tblMaterialDetail");
                            $("#AutoMatCodes1").autocomplete({
                                source: availableItems,
                                minLength: 0,
                                scroll: true,
                                success: function (result) {
                                    response($.map(result.d[0], function (item) {
                                        return {
                                            val: item.split('-')[0],
                                            label: item.split('-')[1]
                                        }
                                    }))
                                }
                            }).data("ui-autocomplete")._renderItem = function (ul, item) {

                                return $("<li>")
                                    .append('<a>'
                                        + '<table style="width:100% !important"><tr style="width:100% !important;">'
                                    + '<td style="width:14% !important;border:1px solid;font-size:10px !important;padding-left:2px;">' + item.label.split('-')[0] + '</td>'
                                    + '<td style="width:53%;;border:1px solid;font-size:10px !important;padding-left:2px;">' + item.label.split('-')[1] + '</td>'
                                    + '<td style="width:5%;;border:1px solid;font-size:10px !important; text-align:right;padding-right:3px;">' + item.label.split('-')[2] + '</td>'
                                    + '<td style="width:9%;;border:1px solid;font-size:10px !important;text-align:right;padding-right:3px;">' + item.label.split('-')[3] + '</td>'
                                    + '<td style="width:3%;;border:1px solid;font-size:10px !important;padding-left:5px;padding-right:5px;">' + item.label.split('-')[4] + '</td>'
                                        + '</tr></table></a>')
                                    .appendTo(ul);
                            };
                            $("#txtMobile").val(result.d[1]);
                            $("#txtMobile").attr('disabled', 'disabled')

                            if (CustType == "2" && (result.d[1] == null || result.d[1].length != 10))
                                $("#txtMobile").removeAttr('disabled')


                            if (CustType == "4" || (result.d[2] != "" && result.d[2] != null)) {
                                $("#txtGSTIN").val(result.d[2]);
                                $("#txtGSTIN").attr('disabled', 'disabled');
                            }
                            else {
                                $("#txtGSTIN").val("");
                                $("#txtGSTIN").removeAttr('disabled');
                            }
                            $("#hdnBillToCustID").val(result.d[3]);
                            $("#lblBillToPartyCode").val(result.d[4]);

                            $("#lblgrowth").text("I/c Gross Amount YTD Growth : " + result.d[5] + "%");
                            $("#lblLy").text("LY : " + result.d[6]);
                            $("#lblCy").text("CY : " + result.d[7]);
                            if (result.d[8] == 0) {
                                $(".grthUp").css('display', 'none');
                                $(".grthdown").css('display', 'block');
                            }
                            else {
                                $(".grthUp").css('display', 'block');
                                $(".grthdown").css('display', 'none');
                            }
                        }
                    },
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        alert('Something is wrong...' + XMLHttpRequest.responseText);
                        event.preventDefault();
                        return false;
                    }
                });
            }
        }

        function summary() {

            var Total = Number($('.txtSubTotal').val()) + Number($('.txtTax').val());

            $('.txtRounding').val(Number(Math.round(Total) - Total).toFixed(2));

            $('.txtTotal').val(Number(Total + Number($('.txtRounding').val())).toFixed(2));

            $('.txtPending').val(Number(Number($('.txtTotal').val()) - Number($('.txtPaid').val())).toFixed(2));


        }

        function AddMoreRowMaterial() {

            $('table#tblMaterialDetail tr#NoROW').remove();  // Remove NO ROW

            /// Add Dynamic Row to the existing Table
            var ind = $('#CountRowMaterial').val();
            ind = parseInt(ind) + 1;
            $('#CountRowMaterial').val(ind);

            var str = "";
            str = "<tr id='trMaterial" + ind + "'>"
                + "<td class='txtSrNo' id='txtSrNo" + ind + "'>" + ind + "</td>"
                + "<td><input type='text' id='AutoMatCodes" + ind + "' name='AutoMatCode' class='form-control search' /></td>"
                + "<td><select id='ddlUnit" + ind + "' name='ddlUnit' class='form-control ddlUnit'  /></td>"
                + "<td id='tdPrice" + ind + "' class='tdPrice'></td>"
                + "<td id='tdAvailable" + ind + "' class='tdAvailable'></td>"
                + "<td id='tdOrderQty" + ind + "' class='tdOrderQty'></td>"
                + "<td><input type='text' id='txtReqQty" + ind + "' name='txtReqQty' maxlength='10' value='0' class='form-control allownumericwithdecimal txtReqQty tdTotalQty' onfocus='SetQtyDataFocus(this);' onblur='SetQtyDataBlur(this);' /></td>"
                //+ "<td id='tdTotalQty" + ind + "' class='tdTotalQty'></td>"
                + "<td id='tdSubTotal" + ind + "' class='tdSubTotal'></td>"
                + "<td id='tdTax" + ind + "' class='tdTax'></td>"
                + "<td id='tdTotalPrice" + ind + "' class='tdTotalPrice'></td>"
                + "<td style='display:none'><input type='hidden' id='hdnItemID" + ind + "' name='hdnItemID'/>"
                + "<input type='hidden' id='hdnSchemeID" + ind + "' name='hdnSchemeID' value='0' />"
                + "<input type='hidden' id='hdnScheme" + ind + "' name='hdnScheme' value='0' />"
                + "<input type='hidden' id='hdnItemScheme" + ind + "' name='hdnItemScheme' value='0' />"
                + "<input type='hidden' id='hdnMainID" + ind + "' name='hdnMainID' value='0' />"
                + "<input type='hidden' id='hdnMaterialPriceTax" + ind + "' name='hdnMaterialPriceTax' value='0' />"
                + "<input type='hidden' id='hdnMaterialUnitPrice" + ind + "' name='hdnMaterialUnitPrice' value='0' />"
                + "<input type='hidden' id='hdnMRP" + ind + "' name='hdnMRP' value='0' />"
                + "<input type='hidden' id='hdnNormalPrice" + ind + "' name='hdnNormalPrice' value='0' />"
                + "<input type='hidden' id='hdnMaterialTaxID" + ind + "' name='hdnMaterialTaxID' value='0' />"
                + "<input type='hidden' id='hdnOrderQty" + ind + "' name='hdnOrderQty' value='0' />"
                + "<input type='hidden' id='hdnDiscountSubTotal" + ind + "' name='hdnDiscountSubTotal' value='0' />"
                + "<input type='hidden' id='hdnDiscountPrice" + ind + "' name='hdnDiscountPrice' value='0' />"
                + "<input type='hidden' id='hdnDiscountTax" + ind + "' name='hdnDiscountTax' value='0' />"
                + "<input type='hidden' id='hdnDiscountTotal" + ind + "' name='hdnDiscountTotal' value='0' />"
                + "<input type='hidden' id='hdnLineNum" + ind + "' name='hdnLineNum' value='" + ind + "' />"
                + "<input type='hidden' id='hdnMappingQty" + ind + "' name='hdnMappingQty' value='0' /></td>";

            $('#tblMaterialDetail > tbody').append(str);

            var lineNum = 0;
            $('#tblMaterialDetail > tbody > tr').each(function (row, tr) {
                lineNum++;
                $(".txtSrNo", this).text(lineNum);
            });

            $('#ddlUnit' + ind).on('change', function () {
                SetUnitPrice(ind);
            });

            var table = document.getElementById("tblMaterialDetail");
            //$("#AutoMatCodes" + ind).bind("keydown", function (event) {

            //    if (event.keyCode === $.ui.keyCode.PAGE_UP) {

            //        $(".ui-menu-item").hide();
            //        return false;
            //    }
            //    else if (event.keyCode === $.ui.keyCode.PAGE_DOWN) {

            //        $(".ui-menu-item").hide();
            //        return false;
            //    }
            //    //else if (event.keyCode === $.ui.keyCode.SPACE) {

            //    //    $(".ui-menu-item").hide();
            //    //    return false;
            //    //}
            //    //else if (event.keyCode === $.ui.keyCode.UP) {

            //    //    $(".ui-menu-item").hide();
            //    //    return false;
            //    //}
            //    //else if (event.keyCode === $.ui.keyCode.DOWN) {

            //    //    $(".ui-menu-item").hide();
            //    //    return false;
            //    //}
            //    //else if (event.keyCode === $.ui.keyCode.RIGHT) {
            //    //    $(".ui-menu-item").hide();
            //    //    return false;
            //    //}
            //    //else if (event.keyCode === $.ui.keyCode.LEFT) {
            //    //    $(".ui-menu-item").hide();
            //    //    return false;
            //    //}
            //    //else if (event.keyCode === $.ui.keyCode.TAB) {
            //    //    event.preventDefault();
            //    //}
            //    //else if (event.keyCode === $.ui.keyCode.DELETE) {
            //    //    event.preventDefault();
            //    //}
            //    //else if (event.keyCode === $.ui.keyCode.END) {
            //    //    event.preventDefault();
            //    //}
            //    //else if (event.keyCode === $.ui.keyCode.HOME) {
            //    //    event.preventDefault();
            //    //}
            //    //event.keyCode === $.ui.keyCode.DELETE || event.keyCode === $.ui.keyCode.END || event.keyCode === $.ui.keyCode.HOME
            //})
            //$("#AutoMatCodes" + ind).bind("keydown", function (event) {
            //    if ((event.keyCode === $.ui.keyCode.PAGE_UP || event.keyCode === $.ui.keyCode.PAGE_DOWN || event.keyCode === $.ui.keyCode.SPACE || event.keyCode === $.ui.keyCode.UP || event.keyCode === $.ui.keyCode.DOWN || event.keyCode === $.ui.keyCode.RIGHT || event.keyCode === $.ui.keyCode.LEFT || event.keyCode === $.ui.keyCode.TAB || event.keyCode === $.ui.keyCode.DELETE || event.keyCode === $.ui.keyCode.END || event.keyCode === $.ui.keyCode.HOME)) {
            //       //  $(this).data("ui-autocomplete").addClass("display", "none");
            //        event.preventDefault();
            //       return false;
            //    }
            //})
            $("#AutoMatCodes" + ind).bind("keydown", function (event) {
                if ((event.keyCode === $.ui.keyCode.PAGE_UP || event.keyCode === $.ui.keyCode.PAGE_DOWN)) {
                    $(this).data("ui-autocomplete").addClass("display", "none");
                    event.preventDefault();
                    return false;
                }
            })
            $("#AutoMatCodes" + ind).autocomplete({
                source: availableItems,
                minLength: 0,
                scroll: true,
                position: { collision: "flip" }
            }).data("ui-autocomplete")._renderItem = function (ul, item) {

                return $("<li>")
                    .append('<a>'
                        + '<table style="width:100% !important"><tr style="width:100% !important;">'
                    + '<td style="width:14% !important;border:1px solid;font-size:10px !important;padding-left:2px;">' + item.label.split('-')[0] + '</td>'
                    + '<td style="width:53%;;border:1px solid;font-size:10px !important;padding-left:2px;">' + item.label.split('-')[1] + '</td>'
                    + '<td style="width:5%;;border:1px solid;font-size:10px !important; text-align:right;padding-right:3px;">' + item.label.split('-')[2] + '</td>'
                    + '<td style="width:9%;;border:1px solid;font-size:10px !important;text-align:right;padding-right:3px;">' + item.label.split('-')[3] + '</td>'
                        + '<td style="width:3%;;border:1px solid;font-size:10px !important;padding-left:5px; padding-right:5px;">' + item.label.split('-')[4] + '</td>'
                        + '</tr></table></a>')
                    .appendTo(ul);
            };


            $('#AutoMatCodes' + ind).on('change keyup', function () {
                if ($('#AutoMatCodes' + ind).val() == "") {
                    ClearMaterialRow(ind);
                }
            });

            $('#AutoMatCodes' + ind).on('autocompleteselect', function (e, ui) {
                $('#AutoMatCodes' + ind).val(ui.item.value);
                GetItemDetailsByCode(ui.item.value, ind);
            });

            $('#AutoMatCodes' + ind).on('blur', function (e, ui) {
                if ($('#AutoMatCodes' + ind).val().trim() != "")
                    if ($('#AutoMatCodes' + ind).val().indexOf('-') == -1) {
                        ModelMsg("Select Proper Item", 3);
                        $('#AutoMatCodes' + ind).val("");
                        return;
                    }
                var txt = $('#AutoMatCodes' + ind).val().trim();
                if (txt == "undefined" || txt == "") {
                    //ModelMsg("Enter Item Code Or Name", 3);
                    event.preventDefault();
                    return false;
                }
                CheckDuplicateItem($('#AutoMatCodes' + ind).val().trim(), ind);
            });


            $("#txtReqQty" + ind).on('change keyup paste', function (event) {
                CalculateSum(ind);

            });

            // allow decimal values only
            $(".allownumericwithdecimal").keydown(function (e) {
                // Allow: backspace, delete, tab, escape, enter
                if ($.inArray(e.keyCode, [46, 8, 9, 13]) !== -1 ||
                    // Allow: Ctrl+A, Command+A
                    ((e.keyCode == 65 || e.keyCode == 67) && (e.metaKey === true)) ||
                    // Allow: home, end, left, right, down, up
                    (e.keyCode >= 35 && e.keyCode <= 40)) {
                    // let it happen, don't do anything

                    var myval = $(this).val();
                    if (myval != "") {
                        if (isNaN(myval)) {
                            $(this).val('');
                            e.preventDefault();
                            return false;
                        }
                    }

                    return;
                }
                // Ensure that it is a number and stop the keypress
                if ((e.shiftKey || (e.keyCode < 48 || e.keyCode > 57)) && (e.keyCode < 96 || e.keyCode > 105)) {
                    e.preventDefault();
                }
            });

        }

        function CalculateSum(ind) {
            var rowCnt_Material = 1;
            var MainLineTotal = 0;
            var MainTaxTotal = 0;
            var MainSubTotal = 0;
            var MainDiscountTotal = 0;
            var totQTY = 0;
            var ALLQTY = 0;

            var FootAvailable = 0;
            var FootOrder = 0;
            var FootDispatch = 0;
            var FootTotalQty = 0;
            var FootSubTotal = 0;
            var FootTax = 0;
            var FootTotalPrice = 0;

            $('#tblMaterialDetail  > tbody > tr').each(function (row, tr) {

                if ($("input[name='AutoMatCode']", this).val() != "") {
                    var Data = new Array();

                    if ($("select[name='ddlUnit']", this).val() != null)
                        Data = $("select[name='ddlUnit']", this).val().split(',');

                    $(".tdPrice", this).text(Data[1]);

                    var Price = $(".tdPrice", this).text();
                    if (Price == "") {
                        Price = 0;
                    }

                    var EnterQty = $("input[name='txtReqQty']", this).val();
                    if (EnterQty == "") {
                        EnterQty = 0;
                    }

                    var Available = $(".tdAvailable", this).text();
                    if (Available == "") {
                        Available = 0;
                    }


                    $(".tdTotalQty", this).text((EnterQty * Data[3]).toFixed(2));
                    $(".tdTax", this).text((Number(Data[2]) * EnterQty).toFixed(2));

                    $(".tdSubTotal", this).text((Number(Price) * parseFloat(EnterQty)).toFixed(2));
                    $(".tdTotalPrice", this).text((Number($(".tdSubTotal", this).text()) + Number($(".tdTax", this).text())).toFixed(2));


                    if (!$("input[name='txtReqQty']", this).is(':disabled')) {
                        $("input[name='hdnDiscountTax']", this).val((Number(Data[2]) * EnterQty).toFixed(2));

                        $("input[name='hdnDiscountSubTotal']", this).val((Number(Price) * parseFloat(EnterQty)).toFixed(2));
                        $("input[name='hdnDiscountTotal']", this).val((Number($(".tdSubTotal", this).text()) + Number($(".tdTax", this).text())).toFixed(2));
                    }


                    FootAvailable = parseFloat(parseFloat(FootAvailable) + parseFloat(Available)).toFixed(2);
                    FootDispatch = parseFloat(parseFloat(FootDispatch) + parseFloat(EnterQty)).toFixed(2);
                    FootOrder = parseFloat(parseFloat(FootOrder) + parseFloat($(".tdOrderQty", this).text())).toFixed(2);
                    FootTotalQty = parseFloat(parseFloat(FootTotalQty) + parseFloat($(".tdTotalQty", this).text())).toFixed(2);
                    FootSubTotal = parseFloat(parseFloat(FootSubTotal) + parseFloat($(".tdSubTotal", this).text())).toFixed(2);

                    FootTax = parseFloat(parseFloat(FootTax) + parseFloat($(".tdTax", this).text())).toFixed(2);
                    FootTotalPrice = parseFloat(parseFloat(FootTotalPrice) + parseFloat($(".tdTotalPrice", this).text())).toFixed(2);
                }
                rowCnt_Material++;
            });

            $("#lblFootAvailable").text(Math.round(FootAvailable));
            $("#lblFootOrder").text(Math.round(FootOrder));
            $("#lblFootDispatch").text(Math.round(FootDispatch));
            $("#lblFootTotalQty").text(Math.round(FootDispatch));

            $("#lblFootSubTotal").text(FootSubTotal);
            $("#lblFootTax").text(FootTax);
            $("#lblFootTotalPrice").text(FootTotalPrice);

            $("#txtSubTotal").val(parseFloat(FootSubTotal).toFixed(2));
            $("#txtTax").val(parseFloat(FootTax).toFixed(2));
            $("#txtTotal").val(FootTotalPrice);
            $("#txtPending").val(FootTotalPrice);

            $("#txtTotalQty").val(Math.round(FootDispatch));
            //$("#txtMachineScheme").val(0);
            //$("#txtMScheme").val(0);
            //$("#txtQScheme").val(0);
            //$("#txtDScheme").val(0);
            //$("#txtVRSDiscount").val(0);
            $("#txtGrossAmount").val(parseFloat(FootSubTotal).toFixed(2));

            CalculateSum_General();
        }

        function GetItemDetailsByCode(itemCode, row) {
            var allUnits = [];
            var itemtext = itemCode;
            var Item = itemCode.split("-")[0].trim();
            var customercode = $("#AutoCustomer").val().split(" - ")[0].trim();
            var ddlWhs = $("select[name='ddlWhs']").val();
            var rowCnt_Material = 1;
            var cnt = 0;
            var errRow = 0;
            var chktemp = $('#chkTemp').is(':checked');
            var chkexisting = $('#chkExisting').is(':checked');

            $('#tblMaterialDetail  > tbody > tr').each(function (row1, tr) {
                // post table's data to Submit form using Json Format

                var itemCode = $("input[name='AutoMatCode']", this).val().split("-")[0].trim();
                //var isActive = $("input[name='txtisDeleteIDMaterial']", this).val();

                var LineNum = $("input[name='hdnLineNum']", this).val();

                //if (isActive == 'true') {
                if (itemCode != "") {
                    if (parseInt(row) != parseInt(LineNum)) {
                        if (Item == itemCode) {
                            cnt = 1;
                            errRow = row;
                            //$("input[name='AutoMatCode']", this).val('');                            
                            event.preventDefault();
                            return false;
                        }
                    }
                    var ItemActive = $("input[name='AutoMatCode']", this).val().split("-")[4];
                    if (ItemActive == 'N') {
                        cnt = 1;
                        errRow = row;
                        $("input[name='AutoMatCode']", this).val('');
                        ModelMsg(Item + ' Product is In-active', 3);
                        event.preventDefault();
                        return false;
                    }
                    if (cnt != 1) {
                        var ItemStock = $("input[name='AutoMatCode']", this).val().split("-")[2].trim();
                        if (ItemStock <= 0) {
                            cnt = 1;
                            errRow = row;
                            $("input[name='AutoMatCode']", this).val('');
                            ModelMsg(Item + ' Book Stock Not Available', 3);
                            event.preventDefault();
                            return false;
                        }
                    }
                    if (cnt != 1) {
                        var ItemRate = $("input[name='AutoMatCode']", this).val().split("-")[3].trim();
                        if (ItemRate <= 0) {
                            cnt = 1;
                            errRow = row;
                            $("input[name='AutoMatCode']", this).val('');
                            ModelMsg(Item + ' Sales Rate Not Available', 3);
                            event.preventDefault();
                            return false;
                        }
                    }

                }
                //}

                rowCnt_Material++;
            });

            if (cnt == 1) {
                event.preventDefault();
                return false;
            }

            else {

                $.ajax({
                    url: 'SaleDirect.aspx/GetItemDetails',
                    type: 'POST',
                    dataType: 'json',
                    async: false,
                    contentType: 'application/json; charset=utf-8',
                    data: JSON.stringify({ itemCode: Item, customer: customercode, WareHouse: ddlWhs, ChkTemp: chktemp, chkExisting: chkexisting }),

                    success: function (result) {
                        if (result == "") {
                            event.preventDefault();
                            return false;
                        }
                        else if (result.d[0].indexOf("ERROR=") >= 0) {
                            var ErrorMsg = result.d[0].split('=')[1].trim();
                            ModelMsg(ErrorMsg, 3);
                            event.preventDefault();
                            return false;
                        }
                        else {
                            var units = result.d[0];
                            $("#ddlUnit" + row + " option[value!='0']").remove();

                            for (var i = 0; i < units.length; i++) {
                                $("#ddlUnit" + row).append('<option value="' + units[i].Value + '">' + units[i].Text + '</option>');
                            }

                            var Data = new Array();

                            if ($("#ddlUnit" + row).val() != null)
                                Data = $("#ddlUnit" + row).val().split(',');

                            $('#tdPrice' + row).text(Data[1]);
                            $('#hdnItemID' + row).val(result.d[1].ItemID);
                            $('#hdnMaterialTaxID' + row).val(result.d[1].TaxID);
                            $('#hdnMaterialUnitPrice' + row).val(Data[1]);
                            $('#hdnMRP' + row).val(result.d[1].MRP);
                            $('#hdnNormalPrice' + row).val(result.d[1].NormalPrice);
                            $('#hdnMaterialPriceTax' + row).val(Data[2]);

                            $('#hdnDiscountPrice' + row).val(Data[1]);
                            $('#hdnDiscountTax' + row).val(Data[2]);

                            $('#tdAvailable' + row).text(result.d[1].AvailQty);
                            $('#tdOrderQty' + row).text("0");
                            CalculateSum();
                            $('#txtReqQty' + row).focus();
                            $('#txtReqQty' + row).select();
                        }
                    },
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        alert('Something is wrong...' + XMLHttpRequest.responseText);
                        event.preventDefault();
                        return false;
                    }
                });
            }

            $('.dataTables_scrollBody').animate({ scrollTop: $('.dataTables_scrollBody').prop("scrollHeight") }, 0);
        }

        function CheckDuplicateItem(itemCode, row) {
            var allUnits = [];
            var itemtext = itemCode;
            var Item = itemCode.split("-")[0].trim();
            var customercode = $("#AutoCustomer").val().split(" - ")[0].trim();
            var ddlWhs = $("select[name='ddlWhs']").val();
            var rowCnt_Material = 1;
            var cnt = 0;
            var errRow = 0;

            $('#tblMaterialDetail  > tbody > tr').each(function (row1, tr) {
                // post table's data to Submit form using Json Format

                var itemCode = $("input[name='AutoMatCode']", this).val().split("-")[0].trim();
                var LineNum = $("input[name='hdnLineNum']", this).val();
                //var isActive = $("input[name='txtisDeleteIDMaterial']", this).val();

                //if (isActive == 'true') {
                if (itemCode != "") {
                    if (parseInt(row) != parseInt(LineNum)) {
                        if (Item == itemCode) {
                            cnt = 1;
                            errRow = row;
                            $('#AutoMatCodes' + row).val('');
                            errormsg = 'Material = ' + itemCode + ' is already seleted at row : ' + rowCnt_Material;
                            event.preventDefault();
                            return false;
                        }
                    }
                }
                //}

                rowCnt_Material++;
            });

            if (cnt == 1) {
                $('#AutoMatCodes' + row).val('');
                ClearMaterialRow(row);
                ModelMsg(errormsg, 3);
                event.preventDefault();
                return false;
            }

            var ind = $('#CountRowMaterial').val();
            if (ind == row) {
                AddMoreRowMaterial();
            }

        }

        function ClearMaterialRow(row) {
            var rowCnt_Material = 1;
            var cnt = 0;
            var lineNum = 0;
            $('#tblMaterialDetail > tbody > tr').each(function (row1, tr) {
                // post table's data to Submit form using Json Format
                var itemCode = $("input[name='AutoMatCode']", this).val();
                if (itemCode == "") {
                    //$(this).remove();
                }
                cnt++;
                rowCnt_Material++;
            });

            if (cnt > 1) {
                var rowCnt_Material = 1;
                $('#tblMaterialDetail > tbody > tr').each(function (row1, tr) {
                    // post table's data to Submit form using Json Format                    
                    if (cnt != rowCnt_Material) {
                        var itemCode = $("input[name='AutoMatCode']", this).val();
                        if (itemCode == "") {
                            $(this).remove();
                            CalculateSum(1);
                            $("#tblMaterialDetail").tableHeadFixer('60vh');
                        }
                    }
                    rowCnt_Material++;
                });
            }
            $('#tblMaterialDetail > tbody > tr').each(function (row1, tr) {
                lineNum++;
                $(".txtSrNo", this).text(lineNum);
            });
        }

        function SetUnitPrice(row) {
            CalculateSum(row);
        }

        function SetExistingCheckboxValue(obj) {

            $("#chkTemp").attr('disabled', false);

            $("#AutoCustomer").val('');
            $('#txtMobile').val('');

            if ($('#chkExisting').is(":checked")) {

                $("#AutoCustomer").addClass('search');

                if ($('#chkTemp').is(":checked")) {

                    $("#AutoCustomer").autocomplete({
                        source: availableCustomer_temp,
                        minLength: 0,
                        scroll: true
                    });
                }
                else {
                    $("#AutoCustomer").autocomplete({
                        source: availableCustomer,
                        minLength: 0,
                        scroll: true
                    });

                }
            }
            else {

                $('#chkTemp').prop('checked', true);
                $("#chkTemp").attr('disabled', true);

                $("#AutoCustomer").removeClass('search');

                $("#AutoCustomer").autocomplete({
                    source: '',
                    minLength: 0,
                    scroll: true
                });

            }
        }

        function Confirm() {

            $.blockUI({
                message: '<img src="../Images/loadingbd.gif" />',
                css: {
                    padding: 0,
                    margin: 0,
                    width: '15%',
                    top: '36%',
                    left: '40%',
                    textAlign: 'center',
                    cursor: 'wait'
                }
            });

            var TableData_Material = [];
            var rowCnt_Material = 1;
            var totalItemcnt = 0;
            var cnt = 0;
            $('#tblMaterialDetail > tbody > tr').each(function (row, tr) {

                var ItemCode = $("input[name='AutoMatCode']", this).val();
                if (ItemCode != "") {

                    totalItemcnt = 1;

                    var Data = $("select[name='ddlUnit']", this).val().split(',');
                    var UOMName = $("select[name='ddlUnit']", this).val();
                    var Price = $(".tdPrice", this).text();
                    var AvlQty = $(".tdAvailable", this).text();
                    var SubTotal = $(".tdSubTotal", this).text();
                    var RequestQty = $("input[name='txtReqQty']", this).val();
                    var TotalQty = $(".tdTotalQty", this).text();
                    var Tax = $(".tdTax", this).text();
                    var Total = $(".tdTotalPrice", this).text();
                    var ItemID = $("input[name='hdnItemID']", this).val();
                    var MainID = $("input[name='hdnMainID']", this).val();
                    var MRP = $("input[name='hdnMRP']", this).val();
                    var NormalPrice = $("input[name='hdnNormalPrice']", this).val();
                    //if ((UOMName != "" || RequestQty != "") && ItemCode == "") {
                    //    cnt = 1;
                    //    errormsg = 'Please Select Item Code in Row: ' + rowCnt_Material;
                    //    event.preventDefault();
                    //    return false;
                    //}

                    if (ItemCode != "" && RequestQty == "0") {
                        $.unblockUI();
                        cnt = 1;
                        errormsg = 'Please enter Dispatch Quantity in Row: ' + (parseInt(rowCnt_Material) + 1);
                        event.preventDefault();
                        return false;
                    }

                    var obj = {
                        ItemID: ItemID,
                        ItemCode: ItemCode,
                        Price: Price,
                        AvlQty: AvlQty,
                        RequestQty: RequestQty,
                        TotalQty: TotalQty,
                        SubTotal: SubTotal,
                        Tax: Tax,
                        Total: Total,
                        MainID: MainID,
                        UnitID: Data[0],
                        UnitPrice: Data[1],
                        MRP: MRP,
                        NormalPrice: NormalPrice,
                        PriceTax: Data[2],
                        MapQuantity: Data[3],
                    };
                    TableData_Material.push(obj);
                }
                rowCnt_Material++;
            });

            if (totalItemcnt == 0) {
                $.unblockUI();
                ModelMsg("Please select atleast one Item", 3);
                event.preventDefault();
                return false;
            }
            if (cnt == 1) {
                $.unblockUI();
                ModelMsg(errormsg, 3);
                event.preventDefault();
                return false;
            }
            $('#hidJsonInputMaterial').val(JSON.stringify(TableData_Material));

            var AutoCustomer = $('#AutoCustomer').val().split(" - ")[0].trim();
            var AutoTemplate = $('#AutoTemplate').val();
            var AutoVehicle = $('#AutoVehicle').val();
            var AutoOrderForm = $('#AutoOrderForm').val();
            var ChkTemp = $('#chkTemp').is(':checked');
            var ddlWhs = $("select[name='ddlWhs']").val();

            var lblFootSubTotal = $(".lblFootSubTotal").text();
            var lblFootTotalPrice = $(".lblFootTotalPrice").text();

            var postData = {
                AutoCustomer: AutoCustomer,
                AutoTemplate: AutoTemplate,
                AutoVehicle: AutoVehicle,
                AutoOrderForm: AutoOrderForm,
                ChkTemp: ChkTemp,
                ddlWhs: ddlWhs,
                SubTotal: lblFootSubTotal,
                Total: lblFootTotalPrice,
            }
            $('#hidJsonOrderDetail').val(JSON.stringify(postData));

            var MaterialData = $('#hidJsonInputMaterial').val();
            var HeaderData = $('#hidJsonOrderDetail').val();

            $.ajax({
                url: 'SaleDirect.aspx/LoadSchemeData',
                type: 'POST',
                dataType: 'json',
                traditional: true,
                data: JSON.stringify({ hidJsonInputMaterial: MaterialData, hidJsonInputHeader: HeaderData }),
                contentType: 'application/json; charset=utf-8',
                success: function (result) {
                    $.unblockUI();
                    if (result.d == "") {
                        event.preventDefault();
                        return false;
                    }
                    else if (result.d[0].indexOf("ERROR=") >= 0) {
                        var ErrorMsg = result.d[0].split('=')[1].trim();
                        ModelMsg(ErrorMsg, 3);
                        event.preventDefault();
                        return false;
                    }
                    else {

                        var cnt = 1;
                        if (ChkTemp == false) {

                            //var SchemeTotal = $('#txtSchemeTotal').val();
                            //if (SchemeID_Apply == '') {
                            $('.txtMachineScheme').val(result.d[0]);
                            $('.txtVRSDiscount').val(result.d[1]);
                            $('.txtMScheme').val(result.d[2]);

                            $('.txtDScheme').val(result.d[3]);

                            //    $('#SCHEMEAMOUNT').val(parseFloat(result[0]).toFixed(2));
                            //}
                            //else {
                            //    $('#txtSchemeTotal').val(parseFloat(parseFloat(SchemeTotal) + parseFloat(result[0])).toFixed(2));
                            //    $('#SCHEMEAMOUNT').val(parseFloat(parseFloat(SchemeTotal) + parseFloat(result[0])).toFixed(2));
                            //}
                            //CalculateSum_General();
                          
                            for (var i = 0; i < result.d[4].length; i++) {
                                //$('#CountRowMaterial').val(i);
                                  
                                if (result.d[4][i].MainID == "1") {
                                    AddMoreRowMaterial();
                                    var ind = $('#CountRowMaterial').val();
                                    ind = parseInt(ind) - 1;
                                     
                                    // console.log(2);
                                    //  console.log(result.d[4][i].ItemCode + ' - ' + result.d[4][i].ItemName);
                                    // console.log(2);
                                    $('#AutoMatCodes' + ind).val(result.d[4][i].ItemCode + ' - ' + result.d[4][i].ItemName);
                                    GetItemDetailsByCode($('#AutoMatCodes' + ind).val(), ind);

                                    //$('#tdPrice' + cnt).text(result.d[2][i].PRICE);
                                    $('#txtReqQty' + ind).val(result.d[4][i].Quantity);
                                    $('#hdnMainID' + ind).val(result.d[4][i].MainID);
                                    $('#hdnSchemeID' + ind).val(result.d[4][i].SchemeID);
                                    $('#hdnMaterialTaxID' + ind).val(result.d[4][i].TaxID);
                                    CalculateSum(ind);
                                    $('#hdnDiscountPrice' + ind).val(result.d[4][i].Price);
                                    $('#hdnDiscountTax' + ind).val(result.d[4][i].Tax);
                                    $('#hdnDiscountSubTotal' + ind).val(result.d[4][i].SubTotal);
                                    $('#hdnDiscountTotal' + ind).val(result.d[4][i].Total);

                                }
                                else {
                                     
                                    rowCnt_Material = 1;
                                    $('#tblMaterialDetail  > tbody > tr').each(function (row, tr) {
                                        var ItemCode = $("input[name='hdnItemID']", this).val();
                                        if (ItemCode != "0") {
                                            if (ItemCode == result.d[4][i].ItemID) {
                                                $("input[name='hdnSchemeID']", this).val(result.d[4][i].SchemeID);
                                                $("input[name='hdnItemScheme']", this).val(parseFloat(result.d[4][i].ItemScheme));
                                                $("input[name='hdnScheme']", this).val(parseFloat(result.d[4][i].Scheme));
                                                CalculateSum(rowCnt_Material);
                                                $("input[name='hdnDiscountPrice']", this).val(result.d[4][i].Price);
                                                $("input[name='hdnDiscountTax']", this).val(result.d[4][i].Tax);
                                                $("input[name='hdnDiscountSubTotal']", this).val(result.d[4][i].SubTotal);
                                                $("input[name='hdnDiscountTotal']", this).val(result.d[4][i].Total);

                                            }
                                        }
                                        rowCnt_Material++;
                                    });
                                }

                                cnt++;
                            }
                            $('#txtSubTotal').val(parseFloat(result.d[6]).toFixed(2));
                            $('#txtTax').val(parseFloat(result.d[7]).toFixed(2));

                            var SchemeIDs = [];
                            for (var i = 0; i < result.d[8].length; i++) {
                                var obj = {
                                    SchemeID: result.d[8][i].SchemeID,
                                    Mode: result.d[8][i].Mode,
                                    Amount: result.d[8][i].Amount,
                                    EffectOnBill: result.d[8][i].EffectOnBill,
                                    ContraTax: result.d[8][i].ContraTax,
                                    SaleAmount: result.d[8][i].SaleAmount,
                                    AssetID: result.d[8][i].AssetID,
                                    BasedOn: result.d[8][i].BasedOn,
                                    RateForScheme: result.d[8][i].RateForScheme,
                                    ItemID: result.d[8][i].ItemID
                                }
                                SchemeIDs.push(obj);
                            }
                            $('#hdnSchemeIDs').val(JSON.stringify(SchemeIDs));
                        }

                        cnt = 1;
                        $('#chkHead').prop('checked', true);
                        var HasQPS = 0;
                        var IsEable = true;
                        for (var i = 0; i < result.d[5].length; i++) {
                            HasQPS = 1;
                            AddMoreRowScheme();
                            if (result.d[5][i].MainId == 1 && IsEdit == false) {
                                $('#chkCheck' + cnt).prop('checked', true);
                                IsEable = false;
                            }
                           
                            $('#tdSchemeName' + cnt).text(result.d[5][i].ScName);
                            if (result.d[5][i].ItemCode != null) {
                                $('#tdItemCode' + cnt).val(result.d[5][i].ItemCode);
                            }
                            else {
                                $('#tdItemCode' + cnt).val('');
                            }

                            if (result.d[5][i].ItemName != null) {
                                $('#tdSchemeItemName' + cnt).text(result.d[5][i].ItemCode + ' - ' + result.d[5][i].ItemName);
                            }
                            else {
                                $('#tdSchemeItemName' + cnt).text('');
                            }

                            if (result.d[5][i].UnitName != null) {
                                $('#tdUnit' + cnt).text(result.d[5][i].UnitName);
                            }
                            else {
                                $('#tdUnit' + cnt).text('');
                            }
                            if (result.d[5][i].AvailQty != null) {
                                $('#tdStock' + cnt).text(result.d[5][i].AvailQty);
                            }
                            else {
                                $('#tdStock' + cnt).text('');
                            }
                            $("#lblQPSSchemeMessage").text(result.d[5][0].AlertMessage);
                            $("#lblSchemeAmount").text(result.d[5][0].SaleAmount);
                            $("#lblQtyPrint").text(' / ' + result.d[5][0].QPSQTY);
                            $('#tdQuantity' + cnt).text(result.d[5][i].Quantity);
                            $('#tdDiscount' + cnt).text(parseFloat(result.d[5][i].Discount).toFixed(2));
                            $('#txtSchemeID' + cnt).text(result.d[5][i].SchemeID);
                            $('#hdnSchemID' + cnt).val(result.d[5][i].SchemeID);

                            $('#tdOccurance' + cnt).text(result.d[5][i].Occurance.toFixed(2));
                            if (result.d[5][i].BasedOn == "1") {
                                $('#tdBasedOn' + cnt).text("Gross Amount");
                            }
                            else if (result.d[5][i].BasedOn == "2") {
                                $('#tdBasedOn' + cnt).text("Purchase Qty");
                            }
                            else {
                                $('#tdBasedOn' + cnt).text("Unit");
                            }

                            $('#tdHigherLimit' + cnt).text(result.d[5][i].HigherLimit.toFixed(2));
                            $('#tdLowerLimit' + cnt).text(result.d[5][i].LowerLimit.toFixed(2));

                            $('#tdIsPair' + cnt).text(result.d[5][i].IsPair);


                            $('#hdnBasedOn' + cnt).val(result.d[5][i].BasedOn);
                            $('#hdnRateForScheme' + cnt).val(result.d[5][i].RateForScheme);
                            $('#hdnSaleAmount' + cnt).val(result.d[5][i].SaleAmount);
                            $('#hdnMode' + cnt).val(result.d[5][i].Mode);

                            $('#hdnTaxID' + cnt).val(result.d[5][i].TaxID);
                            $('#hdnTax' + cnt).val(result.d[5][i].Tax);

                            $('#hdnPrice' + cnt).val(result.d[5][i].Price);
                            $('#hdnPriceTax' + cnt).val(result.d[5][i].PriceTax);

                            $('#hdnSchemeUnitPrice' + cnt).val(result.d[5][i].UnitPrice);
                            $('#hdnSchemeMRP' + cnt).val(result.d[5][i].MRP);
                            $('#hdnContraTax' + cnt).val(result.d[5][i].ContraTax);
                            $('#hdnSchemeItemID' + cnt).val(result.d[5][i].ItemID);
                            $('#hdnSchemeNormalPrice' + cnt).val(result.d[5][i].NormalPrice);
                            $('#hdnSchemeDiscount' + cnt).val(result.d[5][i].SchemeDiscount);
                            $('#hdnScheme3ID' + cnt).val(result.d[5][i].Scheme3ID);
                            cnt++;

                        }
                        if (IsEable == false) {
                            $('.chktbl').prop('disabled', true);
                        }
                        else {
                            $('.chktbl').prop('disabled', false);
                        }
                        if (HasQPS == 1) {
                            $('#tabs a[href="#tabs-2"]').tab('show');
                        }

                        CalculateSum(0);

                        CalculateSum_General();
                        // 21-Sep-22  Vimal -> As per discuss with jigneshbhai Sub Total Calculation wrong so changed
                        //var SubTotal = parseFloat($("#txtSubTotal").val()) - parseFloat($('.txtTotalDiscoun').val());
                        // $("#txtSubTotal").val(SubTotal);
                        SetReadOnly(true);
                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    $.unblockUI();
                    alert('Something is wrong...' + XMLHttpRequest.responseText);
                    event.preventDefault();
                    return false;
                }
            });
        }

        function SetReadOnly(readonly) {

            if (OrderID == 0) {
                $("#AutoCustomer").attr('disabled', readonly);
                $("#chkExisting").attr('disabled', readonly);
                $("#chkExisting").attr('disabled', true);
                $("#chkTemp").attr('disabled', true);
                // $("#chkTemp").attr('disabled', readonly);
                //  $("#txtDate").attr('disabled', readonly);
            }
            var rowCnt_Material = 1;
            $('#tblMaterialDetail  > tbody > tr').each(function (row, tr) {
                $("input[name='AutoMatCode']", this).attr('disabled', readonly);
                $("input[name='txtReqQty']", this).attr('disabled', readonly);
                $("select[name='ddlUnit']", this).attr('disabled', readonly);
                rowCnt_Material++;
            });

            if (readonly == true) {
                $('#btnConfirm').css("display", "none");
                $('#btnEdit').css("display", "");
                $('#btnApplyScheme').css("display", "");
            }
            else {
                $('#btnConfirm').css("display", "");
                $('#btnEdit').css("display", "none");
                $('#btnApplyScheme').css("display", "none");
            }
        }

        function Edit() {
            IsEdit = true;
            SetReadOnly(false);
            //SetTab("#Material");
            //$("#btnSubmit").attr('disabled', true);
            $('#tabs a[href="#tabs-1"]').tab('show');
            $('#hdnSchemeApply').val('0');
            var cnt = 1;
            var len = $("#tblSchemeDetail > tbody > tr").length;
            var lineNum = 0;
            $("#tblSchemeDetail tr").each(function () {
                if (cnt > 1) {
                    $(this).remove();
                }
                cnt++;
            });

            $('#CountRowScheme').val(0);

            //$('#SCHEMEAMOUNT').val(0);
            //$('#txtSchemeTotal').val(0);

            var TableData_Material = [];
            var rowCnt_Material = 1;
            var totalItemcnt = 0;
            var cnt = 0;
            $('#tblMaterialDetail  > tbody > tr').each(function (row, tr) {
                var MainID = $("input[name='hdnMainID']", this).val();
                if (MainID == "1") {
                    $(this).remove();
                }
                else {
                    $("input[name='hdnMainID']", this).val('0');
                    $("input[name='hdnSchemeID']", this).val('0');
                    $("input[name='hdnScheme']", this).val('0');
                    $("input[name='hdnItemScheme']", this).val('0');

                    $("input[name='AutoMatCode']", this).val($("input[name='AutoMatCode']", this).val().replace("#  ", ""));
                    CalculateSum(rowCnt_Material);
                    cnt++;
                }
                rowCnt_Material++;
            });
            $('#tblMaterialDetail > tbody > tr').each(function (row1, tr) {
                lineNum++;
                $(".txtSrNo", this).text(lineNum);
            });
            $('#hdnSchemeIDs').val('');
            //$('#CountRowMaterial').val(cnt);
        }

        function AddMoreRowScheme() {
            $('table#tblSchemeDetail tr#NoROW').remove();  // Remove NO ROW

            /// Add Dynamic Row to the existing Table
            var ind = $('#CountRowScheme').val();
            ind = parseInt(ind) + 1;
            $('#CountRowScheme').val(ind);

            var str = "";
            str = "<tr id='trScheme" + ind + "'>"
                + "<td><input type='radio' id='chkCheck" + ind + "' name='chkCheck' class='chktbl' class='form-control search' /></td>"
                + "<td id='tdSrNo" + ind + "' class='tdSrNo'>" + ind + "</td>"
                + "<td id='tdSchemeName" + ind + "' class='tdSchemeName'></td>"

                + "<td id='tdSchemeItemName" + ind + "' class='tdSchemeItemName'></td>"
                + "<td id='tdUnit" + ind + "' class='tdUnit'></td>"
                + "<td id='tdStock" + ind + "' class='tdStock'></td>"
                + "<td id='tdQuantity" + ind + "' class='tdQuantity'></td>"
                + "<td id='tdDiscount" + ind + "' class='tdDiscount'></td>"

                + "<td id='tdLowerLimit" + ind + "' class='tdLowerLimit'></td>"
                + "<td id='tdHigherLimit" + ind + "' class='tdHigherLimit'></td>"
                + "<td id='tdOccurance" + ind + "' class='tdOccurance'></td>"
                + "<td id='tdBasedOn" + ind + "' class='tdBasedOn'></td>"
                + "<td id='tdIsPair" + ind + "' class='tdIsPair'></td>"
                + "<td style='display:none'><input type='text' id='txtSchemeID" + ind + "' name='txtSchemeID' style='display:none' value='0' /></td>"
                + "<td style='display:none'>"
                + "<input type='hidden' id='hdnSchemID" + ind + "' name='hdnSchemID' value='0' />"
                + "<input type='hidden' id='hdnBasedOn" + ind + "' name='hdnBasedOn' value='0' />"
                + "<input type='hidden' id='hdnRateForScheme" + ind + "' name='hdnRateForScheme' value='0' />"
                + "<input type='hidden' id='hdnSaleAmount" + ind + "' name='hdnSaleAmount' value='0' />"
                + "<input type='hidden' id='hdnMode" + ind + "' name='hdnMode' value='0' />"
                + "<input type='hidden' id='hdnTaxID" + ind + "' name='hdnTaxID' value='0' />"
                + "<input type='hidden' id='hdnSchemeItemID" + ind + "' name='hdnSchemeItemID' value='0' />"
                + "<input type='hidden' id='hdnTax" + ind + "' name='hdnTax' value='0' />"
                + "<input type='hidden' id='hdnPrice" + ind + "' name='hdnPrice' value='0' />"
                + "<input type='hidden' id='hdnPriceTax" + ind + "' name='hdnPriceTax' value='0' />"
                + "<input type='hidden' id='hdnSchemeNormalPrice" + ind + "' name='hdnSchemeNormalPrice' value='0' />"
                + "<input type='hidden' id='hdnContraTax" + ind + "' name='hdnContraTax' value='0' />"
                + "<input type='hidden' id='hdnSchemeDiscount" + ind + "' name='hdnSchemeDiscount' value='0' />"
                + "<input type='hidden' id='hdnScheme3ID" + ind + "' name='hdnScheme3ID' value='0' />"
                + "<input type='hidden' id='hdnSchemeUnitPrice" + ind + "' name='hdnSchemeUnitPrice' value='0' />"
                + "<input type='hidden' id='hdnSchemeMRP" + ind + "' name='hdnSchemeMRP' value='0' />"
                + "<input type='hidden' id='tdItemCode" + ind + "' name='tdItemCode' value='0' />"
                + "</td>"
                + "</tr>";


            $('#tblSchemeDetail').append(str);
        }

        function ApplyScheme(SchemeID_Apply) {
             
            $.blockUI({
                message: '<img src="../Images/loadingbd.gif" />',
                css: {
                    padding: 0,
                    margin: 0,
                    width: '15%',
                    top: '36%',
                    left: '40%',
                    textAlign: 'center',
                    cursor: 'wait'
                }
            });

            var TableData_Scheme = [];
            var rowCnt_Scheme = 0;
            var totalItemcnt = 0;
            var cnt = 0;
            $('#tblSchemeDetail tr').each(function (row, tr) {
                if (rowCnt_Scheme != 0) {  // Don't add data for the Header-Row
                    var check = $("input[name='chkCheck']", this).is(":checked");
                    var SchemID = $("input[name='hdnSchemID']", this).val();
                    if (check == true) {

                        totalItemcnt = 1;
                        var SchemeName = $(".tdSchemeName", this).text();
                        //var ItemCode = $(".tdItemCode", this).text();
                        var ItemCode = $("input[name='tdItemCode']", this).val();
                        var tdSchemeItemName = $(".tdSchemeItemName", this).text();
                        var Unit = $(".tdUnit", this).text();
                        var Stock = $(".tdStock", this).text();
                        var Quantity = $(".tdQuantity", this).text();
                        var Discount = $(".tdDiscount", this).text();
                        var BasedOn = $("input[name='hdnBasedOn']", this).val();
                        var RateForScheme = $("input[name='hdnRateForScheme']", this).val();
                        var SaleAmount = $("input[name='hdnSaleAmount']", this).val();
                        var SchemeDiscount = $("input[name='hdnSchemeDiscount']", this).val();
                        var NormalPrice = $("input[name='hdnSchemeNormalPrice']", this).val();
                        var Mode = $("input[name='hdnMode']", this).val();
                        var TaxID = $("input[name='hdnTaxID']", this).val();
                        var Tax = $("input[name='hdnTax']", this).val();
                        var Price = $("input[name='hdnPrice']", this).val();
                        var PriceTax = $("input[name='hdnPriceTax']", this).val();
                        var UnitPrice = $("input[name='hdnSchemeUnitPrice']", this).val();
                        var MRP = $("input[name='hdnSchemeMRP']", this).val();
                        var ContraTax = $("input[name='hdnContraTax']", this).val();
                        var Scheme3ID = $("input[name='hdnScheme3ID']", this).val();
                        var SchemeItemID = $("input[name='hdnSchemeItemID']", this).val();
                        var obj = {
                            check: check,
                            SchemeName: SchemeName,
                            ItemCode: ItemCode,
                            ItemName: tdSchemeItemName,
                            Unit: Unit,
                            Quantity: Quantity,
                            Discount: Discount,
                            SchemeID: SchemID,
                            BasedOn: BasedOn,
                            RateForScheme: RateForScheme,
                            SaleAmount: SaleAmount,
                            Mode: Mode,
                            TaxID: TaxID,
                            Tax: Tax,
                            Price: Price,
                            PriceTax: PriceTax,
                            ContraTax: ContraTax,
                            SchemeDiscount: SchemeDiscount,
                            NormalPrice: NormalPrice,
                            Scheme3ID: Scheme3ID,
                            ItemID: SchemeItemID,
                            UnitPrice: UnitPrice,
                            MRP: MRP
                        };
                        TableData_Scheme.push(obj);
                    }
                }
                rowCnt_Scheme++;
            });

            if (rowCnt_Scheme > 1) {
                if (totalItemcnt == 0) {
                    $.unblockUI();
                    ModelMsg("Please select at least one Scheme", 3);
                    event.preventDefault();
                    return false;
                }
            }
            $('#hidJsonInputScheme').val(JSON.stringify(TableData_Scheme));

            var TableData_Material = [];
            var rowCnt_Material = 1;
            var totalItemcnt = 0;
            var cnt = 0;
            $('#tblMaterialDetail  > tbody > tr').each(function (row, tr) {
                var MainID = $("input[name='hdnMainID']", this).val();
                if (MainID == "1") {
                    $(this).remove();
                }
                rowCnt_Material++;
            });

            rowCnt_Material = 1;

            $('#tblMaterialDetail  > tbody > tr').each(function (row, tr) {
                var ItemCode = $("input[name='AutoMatCode']", this).val();
                if (ItemCode != "") {
                    totalItemcnt = 1;
                    var Data = $("select[name='ddlUnit']", this).val().split(',');
                    var UOMName = $("select[name='ddlUnit']", this).val();
                    var Price = $("input[name='hdnDiscountPrice']", this).val();
                    var AvlQty = $(".tdAvailable", this).text();
                    var SubTotal = $("input[name='hdnDiscountSubTotal']", this).val();
                    var RequestQty = $("input[name='txtReqQty']", this).val();
                    var TotalQty = $(".tdTotalQty", this).text();
                    var Tax = $("input[name='hdnDiscountTax']", this).val();
                    var Total = $("input[name='hdnDiscountTotal']", this).val();
                    var ItemID = $("input[name='hdnItemID']", this).val();
                    var MainID = $("input[name='hdnMainID']", this).val();
                    var hdnItemScheme = $("input[name='hdnItemScheme']", this).val();
                    var hdnScheme = $("input[name='hdnScheme']", this).val();
                    var MRP = $("input[name='hdnMRP']", this).val();
                    var NormalPrice = $("input[name='hdnNormalPrice']", this).val();

                    if ((UOMName != "" || RequestQty != "") && ItemCode == "") {
                        $.unblockUI();
                        cnt = 1;
                        errormsg = 'Please Select Item Code in Row: ' + rowCnt_Material;
                        event.preventDefault();
                        return false;
                    }

                    if (ItemCode != "" && RequestQty == "0") {
                        $.unblockUI();
                        cnt = 1;
                        errormsg = 'Please enter Request Quantity in Row: ' + rowCnt_Material;
                        event.preventDefault();
                        return false;
                    }

                    var obj = {
                        ItemID: ItemID,
                        ItemCode: ItemCode,
                        Price: Price,
                        AvlQty: AvlQty,
                        RequestQty: RequestQty,
                        TotalQty: TotalQty,
                        SubTotal: SubTotal,
                        Tax: Tax,
                        Total: Total,
                        MainID: MainID,
                        UnitID: Data[0],
                        UnitPrice: Data[1],
                        MRP: MRP,
                        NormalPrice: NormalPrice,
                        PriceTax: Data[2],
                        MapQuantity: Data[3],
                        ItemScheme: hdnItemScheme,
                        Scheme: hdnScheme
                    };
                    TableData_Material.push(obj);
                }
                rowCnt_Material++;
            });

            $('#hidJsonInputMaterial').val(JSON.stringify(TableData_Material));

            var AutoCustomer = $('#AutoCustomer').val().split(" - ")[0].trim();
            var AutoTemplate = $('#AutoTemplate').val();
            var AutoVehicle = $('#AutoVehicle').val();
            var AutoOrderForm = $('#AutoOrderForm').val();
            var ChkTemp = $('#chkTemp').is(':checked');
            var ddlWhs = $("select[name='ddlWhs']").val();

            var lblFootSubTotal = $(".lblFootSubTotal").text();
            var lblFootTotalPrice = $(".lblFootTotalPrice").text();

            var postData = {
                AutoCustomer: AutoCustomer,
                AutoTemplate: AutoTemplate,
                AutoVehicle: AutoVehicle,
                AutoOrderForm: AutoOrderForm,
                ChkTemp: ChkTemp,
                ddlWhs: ddlWhs,
                SubTotal: lblFootSubTotal,
                Total: lblFootTotalPrice,
            }
            $('#hidJsonOrderDetail').val(JSON.stringify(postData));

            var successMSG = false;
            var MaterialData = $('#hidJsonInputMaterial').val();
            var SchemeData = $('#hidJsonInputScheme').val();
            var HeaderData = $('#hidJsonOrderDetail').val();
            var successMSG = true;



            if (successMSG == false) {
                $.unblockUI();
                event.preventDefault();
                return false;
            }
            else {
                $.unblockUI();
                //$("#btnSubmit").attr('disabled', false);                
                //$('#hdnSchemeApply').val('1');
                var successMSG = true;
                var SchemeAmount = 0; //$('#SCHEMEAMOUNT').val();
                $.ajax({
                    url: 'SaleDirect.aspx/ApplyScheme',
                    type: 'POST',
                    async: false,
                    dataType: 'json',
                    traditional: true,
                    data: JSON.stringify({ hidJsonInputMaterial: MaterialData, hidJsonInputHeader: HeaderData, hidJsonInputScheme: SchemeData, hdnSchemeIDs: $('#hdnSchemeIDs').val() }),
                    contentType: 'application/json; charset=utf-8',

                    success: function (result) {
                        $.unblockUI();
                        if (result.d == "") {
                            event.preventDefault();
                            return false;
                        }
                        else if (result.d[0].indexOf("ERROR=") >= 0) {
                            var ErrorMsg = result.d[0].split('=')[1].trim();
                            ModelMsg(ErrorMsg, 3);
                            event.preventDefault();
                            return false;
                        }
                        else {

                            //if (ChkTemp == false) {
                            $('.txtQScheme').val(parseFloat(result.d[0]).toFixed(2));
                            //$('#txtTax').val(parseFloat(result.d[3]).toFixed(2));

                            //var SchemeTotal = $('#txtSchemeTotal').val();
                            //if (SchemeID_Apply == '') {
                            //    $('#txtSchemeTotal').val(parseFloat(result[0]).toFixed(2));
                            //    $('#SCHEMEAMOUNT').val(parseFloat(result[0]).toFixed(2));
                            //}
                            //else {
                            //    $('#txtSchemeTotal').val(parseFloat(parseFloat(SchemeTotal) + parseFloat(result[0])).toFixed(2));
                            //    $('#SCHEMEAMOUNT').val(parseFloat(parseFloat(SchemeTotal) + parseFloat(result[0])).toFixed(2));
                            //}
                            //CalculateSum_General();
                            var cnt = 1;
                            for (var i = 0; i < result.d[1].length; i++) {

                                if (result.d[1][i].MainID == "1") {
                                   
                                    AddMoreRowMaterial();
                                    var ind = $('#CountRowMaterial').val();
                                    ind = parseInt(ind) - 1;


                                    $('#AutoMatCodes' + ind).val(result.d[1][i].ItemName);

                                    $("#ddlUnit" + ind + " option[value!='0']").remove();

                                    var UnitID = result.d[1][i].UnitID + ',' + (result.d[1][i].Price) + ',' + (isNaN((result.d[1][i].Tax) / (result.d[1][i].Quantity)) ? 0 : ((result.d[1][i].Tax) / (result.d[1][i].Quantity))) + ',' + result.d[1][i].MapQty;

                                    $("#ddlUnit" + ind).append('<option value="' + UnitID + '">' + result.d[1][i].UnitName + '</option>');

                                    $('#hdnItemID' + ind).val(result.d[1][i].ItemID);

                                    $('#tdAvailable' + ind).text(result.d[1][i].AvailQty);
                                    $('#tdOrderQty' + ind).text("0");
                                    $('#tdPrice' + ind).text(result.d[1][i].Price);
                                    $('#txtReqQty' + ind).val(result.d[1][i].Quantity);
                                    $('#hdnMainID' + ind).val(result.d[1][i].MainID);
                                    $('#hdnSchemeID' + ind).val(result.d[1][i].SchemeID);
                                    $('#hdnMaterialPriceTax' + ind).val(result.d[1][i].PriceTax);
                                    $('#hdnMaterialUnitPrice' + ind).val(result.d[1][i].UnitPrice);
                                    $('#hdnMRP' + ind).val(result.d[1][i].MRP);
                                    $('#hdnNormalPrice' + ind).val(result.d[1][i].NormalPrice);
                                    $('#hdnMaterialTaxID' + ind).val(result.d[1][i].TaxID);
                                    $('#hdnItemScheme' + ind).val(parseFloat(result.d[1][i].ItemScheme).toFixed(2));
                                    $('#hdnScheme' + ind).val(parseFloat(result.d[1][i].Scheme).toFixed(2));
                                    CalculateSum(ind);
                                    $('#hdnDiscountPrice' + ind).val(result.d[1][i].Price);
                                    $('#hdnDiscountTax' + ind).val(result.d[1][i].Tax);
                                    $('#hdnDiscountSubTotal' + ind).val(result.d[1][i].SubTotal);
                                    $('#hdnDiscountTotal' + ind).val(result.d[1][i].Total);


                                }
                                else {
                                    
                                    rowCnt_Material = 1;
                                    $('#tblMaterialDetail  > tbody > tr').each(function (row, tr) {
                                        var ItemCode = $("input[name='hdnItemID']", this).val();
                                        if (ItemCode != "0") {
                                            if (ItemCode == result.d[1][i].ItemID) {
                                                $("input[name='AutoMatCode']", this).val(result.d[1][i].ItemCode);

                                                $("input[name='hdnSchemeID']", this).val(result.d[1][i].SchemeID);
                                                $("input[name='hdnItemScheme']", this).val(parseFloat(result.d[1][i].ItemScheme));
                                                $("input[name='hdnScheme']", this).val(parseFloat(result.d[1][i].Scheme));
                                                $("input[name='hdnMainID']", this).val(parseFloat(result.d[1][i].MainID));
                                                CalculateSum(rowCnt_Material);
                                                $("input[name='hdnDiscountPrice']", this).val(result.d[1][i].Price);
                                                $("input[name='hdnDiscountTax']", this).val(result.d[1][i].Tax);
                                                $("input[name='hdnDiscountSubTotal']", this).val(result.d[1][i].SubTotal);
                                                $("input[name='hdnDiscountTotal']", this).val(result.d[1][i].Total);

                                            }
                                        }
                                        rowCnt_Material++;
                                    });
                                }
                            }
                            $('#txtSubTotal').val(parseFloat(result.d[2]).toFixed(2));
                            $('#txtTax').val(parseFloat(result.d[3]).toFixed(2));

                            var SchemeIDs = [];
                            for (var i = 0; i < result.d[4].length; i++) {
                                var obj = {
                                    SchemeID: result.d[4][i].SchemeID,
                                    Mode: result.d[4][i].Mode,
                                    Amount: result.d[4][i].Amount,
                                    EffectOnBill: result.d[4][i].EffectOnBill,
                                    ContraTax: result.d[4][i].ContraTax,
                                    SaleAmount: result.d[4][i].SaleAmount,
                                    AssetID: result.d[4][i].AssetID,
                                    BasedOn: result.d[4][i].BasedOn,
                                    RateForScheme: result.d[4][i].RateForScheme,
                                    ItemID: result.d[4][i].ItemID
                                }
                                SchemeIDs.push(obj);
                            }
                            $('#hdnSchemeIDs').val(JSON.stringify(SchemeIDs));
                            //}
                            CalculateSum_General();
                            SetReadOnly(true);
                            $('#hdnSchemeApply').val('1');
                            $('#tabs a[href="#tabs-1"]').tab('show');
                            $('#btnApplyScheme').css("display", "none");

                        }

                        //SetTab("#Material");
                    },
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        $.unblockUI();
                        alert('Something is wrong...' + XMLHttpRequest.responseText);
                        event.preventDefault();
                        return false;
                    }
                });
            }
        }

        function CalculateSum_General() {

            var SubTotal = $("#txtSubTotal").val();
            if (SubTotal == "") {
                SubTotal = 0;
            }
            var Tax = $("#txtTax").val();
            if (Tax == "") {
                Tax = 0;
            }
            var MachineScheme = $("#txtMachineScheme").val();
            if (MachineScheme == "") {
                MachineScheme = 0;
            }
            var VRSScheme = $("#txtVRSDiscount").val();
            if (VRSScheme == "") {
                VRSScheme = 0;
            }
            var MScheme = $("#txtMScheme").val();
            if (MScheme == "") {
                MScheme = 0;
            }
            var QScheme = $("#txtQScheme").val();
            if (QScheme == "") {
                QScheme = 0;
            }
            var DisScheme = $("#txtDScheme").val();
            if (DisScheme == "") {
                DisScheme = 0;
            }

            $('.txtTotalDiscoun').val((parseFloat(MachineScheme) + parseFloat(VRSScheme) + parseFloat(MScheme) + parseFloat(QScheme) + parseFloat(DisScheme)).toFixed(2));


            //SubTotal = parseFloat(SubTotal) - parseFloat(MScheme) - parseFloat(QScheme);
            //$("#txtSubTotal").val(SubTotal);

            // 21-Sep-22  Vimal -> As per discuss with jigneshbhai Sub Total Calculation wrong so changed
            //SubTotal = parseFloat(SubTotal) - parseFloat($('.txtTotalDiscoun').val());
            //$("#txtSubTotal").val(SubTotal);

            SubTotal = parseFloat(SubTotal) + parseFloat(Tax);

            MainTotal = parseFloat(SubTotal);

            $('#txtRounding').val(Number(Math.round(MainTotal) - MainTotal).toFixed(2));

            MainTotal = Number(MainTotal + Number($('#txtRounding').val())).toFixed(2);

            $("#txtTotal").val(parseFloat(MainTotal).toFixed(2));
            $("#txtPending").val(parseFloat(MainTotal).toFixed(2));

            summary();
        }

        function btnSubmit_Click(print) {

            $("#btnSubmit").attr('disabled', 'disabled');
            $("#btnSavePrint").attr('disabled', 'disabled');

            if (CustType == "2" && $('#txtMobile').val().length != 10) {
                ModelMsg("Please enter proper Mobile.", 3);
                $("#btnSubmit").removeAttr('disabled');
                if (CustType == "4" && $('#AutoVehicle').val().trim().indexOf("SELF LIFT") == -1) {
                    $("#btnSavePrint").attr('disabled', 'disabled');
                }
                else {
                    $("#btnSavePrint").removeAttr('disabled');
                }
                return false;
            }

            $.blockUI({
                message: '<img src="../Images/loadingbd.gif" />',
                css: {
                    padding: 0,
                    margin: 0,
                    width: '15%',
                    top: '36%',
                    left: '40%',
                    textAlign: 'center',
                    cursor: 'wait'
                }
            });

            var TableData_Material = [];
            //var rowCnt_Material = 1;
            var totalItemcnt = 0;
            var cnt = 0;
            //$('#tblMaterialDetail  > tbody > tr').each(function (row, tr) {
            //    var MainID = $("input[name='hdnMainID']", this).val();
            //    if (MainID == "1") {
            //        $(this).remove();
            //    }
            //    rowCnt_Material++;
            //});

            rowCnt_Material = 0;

            $('#tblMaterialDetail  > tbody > tr').each(function (row, tr) {
                var ItemCode = $("input[name='AutoMatCode']", this).val();
                if (ItemCode != "") {
                    totalItemcnt = 1;
                    var Data = $("select[name='ddlUnit']", this).val().split(',');
                    var UOMName = $("select[name='ddlUnit']", this).val();
                    var Price = $("input[name='hdnDiscountPrice']", this).val();
                    var AvlQty = $(".tdAvailable", this).text();
                    var SubTotal = $("input[name='hdnDiscountSubTotal']", this).val();
                    var RequestQty = $("input[name='txtReqQty']", this).val();
                    var TotalQty = $(".tdTotalQty", this).text();
                    var Tax = $("input[name='hdnDiscountTax']", this).val();
                    var Total = $("input[name='hdnDiscountTotal']", this).val();
                    var ItemID = $("input[name='hdnItemID']", this).val();
                    var MainID = $("input[name='hdnMainID']", this).val();
                    var hdnItemScheme = $("input[name='hdnItemScheme']", this).val();
                    var hdnScheme = $("input[name='hdnScheme']", this).val();
                    var SchemeID = $("input[name='hdnSchemeID']", this).val();
                    var PriceTax = $("input[name='hdnMaterialPriceTax']", this).val();
                    var UnitPrice = $("input[name='hdnMaterialUnitPrice']", this).val();
                    var MRP = $("input[name='hdnMRP']", this).val();
                    var NormalPrice = $("input[name='hdnNormalPrice']", this).val();
                    var TaxID = $("input[name='hdnMaterialTaxID']", this).val();
                    var OrderQty = $("input[name='hdnOrderQty']", this).val();
                   
                    if (SchemeID == "" || SchemeID == undefined) {
                        SchemeID = "0";
                    }
                    //if ((UOMName != "" || RequestQty != "") && ItemCode == "") {
                    //    cnt = 1;
                    //    errormsg = 'Please Select Item Code in Row: ' + rowCnt_Material;
                    //    event.preventDefault();
                    //    return false;
                    //}

                    if (ItemCode != "" && RequestQty == "0") {
                        cnt = 1;
                        errormsg = 'Please enter Dispatch Quantity in Row: ' + (parseInt(rowCnt_Material) + 1);
                        event.preventDefault();
                        return false;
                    }

                    var obj = {
                        ItemID: ItemID,
                        ItemCode: ItemCode,
                        Price: Price,
                        AvlQty: AvlQty,
                        OrderQty: OrderQty,
                        RequestQty: RequestQty,
                        TotalQty: TotalQty,
                        SubTotal: SubTotal,
                        Tax: Tax,
                        Total: Total,
                        MainID: MainID,
                        UnitID: Data[0],
                        MapQuantity: Data[3],
                        ItemScheme: hdnItemScheme,
                        Scheme: hdnScheme,
                        SchemeID: SchemeID,
                        PriceTax: PriceTax,
                        UnitPrice: UnitPrice,
                        MRP: MRP,
                        NormalPrice: NormalPrice,
                        TaxID: TaxID
                    };
                    TableData_Material.push(obj);
                }
                rowCnt_Material++;
            });

            if (totalItemcnt == 0) {
                $.unblockUI();
                $("#btnSubmit").removeAttr('disabled');
                if (CustType == "4" && $('#AutoVehicle').val().trim().indexOf("SELF LIFT") == -1) {
                    $("#btnSavePrint").attr('disabled', 'disabled');
                }
                else {
                    $("#btnSavePrint").removeAttr('disabled');
                }
                ModelMsg("Please select atleast one Item", 3);
                event.preventDefault();
                return false;
            }
            if (cnt == 1) {
                $.unblockUI();
                $("#btnSubmit").removeAttr('disabled');
                if (CustType == "4" && $('#AutoVehicle').val().trim().indexOf("SELF LIFT") == -1) {
                    $("#btnSavePrint").attr('disabled', 'disabled');
                }
                else {
                    $("#btnSavePrint").removeAttr('disabled');
                }
                ModelMsg(errormsg, 3);
                event.preventDefault();
                return false;
            }


            $('#hidJsonInputMaterial').val(JSON.stringify(TableData_Material));


            if ($('#hdnSchemeApply').val() == '0') {
                $.unblockUI();
                $("#btnSubmit").removeAttr('disabled');
                if (CustType == "4" && $('#AutoVehicle').val().trim().indexOf("SELF LIFT") == -1) {
                    $("#btnSavePrint").attr('disabled', 'disabled');
                }
                else {
                    $("#btnSavePrint").removeAttr('disabled');
                }
                ModelMsg("Please Confirm and Apply scheme first.", 3);
                event.preventDefault();
                return false;
            }

            var TableData_Scheme = [];
            var rowCnt_Scheme = 0;
            var totalItemcnt = 0;
            cnt = 0;
            $('#tblSchemeDetail tr').each(function (row, tr) {
                if (rowCnt_Scheme != 0) {  // Don't add data for the Header-Row
                    var check = $("input[name='chkCheck']", this).is(":checked");
                    var SchemID = $("input[name='hdnSchemID']", this).val();
                    if (check == true) {

                        totalItemcnt = 1;
                        var SchemeName = $(".tdSchemeName", this).text();
                        var ItemCode = $(".tdItemCode", this).text();
                        var tdSchemeItemName = $(".tdSchemeItemName", this).text();
                        var Unit = $(".tdUnit", this).text();
                        var Stock = $(".tdStock", this).text();
                        var Quantity = $(".tdQuantity", this).text();
                        var Discount = $(".tdDiscount", this).text();
                        var BasedOn = $("input[name='hdnBasedOn']", this).val();
                        var SaleAmount = $("input[name='hdnSaleAmount']", this).val();
                        var SchemeDiscount = $("input[name='hdnSchemeDiscount']", this).val();
                        var NormalPrice = $("input[name='hdnSchemeNormalPrice']", this).val();
                        var Mode = $("input[name='hdnMode']", this).val();
                        var TaxID = $("input[name='hdnTaxID']", this).val();
                        var Tax = $("input[name='hdnTax']", this).val();
                        var Price = $("input[name='hdnPrice']", this).val();
                        var PriceTax = $("input[name='hdnPriceTax']", this).val();
                        var MRP = $("input[name='hdnSchemeMRP']", this).val();
                        var ContraTax = $("input[name='hdnContraTax']", this).val();
                        var Scheme3ID = $("input[name='hdnScheme3ID']", this).val();
                        var SchemeItemID = $("input[name='hdnSchemeItemID']", this).val();
                        var obj = {
                            check: check,
                            SchemeName: SchemeName,
                            ItemCode: ItemCode,
                            ItemName: tdSchemeItemName,
                            Unit: Unit,
                            Quantity: Quantity,
                            Discount: Discount,
                            SchemeID: SchemID,
                            BasedOn: BasedOn,
                            SaleAmount: SaleAmount,
                            Mode: Mode,
                            TaxID: TaxID,
                            Tax: Tax,
                            Price: Price,
                            MRP: MRP,
                            PriceTax: PriceTax,
                            ContraTax: ContraTax,
                            SchemeDiscount: SchemeDiscount,
                            NormalPrice: NormalPrice,
                            Scheme3ID: Scheme3ID,
                            ItemID: SchemeItemID
                        };
                        TableData_Scheme.push(obj);
                    }
                }
                rowCnt_Scheme++;
            });
            if (rowCnt_Scheme > 1) {
                if (totalItemcnt == 0) {
                    $.unblockUI();
                    $("#btnSubmit").removeAttr('disabled');
                    if (CustType == "4" && $('#AutoVehicle').val().trim().indexOf("SELF LIFT") == -1) {
                        $("#btnSavePrint").attr('disabled', 'disabled');
                    }
                    else {
                        $("#btnSavePrint").removeAttr('disabled');
                    }
                    ModelMsg("Please select at least one Scheme", 3);
                    event.preventDefault();
                    return false;
                }
            }
            $('#hidJsonInputScheme').val(JSON.stringify(TableData_Scheme));

            var OrderID = $("#hdnOrderID").val();
            var OrderType = $("#hdnOrderType").val();
            var OrderCustID = $("#hdnOrderCustID").val();
            var BillToCustomerID = $("#hdnBillToCustID").val();

            var AutoCustomer = $('#AutoCustomer').val().split(" - ")[0].trim();
            var AutoTemplate = $('#AutoTemplate').val();
            var AutoVehicle = $('#AutoVehicle').val().split("-")[0].trim();
            var AutoOrderForm = $('#AutoOrderForm').val().split("-")[0].trim();
            var ChkTemp = $('#chkTemp').is(':checked');
            var chkExisting = $('#chkExisting').is(':checked');

            var ddlWhs = $("select[name='ddlWhs']").val();
            var GSTIN = $("#txtGSTIN").val();
            var SubTotal = $("#txtSubTotal").val();
            var TotalPrice = $("#txtTotal").val();

            var txtPaid = $('#txtPaid').val();
            var txtMScheme = $('#txtMScheme').val();
            var txtDScheme = $('#txtDScheme').val();
            var txtQScheme = $('#txtQScheme').val();
            var txtRounding = $('#txtRounding').val();
            var txtTax = $('#txtTax').val();
            var txtNotes = $('#body_txtNotes').val().replace(":", "#");
            var txtMobile = $('#txtMobile').val();
            var txtDate = $('#txtDate').val();
            var txtPending = $('#txtPending').val();

            var postData = {
                OrderID: OrderID,
                OrderType: OrderType,
                OrderCustID: OrderCustID,
                BillToCustomerID: BillToCustomerID,
                AutoCustomer: AutoCustomer,
                AutoTemplate: AutoTemplate,
                AutoVehicle: AutoVehicle,
                AutoOrderForm: AutoOrderForm,
                ChkTemp: ChkTemp,
                chkExisting: chkExisting,
                ddlWhs: ddlWhs,
                SubTotal: SubTotal,
                Total: TotalPrice,
                Tax: txtTax,
                Paid: txtPaid,
                GSTIN: GSTIN,
                MScheme: txtMScheme,
                DScheme: txtDScheme,
                QScheme: txtQScheme,
                Rounding: txtRounding,
                Notes: txtNotes,
                Mobile: txtMobile,
                Date: txtDate,
                Pending: txtPending
            }
            $('#hidJsonOrderDetail').val(JSON.stringify(postData));

            var successMSG = false;
            var MaterialData = $('#hidJsonInputMaterial').val();
            var SchemeData = $('#hidJsonInputScheme').val();
            var HeaderData = $('#hidJsonOrderDetail').val();
            var successMSG = true;

            if (txtNotes.length > 50) {
                ModelMsg("Please Enter only 50 character in Notes.", 3);
                successMSG = false;
            }

            if (successMSG == false) {
                $.unblockUI();
                $("#btnSubmit").removeAttr('disabled');
                if (CustType == "4" && $('#AutoVehicle').val().trim().indexOf("SELF LIFT") == -1) {
                    $("#btnSavePrint").attr('disabled', 'disabled');
                }
                else {
                    $("#btnSavePrint").removeAttr('disabled');
                }
                event.preventDefault();
                return false;
            }
            else {
                var successMSG = true;
                var SchemeAmount = 0; //$('#SCHEMEAMOUNT').val();
                var sv = $.ajax({
                    url: 'SaleDirect.aspx/SaveData',
                    type: 'POST',
                    //async: false,
                    dataType: 'json',
                    // traditional: true,
                    data: JSON.stringify({ hidJsonInputMaterial: MaterialData, hidJsonInputHeader: HeaderData, hidJsonInputScheme: SchemeData, hdnSchemeIDs: $('#hdnSchemeIDs').val() }),
                    contentType: 'application/json; charset=utf-8'
                });

                var sendcall = 0;
                sv.success(function (result) {
                    if (result.d == "") {
                        $.unblockUI();
                        $("#btnSubmit").removeAttr('disabled');
                        if (CustType == "4" && $('#AutoVehicle').val().trim().indexOf("SELF LIFT") == -1) {
                            $("#btnSavePrint").attr('disabled', 'disabled');
                        }
                        else {
                            $("#btnSavePrint").removeAttr('disabled');
                        }
                        event.preventDefault();
                        return false;
                    }
                    else if (result.d.indexOf("ERROR=") >= 0) {
                        $.unblockUI();
                        $("#btnSubmit").removeAttr('disabled');
                        if (CustType == "4" && $('#AutoVehicle').val().trim().indexOf("SELF LIFT") == -1) {
                            $("#btnSavePrint").attr('disabled', 'disabled');
                        }
                        else {
                            $("#btnSavePrint").removeAttr('disabled');
                        }
                        var ErrorMsg = result.d.split('=')[1].trim();
                        ModelMsg(ErrorMsg, 2);
                        event.preventDefault();
                        return false;
                    }
                    if (result.d.indexOf("SUCCESS=") >= 0) {
                        var SuccessMsg = result.d.split('=')[1].trim();
                        var MsgForFSSI = result.d.split('=')[2].trim();

                        var OrderNo = result.d.split('#')[1].trim();


                        if (print == "1") {
                            if (MsgForFSSI != "")
                                alert(MsgForFSSI);
                            alert(SuccessMsg);
                            $.colorbox({
                                width: '80%',
                                height: '80%',
                                iframe: true,
                                overlayClose: false,
                                escKey: false,
                                href: '../Reports/ViewReport.aspx?SalesOrderNo=' + OrderNo + '&SalesOrderPageSize=' + "A4" + '&CompCust=0&SalesOrderIsOld=2',
                                onClosed: function () {
                                    if (OrderID != 0) {
                                        window.location.replace("../Sales/SalesOrderData.aspx");
                                    }
                                    else {
                                        location.reload(true);
                                    }

                                    event.preventDefault();
                                    return false;
                                }
                            });
                        }
                        else {
                            if (sendcall == 1) {
                                if (MsgForFSSI != "")
                                    alert(MsgForFSSI);
                                alert(SuccessMsg);
                                if (OrderID != 0) {
                                    window.location.replace("../Sales/SalesOrderData.aspx");
                                }
                                else {
                                    location.reload(true);
                                }
                                event.preventDefault();
                                return false;
                            }
                        }
                    }
                });

                sv.error(function (XMLHttpRequest, textStatus, errorThrown) {
                    alert('Something is wrong...' + XMLHttpRequest.responseText);
                    event.preventDefault();
                    return false;
                });
            }

            if (sendcall == 0) {
                event.preventDefault();
                sendcall = 1;
                return false;
            }
        }

    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <input type="hidden" id="hdnSchemeApply" value="0" class="hdnSchemeApply" />
    <input type="hidden" id="hdnOrderID" value="0" class="hdnOrderID" />
    <input type="hidden" id="hdnOrderType" value="0" class="hdnOrderType" />
    <input type="hidden" id="hdnOrderCustID" value="0" class="hdnOrderCustID" />
    <input type="hidden" id="hdnBillToCustID" value="0" class="hdnBillToCustID" />
    <div class="panel panel-default" style="margin-top: 35px; margin-left: 18px;">
        <div class="panel-body">
            <div class="row">
                <div class="col-lg-12">
                    <div class="col-lg-4">
                        <div class="input-group form-group">
                            <label class="input-group-addon">Invoice Date</label>
                            <input type="text" id="txtDate" name="txtDate" disabled="disabled" class="datepick form-control" onkeyup="return ValidateDate(this);" tabindex="1" />
                            <input type="hidden" id="hidJsonInputMaterial" name="hidJsonInputMaterial" value="" />
                            <input type="hidden" id="hidJsonOrderDetail" name="hidJsonOrderDetail" value="" />
                            <input type="hidden" id="hidJsonInputScheme" name="hidJsonInputScheme" value="" />
                            <input type="hidden" id="hdnSchemeIDs" name="hdnSchemeIDs" value="" />
                        </div>
                    </div>
                    <div class="col-lg-4">
                        <div class="input-group form-group">
                            <label class="input-group-addon">Shipped To Party</label>
                            <input type="text" id="AutoCustomer" name="AutoCustomer" class="form-control search" value="" tabindex="2" />
                        </div>

                    </div>
                    <div class="col-lg-4">
                        <div class="input-group form-group">
                            <label class="input-group-addon">Vehicle No.</label>
                            <input type="text" id="AutoVehicle" name="AutoVehicle" class="form-control search" value="" tabindex="5" />
                        </div>
                        <div class="input-group form-group" style="display: none;">
                            <label class="input-group-addon">Warehouse</label>
                            <select id="ddlWhs" name="ddlWhs" class="form-control" tabindex="3"></select>
                        </div>
                    </div>
                </div>
                <div class="col-lg-12">
                    <div class="col-lg-4">
                        <div class="input-group form-group">
                            <label class="input-group-addon">Order From</label>
                            <input type="text" id="AutoOrderForm" name="AutoOrderForm" class="form-control search" value="" maxlength="250" tabindex="8" />
                        </div>
                        <div class="input-group form-group" style="display: none;">
                            <label class="input-group-addon">Existing Customer</label>
                            <span class="form-control chkExist">
                                <input type="checkbox" id="chkExisting" name="chkExisting" class="chkbox" onchange="SetExistingCheckboxValue(this);" disabled="disabled" checked="checked" tabindex="4" />
                            </span>

                        </div>
                    </div>
                    <div class="col-lg-4">
                        <div class="input-group form-group" style="display: none;">
                            <label class="input-group-addon">Template</label>
                            <input type="text" id="AutoTemplate" name="AutoTemplate" class="form-control search" value="" />
                        </div>
                        <div class="input-group form-group">
                            <label class="input-group-addon">Billed To Party</label>
                            <input type="text" id="lblBillToPartyCode" disabled="disabled" class="lblBillToPartyCode form-control" />
                        </div>
                    </div>
                    <div class="col-lg-4">
                        <div class="input-group form-group">
                            <label class="input-group-addon">Mobile No</label>
                            <input type="text" class="form-control txtMobileNo" id="txtMobile" tabindex="6" onkeypress="return isNumberKey(event);" onpaste="return false;" name="txtMobile" maxlength="10" />
                        </div>
                    </div>
                </div>
                <div class="col-lg-12">
                    <div class="col-lg-4">
                        <div class="input-group form-group">
                            <span class="input-group-addon">GST IN</span>
                            <input type="text" class="form-control txtGSTIN" maxlength="20" id="txtGSTIN" name="txtGSTIN" tabindex="9" <%= (CustType == 2) ? "" : "disabled" %> onblur="fnValidateGSTIN(this);" />
                        </div>
                        <div class="input-group form-group" style="display: none;">
                            <label class="input-group-addon">Temp</label>
                            <span class="form-control chkTmp">
                                <input type="checkbox" id="chkTemp" class="chkbox" name="chkTemp" onchange="SetExistingCheckboxValue(this);" disabled="disabled" tabindex="7" />
                            </span>
                        </div>
                    </div>
                    <div class="col-lg-8" id="divdata" runat="server">
                        <div class="input-group form-group">
                            <span class="input-group-addon">Notes</span>
                            <asp:TextBox runat="server" ID="txtNotes" TabIndex="25" Rows="2" MaxLength="50" CssClass="form-control txtNotes" Style="resize: none;" />
                        </div>
                    </div>
                </div>
            </div>
            <div class="row" style="margin-bottom: -1px !important;">
                <div class="col-lg-9">
                    <ul id="tabs" class="nav nav-tabs" role="tablist">
                        <li class="active"><a href="#tabs-1" tabindex="10" role="tab" data-toggle="tab">Item</a></li>
                        <li><a href="#tabs-2" role="tab" tabindex="11" data-toggle="tab">Scheme</a></li>
                        <li style="margin-left: 213px !important;">
                            <input type="button" id="btnConfirm" name="btnConfirm" value="Confirm" onclick="Confirm();" class="btn btn-default" tabindex="13" />
                            &nbsp;&nbsp;&nbsp;&nbsp;

                        </li>
                        <li>
                            <input type="button" id="btnEdit" name="btnEdit" style="display: none" value="Edit" onclick="Edit();" class="btn btn-default" tabindex="14" />
                            &nbsp;&nbsp;&nbsp;&nbsp;
                        </li>
                        <li>
                            <input type="button" id="btnApplyScheme" style="display: none" name="btnApplyScheme" value="Apply Scheme" onclick="ApplyScheme('');" class="btn btn-default" tabindex="15" />
                            &nbsp;&nbsp;&nbsp;&nbsp;
                        </li>
                        <li>
                            <input type="submit" value="Save" class="btn btn-default" tabindex="26" id="btnSubmit" onclick="return btnSubmit_Click('0');" />
                            &nbsp;&nbsp;&nbsp;&nbsp;
                        </li>
                        <li>
                            <input type="submit" value="Save & Print" class="btn btn-default" tabindex="27" id="btnSavePrint" runat="server" onclick="return btnSubmit_Click('1');" /></li>
                        <li>
                            <input type="submit" value="Cancel" style="display: none;" id="btnCancel" class="btn btn-default" tabindex="28" onclick="btnCancel_Click();" /></li>
                        <label id="lblgrowth" class="lblgrowth" style="margin-left: 65px; color: blue;"></label>

                        <label id="lblQPSSchemeMessage" class="lblQPSSchemeMessage" style="display: none;"></label>
                        <label id="lblSchemeAmount" class="lblSchemeAmount" style="display: none;"></label>
                        <label id="lblQtyPrint" class="lblQtyPrint" style="display: none;"></label>

                    </ul>
                    <div id="myTabContent" class="tab-content">
                        <div id="tabs-1" class="tab-pane active" tabindex="9" style="height: 355px;">
                            <br />
                            <div id="Material" class="tab-pane" style="width: 1047px;">
                                <div class="row" style="display: none">
                                    <div class="col-lg-1">
                                        <div class="input-group form-group">
                                            <input type="hidden" id="CountRowMaterial" />
                                            <input type="button" id="btnAddMoreMaterial" name="btnAddMoreMaterial" value="Add Row" onclick="AddMoreRowMaterial();" class="btn btn-default" />
                                        </div>
                                    </div>
                                    <div class="col-lg-11">
                                        <div class="input-group form-group" style="width: 100%">
                                            <input type="text" id="txtSearchMaterial" class="form-control" placeholder="Type to Search" style="background-image: url('../Images/Search.png'); background-position: right; background-repeat: no-repeat; width: 100%" />
                                        </div>
                                    </div>
                                </div>
                                <div class="border-la">&nbsp;</div>
                                <table id="tblMaterialDetail" class="table" border="1" tabindex="10">
                                    <thead>
                                        <tr class="table-header-gradient">
                                            <th style="width: 3%; text-align: center;">Sr.</th>
                                            <th style="width: 17%;">Item Code - Name</th>
                                            <th style="width: 5%">Unit</th>
                                            <th style="width: 4%; text-align: right;">Rate</th>
                                            <th style="width: 4%; text-align: right;">Stock</th>
                                            <th style="width: 4%; text-align: right;">Order</th>
                                            <th style="width: 4%; text-align: right;">Dispatch</th>
                                            <%--<th style="width: 8%;">Total Qty</th>--%>
                                            <th style="width: 6%; text-align: right;">Gross Amt</th>
                                            <th style="width: 6%; text-align: right;">GST Amt</th>
                                            <th style="width: 6%; text-align: right;">Net Amt</th>
                                            <th style="display: none">ID</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                    </tbody>
                                    <tfoot>
                                        <tr class="table-header-gradient">
                                            <th></th>
                                            <th></th>
                                            <th></th>
                                            <th></th>
                                            <th style="text-align: right !important;">
                                                <label id="lblFootAvailable" style="display: none;"></label>
                                            </th>
                                            <th style="text-align: right !important;">
                                                <label id="lblFootOrder"></label>
                                            </th>
                                            <th style="text-align: right !important;">
                                                <label id="lblFootDispatch"></label>
                                            </th>

                                            <th style="text-align: right !important;">
                                                <label id="lblFootTotalQty" style="display: none;"></label>
                                                <label id="lblFootSubTotal" class="lblFootSubTotal"></label>
                                            </th>
                                            <th style="text-align: right !important;">
                                                <label id="lblFootTax"></label>
                                            </th>
                                            <th style="text-align: right !important;">
                                                <label id="lblFootTotalPrice" class="lblFootTotalPrice"></label>
                                            </th>
                                            <th style="display: none">ID</th>
                                        </tr>
                                    </tfoot>
                                </table>
                            </div>
                        </div>
                        <div id="tabs-2" class="tab-pane" tabindex="11" style="height: 400px; width: 100% !important; margin-top: 22px !important;">
                            <input type="hidden" id="CountRowScheme" value="0" />
                            <div class="row" style="display: none">
                            </div>

                            <table id="tblSchemeDetail" class="table" border="1" tabindex="12">
                                <thead>
                                    <tr class="table-header-gradient">
                                        <th style="width: 2%;"></th>
                                        <th style="width: 3%; text-align: center;">Sr.</th>
                                        <th style="width: 30%;">Scheme Code & Name</th>
                                        <th style="width: 26%">Item Code & Name</th>
                                        <th style="width: 3%">Unit</th>
                                        <th style="width: 3%">Stock</th>
                                        <th style="width: 3%">Qty</th>
                                        <th style="width: 6%; text-align: right;">Disc.</th>
                                        <th style="width: 6%; text-align: right;">Low.Limit</th>
                                        <th style="width: 6%; text-align: right;">Hig.Limit</th>
                                        <th style="width: 6%; text-align: right;">Occurance</th>
                                        <th style="width: 25%">Base On</th>
                                        <th style="width: 8%">Pair</th>
                                        <th style="display: none">ID</th>
                                    </tr>
                                </thead>
                            </table>

                        </div>



                    </div>
                </div>
                <div class="col-lg-3 side-bar-amount" style="margin-top: 30px; padding-left: 0px;">
                    <div class="input-group form-group">
                        <label id="lblLy" class="lblLy" style="margin-top: -26px; color: blue;"></label>
                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        <label id="lblCy" class="lblCy" style="margin-top: -26px; color: blue;"></label>
                        &nbsp;&nbsp;&nbsp;
                           <img src="../Images/up.png" alt="" class="grthUp" style="margin-top: -26px; height: 20px; display: none;" />
                        <img src="../Images/down.png" alt="" class="grthdown" style="margin-top: -26px; height: 20px; display: none;" />
                    </div>
                    <div class="input-group form-group">
                        <span class="input-group-addon">Qty</span>
                        <input type="text" id="txtTotalQty" tabindex="18" style="width: 100%" maxlength="12" class="txtTotalQty form-control" disabled="disabled" />
                    </div>

                    <div class="input-group form-group">
                        <span class="input-group-addon">Gross Amount</span>
                        <input type="text" id="txtGrossAmount" tabindex="20" style="width: 100%" maxlength="12" value="0.00" class="txtGrossAmount form-control" disabled="disabled" />
                    </div>

                    <div class="input-group form-group">
                        <span class="input-group-addon">Machine / Parlour Scheme  </span>
                        <input type="text" id="txtMachineScheme" tabindex="16" style="width: 100%" maxlength="12" value="0.00" class="txtMachineScheme form-control" disabled="disabled" />
                    </div>

                    <div class="input-group form-group">
                        <span class="input-group-addon">Master Scheme</span>
                        <input type="text" id="txtMScheme" tabindex="17" style="width: 100%" maxlength="12" value="0.00" class="txtMScheme form-control" disabled="disabled" />
                    </div>

                    <div class="input-group form-group" style="display: none;">
                        <span class="input-group-addon">QPS Scheme</span>
                        <input type="text" id="txtQScheme" tabindex="18" style="width: 100%" maxlength="12" value="0.00" class="txtQScheme form-control" disabled="disabled" />
                    </div>

                    <div class="input-group form-group">
                        <span class="input-group-addon">STOD Discount</span>
                        <input type="text" id="txtDScheme" tabindex="17" style="width: 100%" maxlength="12" value="0.00" class="txtDScheme form-control" disabled="disabled" />
                    </div>

                    <div class="input-group form-group">
                        <span class="input-group-addon">VRS Discount</span>
                        <input type="text" id="txtVRSDiscount" tabindex="18" style="width: 100%" maxlength="12" value="0.00" class="txtVRSDiscount form-control" disabled="disabled" />
                    </div>

                    <div class="input-group form-group">
                        <span class="input-group-addon">Total Discount</span>
                        <input type="text" id="txtTotalDiscoun" tabindex="18" style="width: 100%" maxlength="12" value="0.00" class="txtTotalDiscoun form-control" disabled="disabled" />
                    </div>

                    <div class="input-group form-group">
                        <span class="input-group-addon">Sub Total</span>
                        <input type="text" id="txtSubTotal" tabindex="20" style="width: 100%" maxlength="12" class="txtSubTotal form-control" disabled="disabled" />
                    </div>

                    <div class="input-group form-group">
                        <span class="input-group-addon">GST Amount</span>
                        <input type="text" id="txtTax" tabindex="21" style="width: 100%" maxlength="12" class="txtTax form-control" disabled="disabled" />
                    </div>

                    <div class="input-group form-group">
                        <span class="input-group-addon">Rounding</span>
                        <input type="text" id="txtRounding" tabindex="19" style="width: 100%" maxlength="12" class="txtRounding form-control" disabled="disabled" />
                    </div>

                    <div class="input-group form-group">
                        <span class="input-group-addon">Net Amount</span>
                        <input type="text" id="txtTotal" tabindex="22" style="width: 100%" maxlength="12" class="txtTotal form-control" disabled="disabled" />
                    </div>

                    <div class="input-group form-group">
                        <span class="input-group-addon">Paid Amount</span>
                        <input type="text" id="txtPaid" tabindex="23" style="width: 100%" maxlength="12" class="txtPaid form-control" onkeypress="return isNumberKeyForAmount(event);" onpaste="return false;" />
                    </div>

                    <div class="input-group form-group">
                        <span class="input-group-addon">Pending Amount</span>
                        <input type="text" id="txtPending" tabindex="24" style="width: 100%" maxlength="12" class="txtPending form-control" disabled="disabled" />
                    </div>
                </div>
            </div>
        </div>
    </div>

</asp:Content>

