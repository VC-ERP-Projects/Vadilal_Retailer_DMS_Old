<%@ Page Title="" Language="C#" MasterPageFile="~/MainMaster.master" AutoEventWireup="true" CodeFile="ReceiptDirect.aspx.cs" Inherits="Purchase_ReceiptDirect" %>

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

        table#tblItem {
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
    </style>
    <script type="text/javascript">

        $(document).ready(function () {
            $("#tblItem").tableHeadFixer('60vh');
        });

    </script>
    <script type="text/javascript">
        var availableItems = [];
        var availableTemplate = [];
        var availableOrderForm = [];
        var ReasonList = [];
        var TemplateItems = [];
        $(document).ready(function () {

            $("#txtDiscount").prop("disabled", true);
            $("#txtReceiveDate").prop("disabled", true);
            $("#txtBillAmount").prop("disabled", true);
            $("#txtTax").prop("disabled", true);
            $("#txtRounding").prop("disabled", true);
            $("#txtTotal").prop("disabled", true);
            $("#txtPending").prop("disabled", true);

            $('#CountRowMaterial').val(0);

            $("#txtPaid").on('change  paste', function (event) {
                summary();
            });

            $("#txtDiscount").on('blur', function (event) {
                CalculateDiscount();

            });

            $("#txtBillDate,#txtReceiveDate").datepicker({
                dateFormat: 'dd/MM/yy',
                changeMonth: true, changeYear: true,
                yearRange: "2000:2090",
                beforeShow: function () {
                    setTimeout(function () {
                        $('.ui-datepicker').css('z-index', 99999999999999);
                    }, 0);
                }
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

            $('#txtDate').val(today);
            $('#txtBillDate').val(today);
            $('#txtReceiveDate').val(today);

            FillData();

            AddMoreRow();
        });

        function FillData() {
            $.ajax({
                url: 'ReceiptDirect.aspx/LoadData',
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
                        $('#txtBillDate').val(today);
                        $('#txtReceiveDate').val(today);

                        return false;
                    }
                    else {
                        var lstVendor = result.d[0]
                        var lstDivision = result.d[1];
                        var WareHouse = result.d[2];
                        var Template = result.d[4];
                        var Reason = result.d[5];
                        $("#ddlDivision option[value!='0']").remove();
                        $("#ddlDivision").append('<option  value="0">--Select--</option>');
                        for (var i = 0; i < lstDivision.length; i++) {

                            $("#ddlDivision").append('<option Selected value="' + lstDivision[i]["DivisionlID"] + '">' + lstDivision[i]["DivisionName"] + '</option>');
                            OnDivisionChange();
                        }
                        for (var i = 0; i < Reason.length; i++) {

                            ReasonList.push(Reason[i]);
                        }

                        $("#ddlWhs option[value!='0']").remove();

                        for (var i = 0; i < WareHouse.length; i++) {
                            $("#ddlWhs").append('<option value="' + WareHouse[i]["Value"] + '">' + WareHouse[i]["Name"] + '</option>');
                        }
                        $("#ddlVendor option[value!='0']").remove();

                        for (var i = 0; i < lstVendor.length; i++) {
                            $("#ddlVendor").append('<option value="' + lstVendor[i]["VendorID"] + '">' + lstVendor[i]["VendorName"] + '</option>');
                        }

                        for (var i = 0; i < Template.length; i++) {
                            availableTemplate.push(Template[i]);
                        }

                        $("#txtTemplate").autocomplete({
                            source: availableTemplate,
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
    function LoadItemTemlateWise(txt) {
        var ddlWhs = $("select[name='ddlWhs']").val().trim();
        var division = $("select[name='ddlDivision']").val().trim();
        var TempId = txt;
        if (ddlWhs != null && TempId != null && division != 0) {
            $.ajax({
                url: 'ReceiptDirect.aspx/LoadTemplateItems',
                type: 'POST',
                dataType: 'json',
                data: JSON.stringify({ ddlWhs: ddlWhs, division: division, TempId: TempId }),
                async: false,
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
                        availableItems = result.d[0];

                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {

                    alert('Something is wrong...' + XMLHttpRequest.responseText);
                    event.preventDefault();
                    return false;
                }
            });
        }
        else {
            ModelMsg("Select Division,WareHouse and TemplateName", 3);
        }
    }
    function summary() {
        var Total = parseFloat($('#txtTotal').val());
        var paid = parseFloat($('#txtPaid').val());
        if (Total != null && paid != null) {
            $('#txtPending').val(parseFloat(Math.round(Total) - paid).toFixed(2));
        }
    }
    function AddMoreRow() {

        $('table#tblItem tr#NoROW').remove();  // Remove NO ROW

        /// Add Dynamic Row to the existing Table
        var ind = $('#CountRowMaterial').val();
        ind = parseInt(ind) + 1;
        $('#CountRowMaterial').val(ind);

        var str = "";
        str = "<tr id='trItem" + ind + "'>"
            + "<td><input type='text' id='AutoMatCodes" + ind + "' name='AutoMatCodes' class='form-control search ' /></td>"
            + "<td><select id='ddlUnit" + ind + "' name='ddlUnit' class='form-control' onchange='ChangeQuantity(this);' onkeyup='enter(this);'/></td>"
            + "<td id='tdPrice" + ind + "' class='tdPrice'></td>"
            + "<td id='tdAvailable" + ind + "' class='tdAvailable'></td>"
            + "<td><input type='text' id='txtReciept" + ind + "' name='txtReciept' maxlength='10' value='0' class='form-control allownumericwithdecimal' onfocus='SetQtyDataFocus(this);' onblur='SetQtyDataBlur(this);' onchange='ChangeQuantity(this);'  /></td>"
            + "<td id='tdTotalQty" + ind + "' class='tdTotalQty'></td>"
            + "<td id='tdSubTotal" + ind + "' class='tdSubTotal'></td>"
            + "<td id='tdTax" + ind + "' class='tdTax'></td>"
            + "<td id='tdTotalPrice" + ind + "' class='tdTotalPrice'></td>"
             + "<td><select id='ddlReason" + ind + "' name='ddlReason' class='form-control'  /></td>"
            + "<td style='display:none'><input type='hidden' id='hdnItemID" + ind + "' name='hdnItemID'/>"
            + "<input type='hidden' id='hdnMainID" + ind + "' name='hdnMainID' value='0' />"
            + "<input type='hidden' id='hdnMaterialPriceTax" + ind + "' name='hdnMaterialPriceTax' value='0' />"
            + "<input type='hidden' id='hdnMaterialUnitPrice" + ind + "' name='hdnMaterialUnitPrice' value='0' />"
            + "<input type='hidden' id='hdnMaterialTaxID" + ind + "' name='hdnMaterialTaxID' value='0' />"

            + "<input type='hidden' id='hdnDiscountSubTotal" + ind + "' name='hdnDiscountSubTotal' value='0' />"
            + "<input type='hidden' id='hdnDiscountPrice" + ind + "' name='hdnDiscountPrice' value='0' />"
            + "<input type='hidden' id='hdnDiscountTax" + ind + "' name='hdnDiscountTax' value='0' />"
            + "<input type='hidden' id='hdnDiscountTotal" + ind + "' name='hdnDiscountTotal' value='0' />"
            + "<input type='hidden' id='hdnLineNum" + ind + "' name='hdnLineNum' value='" + ind + "' />"
            + "<input type='hidden' id='hdnMappingQty" + ind + "' name='hdnMappingQty' value='0' /></td>";

        $('#tblItem > tbody').append(str);


        $('#ddlUnit' + ind).on('change', function () {
            SetUnitPrice(ind);
        });

        $('#AutoMatCodes' + ind).autocomplete({
            source: availableItems,
            minLength: 0,
            scroll: true
        });
        $('#AutoMatCodes' + ind).on('autocompleteselect', function (e, ui) {
            $('#AutoMatCodes' + ind).val(ui.item.value);

            GetItemDetailsByCode(ui.item.value, ind);
        });

        $('#AutoMatCodes' + ind).bind("autocompleteselect", function (event, ui) {
            //availableItems.splice(availableItems.indexOf(ui.item.value), 1);
            $(this).autocomplete("option", "source", availableItems);
        });
        $('#AutoMatCodes' + ind).on('blur', function (e, ui) {
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
                CheckDuplicateItem($('#AutoMatCodes' + ind).val().trim(), ind);
            }
        });

        $('#AutoMatCodes' + ind).on('change keyup', function () {
            if ($('#AutoMatCodes' + ind).val() == "") {
                ClearMaterialRow(ind);
            }
        });

        $("#txtReciept" + ind).on('change keyup paste', function (event) {
            CalculateSum(ind);
            
        });

        // allow decimal values only
        $(".allownumericwithdecimal").keydown(function (e) {
            // Allow: backspace, delete, tab, escape, enter
            if ($.inArray(e.keyCode, [46, 8, 9, 13]) !== -1 ||
                // Allow: Ctrl+A, Command+A
                ((e.keyCode == 65) && (e.metaKey === true)) ||
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
    function ChangeQuantity(txt) {

        var EnterQty = 0;
        if (txt != undefined) {
            var Container = $(txt).parent().parent();
            var Data = new Array();

            if (Container.find('.ddlUnit').val() != null)
                Data = Container.find('.ddlUnit').val().split(',');

            if (txt.className.indexOf('ddlUnit') >= 0)
                EnterQty = Container.find('.txtRecieptQty').val();
            else if ($(txt).val() == "" || isNaN(parseInt($(txt).val()))) {
                $(txt).val("0"); EnterQty = 0;
            }
            else
                EnterQty = $(txt).val();

            if (Data.length == 4) {
                Container.find('.lblPrice').val(Number(Data[1]).toFixed(2));
                Container.find('.txtTotalQty').val(EnterQty * Number(Data[3]));
                Container.find('.lblSubTotal').val((Number(Container.find('.lblPrice').val()) * EnterQty).toFixed(2));
                Container.find('.lblTax').val((EnterQty * Number(Data[2])).toFixed(2));
                Container.find('.txtAvailQty').val((Number(Container.find('.hdnAvailQty').val()) / Number(Data[3])).toFixed(0));
                Container.find('.lblTotalPrice').val((Number(Container.find('.lblSubTotal').val()) + Number(Container.find('.lblTax').val())).toFixed(2));

                AddFunction(Container.find('.lblNo').text(), Data[0], Data[2], Data[3], Container.find('.lblPrice').val(), Container.find('.txtRecieptQty').val(),
          Container.find('.lblSubTotal').val(), Container.find('.lblTax').val(), Container.find('.lblTotalPrice').val(), Container.find('.ddlReason').val());

            }
        }

        var main = $('.tblItem');
        var AllRows = $(main).find('tbody').find('tr');
        var AvailQty = 0, RecieptQty = 0, TotalQty = 0, SubTotal = 0, Tax = 0, TotalPrice = 0;
        for (var i = 0; i < AllRows.length; i++) {

            if (txt == undefined) {

                var Data = new Array();

                EnterQty = $(AllRows[i]).find('.txtRecieptQty').val();

                if ($(AllRows[i]).find('.ddlUnit').val() != null)
                    Data = $(AllRows[i]).find('.ddlUnit').val().split(',');

                if (Data.length == 4) {
                    $(AllRows[i]).find('.lblPrice').val(Number(Data[1]).toFixed(2));
                    $(AllRows[i]).find('.txtTotalQty').val(EnterQty * Number(Data[3]));
                    $(AllRows[i]).find('.lblSubTotal').val((Number($(AllRows[i]).find('.lblPrice').val()) * EnterQty).toFixed(2));
                    $(AllRows[i]).find('.lblTax').val((EnterQty * Number(Data[2])).toFixed(2));
                    $(AllRows[i]).find('.txtAvailQty').val((Number($(AllRows[i]).find('.hdnAvailQty').val()) / Number(Data[3])).toFixed(0));
                    $(AllRows[i]).find('.lblTotalPrice').val((Number($(AllRows[i]).find('.lblSubTotal').val()) + Number($(AllRows[i]).find('.lblTax').val())).toFixed(2));
                }
            }
            AvailQty += Number($(AllRows[i]).find('.txtAvailQty').val());
            RecieptQty += Number($(AllRows[i]).find('.txtRecieptQty').val());
            TotalQty += Number($(AllRows[i]).find('.txtTotalQty').val());
            SubTotal += Number($(AllRows[i]).find('.lblSubTotal').val());
            Tax += Number($(AllRows[i]).find('.lblTax').val());
            TotalPrice += Number($(AllRows[i]).find('.lblTotalPrice').val());
        }
        var FooterContainer = $(main).find('.table-header-gradient');
        FooterContainer.find('.txtTAvailQty').val(AvailQty);
        FooterContainer.find('.txtTRecieptQty').val(RecieptQty);
        FooterContainer.find('.txtTTotalQty').val(TotalQty);
        FooterContainer.find('.lblTSubTotal').val(SubTotal.toFixed(2));
        FooterContainer.find('.lblTTax').val(Tax.toFixed(2));
        FooterContainer.find('.lblTPrice').val(TotalPrice.toFixed(2));

        isNaN(SubTotal) ? SubTotal = 0 : 0;
        isNaN(Tax) ? Tax = 0 : 0;
        isNaN(TotalPrice) ? TotalPrice = 0 : 0;

        $('.txtBillAmount').val(SubTotal.toFixed(2));
        $('.txtTax').val(Tax.toFixed(2));
        $('.txtTotal').val(TotalPrice.toFixed(2));

        $('body').animate({ scrollTop: $(window).width() }, 1000);

        summary();

    }
    function CalculateDiscount() {

        var DiscValue = $("#txtDiscount").val();
        if (DiscValue != "") {
            var TotalWithDisc = 0;
            var gtotal = $("#txtTotal").val();
            if (gtotal != "") {
                TotalWithDisc = (parseFloat(gtotal) - parseFloat(DiscValue)).toFixed(2);
                $("#txtTotal").val(TotalWithDisc);
                $("#txtPending").val(TotalWithDisc);

            }
            else {
                return false;
            }
        }
        else {
            return false;
            //}
        }
    }
    function SetUnitPrice(row) {
        CalculateSum(row);
    }
    function Cancel() {
        window.location = "../Purchase/Purchase.aspx";
    }
    function OnDivisionChange() {
        var DivisionID = $('#ddlDivision').val();
        if (DivisionID == 0) {
            return false;
        }
        else {
            $.ajax({
                url: 'ReceiptDirect.aspx/LoadItemsByDivision',
                type: 'POST',
                dataType: 'json',
                data: JSON.stringify({ DivisionID: DivisionID }),
                async: false,
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
    function GetItemDetailsByCode(itemCode, row) {
        var allUnits = [];
        var itemtext = itemCode;
        var Item = itemCode.split("-")[0].trim();

        var ddlWhs = $("select[name='ddlWhs']").val();
        var rowCnt_Material = 1;
        var cnt = 0;
        var errRow = 0;

        $('#tblItem  > tbody > tr').each(function (row1, tr) {
            // post table's data to Submit form using Json Format

            var itemCode = $("input[name='AutoMatCodes']", this).val().split("-")[0].trim();
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
            }
            //}

            rowCnt_Material++;
        });
        $.ajax({
            url: 'ReceiptDirect.aspx/GetItemDetails',
            type: 'POST',
            dataType: 'json',
            async: false,
            contentType: 'application/json; charset=utf-8',
            data: JSON.stringify({ txt: itemCode, WhsID: ddlWhs }),

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
                    $('#hdnMaterialPriceTax' + row).val(Data[2]);

                    $('#hdnDiscountPrice' + row).val(Data[1]);
                    $('#hdnDiscountTax' + row).val(Data[2]);

                    $('#tdAvailable' + row).text(result.d[1].AvailQty);
                    $("#ddlReason" + row + " option[value!='0']").remove();

                    for (var i = 0; i < ReasonList.length; i++) {
                        $("#ddlReason" + row).append('<option value="' + ReasonList[i]["ReasonID"] + '">' + ReasonList[i]["ReasonName"] + '</option>');
                    }

                    //for (var i = 0; i < ReasonList.length; i++) {
                    //    $("#ddlReason").append('<option value="' + ReasonList[i]["ReasonID"] + '">' + ReasonList[i]["ReasonName"] + '</option>');
                    //}

                    $('#txtReciept' + row).focus();
                    $('#txtReciept' + row).select();

                }
            },
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                alert('Something is wrong...' + XMLHttpRequest.responseText);
                event.preventDefault();
                return false;
            }
        });


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
        var FootAvailable = 0;
        var FootReceipt = 0;
        var FootTotalQty = 0;
        var FootSubTotal = 0;
        var FootTax = 0;
        var FootTotalPrice = 0;

        $('#tblItem  > tbody > tr').each(function (row, tr) {

            if ($("input[name='AutoMatCodes']", this).val() != "") {
                var Data = new Array();

                if ($("select[name='ddlUnit']", this).val() != null || $("select[name='ddlUnit']", this).val() != " ")
                    Data = $("select[name='ddlUnit']", this).val().split(',');

                $(".tdPrice", this).text(Data[1]);

                var Price = $(".tdPrice", this).text();
                if (Price == "") {
                    Price = 0;
                }

                var EnterQty = $("input[name='txtReciept']", this).val();
                if (EnterQty == "") {
                    EnterQty = 0;
                }

                var Available = $(".tdAvailable", this).text();
                if (Available == "") {
                    Available = 0;
                }


                $(".tdTotalQty", this).text((EnterQty * Data[3]).toFixed(2));
                $(".tdTax", this).text((Number(Data[2]) * EnterQty).toFixed(2));

                $(".tdSubTotal", this).text(Number(Number(Price) * parseFloat(EnterQty)).toFixed(2));
                $(".tdTotalPrice", this).text((Number($(".tdSubTotal", this).text()) + Number($(".tdTax", this).text())).toFixed(2));


                if (!$("input[name='txtReciept']", this).is(':disabled')) {
                    $("input[name='hdnDiscountTax']", this).val((Number(Data[2]) * EnterQty).toFixed(2));

                    $("input[name='hdnDiscountSubTotal']", this).val((Number(Price) * parseFloat(EnterQty)).toFixed(2));
                    $("input[name='hdnDiscountTotal']", this).val((Number($(".tdSubTotal", this).text()) + Number($(".tdTax", this).text())).toFixed(2));
                }


                FootAvailable = parseFloat(parseFloat(FootAvailable) + parseFloat(Available)).toFixed(2);
                FootReceipt = parseFloat(parseFloat(FootReceipt) + parseFloat(EnterQty)).toFixed(2);

                FootTotalQty = parseFloat(parseFloat(FootTotalQty) + parseFloat($(".tdTotalQty", this).text())).toFixed(2);
                FootSubTotal = parseFloat(parseFloat(FootSubTotal) + parseFloat($(".tdSubTotal", this).text())).toFixed(2);

                FootTax = parseFloat(parseFloat(FootTax) + parseFloat($(".tdTax", this).text())).toFixed(2);
                FootTotalPrice = parseFloat(parseFloat(FootTotalPrice) + parseFloat($(".tdTotalPrice", this).text())).toFixed(2);
            }
            rowCnt_Material++;
        });

        $("#lblFootAvailable").text(FootAvailable);
        $("#lblFootReceipt").text(FootReceipt);
        $("#lblFootTotalQty").text(FootTotalQty);
        $("#lblFootSubTotal").text(FootSubTotal);
        $("#lblFootTax").text(FootTax);
        $("#lblFootTotalPrice").text(FootTotalPrice);

        $("#txtBillAmount").val(FootSubTotal);
        $("#txtTax").val(FootTax);
        $("#txtTotal").val(FootTotalPrice);
        $("#txtPending").val(FootTotalPrice);
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
        $("#txtPending").val(parseFloat(MainTotal).toFixed(2));
    }
    function CheckDuplicateItem(itemCode, row) {
        var allUnits = [];
        var itemtext = itemCode;
        var Item = itemCode.split("-")[0].trim();
        var ddlWhs = $("select[name='ddlWhs']").val();
        var rowCnt_Material = 1;
        var cnt = 0;
        var errRow = 0;

        $('#tblItem  > tbody > tr').each(function (row1, tr) {
            // post table's data to Submit form using Json Format

            var itemCode = $("input[name='AutoMatCodes']", this).val().split("-")[0].trim();
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
                //$(this).remove();
            }
            cnt++;

            rowCnt_Material++;
        });

        if (cnt > 1) {
            var rowCnt_Material = 1;
            $('#tblItem > tbody > tr').each(function (row1, tr) {
                // post table's data to Submit form using Json Format                    
                if (cnt != rowCnt_Material) {
                    var itemCode = $("input[name='AutoMatCodes']", this).val();
                    if (itemCode == "") {
                        $(this).remove();
                        CalculateSum(1);
                        //availableItems.push(this);
                    }
                }

                rowCnt_Material++;
            });
        }

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
            if (ItemCode != "") {
                totalItemcnt = 1;
                var Data = $("select[name='ddlUnit']", this).val().split(',');
                var UOMName = $("select[name='ddlUnit']", this).val();
                var Price = $("input[name='hdnDiscountPrice']", this).val();
                var AvlQty = $(".tdAvailable", this).text();
                var SubTotal = $("input[name='hdnDiscountSubTotal']", this).val();
                var txtReciept = $("input[name='txtReciept']", this).val();
                var TotalQty = $(".tdTotalQty", this).text();
                var Tax = $("input[name='hdnDiscountTax']", this).val();
                var Total = $("input[name='hdnDiscountTotal']", this).val();
                var ItemID = $("input[name='hdnItemID']", this).val();
                var MainID = $("input[name='hdnMainID']", this).val();
                var PriceTax = $("input[name='hdnMaterialPriceTax']", this).val();
                var UnitPrice = $("input[name='hdnMaterialUnitPrice']", this).val();
                var TaxID = $("input[name='hdnMaterialTaxID']", this).val();
                var ReasonId = $("select[name='ddlReason']", this).val().trim();

                if (ItemCode != "" && txtReciept == "0") {
                    cnt = 1;
                    $.unblockUI();
                    errormsg = 'Please enter Reciept Quantity in Row: ' + (parseInt(rowCnt_Material) + 1);
                    event.preventDefault();
                    return false;
                }

                var obj = {
                    ItemID: ItemID,
                    ItemCode: ItemCode,
                    Price: Price,
                    AvlQty: AvlQty,
                    txtReciept: txtReciept,
                    TotalQty: TotalQty,
                    SubTotal: SubTotal,
                    Tax: Tax,
                    Total: Total,
                    MainID: MainID,
                    UnitID: Data[0],
                    MapQuantity: Data[3],
                    PriceTax: PriceTax,
                    UnitPrice: UnitPrice,
                    TaxID: TaxID,
                    Reason: ReasonId[0]
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


        var totalItemcnt = 0;
        cnt = 0;

        var ddlWhs = $("select[name='ddlWhs']").val().trim();
        var SubTotal = $("#txtBillAmount").val();
        var TotalPrice = $("#txtTotal").val();
        var Vendor = $("select[name='ddlVendor']").val();
        var Discount = $('#txtDiscount').val();
        var txtPaid = $('#txtPaid').val();
        var txtBillNumber = $('#txtBillNumber').val();
        var txtRounding = $('#txtRounding').val();
        var txtTax = $('#txtTax').val();
        var txtNotes = $('#txtNotes').val();
        var txtDate = $('#txtDate').val();
        var txtPending = $('#txtPending').val();
        var paidTo = $('#txtPaidTo').val();
        var postData = {

            ddlWhs: ddlWhs,
            Vendor: Vendor,
            SubTotal: SubTotal,
            Total: TotalPrice,
            Tax: txtTax,
            Paid: txtPaid,
            Discount: Discount,
            BillNumber: txtBillNumber,
            Rounding: txtRounding,
            Notes: txtNotes,
            Date: txtDate,
            Pending: txtPending,
            paidTo: paidTo
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
                url: 'ReceiptDirect.aspx/SaveData',
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
                    ModelMsg(ErrorMsg, 2);
                    event.preventDefault();
                    return false;
                }
                if (result.d.indexOf("SUCCESS=") >= 0) {
                    var SuccessMsg = result.d.split('=')[1].trim();
                    var OrderNo = result.d.split('#')[1].trim();
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

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel panel-default">
        <div class="panel-body _masterForm">
            <div class="row">
                <div class="col-lg-4">

                    <input type="hidden" id="hidJsonInputMaterial" name="hidJsonInputMaterial" value="" />
                    <input type="hidden" id="hidJsonOrderDetail" name="hidJsonOrderDetail" value="" />
                    <div class="input-group form-group">
                        <label class="input-group-addon">Order Date</label>
                        <input type="text" id="txtDate" disabled="disabled" name="txtDate" class="datepick form-control" tabindex="8" />

                    </div>
                    <div class="input-group form-group">
                        <label class="input-group-addon">Division/Group</label>
                        <select id="ddlDivision" name="ddlDivision" class="form-control" onchange="OnDivisionChange()" tabindex="4"></select>
                    </div>


                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <label class="input-group-addon">Vendor</label>
                        <select id="ddlVendor" name="ddlVendor" class="form-control" tabindex="1"></select>
                    </div>

                    <div class="input-group form-group">
                        <label class="input-group-addon">BillNumber</label>
                        <input type="text" class="form-control" id="txtBillNumber" name="txtBillNumber" data-bv-notempty="true" data-bv-notempty-message="Field is required" tabindex="9" />

                    </div>

                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <label class="input-group-addon">Warehouse</label>
                        <select id="ddlWhs" name="ddlWhs" class="form-control" tabindex="2"></select>

                    </div>
                    <div class="input-group form-group" style="display: none;">
                        <label class="input-group-addon">Template</label>
                        <input type="text" class="form-control" id="txtTemplate" name="txtTemplate" style="background-color: rgb(250, 255, 189);" tabindex="5" />
                    </div>
                </div>
            </div>
            <input type="text" data-val="false" id="txtSearch" class="txtSearch form-control" placeholder="Search here" tabindex="6" />
            <br />
            <input type="hidden" id="CountRowMaterial" />
            <table id="tblItem" class="table" border="1" tabindex="7">
                <thead>
                    <tr class="table-header-gradient">
                        <th style="width: 20%;">Item Details</th>
                        <th style="width: 8%">Unit</th>
                        <th style="width: 8%;">Price</th>
                        <th style="width: 8%;">Available</th>
                        <th style="width: 8%;">Receipt</th>
                        <th style="width: 8%;">Total Qty</th>
                        <th style="width: 8%;">SubTotal</th>
                        <th style="width: 8%;">Tax</th>
                        <th style="width: 8%">Total Price</th>
                        <th style="width: 8%">Reason</th>
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
                        <th>
                            <label id="lblFootAvailable"></label>
                        </th>
                        <th>
                            <label id="lblFootReceipt"></label>
                        </th>
                        <th>
                            <label id="lblFootTotalQty"></label>
                        </th>
                        <th>
                            <label id="lblFootSubTotal" class="lblFootSubTotal"></label>
                        </th>
                        <th>
                            <label id="lblFootTax"></label>
                        </th>
                        <th>
                            <label id="lblFootTotalPrice" class="lblFootTotalPrice"></label>
                        </th>
                        <th>
                            <label id="lblReason" class="lblReason"></label>
                        </th>
                        <th style="display: none">ID</th>
                    </tr>
                </tfoot>
            </table>
            <div class="row">
                <div class="col-lg-4">

                    <div class="input-group form-group">
                        <label class="input-group-addon">Bill Date</label>
                        <input type="text" id="txtBillDate" name="txtBillDate" class="datepick form-control" tabindex="10" />

                    </div>
                    <div class="input-group form-group">
                        <label class="input-group-addon">Receive Date</label>
                        <input type="text" id="txtReceiveDate" name="txtReceiveDate" class="datepick form-control" tabindex="11" />

                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <label class="input-group-addon">Bill Amount</label>
                        <input type="text" id="txtBillAmount" name="txtBillAmount" class="txtBillAmount form-control" value="0.0" tabindex="12" />
                    </div>
                    <div class="input-group form-group">
                        <label class="input-group-addon">Tax</label>
                        <input type="text" id="txtTax" name="txtTax" class="txtTax form-control" value="0.0" tabindex="13" />

                    </div>
                    <div class="input-group form-group">
                        <label class="input-group-addon">Rounding</label>
                        <input type="text" id="txtRounding" name="txtRounding" class="txtRounding form-control" value="0.0" tabindex="14" />

                    </div>
                    <div class="input-group form-group">
                        <label class="input-group-addon">Total</label>
                        <input type="text" id="txtTotal" name="txtTotal" class="txtTotal form-control" value="0.0" tabindex="15" />

                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <label class="input-group-addon">Discount</label>
                        <input type="text" id="txtDiscount" name="txtDiscount" class="txtDiscount form-control" value="0.0" tabindex="16" />

                    </div>
                    <div class="input-group form-group">
                        <label class="input-group-addon">Paid</label>
                        <input type="text" id="txtPaid" name="txtPaid" class="txtPaid form-control" value="0.0" tabindex="17" onkeypress="return isNumberKeyForAmount(event);" onpaste="return false;" />

                    </div>
                    <div class="input-group form-group">
                        <label class="input-group-addon">Pending</label>
                        <input type="text" id="txtPending" name="txtPending" class="txtPending form-control" value="0.0" tabindex="18" />

                    </div>
                    <div class="input-group form-group">
                        <label class="input-group-addon">Paid To</label>
                        <input type="text" id="txtPaidTo" name="txtPaidTo" class="txtPaidTo form-control" tabindex="19" />

                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-lg-12 _textArea">
                    <div class="input-group form-group">
                        <label class="input-group-addon">Notes</label>
                        <textarea name="txtNotes" id="txtNotes" cols="40" rows="2" class="form-control" tabindex="20"></textarea>


                    </div>
                </div>
            </div>
            <br />
            <input type="button" id="btnSubmit" name="btnSubmit" value="Submit" class="btn btn-default" onclick="btnSubmit_Click()" tabindex="21" />
            <input type="button" id="btnCancel" name="btnCancel" value="Cancel" onclick="Cancel()" class="btn btn-default" tabindex="22" />

        </div>

    </div>
</asp:Content>

