<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="InventoryReturn.aspx.cs" Inherits="Inventory_InventoryReturn" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <link href="../Scripts/colorbox/colorbox.css" rel="stylesheet" />
    <script type="text/javascript" src="../Scripts/colorbox/jquery.colorbox-min.js"></script>
    <script type="text/javascript" src="../Scripts/fixHeaderFooter.js"></script>

    <style>
        .req:after {
            content: "*";
            color: red;
        }

        .search {
            background-color: lightyellow;
        }

        .table#tblItem {
            width: 100%;
            margin-top: 0px !important;
            margin-bottom: 0px !important;
            position: relative;
        }

        table#tblItem tbody {
            width: 100%;
        }

        table#tblItem thead tr {
            position: relative;
        }

        table#tblItem tfoot tr {
            position: relative;
        }


        .border-la {
            float: left;
            width: 100%;
            height: 1px;
            padding-right: 10px;
            background: #000;
        }

        .panel-body {
            padding: 7px;
        }

        #tbl {
            margin-top: 10px;
        }

        .FontSize {
            font-size: 11px;
        }

        .form-control {
            height: 29px;
        }
    </style>

    <script type="text/javascript">

        $(document).ready(function () {
            $("#tblItem").tableHeadFixer('60vh');
        });

    </script>

    <script type="text/javascript">

        var availableTemplate = [];
        var availableVehicle = [];
        var availableOrderForm = [];
        var availableItems = [];
        var availableCustomer = [];
        var gridItems = [];
        var Units = [];

        $(document).ready(function () {
            $('#CountRowMaterial').val(0);

            $("#txtDiscount").on('blur', function (event) {
                CalculateDiscount();

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
            });


            $('#txtSearch').on('keyup', function () {
                var word = this.value;
                $('#tblItem > tbody tr').each(function () {

                    var itmdata = $("input[name='AutoMatCodes']", this).val();
                    if (($(this).find("td").text().toUpperCase().indexOf(word.toUpperCase()) >= 0) || (itmdata.toUpperCase().indexOf(word.toUpperCase()) >= 0))
                        $(this).show();
                    else
                        $(this).hide();
                });
            });

            var today = '<%=DateTime.Now.ToShortDateString()%>';
            console.log(today);
            $('#txtDate').val(today);

            AddMoreRow();
            DisableControls();
            GetItems();
        });

        function FillData() {

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

            var IsValid = true;

            var Dist = 0;
            if ($(".txtCustCode").val() != undefined && $(".txtCustCode").val().length > 0) {
                Dist = $(".txtCustCode").val().split('-')[2].trim();
            }
            $.ajax({
                url: 'InventoryReturn.aspx/LoadData',
                type: 'POST',
                dataType: 'json',
                data: JSON.stringify({ Date: $('#txtDate').val(), CustID: Dist }),
                contentType: 'application/json; charset=utf-8',
                success: function (result) {
                    $.unblockUI();

                    if (result.d == "") {
                        ClearAll();
                        $.unblockUI();
                        event.preventDefault();
                        return false;
                    }
                    else if (result.d[0].indexOf("ERROR#") >= 0) {
                        $.unblockUI();
                        var ErrorMsg = result.d[0].split('#')[1].trim();
                        ModelMsg(ErrorMsg, 3);

                        event.preventDefault();

                        var today = '<%=DateTime.Now.ToShortDateString()%>';

                        $('#txtDate').val(today);
                        return false;
                    }
                    else {
                        var items = result.d[0];
                        if (items.length > 0) {
                            $('#tblItem  > tbody > tr').each(function (row1, tr) {
                                // post table's data to Submit form using Json Format
                                $(this).remove();
                            });
                            var row = 1;
                            $('#CountRowMaterial').val(0);
                            $("#txtBillAmount").val('');
                            $("#txtRounding").val('');
                            $("#txtTotal").val('');
                            $("#txtNotes").val('');
                            $("#txtOINVRID").val('');
                            $("#lblFootReceipt").text('');
                            $("#lblFootTotalPrice").text('');
                            for (var i = 0; i < items.length; i++) {
                                AddMoreRow();
                                row = $('#CountRowMaterial').val();
                                $('#tdDate' + row).text(items[i].Date);
                                $('#hdnCustID' + row).val(items[i].CustomerID);
                                $('#AutoCustCode' + row).val(items[i].CustomerCode);
                                $('#tdCustomerName' + row).text(items[i].CustomerName);
                                $('#AutoMatCodes' + row).val(items[i].ItemCode);
                                $('#tdItemName' + row).text(items[i].ItemName);
                                $('#hdnItemID' + row).val(items[i].ItemID);
                                if (Dist > 0)
                                    GetItemDetailsByCode(items[i].ItemCode, row);
                                $("#ddlUnit" + row).find("option:contains(" + items[i].UnitName + ")").attr("selected", "selected");
                                //$('#ddlUnit' + row + ' option[text=' + items[i].UnitName + ']').attr("selected", "selected");
                                $('#txtReciept' + row).val(items[i].Quantity);
                                CalculateSum(row);
                                $('#hdnMainID' + row).val(items[i].OINVRID);
                                $('#hdnINVRid' + row).val(items[i].INVR1ID);
                            }
                            var header = result.d[1];
                            $("#txtBillAmount").val(header.Subtotal);
                            $("#txtRounding").val(header.Rounding);
                            $("#txtTotal").val(parseFloat(header.Total).toFixed(2));
                            $("#txtNotes").val(header.Notes);
                            $("#txtOINVRID").val(header.OINVRID);
                        }
                    }
                    AddMoreRow();
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    $.unblockUI();
                    alert('Something is wrong...' + XMLHttpRequest.responseText);
                    event.preventDefault();
                    return false;
                }
            });
    }


    function AddMoreRow() {

        $('table#tblItem tr#NoROW').remove();  // Remove NO ROW

        /// Add Dynamic Row to the existing Table
        var ind = $('#CountRowMaterial').val();
        ind = parseInt(ind) + 1;
        $('#CountRowMaterial').val(ind);

        var str = "";
        str = "<tr id='trItem" + ind + "'>"
            + "<td id='tdSrNo" + ind + "' class='tdSrNo'>" + ind + "</td>"
            + "<td id='tdDate" + ind + "' class='tdDate'>" + $('#txtDate').val() + "</td>"
            + "<td><input type='text' id='AutoCustCode" + ind + "' name='AutoCustCode' class='AutoCustCode form-control search FontSize' /></td>"
            + "<td id='tdCustomerName" + ind + "' class='tdCustomerName'></td>"
            + "<td><input type='text' id='AutoMatCodes" + ind + "' name='AutoMatCodes' class='AutoMatCodes form-control search FontSize' /></td>"
            + "<td id='tdItemName" + ind + "' class='tdItemName'></td>"
            + "<td style='display: none;'><select id='ddlUnit" + ind + "' name='ddlUnit' class='form-control' onkeyup='enter(this);' /></td>"
            + "<td id='tdMapQty" + ind + "' class='tdMapQty' style='align:right;text-align:right'></td>"
            + "<td id='tdBoxesRate" + ind + "' class='tdBoxesRate' style='text-align:right'></td>"
            + "<td id='tdPrice" + ind + "' class='tdPrice' style='text-align:right'></td>"
            + "<td><input type='text' id='txtReciept" + ind + "' style='text-align:right' name='txtReciept' maxlength='10' value='0' class='form-control allownumericwithdecimal FontSize' onfocus='SetQtyDataFocus(this);' onblur='SetQtyDataBlur(this);' /></td>"
            + "<td id='tdTotalPrice" + ind + "' class='tdTotalPrice' style='text-align:right'></td>"
            + "<td style='display:none'><input type='hidden' id='hdnItemID" + ind + "' name='hdnItemID'/>"
            + "<input type='hidden' id='hdnMainID" + ind + "' name='hdnMainID' value='0' />"
            + "<input type='hidden' id='hdnLineNum" + ind + "' name='hdnLineNum' value='" + ind + "' />"
            + "<input type='hidden' id='hdnINVRid" + ind + "' name='hdnINVRid' value='0' />"
            + "<input type='hidden' id='hdnCustID" + ind + "' name='hdnCustID' value='" + ind + "' /></td></tr>"

        $('#tblItem > tbody').append(str);


        $('#ddlUnit' + ind).on('change', function () {
            SetUnitPrice(ind);
        });

        $("#AutoCustCode" + ind).autocomplete({
            source: availableCustomer,
            minLength: 0,
            scroll: true
        });

        $('#AutoCustCode' + ind).on('autocompleteselect', function (e, ui) {
            $('#AutoCustCode' + ind).val(ui.item.value);
            $('#tdCustomerName' + ind).text('');
            $('#tdCustomerName' + ind).text(($('#AutoCustCode' + ind).val().split('#')[1]));
            $('#hdnCustID' + ind).val($('#AutoCustCode' + ind).val().split('#')[2].trim());
            ClearMaterialRow(ind);
        });


        $('#AutoCustCode' + ind).on('change keyup', function () {
            if ($('#AutoCustCode' + ind).val() == "") {
                $('#tdCustomerName' + ind).text('');
                ClearMaterialRow(ind);
            }
        });

        $("#AutoMatCodes" + ind).autocomplete({
            source: availableItems,
            minLength: 0,
            scroll: true
        });


        $('#AutoMatCodes' + ind).on('autocompleteselect', function (e, ui) {
            $('#AutoMatCodes' + ind).val(ui.item.value);
            GetItemDetailsByCode(ui.item.value, ind);
        });

        $('#AutoMatCodes' + ind).on('change keyup', function () {
            if ($('#AutoMatCodes' + ind).val() == "") {
                $('#tdItemName' + ind).text('');
                ClearMaterialRow(ind);
            }
        });

        $('#AutoMatCodes' + ind).bind("autocompleteselect", function (event, ui) {
            // Remove the element and overwrite the availableItems var
            //availableItems.splice(availableItems.indexOf(ui.item.value), 1);
            // Re-assign the source
            $(this).autocomplete("option", "source", availableItems);
        });

        $('#AutoMatCodes' + ind).on('blur', function (e, ui) {
            ClearMaterialRow(ind);
            if ($('#AutoMatCodes' + ind).val().trim() != "") {
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
                CheckDuplicateItem($('#AutoMatCodes' + ind).val().split("-")[0].trim(), $('#AutoCustCode' + ind).val().split("#")[0].trim(), ind);
            }
        });

        $("#txtReciept" + ind).on('change keyup paste', function (event) {
            CalculateSum(ind);
            DisableControls();
        });
        $(function () {
            $("#txtReciept" + ind).keydown(function (event) {


                if (event.shiftKey == true) {
                    event.preventDefault();
                }

                if ((event.keyCode >= 48 && event.keyCode <= 57) || (event.keyCode >= 96 && event.keyCode <= 105) || event.keyCode == 8 || event.keyCode == 9 || event.keyCode == 37 || event.keyCode == 39 || event.keyCode == 46 || event.keyCode == 190) {

                } else {
                    event.preventDefault();
                }

                if ($(this).val().indexOf('.') !== -1 && event.keyCode == 190)
                    event.preventDefault();

            });
        });
    }

    function DisableControls() {
        $("#txtBillAmount").prop("disabled", true);
        $("#txtTax").prop("disabled", true);
        $("#txtRounding").prop("disabled", true);
        $("#txtTotal").prop("disabled", true);

    }

    function CalculateDiscount() {
        var DiscValue = $("#txtDiscount").val();
        if (DiscValue != "") {
            var TotalWithDisc = 0;
            var gtotal = $("#txtTotal").val();

            if (gtotal != "") {
                TotalWithDisc = (Number(gtotal) - parseFloat(DiscValue)).toFixed(0);
                $("#txtTotal").val(TotalWithDisc);

            }
            else {
                return false;
            }
        }
        else {
            return false;
        }

    }

    function SetUnitPrice(row) {
        CalculateSum(row);
    }

    function Cancel() {
        window.location = "../Inventory/Inventory.aspx";
    }

    function GetItems() {

        var Dist = 0;
        if (($(".txtCustCode").val() != undefined) && $(".txtCustCode").val().length > 0) {
            Dist = $(".txtCustCode").val().split('-')[2].trim();
            FillData();
        }

        $.ajax({
            url: 'InventoryReturn.aspx/GetItems',
            type: 'POST',
            dataType: 'json',
            data: JSON.stringify({ DistCode: Dist }),
            contentType: 'application/json; charset=utf-8',
            success: function (result) {
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
                    var ind = $('#CountRowMaterial').val();
                    availableItems = result.d[0];
                    $('#AutoMatCodes' + ind).autocomplete({
                        source: availableItems,
                        minLength: 0,
                        scroll: true
                    });
                    availableCustomer = result.d[1];
                    $('#AutoCustCode' + ind).autocomplete({
                        source: availableCustomer,
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

    function GetItemDetailsByCode(itemCode, row) {
        var allUnits = [];
        var itemtext = itemCode;
        var Item = itemCode.split("-")[0].trim();

        //var ddlWhs = $("select[name='ddlWhs']").val().trim();
        var rowCnt_Material = 1;
        var cnt = 0;
        var errRow = 0;

        $('#tblItem  > tbody > tr').each(function (row1, tr) {
            // post table's data to Submit form using Json Format
            var itemCode = $("input[name='AutoMatCodes']", this).val();
            var LineNum = $("input[name='hdnLineNum']", this).val();
            if (itemCode != "") {
                if (parseInt(row) != parseInt(LineNum)) {
                    if (Item == itemCode) {
                        cnt = 1;
                        errRow = row;
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
            var DistriID = $(".txtCustCode").val().split('-')[2].trim()
            var CustID = $('#AutoCustCode' + row).val().split('#').pop().trim();
            CustID = DistriID + "#" + CustID;

            $.ajax({
                url: 'InventoryReturn.aspx/GetItemDetails',
                type: 'POST',
                dataType: 'json',
                async: false,
                contentType: 'application/json; charset=utf-8',
                data: JSON.stringify({ txt: itemCode, WhsID: 1, CustID: CustID }),

                success: function (result) {
                    if (result == "") {
                        event.preventDefault();
                        return false;
                    }
                    else if (result.d[0].indexOf("ERROR=") >= 0) {
                        var ErrorMsg = result.d[0].split('=')[1].trim();
                        ModelMsg(ErrorMsg, 3);
                        $("input[name='AutoMatCodes']", this).val() == "";
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
                        $('#tdPrice' + row).text(Number(Data[1]).toFixed(2));
                        $('#tdBoxesRate' + row).text(Number(Data[2]).toFixed(2));
                        $('#hdnItemID' + row).val(result.d[1].ItemID);
                        $('#tdItemName' + row).text(result.d[1].ItemName);
                        $('#tdMapQty' + row).text(Number(Data[3]).toFixed(0));
                        $('#txtReciept' + row).focus();
                        $('#txtReciept' + row).select();

                        CalculateSum(row);
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

    function CalculateSum(ind) {
        var rowCnt_Material = 1;
        var MainLineTotal = 0;
        var MainTaxTotal = 0;
        var MainSubTotal = 0;
        var MainDiscountTotal = 0;
        var totQTY = 0;
        var ALLQTY = 0;
        var FootReceipt = 0;
        var FootSubTotal = 0;
        var FootTotalPrice = 0;
        var SrCnt = 1;

        $('#tblItem  > tbody > tr').each(function (row, tr) {

            $('.tdSrNo', this).text(SrCnt++);

            if ($("input[name='AutoMatCodes']", this).val() != "") {
                var Data = new Array();

                if ($("select[name='ddlUnit']", this).val().trim() != null)
                    Data = $("select[name='ddlUnit']", this).val().split(',');

                $(".tdPrice", this).text(Number(Data[1]).toFixed(2));

                var Price = $(".tdPrice", this).text();
                if (Price == "") {
                    Price = 0;
                }

                var EnterQty = $("input[name='txtReciept']", this).val();
                if (EnterQty == "") {
                    EnterQty = 0;
                }


                $(".tdTotalPrice", this).text((Number(Price) * parseFloat(EnterQty)).toFixed(2));
                FootReceipt = parseFloat(parseFloat(FootReceipt) + parseFloat(EnterQty)).toFixed(0);
                FootSubTotal = parseFloat(parseFloat(FootSubTotal) + parseFloat($(".tdTotalPrice", this).text())).toFixed(2);
                FootTotalPrice = parseFloat(parseFloat(FootTotalPrice) + parseFloat($(".tdTotalPrice", this).text())).toFixed(2);
            }
            rowCnt_Material++;
        });

        $("#lblFootReceipt").text(FootReceipt);
        $("#lblFootTotalPrice").text(FootTotalPrice);
        $("#txtBillAmount").val(FootSubTotal);
        $("#txtTotal").val(FootTotalPrice);

        CalculateSum_General();
    }

    function CalculateSum_General() {

        var SubTotal = $("#txtBillAmount").val();
        if (SubTotal == "") {
            SubTotal = 0;
        }
        var Tax = $("#txtTax").val();
        if (Tax == "") {
            Tax = 0;
        }
        SubTotal = parseFloat(SubTotal) + parseFloat(Tax);

        MainTotal = parseFloat(SubTotal);

        $('#txtRounding').val(Number(Math.round(MainTotal) - MainTotal).toFixed(2));

        MainTotal = Number(MainTotal + Number($('#txtRounding').val())).toFixed(2);

        $("#txtTotal").val(parseFloat(MainTotal).toFixed(2));

    }

    function CheckDuplicateItem(itemCode, CustCode, row) {

        var allUnits = [];
        var itemtext = itemCode;
        var Item = itemCode;
        var Cust = CustCode;
        var rowCnt_Material = 1;
        var cnt = 0;
        var errRow = 0;

        //$('#tblItem  > tbody > tr').each(function (row1, tr) {
        //    // post table's data to Submit form using Json Format

        //    var itemCode = $("input[name='AutoMatCodes']", this).val().split("-")[0].trim();
        //    var CustCode = $("input[name='AutoCustCode']", this).val().split("#")[0].trim();
        //    var LineNum = $("input[name='hdnLineNum']", this).val();

        //    //if (itemCode != "") {
        //    //    if (parseInt(row) != parseInt(LineNum)) {
        //    //        if (Item == itemCode && Cust == CustCode) {
        //    //            cnt = 1;
        //    //            errRow = row;
        //    //            $('#AutoMatCodes' + row).val('');
        //    //            $('#AutoCustCode' + row).val('');
        //    //            errormsg = 'Customer = ' + CustCode + ' And Material = ' + itemCode + ' is already seleted at row : ' + rowCnt_Material;
        //    //            event.preventDefault();
        //    //            return false;
        //    //        }
        //    //    }
        //    //}
        //    //}

        //    rowCnt_Material++;
        //});

        //if (cnt == 1) {
        //    $('#AutoMatCodes' + row).val('');
        //    $('#tdItemName' + row).text('');
        //    $('#AutoCustCode' + row).val('');
        //    $('#tdCustomerName' + row).text('');

        //    ClearMaterialRow(row);
        //    ModelMsg(errormsg, 3);
        //    event.preventDefault();
        //    return false;
        //}

        var ind = $('#CountRowMaterial').val();
        if (ind == row) {
            AddMoreRow();
        }

    }

    function ClearMaterialRow(row) {
        var rowCnt_Material = 1;
        var cnt = 0;
        $('#tblItem > tbody > tr').each(function (row1, tr) {
            // post table's data to Submit form using Json Format

            var itemCode = $("input[name='AutoMatCodes']", this).val();
            if (itemCode == "") {
                $(".tdMapQty", this).text('');
                $(".tdBoxesRate", this).text('');
                $(".tdPrice", this).text('');
                $(".tdTotalPrice", this).text('');
                $("input[name='txtReciept']", this).val('');
            }
            cnt++;

            rowCnt_Material++;
        });

        if (cnt >= 1) {
            var rowCnt_Material = 1;
            $('#tblItem > tbody > tr').each(function (row1, tr) {
                // post table's data to Submit form using Json Format                    
                if (cnt != rowCnt_Material) {
                    var itemCode = $("input[name='AutoMatCodes']", this).val();
                    var custCode = $("input[name='AutoCustCode']", this).val();

                    if (custCode == "") {
                        $(this).remove();
                        CalculateSum(1);

                        $("#tblItem").tableHeadFixer('60vh');
                    }
                }

                rowCnt_Material++;
            });
        }

    }

    function ClearAll() {
        $("#txtBillAmount").val('');
        $("#txtRounding").val('');
        $("#txtTotal").val('');
        $("#txtNotes").val('');
        $("#txtOINVRID").val('');
        $("#lblFootReceipt").text('');
        $("#lblFootTotalPrice").text('');
        $('#tblItem  > tbody > tr').each(function (row1, tr) {
            // post table's data to Submit form using Json Format
            $(this).remove();
        });
        $('#CountRowMaterial').val(0);
        AddMoreRow();
    }
    function btnSubmit_Click() {

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

        var IsValid = true;

        if (!$('._masterForm').data('bootstrapValidator').isValid())
            $('._masterForm').bootstrapValidator('validate');

        IsValid = $('._masterForm').data('bootstrapValidator').isValid();

        if (!IsValid) {
            $.unblockUI();
            event.preventDefault();
            return false;
        }

        var TableData_Material = [];
        var totalItemcnt = 0;
        var cnt = 0;
        rowCnt_Material = 0;

        $('#tblItem  > tbody > tr').each(function (row, tr) {
            var ItemCode = $("input[name='AutoMatCodes']", this).val();
            var CustCode = $("input[name='AutoCustCode']", this).val();
            if ((ItemCode == "" && CustCode != "") || (ItemCode != "" && CustCode == "")) {
                cnt = 1;
                $.unblockUI();
                errormsg = 'Please select Dealer and Item both in Row: ' + (parseInt(rowCnt_Material) + 1);
                event.preventDefault();
                return false;
            }
            if (CustCode != "" && ItemCode != "") {
                totalItemcnt = 1;
                if ($("select[name='ddlUnit']", this).val() == null) {
                    cnt = 1;
                    $.unblockUI();
                    errormsg = 'Please Select proper Item in Row: ' + (parseInt(rowCnt_Material) + 1);
                    event.preventDefault();
                    return false;
                }
                var CustomerID = $("input[name='hdnCustID']", this).val();
                var ItemID = $("input[name='hdnItemID']", this).val();
                var Data = $("select[name='ddlUnit']", this).val().trim().split(',');
                var UOMName = $("select[name='ddlUnit']", this).val().trim();
                var tdMapQty = $(".tdMapQty", this).text();
                var tdBoxesRate = $(".tdBoxesRate", this).text();
                var tdPrice = $(".tdPrice", this).text();
                var Total = $(".tdTotalPrice", this).text();
                var txtReciept = $("input[name='txtReciept']", this).val();
                var MainID = $("input[name='hdnMainID']", this).val();
                var LineNum = $("input[name='hdnINVRid']", this).val();


                if (CustomerID != "" && ItemCode != "" && txtReciept == "0") {
                    cnt = 1;
                    $.unblockUI();
                    errormsg = 'Please enter Damage Quantity in Row: ' + (parseInt(rowCnt_Material) + 1);
                    event.preventDefault();
                    return false;
                }


                var obj = {
                    CustomerID: CustomerID,
                    ItemID: ItemID,
                    ItemCode: ItemCode,
                    Price: Data[1].trim(),
                    txtReciept: txtReciept,
                    Total: Total,
                    MainID: MainID,
                    LineNum: LineNum,
                    UnitID: Data[0].trim(),
                    BoxRate: Data[2].trim(),
                    MapQuantity: Data[3].trim(),
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

        var TableData_Scheme = [];
        var rowCnt_Scheme = 0;
        var totalItemcnt = 0;
        cnt = 0;

        var txtDate = $('#txtDate').val();
        var CustomerID = $(".txtCustCode").val().split('-')[2].trim();
        var SubTotal = $("#txtBillAmount").val();
        var TotalPrice = $("#txtTotal").val();
        var txtRounding = $('#txtRounding').val();
        var txtNotes = $('#txtNotes').val();
        var txtOINVRID = $('#txtOINVRID').val();

        var postData = {
            Date: txtDate,
            CustomerID: CustomerID,
            SubTotal: SubTotal,
            Total: TotalPrice,
            Rounding: txtRounding,
            Notes: txtNotes,
            OINVRID: txtOINVRID
        }
        $('#hidJsonOrderDetail').val(JSON.stringify(postData));

        var successMSG = false;
        var MaterialData = $('#hidJsonInputMaterial').val();

        var HeaderData = $('#hidJsonOrderDetail').val();
        var successMSG = true;
        if (successMSG == false) {
            $.unblockUI();
            event.preventDefault();
            return false;
        }
        else {
            var successMSG = true;
            var sv = $.ajax({
                url: 'InventoryReturn.aspx/SaveData',
                type: 'POST',
                //async: false,
                dataType: 'json',
                // traditional: true,
                data: JSON.stringify({ hidJsonInputMaterial: MaterialData, hidJsonInputHeader: HeaderData }),
                contentType: 'application/json; charset=utf-8'
            });

            var sendcall = 0;
            sv.success(function (result) {

                if (result.d == "") {
                    $.unblockUI();
                    event.preventDefault();
                    return false;
                }
                else if (result.d.indexOf("ERROR=") >= 0) {
                    $.unblockUI();
                    var ErrorMsg = result.d.split('=')[1].trim();
                    if (ErrorMsg.indexOf('Same Month Entry Found') >= 0) {
                        alert(ErrorMsg);
                        location.reload(true);
                    }
                    else
                        ModelMsg(ErrorMsg, 2);

                    event.preventDefault();
                    return false;
                }
                if (result.d.indexOf("SUCCESS=") >= 0) {
                    var SuccessMsg = result.d.split('=')[1].trim();
                    sendcall = 1;

                    if (sendcall == 1) {

                        alert(SuccessMsg);
                        location.reload(true);
                        event.preventDefault();
                        return false;
                    }

                }

            });

            sv.error(function (XMLHttpRequest, textStatus, errorThrown) {
                $.unblockUI();
                alert('Something is wrong...' + XMLHttpRequest.responseText);
                event.preventDefault();
                return false;
            });
        }


    }

    function CheckCust(txt) {
        ClearAll();
        if ($(txt).val().split('-').length == 3) {
            GetItems();
        }
    }

    </script>

</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel panel-default">
        <div class="panel-body _masterForm">
            <div class="row">
                <div class="col-lg-3" style="display: none">

                    <input type="hidden" id="hidJsonInputMaterial" name="hidJsonInputMaterial" value="" />
                    <input type="hidden" id="hidJsonOrderDetail" name="hidJsonOrderDetail" value="" />

                    <div class="input-group form-group">
                        <label class="input-group-addon">Damage Date</label>
                        <input type="text" id="txtDate" name="txtDate" disabled="disabled" class="datepick form-control" tabindex="8" />

                    </div>

                </div>
                <%-- <div class="col-lg-4">
                    <div class="input-group form-group">
                        <label class="input-group-addon">Warehouse</label>
                        <select id="ddlWhs" name="ddlWhs" class="form-control" tabindex="2"></select>
                    </div>
                </div>--%>
                <div class="col-lg-4">
                    <div class="input-group form-group" id="divCustomer" runat="server">
                        <asp:Label ID="lblCustomer" runat="server" Text="Customer" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCustCode" runat="server" TabIndex="2" CssClass="txtCustCode form-control" autocomplete="off" onchange="CheckCust(this);" Style="background-color: lightyellow"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtName" runat="server" ServicePath="~/WebService.asmx"
                            UseContextKey="true" ContextKey="3" ServiceMethod="GetActiveInActiveCustomer" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCustCode">
                        </asp:AutoCompleteExtender>
                    </div>
                    <div class="input-group form-group" style="display: none;">
                        <label class="input-group-addon">Vehicle No.</label>
                        <input type="text" class="form-control" tabindex="3" id="txtVehicle" style="background-color: rgb(250, 255, 189);" name="txtVehicle" data-bv-notempty="true" data-bv-notempty-message="Field is required" />
                    </div>
                    <div class="input-group form-group" style="display: none;">
                        <label class="input-group-addon">Template</label>
                        <input type="text" class="form-control" id="txtTemplate" name="txtTemplate" style="background-color: rgb(250, 255, 189);" tabindex="5" />
                    </div>
                </div>
                <div class="col-lg-8">
                    <div class="input-group form-group">
                        <label class="input-group-addon">Notes</label>
                        <textarea name="txtNotes" id="txtNotes" cols="2" rows="1" class="form-control" tabindex="3"></textarea>
                        <input type="hidden" name="txtOINVRID" id="txtOINVRID" class="txtOINVRID" />
                    </div>
                </div>
            </div>

            <input type="hidden" id="CountRowMaterial" />
            <div id="tbl">
                <table id="tblItem" class="table" border="1" tabindex="6" style="font-size: 11px;">
                    <thead>
                        <tr class="table-header-gradient">
                            <th style="width: 2%;">Sr. No</th>
                            <th style="width: 6%;">Date</th>
                            <th style="width: 6%;">Dealer Code</th>
                            <th style="width: 17%;">Dealer Name</th>
                            <th style="width: 6%;">Item Code</th>
                            <th style="width: 17%;">Item Name</th>
                            <%--<th style="width: 6%">Unit</th>--%>
                            <th style="width: 3%; text-align: right">Pcs of Box</th>
                            <th style="width: 3%; text-align: right">Boxes Rate</th>
                            <th style="width: 3%; text-align: right">Pcs Rate</th>
                            <th style="width: 3.5%; text-align: right">Damage Pcs</th>
                            <th style="width: 4%; text-align: right">Damage Amount</th>
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
                            <th></th>
                            <th></th>
                            <th style='text-align: right'>
                                <label id="lblFootAvailable"></label>
                            </th>
                            <th></th>
                            <th></th>
                            <th style='text-align: right'>
                                <label id="lblFootReceipt"></label>
                            </th>
                            <th style='text-align: right'>
                                <label id="lblFootTotalPrice" class="lblFootTotalPrice"></label>
                            </th>
                            <th style="display: none">ID</th>
                        </tr>
                    </tfoot>
                </table>
            </div>
            <br />
            <div class="row">
                <div class="col-lg-6">
                    <div class="input-group form-group">
                        <input type="button" id="btnSubmit" name="btnSubmit" value="Save" class="btn btn-default" onclick="btnSubmit_Click()" tabindex="18" />&nbsp;
                        <input type="button" id="btnCancel" name="btnCancel" value="Cancel" onclick="Cancel()" class="btn btn-default" tabindex="19" />
                    </div>
                </div>
                <div class="col-lg-4" style="display: none;">
                    <div class="input-group form-group">
                        <label class="input-group-addon">Gross Amount</label>
                        <input type="text" id="txtBillAmount" name="txtBillAmount" class="txtBillAmount form-control " value="0.0" tabindex="9" />
                    </div>
                    <div class="input-group form-group" style="display: none;">
                        <label class="input-group-addon">Tax</label>
                        <input type="text" id="txtTax" name="txtTax" class="txtTax form-control" value="0.0" tabindex="10" />
                    </div>
                </div>
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <label class="input-group-addon">Rounding</label>
                        <input type="text" id="txtRounding" name="txtRounding" class="txtRounding form-control" disabled="disabled" value="0.0" tabindex="11" />
                    </div>
                </div>
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <label class="input-group-addon">Total</label>
                        <input type="text" id="txtTotal" name="txtTotal" class="txtTotal form-control" value="0.0" tabindex="12" />
                    </div>
                    <div class="input-group form-group" style="display: none;">
                        <label class="input-group-addon">Discount</label>
                        <input type="text" id="txtDiscount" name="txtDiscount" class="txtDiscount form-control" value="0.0" tabindex="16" />
                    </div>
                </div>

            </div>
        </div>

    </div>
</asp:Content>

