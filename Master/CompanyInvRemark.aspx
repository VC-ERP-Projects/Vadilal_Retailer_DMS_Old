<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="CompanyInvRemark.aspx.cs" Inherits="Master_CompanyInvRemark" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <link href="../Scripts/datatable_new/jquery.dataTables.min.css" rel="stylesheet" />
    <link href="../Scripts/datatable_new/buttons.dataTables.min.css" rel="stylesheet" />

    <script src="../Scripts/datatable_new/jquery.dataTables.min.js"></script>
    <script src="../Scripts/datatable_new/dataTables.buttons.min.js"></script>
    <script src="../Scripts/datatable_new/buttons.html5.min.js"></script>
    <script src="../Scripts/datatable_new/pdfmake.min.js"></script>
    <script src="../Scripts/datatable_new/vfs_fonts.js"></script>
    <script src="../Scripts/datatable_new/jszip.min.js"></script>
    <script type="text/javascript" src="../Scripts/fixHeaderFooter.js"></script>
    <script type="text/javascript">
        $(function () {
            Relaod();
            $('#tblDiscountExc').DataTable().clear().destroy();
            //$('#tblDiscountExc').DataTable();
            $('#CountRowClaim').val(0);
            FillData();
            setTimeout(function () {
                var aryJSONColTable = [];
                aryJSONColTable.push({ "width": "13px", "sClass": "dtbodyCenter", "aTargets": 0 });
                aryJSONColTable.push({ "width": "20px", "sClass": "dtbodyCenter", "aTargets": 1 });
                aryJSONColTable.push({ "width": "32px", "sClass": "dtbodyCenter", "aTargets": 2 });
                aryJSONColTable.push({ "width": "27px", "sClass": "dtbodyLeft", "aTargets": 3 });
                aryJSONColTable.push({ "width": "130px", "sClass": "dtbodyLeft", "aTargets": 4 });
                aryJSONColTable.push({ "width": "130px", "sClass": "dtbodyLeft", "aTargets": 5 });
                aryJSONColTable.push({ "width": "130px", "sClass": "dtbodyLeft", "aTargets": 6 });//"sClass": "dtbodyLeft",
                aryJSONColTable.push({ "width": "35px", "sClass": "dtbodyCenter", "aTargets": 7 });
                aryJSONColTable.push({ "width": "35px", "sClass": "dtbodyCenter", "aTargets": 8 });
                aryJSONColTable.push({ "width": "20px", "sClass": "dtbodyCenter", "aTargets": 9 });
                aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyLeft", "aTargets": 10 });
                aryJSONColTable.push({ "width": "62px", "sClass": "dtbodyCenter", "aTargets": 11 });
                //aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyLeft", "aTargets": 12 });
                //aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyCenter", "aTargets": 13 });
                //aryJSONColTable.push({ "width": "70px", "aTargets": 14 });
                //aryJSONColTable.push({ "width": "70px", "sClass": "dtbodyCenter", "aTargets": 15 });
                $('#tblDiscountExc').DataTable({
                    bFilter: false,
                    scrollCollapse: true,
                    "sExtends": "collection",
                    scrollX: true,
                    scrollY: '62vh',
                    responsive: true,
                    "bPaginate": false,
                    "autoWidth": false,
                    "bDestroy": true,
                    scroller: false,
                    deferRender: true,
                    "aoColumnDefs": aryJSONColTable,
                    "bProcessing": true,
                    info: false,
                    "stateSave": true,
                    "bLengthChange": false,
                });
            }, 200)
            //  $("#hdnIPAdd").val(IpAddress);
            //  Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        });
        var availableParent = [];
        const JsonUniqNo = [];
        const JsonDivision = [];
        const JsonProductGroup = [];
        const JsonProdSubGroup = [];
        const JsonItemList = [];
        const JsonEmployee = [];
        const JsonRegion = [];
        const JsonDistributor = [];
        const JsonSS = [];
        const JsonCustGroup = [];
        const JsonCustomer = [];
        var Version = 'QA';
        var LogoURL = '../Images/LOGO.png';
        var IpAddress;
        function Relaod() {
            $("ul.nav-tabs > li > a").on("shown.bs.tab", function (e) {
                $.cookie("Scheme", $(e.target).attr("href").substr(1));
                if ($(e.target).attr("href").substr(1) == "tabs-Emp") {
                    $('#tblEmpDiscount').DataTable().clear().destroy();
                    $('#CountRowEmp').val(0);
                    FillDataEmployee();
                    setTimeout(function () {
                        var aryJSONColTableEmp = [];
                        aryJSONColTableEmp.push({ "width": "8px", "sClass": "dtbodyCenter", "aTargets": 0 });
                        aryJSONColTableEmp.push({ "width": "15px", "sClass": "dtbodyCenter", "aTargets": 1 });
                        aryJSONColTableEmp.push({ "width": "20px", "sClass": "dtbodyCenter", "aTargets": 2 });
                        aryJSONColTableEmp.push({ "width": "20px", "sClass": "dtbodyLeft", "aTargets": 3 });
                        aryJSONColTableEmp.push({ "width": "80px", "sClass": "dtbodyLeft", "aTargets": 4 });
                        aryJSONColTableEmp.push({ "width": "100px", "sClass": "dtbodyLeft", "aTargets": 5 });//"sClass": "dtbodyLeft",
                        aryJSONColTableEmp.push({ "width": "100px", "sClass": "dtbodyLeft", "aTargets": 6 });
                        aryJSONColTableEmp.push({ "width": "110px", "sClass": "dtbodyLeft", "aTargets": 7 });
                        aryJSONColTableEmp.push({ "width": "120px", "sClass": "dtbodyLeft", "aTargets": 8 });
                        aryJSONColTableEmp.push({ "width": "50px", "sClass": "dtbodyCenter", "aTargets": 9 });
                        aryJSONColTableEmp.push({ "width": "50px", "sClass": "dtbodyCenter", "aTargets": 10 });
                        aryJSONColTableEmp.push({ "width": "20px", "sClass": "dtbodyCenter", "aTargets": 11 });
                        aryJSONColTableEmp.push({ "width": "18px", "sClass": "dtbodyCenter", "aTargets": 12 });
                        aryJSONColTableEmp.push({ "width": "60px", "sClass": "dtbodyLeft", "aTargets": 13 });
                        aryJSONColTableEmp.push({ "width": "75px", "sClass": "dtbodyCenter", "aTargets": 14 });
                        $('#tblEmpDiscount').DataTable({
                            bFilter: false,
                            scrollCollapse: true,
                            "sExtends": "collection",
                            scrollX: true,
                            scrollY: '62vh',
                            responsive: true,
                            "bPaginate": false,
                            "autoWidth": false,
                            "bDestroy": true,
                            scroller: false,
                            deferRender: true,
                            "aoColumnDefs": aryJSONColTableEmp,
                            "bProcessing": true,
                            info: false,
                            "stateSave": true,
                            "bLengthChange": false,
                        });
                    }, 200)

                    // $('#tblEmpDiscount').DataTable();
                    //  $($.fn.dataTable.tables(true)).DataTable().columns.adjust().fixedColumns().relayout();
                    //$('#tblEmpDiscount').DataTable();
                    //  $('#tblEmpDiscount tr:last').focus();
                    // $($.fn.dataTable.tables(true)).DataTable().columns.adjust();
                }
                else {


                    $('#tblDiscountExc').DataTable().clear().destroy();
                    $('#CountRowClaim').val(0);
                    FillData();
                    setTimeout(function () {
                        var aryJSONColTable = [];
                        aryJSONColTable.push({ "width": "13px", "sClass": "dtbodyCenter", "aTargets": 0 });
                        aryJSONColTable.push({ "width": "20px", "sClass": "dtbodyCenter", "aTargets": 1 });
                        aryJSONColTable.push({ "width": "32px", "sClass": "dtbodyCenter", "aTargets": 2 });
                        aryJSONColTable.push({ "width": "27px", "sClass": "dtbodyLeft", "aTargets": 3 });
                        aryJSONColTable.push({ "width": "130px", "sClass": "dtbodyLeft", "aTargets": 4 });
                        aryJSONColTable.push({ "width": "130px", "sClass": "dtbodyLeft", "aTargets": 5 });
                        aryJSONColTable.push({ "width": "130px", "sClass": "dtbodyLeft", "aTargets": 6 });//"sClass": "dtbodyLeft",
                        aryJSONColTable.push({ "width": "35px", "sClass": "dtbodyCenter", "aTargets": 7 });
                        aryJSONColTable.push({ "width": "35px", "sClass": "dtbodyCenter", "aTargets": 8 });
                        aryJSONColTable.push({ "width": "20px", "sClass": "dtbodyCenter", "aTargets": 9 });
                        aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyLeft", "aTargets": 10 });
                        aryJSONColTable.push({ "width": "62px", "sClass": "dtbodyCenter", "aTargets": 11 });
                        //aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyLeft", "aTargets": 12 });
                        //aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyCenter", "aTargets": 13 });
                        $('#tblDiscountExc').DataTable({
                            bFilter: false,
                            scrollCollapse: true,
                            "sExtends": "collection",
                            scrollX: true,
                            scrollY: '62vh',
                            responsive: true,
                            "bPaginate": false,
                            "autoWidth": false,
                            "bDestroy": true,
                            scroller: false,
                            deferRender: true,
                            "aoColumnDefs": aryJSONColTable,
                            "bProcessing": true,
                            info: false,
                            "stateSave": true,
                            "bLengthChange": false,
                        });
                    }, 200)

                }

            });
            $('#tabs a[href="#' + $.cookie("Scheme") + '"]').tab('show');

        }


        function getUserIP(onNewIP) { //  onNewIp - your listener function for new IPs
            //compatibility for firefox and chrome
            try {
                var myPeerConnection = window.RTCPeerConnection || window.mozRTCPeerConnection || window.webkitRTCPeerConnection;
                var pc = new myPeerConnection({
                    iceServers: []
                }),
                    noop = function () { },
                    localIPs = {},
                    ipRegex = /([0-9]{1,3}(\.[0-9]{1,3}){3}|[a-f0-9]{1,4}(:[a-f0-9]{1,4}){7})/g,
                    key;
            }
            catch (err) {

            }

            function iterateIP(ip) {
                if (!localIPs[ip]) onNewIP(ip);
                localIPs[ip] = true;
            }
            try {
                //create a bogus data channel
                pc.createDataChannel("");

                // create offer and set local description
                pc.createOffer(function (sdp) {
                    sdp.sdp.split('\n').forEach(function (line) {
                        if (line.indexOf('candidate') < 0) return;
                        line.match(ipRegex).forEach(iterateIP);
                    });

                    pc.setLocalDescription(sdp, noop, noop);
                }, noop);

                //listen for candidate events
                pc.onicecandidate = function (ice) {
                    if (!ice || !ice.candidate || !ice.candidate.candidate || !ice.candidate.candidate.match(ipRegex)) return;
                    ice.candidate.candidate.match(ipRegex).forEach(iterateIP);
                };
            }
            catch (err) {

            }
        }
        // Usage
        getUserIP(function (ip) {
            if (IpAddress == undefined)
                IpAddress = ip;
            try {
                if ($("#hdnIPAdd").val() == 0 || $("#hdnIPAdd").val() == "" || $("#hdnIPAdd").val() == undefined) {
                    $("#hdnIPAdd").val(ip);
                }
            }
            catch (err) {

            }
        });

        $(document).ready(function () {

            $("#tblDiscountExc").tableHeadFixer('72vh');
            $("#tblEmpDiscount").tableHeadFixer('72vh');

            $('ul.nav-tabs > li > a').click(function (e) {
                e.preventDefault();
                $(this).tab('show');
            });
            //  $('#tabs a[href="#tabs-Item"]').tab('show');
            //  FillData();

            ClearControls();

            // Item Tab
            //// Start Auto Uniq no

            $(document).on('keyup', '.txtAutoUniq', function () {
                var textValue = $(this).val();
                var currentRow = $(this).closest("tr");
                var col1 = currentRow.find("td:eq(0)").text();
                $('#txtAutoUniq' + col1).autocomplete({
                    source: function (request, response) {
                        $.ajax({
                            type: "POST",
                            url: 'CompanyInvRemark.aspx/SearchGroupRefNo',
                            dataType: "json",
                            data: "{ 'prefixText': '" + (textValue != '' ? textValue : '*') + "'}",
                            contentType: "application/json; charset=utf-8",
                            success: function (data) {
                                response($.map(data.d, function (item) {
                                    return {
                                        label: item.Text,
                                        value: item.Text,
                                        id: item.Value
                                    };
                                }))
                            },
                            error: function (XMLHttpRequest, textStatus, errorThrown) {
                            }
                        });
                    },
                    position: {
                        my: 'left top',
                        at: 'right top',
                        collision: 'flip flip',
                        of: $('#txtAutoUniq' + col1),
                        using: function (obj, info) {
                            if (info.vertical != "top") {
                                $(this).addClass("flipped");
                            } else {
                                $(this).removeClass("flipped");
                            }
                            if (info.horizontal != "left") {
                                $(this).addClass("flipped");
                            } else {
                                $(this).removeClass("flipped");
                            }
                            $(this).css({
                                left: obj.left + 'px',
                                top: obj.top + 'px'
                            });
                        }
                    },
                    select: function (event, ui) {
                        var currentRow = $(this).closest("tr");
                        var col1 = currentRow.find("td:eq(0)").text();
                        $('#txtAutoUniq' + col1).val(ui.item.value + " ");
                        $('#hdnItmGroupId' + col1).val(ui.item.value.split("#")[1].trim());
                    },
                    change: function (event, ui) {
                        if (!ui.item) {

                        }
                    },
                    minLength: 1
                });
            });

            $('.txtAutoUniq').on('autocompleteselect', function (e, ui) {
                var currentRow = $(this).closest("tr");
                var col1 = currentRow.find("td:eq(0)").text();
                $('#txtAutoUniq' + col1).val(ui.item.value);
            });


            $('.txtAutoUniq').on('change keyup', function () {
                var currentRow = $(this).closest("tr");
                var col1 = currentRow.find("td:eq(0)").text();
                if ($('#txtAutoUniq' + col1).val() == "") {
                    ClearClaimRow(col1);
                    $('#hdnItmGroupId' + col1).val(0);
                }
            });


            $('.txtAutoUniq').on('blur', function (e, ui) {
                var currentRow = $(this).closest("tr");
                var col1 = currentRow.find("td:eq(0)").text();
                if ($('#txtAutoUniq' + col1).val().trim() != "") {
                    if ($('#txtAutoUniq' + col1).val().indexOf('#') == -1) {
                        ModelMsg("Select Proper Group or Ref", 3);
                        $('#txtAutoUniq' + col1).val("");
                        $('#hdnItmGroupId' + col1).val('0');
                        return;
                    }
                    var txt = $('#txtAutoUniq' + col1).val().trim();
                    if (txt == "undefined" || txt == "") {
                        //ModelMsg("Enter Item Code Or Name", 3);
                        return false;
                    }
                    var lineNum = 1;
                    $('#tblDiscountExc > tbody > tr').each(function (row, tr) {
                        $(".txtSrNo", this).text(lineNum);
                        lineNum++;
                    });
                }
            });

            ////End Auto Uniq no
            // Start Employee Tab
            //// Start Auto Uniq no

            $(document).on('keyup', '.txtAutoUniqEmp', function () {
                var textValue = $(this).val();
                var currentRow = $(this).closest("tr");
                var col1 = currentRow.find("td:eq(0)").text();
                $('#txtAutoUniqEmp' + col1).autocomplete({
                    source: function (request, response) {
                        $.ajax({
                            type: "POST",
                            url: 'CompanyInvRemark.aspx/SearchGroupRefNo',
                            dataType: "json",
                            data: "{ 'prefixText': '" + (textValue != '' ? textValue : '*') + "'}",
                            contentType: "application/json; charset=utf-8",
                            success: function (data) {
                                response($.map(data.d, function (item) {
                                    return {
                                        label: item.Text,
                                        value: item.Text,
                                        id: item.Value
                                    };
                                }))
                            },
                            error: function (XMLHttpRequest, textStatus, errorThrown) {
                            }
                        });
                    },
                    position: {
                        my: 'left top',
                        at: 'right top',
                        collision: 'flip flip',
                        of: $('#txtAutoUniqEmp' + col1),
                        using: function (obj, info) {
                            if (info.vertical != "top") {
                                $(this).addClass("flipped");
                            } else {
                                $(this).removeClass("flipped");
                            }
                            if (info.horizontal != "left") {
                                $(this).addClass("flipped");
                            } else {
                                $(this).removeClass("flipped");
                            }
                            $(this).css({
                                left: obj.left + 'px',
                                top: obj.top + 'px'
                            });
                        }
                    },
                    select: function (event, ui) {
                        var currentRow = $(this).closest("tr");
                        var col1 = currentRow.find("td:eq(0)").text();
                        $('#txtAutoUniqEmp' + col1).val(ui.item.value + " ");
                        $('#hdnEmpGroupId' + col1).val(ui.item.value.split("#")[1].trim());
                    },
                    change: function (event, ui) {
                        if (!ui.item) {

                        }
                    },
                    minLength: 1
                });
            });

            $('.txtAutoUniqEmp').on('autocompleteselect', function (e, ui) {
                var currentRow = $(this).closest("tr");
                var col1 = currentRow.find("td:eq(0)").text();
                $('#txtAutoUniqEmp' + col1).val(ui.item.value);
            });


            $('.txtAutoUniqEmp').on('change keyup', function () {
                var currentRow = $(this).closest("tr");
                var col1 = currentRow.find("td:eq(0)").text();
                if ($('#txtAutoUniqEmp' + col1).val() == "") {
                    ClearClaimRow(col1);
                    $('#hdnEmpGroupId' + col1).val(0);
                }
            });


            $('.txtAutoUniqEmp').on('blur', function (e, ui) {
                var currentRow = $(this).closest("tr");
                var col1 = currentRow.find("td:eq(0)").text();
                if ($('#txtAutoUniqEmp' + col1).val().trim() != "") {
                    if ($('#txtAutoUniqEmp' + col1).val().indexOf('#') == -1) {
                        ModelMsg("Select Proper Group or Ref", 3);
                        $('#txtAutoUniqEmp' + col1).val("");
                        $('#hdnEmpGroupId' + col1).val('0');
                        return;
                    }
                    var txt = $('#txtAutoUniqEmp' + col1).val().trim();
                    if (txt == "undefined" || txt == "") {
                        //ModelMsg("Enter Item Code Or Name", 3);
                        return false;
                    }
                    var lineNum = 1;
                    $('#tblDiscountExc > tbody > tr').each(function (row, tr) {
                        $(".txtSrNo", this).text(lineNum);
                        lineNum++;
                    });
                }
            });

            ////End Auto Uniq no

            //// Start Region textBox

            $(document).on('keyup', '.AutoRegion', function () {
                var textValue = $(this).val();
                var currentRow = $(this).closest("tr");
                var col1 = currentRow.find("td:eq(0)").text();
                $('#AutoRegion' + col1).autocomplete({
                    source: function (request, response) {
                        $.ajax({
                            type: "POST",
                            url: 'CompanyInvRemark.aspx/SearchRegion',
                            dataType: "json",
                            data: "{ 'prefixText': '" + (textValue != '' ? textValue : '*') + "'}",
                            contentType: "application/json; charset=utf-8",
                            success: function (data) {
                                response($.map(data.d, function (item) {
                                    return {
                                        label: item.Text,
                                        value: item.Text,
                                        id: item.Value
                                    };
                                }))
                            },
                            error: function (XMLHttpRequest, textStatus, errorThrown) {
                            }
                        });
                    },
                    position: {
                        my: 'left top',
                        at: 'right top',
                        collision: 'flip flip',
                        of: $('#AutoRegion' + col1),
                        using: function (obj, info) {
                            if (info.vertical != "top") {
                                $(this).addClass("flipped");
                            } else {
                                $(this).removeClass("flipped");
                            }
                            if (info.horizontal != "left") {
                                $(this).addClass("flipped");
                            } else {
                                $(this).removeClass("flipped");
                            }
                            $(this).css({
                                left: obj.left + 'px',
                                top: obj.top + 'px'
                            });
                        }
                    },
                    select: function (event, ui) {
                        var currentRow = $(this).closest("tr");
                        var col1 = currentRow.find("td:eq(0)").text();
                        $('#AutoRegion' + col1).val(ui.item.value + " ");
                        $('#hdnRegionId' + col1).val(ui.item.value.split("-")[2].trim());
                    },
                    change: function (event, ui) {
                        if (!ui.item) {

                        }
                    },
                    minLength: 1
                });
            });

            $('.AutoRegion').on('autocompleteselect', function (e, ui) {
                var currentRow = $(this).closest("tr");
                var col1 = currentRow.find("td:eq(0)").text();
                $('#AutoRegion' + col1).val(ui.item.value);
            });


            $('.AutoRegion').on('change keyup', function () {
                var currentRow = $(this).closest("tr");
                var col1 = currentRow.find("td:eq(0)").text();
                if ($('#AutoRegion' + col1).val() == "") {
                    ClearClaimRow(col1);
                    $('#hdnRegionId' + col1).val(0);
                }
            });


            $('.AutoRegion').on('blur', function (e, ui) {
                var currentRow = $(this).closest("tr");
                var col1 = currentRow.find("td:eq(0)").text();
                if ($('#AutoRegion' + col1).val().trim() != "") {
                    if ($('#AutoRegion' + col1).val().indexOf('#') == -1) {
                        ModelMsg("Select Proper Region", 3);
                        $('#AutoRegion' + col1).val("");
                        $('#hdnRegionId' + col1).val('0');
                        return;
                    }
                    var txt = $('#AutoRegion' + col1).val().trim();
                    if (txt == "undefined" || txt == "") {
                        //ModelMsg("Enter Item Code Or Name", 3);
                        return false;
                    }
                    var lineNum = 1;
                    $('#tblDiscountExc > tbody > tr').each(function (row, tr) {
                        $(".txtSrNo", this).text(lineNum);
                        lineNum++;
                    });
                    CheckDuplicateDataEmp($('#AutoRegion' + colE1).val().trim(), $('#AutoEmpName' + colE1).val().trim(), $('#AutoDistName' + colE1).val().trim(), $('#AutoSSName' + colE1).val().trim(), colE1, 1, $('#AutoCustGroup' + colE1).val().trim(), $('#AutoCustomer' + colE1).val().trim(), $('#tdFromDateEmp' + colE1).val(), $('#tdToDateEmp' + colE1).val(), $('#txtAutoUniqEmp' + colE1).val());
                }
            });

            ////End Region textbox

            //// Start Employee textBox

            $(document).on('keyup', '.AutoEmpName', function () {
                var textValue = $(this).val();
                var currentRow = $(this).closest("tr");
                var col1 = currentRow.find("td:eq(0)").text();
                $('#AutoEmpName' + col1).autocomplete({
                    source: function (request, response) {
                        var RegionId = $("#AutoRegion" + col1).val() != "" && $("#AutoRegion" + col1).val() != undefined ? $("#AutoRegion" + col1).val().split("-")[2].trim() : "0";
                        $.ajax({
                            type: "POST",
                            url: 'CompanyInvRemark.aspx/SearchEmployee',
                            dataType: "json",
                            data: "{ 'prefixText': '" + (textValue != '' ? textValue : '*') + "','strRegionId':'" + RegionId + "'}",
                            contentType: "application/json; charset=utf-8",
                            success: function (result) {
                                if (result.d == "") {
                                    return false;
                                }
                                else if (result.d[0].indexOf("ERROR=") >= 0) {
                                    var ErrorMsg = result.d[0].split('=')[1].trim();
                                    ModelMsg(ErrorMsg, 3);
                                    return false;
                                }
                                else {
                                    response(result.d[0]);
                                }
                            },
                            error: function (XMLHttpRequest, textStatus, errorThrown) {
                            }
                        });
                    },
                    position: {
                        my: 'left top',
                        at: 'right top',
                        collision: 'flip flip',
                        of: $('#AutoEmpName' + col1),
                        using: function (obj, info) {
                            if (info.vertical != "top") {
                                $(this).addClass("flipped");
                            } else {
                                $(this).removeClass("flipped");
                            }
                            if (info.horizontal != "left") {
                                $(this).addClass("flipped");
                            } else {
                                $(this).removeClass("flipped");
                            }
                            $(this).css({
                                left: obj.left + 'px',
                                top: obj.top + 'px'
                            });
                        }
                    },
                    select: function (event, ui) {
                        var currentRow = $(this).closest("tr");
                        var col1 = currentRow.find("td:eq(0)").text();
                        $('#AutoEmpName' + col1).val(ui.item.value + " ");
                        $('#hdnEmpId' + col1).val(ui.item.value.split("#")[2].trim());
                    },
                    change: function (event, ui) {
                        if (!ui.item) {

                        }
                    },
                    minLength: 1
                });
            });

            $('.AutoEmpName').on('autocompleteselect', function (e, ui) {
                var currentRow = $(this).closest("tr");
                var col1 = currentRow.find("td:eq(0)").text();
                $('#AutoEmpName' + col1).val(ui.item.value);
            });


            $('.AutoEmpName').on('change keyup', function () {
                var currentRow = $(this).closest("tr");
                var col1 = currentRow.find("td:eq(0)").text();
                if ($('#AutoEmpName' + col1).val() == "") {
                    ClearClaimRow(col1);
                    $('#hdnEmpId' + col1).val(0);
                }
            });


            $('.AutoEmpName').on('blur', function (e, ui) {
                var currentRow = $(this).closest("tr");
                var col1 = currentRow.find("td:eq(0)").text();
                if ($('#AutoEmpName' + col1).val().trim() != "") {
                    if ($('#AutoEmpName' + col1).val().indexOf('#') == -1) {
                        ModelMsg("Select Proper Employee Name", 3);
                        $('#AutoEmpName' + col1).val("");
                        $('#hdnEmpId' + col1).val('0');
                        return;
                    }
                    var txt = $('#AutoEmpName' + col1).val().trim();
                    if (txt == "undefined" || txt == "") {
                        //ModelMsg("Enter Item Code Or Name", 3);
                        return false;
                    }
                    var lineNum = 1;
                    $('#tblDiscountExc > tbody > tr').each(function (row, tr) {
                        $(".txtSrNo", this).text(lineNum);
                        lineNum++;
                    });
                    CheckDuplicateDataEmp($('#AutoRegion' + colE1).val().trim(), $('#AutoEmpName' + colE1).val().trim(), $('#AutoDistName' + colE1).val().trim(), $('#AutoSSName' + colE1).val().trim(), colE1, 2, $('#AutoCustGroup' + colE1).val().trim(), $('#AutoCustomer' + colE1).val().trim(), $('#tdFromDateEmp' + colE1).val(), $('#tdToDateEmp' + colE1).val(), $('#txtAutoUniqEmp' + colE1).val());
                }
            });

            ////End Employee textbox


            //// Start Distributor textBox

            $(document).on('keyup', '.AutoDistName', function () {
                var textValue = $(this).val();
                var currentRow = $(this).closest("tr");
                var col1 = currentRow.find("td:eq(0)").text();
                $('#AutoDistName' + col1).autocomplete({
                    source: function (request, response) {
                        var EmpId = $("#AutoEmpName" + col1).val() != "" && $("#AutoEmpName" + col1).val() != undefined ? $("#AutoEmpName" + col1).val().split("#")[2].trim() : "0";
                        var RegionId = $("#AutoRegion" + col1).val() != "" && $("#AutoRegion" + col1).val() != undefined ? $("#AutoRegion" + col1).val().split("-")[2].trim() : "0";
                        var SSID = $("#AutoSSName" + col1).val() != "" && $("#AutoSSName" + col1).val() != undefined ? $("#AutoSSName" + col1).val().split("-")[2].trim() : "0";

                        $.ajax({
                            type: "POST",
                            url: 'CompanyInvRemark.aspx/SearchDistributor',
                            dataType: "json",
                            data: "{ 'prefixText': '" + (textValue != '' ? textValue : '*') + "','strEmpId':'" + EmpId + "','strRegionId':'" + RegionId + "','strSSID':'" + SSID + "'}",
                            contentType: "application/json; charset=utf-8",
                            success: function (data) {
                                response($.map(data.d, function (item) {
                                    return {
                                        label: item.Text,
                                        value: item.Text,
                                        id: item.Value
                                    };
                                }))
                            },
                            error: function (XMLHttpRequest, textStatus, errorThrown) {
                            }
                        });
                    },
                    position: {
                        my: 'left top',
                        at: 'right top',
                        collision: 'flip flip',
                        of: $('#AutoDistName' + col1),
                        using: function (obj, info) {
                            if (info.vertical != "top") {
                                $(this).addClass("flipped");
                            } else {
                                $(this).removeClass("flipped");
                            }
                            if (info.horizontal != "left") {
                                $(this).addClass("flipped");
                            } else {
                                $(this).removeClass("flipped");
                            }
                            $(this).css({
                                left: obj.left + 'px',
                                top: obj.top + 'px'
                            });
                        }
                    },
                    select: function (event, ui) {
                        var currentRow = $(this).closest("tr");
                        var col1 = currentRow.find("td:eq(0)").text();
                        $('#AutoDistName' + col1).val(ui.item.value + " ");
                        $('#hdnDistId' + col1).val(ui.item.value.split("-")[2].trim());
                    },
                    change: function (event, ui) {
                        if (!ui.item) {

                        }
                    },
                    minLength: 1
                });
            });

            $('.AutoDistName').on('autocompleteselect', function (e, ui) {
                var currentRow = $(this).closest("tr");
                var col1 = currentRow.find("td:eq(0)").text();
                $('#AutoDistName' + col1).val(ui.item.value);
            });


            $('.AutoDistName').on('change keyup', function () {
                var currentRow = $(this).closest("tr");
                var col1 = currentRow.find("td:eq(0)").text();
                if ($('#AutoDistName' + col1).val() == "") {
                    ClearClaimRow(col1);
                    $('#hdnDistId' + col1).val(0);
                }
            });


            $('.AutoDistName').on('blur', function (e, ui) {
                var currentRow = $(this).closest("tr");
                var col1 = currentRow.find("td:eq(0)").text();
                if ($('#AutoDistName' + col1).val().trim() != "") {
                    if ($('#AutoDistName' + col1).val().indexOf('-') == -1) {
                        ModelMsg("Select Proper Distributor Name", 3);
                        $('#AutoDistName' + col1).val("");
                        $('#hdnDistId' + col1).val('0');
                        return;
                    }
                    var txt = $('#AutoDistName' + col1).val().trim();
                    if (txt == "undefined" || txt == "") {
                        //ModelMsg("Enter Item Code Or Name", 3);
                        return false;
                    }
                    var lineNum = 1;
                    $('#tblDiscountExc > tbody > tr').each(function (row, tr) {
                        $(".txtSrNo", this).text(lineNum);
                        lineNum++;
                    });
                    CheckDuplicateDataEmp($('#AutoRegion' + colE1).val().trim(), $('#AutoEmpName' + colE1).val().trim(), $('#AutoDistName' + colE1).val().trim(), $('#AutoSSName' + colE1).val().trim(), colE1, 3, $('#AutoCustGroup' + colE1).val().trim(), $('#AutoCustomer' + colE1).val().trim(), $('#tdFromDateEmp' + colE1).val(), $('#tdToDateEmp' + colE1).val(), $('#txtAutoUniqEmp' + colE1).val());
                }
            });

            ////End Distributor textbox


            //// Start SuperStockiest textBox

            $(document).on('keyup', '.AutoSSName', function () {
                var textValue = $(this).val();
                var currentRow = $(this).closest("tr");
                var col1 = currentRow.find("td:eq(0)").text();
                $('#AutoSSName' + col1).autocomplete({
                    source: function (request, response) {
                        var EmpId = $("#AutoEmpName" + col1).val() != "" && $("#AutoEmpName" + col1).val() != undefined ? $("#AutoEmpName" + col1).val().split("#")[2].trim() : "0";
                        var RegionId = $("#AutoRegion" + col1).val() != "" && $("#AutoRegion" + col1).val() != undefined ? $("#AutoRegion" + col1).val().split("-")[2].trim() : "0";
                        $.ajax({
                            type: "POST",
                            url: 'CompanyInvRemark.aspx/SearchSuperStockiest',
                            dataType: "json",
                            data: "{ 'prefixText': '" + (textValue != '' ? textValue : '*') + "','strEmpId':'" + EmpId + "','strRegionId':'" + RegionId + "'}",
                            contentType: "application/json; charset=utf-8",
                            success: function (data) {
                                response($.map(data.d, function (item) {
                                    return {
                                        label: item.Text,
                                        value: item.Text,
                                        id: item.Value
                                    };
                                }))
                            },
                            error: function (XMLHttpRequest, textStatus, errorThrown) {
                            }
                        });
                    },
                    position: {
                        my: 'left top',
                        at: 'right top',
                        collision: 'flip flip',
                        of: $('#AutoSSName' + col1),
                        using: function (obj, info) {
                            if (info.vertical != "top") {
                                $(this).addClass("flipped");
                            } else {
                                $(this).removeClass("flipped");
                            }
                            if (info.horizontal != "left") {
                                $(this).addClass("flipped");
                            } else {
                                $(this).removeClass("flipped");
                            }
                            $(this).css({
                                left: obj.left + 'px',
                                top: obj.top + 'px'
                            });
                        }
                    },
                    select: function (event, ui) {
                        var currentRow = $(this).closest("tr");
                        var col1 = currentRow.find("td:eq(0)").text();
                        $('#AutoSSName' + col1).val(ui.item.value + " ");
                        $('#hdnSSId' + col1).val(ui.item.value.split("-")[2].trim());
                    },
                    change: function (event, ui) {
                        if (!ui.item) {

                        }
                    },
                    minLength: 1
                });
            });

            $('.AutoSSName').on('autocompleteselect', function (e, ui) {
                var currentRow = $(this).closest("tr");
                var col1 = currentRow.find("td:eq(0)").text();
                $('#AutoSSName' + col1).val(ui.item.value);
            });


            $('.AutoSSName').on('change keyup', function () {
                var currentRow = $(this).closest("tr");
                var col1 = currentRow.find("td:eq(0)").text();
                if ($('#AutoSSName' + col1).val() == "") {
                    ClearClaimRow(col1);
                    $('#hdnSSId' + col1).val(0);
                }
            });


            $('.AutoSSName').on('blur', function (e, ui) {
                var currentRow = $(this).closest("tr");
                var col1 = currentRow.find("td:eq(0)").text();
                if ($('#AutoSSName' + col1).val().trim() != "") {
                    if ($('#AutoSSName' + col1).val().indexOf('-') == -1) {
                        ModelMsg("Select Proper Super Stockist Name", 3);
                        $('#AutoSSName' + col1).val("");
                        $('#hdnSSId' + col1).val('0');
                        return;
                    }
                    var txt = $('#AutoSSName' + col1).val().trim();
                    if (txt == "undefined" || txt == "") {
                        //ModelMsg("Enter Item Code Or Name", 3);
                        return false;
                    }
                    var lineNum = 1;
                    $('#tblDiscountExc > tbody > tr').each(function (row, tr) {
                        $(".txtSrNo", this).text(lineNum);
                        lineNum++;
                    });
                    CheckDuplicateDataEmp($('#AutoRegion' + colE1).val().trim(), $('#AutoEmpName' + colE1).val().trim(), $('#AutoDistName' + colE1).val().trim(), $('#AutoSSName' + colE1).val().trim(), colE1, 4, $('#AutoCustGroup' + colE1).val().trim(), $('#AutoCustomer' + colE1).val().trim(), $('#tdFromDateEmp' + colE1).val(), $('#tdToDateEmp' + colE1).val(), $('#txtAutoUniqEmp' + colE1).val());
                }
            });

            ////End SuperStockiest textbox


            //// Start CustomerGroup textBox

            $(document).on('keyup', '.AutoCustGroup', function () {
                var textValue = $(this).val();
                var currentRow = $(this).closest("tr");
                var col1 = currentRow.find("td:eq(0)").text();
                $('#AutoCustGroup' + col1).autocomplete({
                    source: function (request, response) {
                        $.ajax({
                            type: "POST",
                            url: 'CompanyInvRemark.aspx/SearchCustomerGroup',
                            dataType: "json",
                            data: "{ 'prefixText': '" + (textValue != '' ? textValue : '*') + "'}",
                            contentType: "application/json; charset=utf-8",
                            success: function (data) {
                                response($.map(data.d, function (item) {
                                    return {
                                        label: item.Text,
                                        value: item.Text,
                                        id: item.Value
                                    };
                                }))
                            },
                            error: function (XMLHttpRequest, textStatus, errorThrown) {
                            }
                        });
                    },
                    position: {
                        my: 'left top',
                        at: 'right top',
                        collision: 'flip flip',
                        of: $('#AutoCustGroup' + col1),
                        using: function (obj, info) {
                            if (info.vertical != "top") {
                                $(this).addClass("flipped");
                            } else {
                                $(this).removeClass("flipped");
                            }
                            if (info.horizontal != "left") {
                                $(this).addClass("flipped");
                            } else {
                                $(this).removeClass("flipped");
                            }
                            $(this).css({
                                left: obj.left + 'px',
                                top: obj.top + 'px'
                            });
                        }
                    },
                    select: function (event, ui) {
                        var currentRow = $(this).closest("tr");
                        var col1 = currentRow.find("td:eq(0)").text();
                        $('#AutoCustGroup' + col1).val(ui.item.value + " ");
                        $('#hdnCustGroupId' + col1).val(ui.item.value.split("#")[2].trim());
                    },
                    change: function (event, ui) {
                        if (!ui.item) {

                        }
                    },
                    minLength: 1
                });
            });

            $('.AutoCustGroup').on('autocompleteselect', function (e, ui) {
                var currentRow = $(this).closest("tr");
                var col1 = currentRow.find("td:eq(0)").text();
                $('#AutoCustGroup' + col1).val(ui.item.value);
            });


            $('.AutoCustGroup').on('change keyup', function () {
                var currentRow = $(this).closest("tr");
                var col1 = currentRow.find("td:eq(0)").text();
                if ($('#AutoCustGroup' + col1).val() == "") {
                    ClearClaimRow(col1);
                    $('#hdnCustGroupId' + col1).val(0);
                }
            });


            $('.AutoCustGroup').on('blur', function (e, ui) {
                var currentRow = $(this).closest("tr");
                var col1 = currentRow.find("td:eq(0)").text();
                if ($('#AutoCustGroup' + col1).val().trim() != "") {
                    if ($('#AutoCustGroup' + col1).val().indexOf('#') == -1) {
                        ModelMsg("Select Proper Customer Group", 3);
                        $('#AutoCustGroup' + col1).val("");
                        $('#hdnCustGroupId' + col1).val('0');
                        return;
                    }
                    var txt = $('#AutoCustGroup' + col1).val().trim();
                    if (txt == "undefined" || txt == "") {
                        //ModelMsg("Enter Item Code Or Name", 3);
                        return false;
                    }
                    var lineNum = 1;
                    $('#tblDiscountExc > tbody > tr').each(function (row, tr) {
                        $(".txtSrNo", this).text(lineNum);
                        lineNum++;
                    });
                    CheckDuplicateDataEmp($('#AutoRegion' + colE1).val().trim(), $('#AutoEmpName' + colE1).val().trim(), $('#AutoDistName' + colE1).val().trim(), $('#AutoSSName' + colE1).val().trim(), colE1, 5, $('#AutoCustGroup' + colE1).val().trim(), $('#AutoCustomer' + colE1).val().trim(), $('#tdFromDateEmp' + colE1).val(), $('#tdToDateEmp' + colE1).val(), $('#txtAutoUniqEmp' + colE1).val());
                }
            });

            ////End CustomerGroup textbox

            //// Start Customer textBox

            $(document).on('keyup', '.AutoCustomer', function () {
                var textValue = $(this).val();
                var currentRow = $(this).closest("tr");
                var col1 = currentRow.find("td:eq(0)").text();
                $('#AutoCustomer' + col1).autocomplete({
                    source: function (request, response) {
                        var EmpId = $("#AutoEmpName" + col1).val() != "" && $("#AutoEmpName" + col1).val() != undefined ? $("#AutoEmpName" + col1).val().split("#")[2].trim() : "0";
                        var RegionId = $("#AutoRegion" + col1).val() != "" && $("#AutoRegion" + col1).val() != undefined ? $("#AutoRegion" + col1).val().split("-")[2].trim() : "0";
                        var DistId = $("#AutoDistName" + col1).val() != "" && $("#AutoDistName" + col1).val() != undefined ? $("#AutoDistName" + col1).val().split("-")[2].trim() : "0";

                        $.ajax({
                            type: "POST",
                            url: 'CompanyInvRemark.aspx/SearchCustomerData',
                            dataType: "json",
                            data: "{ 'prefixText': '" + (textValue != '' ? textValue : '*') + "','strEmpId':'" + EmpId + "','strRegionId':'" + RegionId + "','strDistId':'" + DistId + "'}",
                            contentType: "application/json; charset=utf-8",
                            success: function (data) {
                                response($.map(data.d, function (item) {
                                    return {
                                        label: item.Text,
                                        value: item.Text,
                                        id: item.Value
                                    };
                                }))
                            },
                            error: function (XMLHttpRequest, textStatus, errorThrown) {
                            }
                        });
                    },
                    position: {
                        my: 'left top',
                        at: 'right top',
                        collision: 'flip flip',
                        of: $('#AutoCustomer' + col1),
                        using: function (obj, info) {
                            if (info.vertical != "top") {
                                $(this).addClass("flipped");
                            } else {
                                $(this).removeClass("flipped");
                            }
                            if (info.horizontal != "left") {
                                $(this).addClass("flipped");
                            } else {
                                $(this).removeClass("flipped");
                            }
                            $(this).css({
                                left: obj.left + 'px',
                                top: obj.top + 'px'
                            });
                        }
                    },
                    select: function (event, ui) {
                        var currentRow = $(this).closest("tr");
                        var col1 = currentRow.find("td:eq(0)").text();
                        $('#AutoCustomer' + col1).val(ui.item.value + " ");
                        $('#hdnCustomerId' + col1).val(ui.item.value.split("-")[2].trim());
                    },
                    change: function (event, ui) {
                        if (!ui.item) {

                        }
                    },
                    minLength: 1
                });
            });

            $('.AutoCustomer').on('autocompleteselect', function (e, ui) {
                var currentRow = $(this).closest("tr");
                var col1 = currentRow.find("td:eq(0)").text();
                $('#AutoCustomer' + col1).val(ui.item.value);
            });


            $('.AutoCustomer').on('change keyup', function () {
                var currentRow = $(this).closest("tr");
                var col1 = currentRow.find("td:eq(0)").text();
                if ($('#AutoCustomer' + col1).val() == "") {
                    ClearClaimRow(col1);
                    $('#hdnCustomerId' + col1).val(0);
                }
            });


            $('.AutoCustomer').on('blur', function (e, ui) {
                var currentRow = $(this).closest("tr");
                var col1 = currentRow.find("td:eq(0)").text();
                if ($('#AutoCustomer' + col1).val().trim() != "") {
                    if ($('#AutoCustomer' + col1).val().indexOf('-') == -1) {
                        ModelMsg("Select Proper Customer", 3);
                        $('#AutoCustomer' + col1).val("");
                        $('#hdnCustomerId' + col1).val('0');
                        return;
                    }
                    var txt = $('#AutoCustomer' + col1).val().trim();
                    if (txt == "undefined" || txt == "") {
                        //ModelMsg("Enter Item Code Or Name", 3);
                        return false;
                    }
                    var lineNum = 1;
                    $('#tblDiscountExc > tbody > tr').each(function (row, tr) {
                        $(".txtSrNo", this).text(lineNum);
                        lineNum++;
                    });
                    CheckDuplicateDataEmp($('#AutoRegion' + colE1).val().trim(), $('#AutoEmpName' + colE1).val().trim(), $('#AutoDistName' + colE1).val().trim(), $('#AutoSSName' + colE1).val().trim(), colE1, 6, $('#AutoCustGroup' + colE1).val().trim(), $('#AutoCustomer' + colE1).val().trim(), $('#tdFromDateEmp' + colE1).val(), $('#tdToDateEmp' + colE1).val(), $('#txtAutoUniqEmp' + colE1).val());
                }
            });

            ////End Customer textbox

            // Start Employee Group


            //End Employee Group

            // End Employee Tab
            //   ShowDistOrSS(); -- 14-Mar-23
            //


            //

            ToDataURL(LogoURL, function (dataUrl) {
                imagebase64 = dataUrl;
            })
            //FillData();
            var clicked = false;
            $(document).on('click', '.btnEdit', function () {

                var checkBoxes = $(this).closest('tr').find('.chkEdit');
                if (checkBoxes.prop("checked") == true) {
                    checkBoxes.prop("checked", false);
                    $(this).closest('tr').find('.search,.checkbox,.days').prop('disabled', false);
                    $(this).val('Update');
                } else {
                    checkBoxes.prop("checked", true);
                    $(this).closest('tr').find('.search,.checkbox,.days').prop('disabled', true);
                    $(this).val('Edit');
                }
            });

            var clickedEmp = false;
            $(document).on('click', '.btnEditEmp', function () {

                var checkBoxes = $(this).closest('tr').find('.chkEditEmp');
                if (checkBoxes.prop("checked") == true) {
                    checkBoxes.prop("checked", false);
                    $(this).closest('tr').find('.search,.checkbox').prop('disabled', false);
                    $(this).val('Update');
                } else {
                    checkBoxes.prop("checked", true);
                    $(this).closest('tr').find('.search,.checkbox').prop('disabled', true);
                    $(this).val('Edit');
                }
            });

        });

        function ToDataURL(url, callback) {
            var xhr = new XMLHttpRequest();
            xhr.onload = function () {
                var reader = new FileReader();
                reader.onloadend = function () {
                    callback(reader.result);
                }
                reader.readAsDataURL(xhr.response);
            };
            xhr.open('GET', url);
            xhr.responseType = 'blob';
            xhr.send();
        }
        //function ShowDistOrSSOnChange() {

        //    var option = $(".ddlOption").val();


        //    if (option == 2) {
        //        $('#CountRowClaim').val(0);
        //        //    console.log(644);
        //        //--  LoadAutoCompleteData(1);
        //        FillData();
        //        //$('#tblDiscountExc').find('th:nth-child(6)').hide();
        //        $('.thSS').hide();
        //        $('.tdSS').hide();
        //        $('.tdSTOD').hide();
        //        $('.thSTOD').hide();
        //        $('.thCustomer').show();
        //        $('.tdCustomer').show();
        //        $('.tdMRP').hide();
        //        $('.thMRP').hide();
        //        $('.tdEmpGroup').hide();
        //        $('.thEmpGroup').hide();
        //        $('.thMaster').show();
        //        $('.tdMaster').show();
        //        $('.thQPS').show();
        //        $('.tdQPS').show();
        //        $('.thMachine').show();
        //        $('.tdMachine').show();
        //        $('.thParlour').show();
        //        $('.tdParlour').show();

        //        // Below Checkbox Temp Hide.
        //        $('.thFOW').hide();
        //        $('.tdFOW').hide();
        //        $('.thSecFright').hide();
        //        $('.tdSecFrieght').hide();
        //        $('.thVRS').hide();
        //        $('.tdVRS').hide();
        //        $('.thRateDiff').hide();
        //        $('.tdRateDiff').hide();
        //        $('.thIOU').hide();
        //        $('.tdIOU').hide();
        //        //$('#tblDiscountExc').find('th:nth-child(8)').show();
        //        //$('.tdCustomer').show();
        //        ClearClaimRowEmp();

        //    }
        //    else if (option == 4) {
        //        //    console.log(456);
        //        //--    LoadAutoCompleteData(2);
        //        $('#CountRowClaim').val(0);
        //        FillData();
        //        //$('#tblDiscountExc').find('th:nth-child(6)').show();
        //        $('.thSS').show();
        //        $('.tdSS').show();
        //        $('.thSTOD').show();
        //        $('.tdSTOD').show();
        //        $('.thCustomer').hide();
        //        $('.tdCustomer').hide();
        //        $('.tdEmpGroup').hide();
        //        $('.thEmpGroup').hide();
        //        $('.thMaster').show();
        //        $('.tdMaster').show();
        //        $('.thQPS').hide();
        //        $('.tdQPS').hide();
        //        $('.thMachine').hide();
        //        $('.tdMRP').hide();
        //        $('.thMRP').hide();
        //        $('.tdMachine').hide();
        //        $('.thParlour').hide();
        //        $('.tdParlour').hide();
        //        $('.thFOW').hide();
        //        $('.tdFOW').hide();
        //        $('.thSecFright').hide();
        //        $('.tdSecFrieght').hide();
        //        $('.thVRS').hide();
        //        $('.tdVRS').hide();
        //        $('.thRateDiff').hide();
        //        $('.tdRateDiff').hide();
        //        $('.thIOU').hide();
        //        $('.tdIOU').hide();
        //        //$('#tblDiscountExc').find('th:nth-child(9)').hide();
        //        //$('.tdCustomer').hide();
        //        //ClearClaimRowEmp();

        //    }
        //    else if (option == 5) {
        //        $('#CountRowClaim').val(0);
        //        //    console.log(644);
        //        //--  LoadAutoCompleteData(1);
        //        FillData();
        //        //$('#tblDiscountExc').find('th:nth-child(6)').hide();
        //        $('.thSS').hide();
        //        $('.tdSS').hide();
        //        $('.tdSTOD').hide();
        //        $('.thSTOD').hide();
        //        $('.thCustomer').show();
        //        $('.tdCustomer').show();
        //        $('.tdEmpGroup').show();
        //        $('.thEmpGroup').show();
        //        $('.tdMRP').show();
        //        $('.thMRP').show();
        //        $('.thMaster').hide();
        //        $('.tdMaster').hide();
        //        $('.thQPS').hide();
        //        $('.tdQPS').hide();
        //        $('.thMachine').hide();
        //        $('.tdMachine').hide();
        //        $('.thParlour').hide();
        //        $('.tdParlour').hide();

        //        // Below Checkbox Temp Hide.
        //        $('.thFOW').hide();
        //        $('.tdFOW').hide();
        //        $('.thSecFright').hide();
        //        $('.tdSecFrieght').hide();
        //        $('.thVRS').hide();
        //        $('.tdVRS').hide();
        //        $('.thRateDiff').hide();
        //        $('.tdRateDiff').hide();
        //        $('.thIOU').hide();
        //        $('.tdIOU').hide();

        //        ClearClaimRowEmp();
        //    }
        //    else if (option == 6) {
        //        $('#CountRowClaim').val(0);
        //        //    console.log(644);
        //        //--  LoadAutoCompleteData(1);
        //        FillData();
        //        //$('#tblDiscountExc').find('th:nth-child(6)').hide();
        //        $('.thSS').hide();
        //        $('.tdSS').hide();
        //        $('.tdSTOD').hide();
        //        $('.thSTOD').hide();
        //        $('.thCustomer').show();
        //        $('.tdCustomer').show();
        //        $('.tdEmpGroup').show();
        //        $('.thEmpGroup').show();
        //        $('.thMaster').hide();
        //        $('.tdMaster').hide();
        //        $('.thQPS').hide();
        //        $('.tdQPS').hide();
        //        $('.thMachine').hide();
        //        $('.tdMachine').hide();
        //        $('.thParlour').hide();
        //        $('.tdParlour').hide();
        //        $('.tdMRP').hide();
        //        $('.thMRP').hide();
        //        // Below Checkbox Temp Hide.
        //        $('.thFOW').hide();
        //        $('.tdFOW').hide();
        //        $('.thSecFright').hide();
        //        $('.tdSecFrieght').hide();
        //        $('.thVRS').hide();
        //        $('.tdVRS').hide();
        //        $('.thRateDiff').hide();
        //        $('.tdRateDiff').hide();
        //        $('.thIOU').hide();
        //        $('.tdIOU').hide();

        //        ClearClaimRowEmp();
        //    }
        //    ClearControls();
        //    $('#hdnDeleteIDs').val('');
        //    $('#hdnIsRowDeleted').val("0");

        //}
        //function ShowDistOrSS() {

        //    var option = $(".ddlOption").val();
        //    if (option == 2) {
        //        // $('#tblDiscountExc').find('th:nth-child(6)').hide();
        //        $('.thSS').hide();
        //        $('.tdSS').hide();
        //        $('.tdSTOD').hide();
        //        $('.thSTOD').hide();
        //        $('.tdEmpGroup').hide();
        //        $('.thEmpGroup').hide();
        //        $('.tdMaster').show();
        //        $('.thMaster').show();
        //        $('.tdMRP').hide();
        //        $('.thMRP').hide();
        //        //  ClearClaimRow();
        //        //  ClearClaimRowEmp();
        //        $('.thQPS').show();
        //        $('.tdQPS').show();
        //        $('.thMachine').show();
        //        $('.tdMachine').show();
        //        $('.thParlour').show();
        //        $('.tdParlour').show();
        //        $('.thFOW').hide();
        //        $('.tdFOW').hide();
        //        $('.thSecFright').hide();
        //        $('.tdSecFrieght').hide();
        //        $('.thVRS').hide();
        //        $('.tdVRS').hide();
        //        $('.thRateDiff').hide();
        //        $('.tdRateDiff').hide();
        //        $('.thIOU').hide();
        //        $('.tdIOU').hide();


        //        $('.thCustomer').show();
        //        $('.tdCustomer').show();
        //        //$('#tblDiscountExc').find('th:nth-child(8)').show();
        //        //$('.tdCustomer').show();
        //    }
        //    else if (option == 4) {
        //        // $('#tblDiscountExc').find('th:nth-child(6)').show();
        //        $('.thSS').show();
        //        $('.tdSS').show();
        //        $('.thSTOD').show();
        //        $('.tdSTOD').show();
        //        // ClearClaimRow();
        //        // ClearClaimRowEmp();
        //        $('.tdMRP').hide();
        //        $('.thMRP').hide();
        //        $('.thCustomer').hide();
        //        $('.tdCustomer').hide();
        //        $('.tdEmpGroup').hide();
        //        $('.thEmpGroup').hide();
        //        $('.tdMaster').show();
        //        $('.thMaster').show();

        //        $('.thQPS').hide();
        //        $('.tdQPS').hide();
        //        $('.thMachine').hide();
        //        $('.tdMachine').hide();
        //        $('.thParlour').hide();
        //        $('.tdParlour').hide();
        //        $('.thFOW').hide();
        //        $('.tdFOW').hide();
        //        $('.thSecFright').hide();
        //        $('.tdSecFrieght').hide();
        //        $('.thVRS').hide();
        //        $('.tdVRS').hide();
        //        $('.thRateDiff').hide();
        //        $('.tdRateDiff').hide();
        //        $('.thIOU').hide();
        //        $('.tdIOU').hide();
        //        //$('#tblDiscountExc').find('th:nth-child(9)').hide();
        //        //$('.tdCustomer').hide();

        //    }
        //    else if (option == 5) {
        //        // $('#tblDiscountExc').find('th:nth-child(6)').hide();
        //        $('.thSS').hide();
        //        $('.tdSS').hide();
        //        $('.tdSTOD').hide();
        //        $('.thSTOD').hide();
        //        //  ClearClaimRow();
        //        //  ClearClaimRowEmp();
        //        $('.thQPS').hide();
        //        $('.tdQPS').hide();
        //        $('.thMachine').hide();
        //        $('.tdMachine').hide();
        //        $('.thParlour').hide();
        //        $('.tdParlour').hide();
        //        $('.thFOW').hide();
        //        $('.tdFOW').hide();
        //        $('.thSecFright').hide();
        //        $('.tdSecFrieght').hide();
        //        $('.thVRS').hide();
        //        $('.tdVRS').hide();
        //        $('.thRateDiff').hide();
        //        $('.tdRateDiff').hide();
        //        $('.thIOU').hide();
        //        $('.tdIOU').hide();
        //        $('.tdMaster').hide();
        //        $('.thMaster').hide();
        //        $('.thEmpGroup').show();
        //        $('.tdEmpGroup').show();
        //        $('.thCustomer').show();
        //        $('.tdCustomer').show();
        //        $('.tdMRP').show();
        //        $('.thMRP').show();
        //        //$('#tblDiscountExc').find('th:nth-child(8)').show();
        //        //$('.tdCustomer').show();
        //    }
        //    else if (option == 6) {
        //        // $('#tblDiscountExc').find('th:nth-child(6)').hide();
        //        $('.thSS').hide();
        //        $('.tdSS').hide();
        //        $('.tdSTOD').hide();
        //        $('.thSTOD').hide();
        //        //  ClearClaimRow();
        //        //  ClearClaimRowEmp();
        //        $('.thQPS').hide();
        //        $('.tdQPS').hide();
        //        $('.thMachine').hide();
        //        $('.tdMachine').hide();
        //        $('.thParlour').hide();
        //        $('.tdParlour').hide();
        //        $('.tdMRP').hide();
        //        $('.thMRP').hide();
        //        $('.thFOW').hide();
        //        $('.tdFOW').hide();
        //        $('.thSecFright').hide();
        //        $('.tdSecFrieght').hide();
        //        $('.thVRS').hide();
        //        $('.tdVRS').hide();
        //        $('.thRateDiff').hide();
        //        $('.tdRateDiff').hide();
        //        $('.thIOU').hide();
        //        $('.tdIOU').hide();
        //        $('.tdMaster').hide();
        //        $('.thMaster').hide();
        //        $('.thEmpGroup').show();
        //        $('.tdEmpGroup').show();
        //        $('.thCustomer').show();
        //        $('.tdCustomer').show();
        //        //$('#tblDiscountExc').find('th:nth-child(8)').show();
        //        //$('.tdCustomer').show();
        //    }
        //}

        //function isNumber(evt) {
        //    evt = (evt) ? evt : window.event;
        //    var charCode = (evt.which) ? evt.which : evt.keyCode;
        //    if (charCode > 31 && (charCode < 48 || charCode > 57)) {
        //        return false;
        //    }

        //    return true;
        //}
        function isNumber(evt) {
            evt = (evt) ? evt : window.event;
            var charCode = (evt.which) ? evt.which : evt.keyCode;
            if (charCode > 31 && charCode != 46 && (charCode < 48 || charCode > 57) || charCode == 190) {
                return false;
            }

            return true;
        }
        function AddMoreRow() {

            $('table#tblDiscountExc tr#NoROW').remove();  // Remove NO ROW
            /// Add Dynamic Row to the existing Table
            var indI = $('#CountRowClaim').val();
            //   console.log(45);
            //  console.log(indI);
            //if (indI == 1)
            //    indI = 0;
            indI = parseInt(indI) + 1;
             
            $('#CountRowClaim').val(indI);

            var str = "";
            str = "<tr id='trClaim" + indI + "'>"
                + "<td class='txtSrNo' id='txtSrNo" + indI + "'>" + indI + "</td>"
                + "<td><input type='checkbox' id='chkEdit" + indI + "' class='chkEdit' checked/>"
                + "<input type='button' class='btnEdit btnEditDelete' id='btnEdit" + indI + "' name='btnEdit' value = 'Edit' /></td>"
                + "<td><input type='button' class='btnDelete btnEditDelete' id='btnDelete" + indI + "' name='btnDelete' value = 'Delete' onclick='RemoveClaimLockingRow(" + indI + ");' /></td>"
                + "<td class='tdUniqNo'><input type='text' id='txtAutoUniq" + indI + "' name='txtAutoUniq' onchange='ChangeData(this);' class='form-control search txtAutoUniq' /></td>"
                + "<td><input type='text' id='txtRemark1" + indI + "' name='txtRemark1' onchange='ChangeDataEmp(this);' class='form-control search txtRemark1' MaxLength='100' /></td>"
                + "<td><input type='text' id='txtRemark2" + indI + "' name='txtRemark2' onchange='ChangeDataEmp(this);' class='form-control search txtRemark2' MaxLength='100' /></td>"
                + "<td><input type='text' id='txtRemark3" + indI + "' name='txtRemark3' onchange='ChangeDataEmp(this);' class='form-control search txtRemark3' MaxLength='100' /></td>"

                + "<td ><input  type='text' id='tdFromDate" + indI + "'name='tdFromDate' onchange='ChangeData(this);' class='form-control startdate search dtbodyCenter' onpaste='return true;'/></td>"
                + "<td><input  type='text' id='tdToDate" + indI + "'name='tdToDate' onchange='ChangeData(this);' class='form-control enddate search dtbodyCenter' onpaste='return true;'/></td>"

                + "<td><input type='checkbox' id='chkIsActive" + indI + "' name='chkIsActive' onchange='ChangeData(this);'  class='checkbox'/></td>"
                // + "<td id='tdUniqueNo" + ind + "' class='tdUniqueNo'></td>"
                //+ "<td id='tdCreatedBy" + indI + "' class='tdCreatedBy'></td>"
                //+ "<td id='tdCreatedDate" + indI + "' class='tdCreatedDate'></td>"
                + "<td id='tdUpdateBy" + indI + "' class='tdUpdateBy'></td>"
                + "<td id='tdUpdateDate" + indI + "' class='tdUpdateDate'></td>"
                + "<input type='hidden' class='hdnItmGroupId' id='hdnItmGroupId" + indI + "' name='hdnItmGroupId'/></td>"
                + "<input type='hidden' class='hdnDiscountExcId' id='hdnDiscountExcId" + indI + "' name='hdnDiscountExcId'/></td>"
                + "<input type='hidden' class='IsChange' id='IsChange" + indI + "' name='IsChange' value='0' /></td>"
                + "<input type='hidden' class='hdnLineNum' id='hdnLineNum" + indI + "' name='hdnLineNum' value='" + indI + "' /></tr>";

            $('#tblDiscountExc > tbody').append(str);
            //  ShowDistOrSS();
            $('.chkEdit').hide();
            $('.chkEdit').prop("checked", true);


            $('.startdate').datepicker({
                numberOfMonths: 1,
                dateFormat: 'dd/mm/yy',
                changeMonth: true,
                changeYear: true,
                minDate: new Date(2014, 1, 1)
            });

            $('.enddate').datepicker({
                numberOfMonths: 1,
                dateFormat: 'dd/mm/yy',
                changeMonth: true,
                changeYear: true,
                minDate: new Date(2014, 1, 1)
            });


            // $('.dataTables_scrollBody').animate({ scrollTop: $('.dataTables_scrollBody').prop("scrollHeight") }, 0);
            var table = document.getElementById("tblDiscountExc");

            // Start Auto Uniq no

            $('#txtAutoUniq' + indI).keyup(function () {
                var textValue = $(this).val();
                var currentRow = $(this).closest("tr");
                var col1 = currentRow.find("td:eq(0)").text();
                $('#txtAutoUniq' + col1).autocomplete({
                    source: function (request, response) {
                        $.ajax({
                            type: "POST",
                            url: 'CompanyInvRemark.aspx/SearchGroupRefNo',
                            dataType: "json",
                            data: "{ 'prefixText': '" + (textValue != '' ? textValue : '*') + "'}",
                            contentType: "application/json; charset=utf-8",
                            success: function (data) {
                                response($.map(data.d, function (item) {
                                    return {
                                        label: item.Text,
                                        value: item.Text,
                                        id: item.Value
                                    };
                                }))
                            },
                            error: function (XMLHttpRequest, textStatus, errorThrown) {
                            }
                        });
                    },
                    //position: { collision: "flip" },
                    select: function (event, ui) {
                        var currentRow = $(this).closest("tr");
                        var col1 = currentRow.find("td:eq(0)").text();
                        $('#txtAutoUniq' + col1).val(ui.item.value + " ");
                        $('#hdnItmGroupId' + col1).val(ui.item.value.split("#")[1].trim());
                        //$('#AutoProdGrp' + ind).val("");
                        //$('#AutoProdSubGrp' + ind).val("");
                        //$('#AutoItemCode' + ind).val("");

                        $('#tdFromDate' + col1).text('');
                        $('#tdToDate' + col1).text('');
                        $('#chkIsActive' + col1).prop('checked', false);
                        $('#chkIsActive' + col1).attr("disabled", false);
                    },
                    change: function (event, ui) {
                        if (!ui.item) {

                        }
                    },
                    minLength: 1
                });
            });


            $('#txtAutoUniq' + indI).autocomplete({
                source: JsonUniqNo,
                position: { collision: "flip" },
                select: function (event, ui) {
                    var currentRowE = $(this).closest("tr");
                    var col1 = currentRowE.find("td:eq(0)").text();
                    $('#txtAutoUniq' + col1).val(ui.item.value + " ");
                    $('#hdnItmGroupId' + col1).val(ui.item.value.split("#")[1].trim());
                    //$('#AutoProdGrp' + indI).val("");
                    //$('#AutoProdSubGrp' + indI).val("");
                    //$('#AutoItemCode' + indI).val("");

                    $('#tdFromDate' + col1).text('');
                    $('#tdToDate' + col1).text('');
                    $('#chkIsActive' + col1).prop('checked', false);
                    $('#chkIsActive' + col1).attr("disabled", false);
                },
                change: function (event, ui) {
                    if (!ui.item) {

                    }
                },

                minLength: 1
            });

            $('#txtAutoUniq' + indI).on('autocompleteselect', function (e, ui) {
                var currentRowE = $(this).closest("tr");
                var col1 = currentRowE.find("td:eq(0)").text();
                $('#txtAutoUniq' + col1).val(ui.item.value);
                //GetCustomerDetailsByCode(ui.item.value, indI);
            });

            $('#txtAutoUniq' + indI).on('change keyup', function () {
                var currentRowE = $(this).closest("tr");
                var col1 = currentRowE.find("td:eq(0)").text();
                if ($('#txtAutoUniq' + col1).val() == "") {
                    ClearClaimRow(col1);
                    $('#hdnItmGroupId' + col1).val(0);

                }
            });

            $('#txtAutoUniq' + indI).on('blur', function (e, ui) {
                var currentRowE = $(this).closest("tr");
                var col1 = currentRowE.find("td:eq(0)").text();
                if ($('#txtAutoUniq' + col1).val().trim() != "") {
                    if ($('#txtAutoUniq' + col1).val().indexOf('#') == -1) {
                        ModelMsg("Select Proper Group or Ref", 3);
                        $('#txtAutoUniq' + col1).val("");
                        $('#hdnItmGroupId' + col1).val('0');
                        return;
                    }
                    var txt = $('#txtAutoUniq' + col1).val().trim();

                    if (txt == "undefined" || txt == "") {
                        //ModelMsg("Enter Item Code Or Name", 3);
                        return false;
                    }
                    var lineNum = 1;
                    $('#tblDiscountExc > tbody > tr').each(function (row, tr) {
                        $(".txtSrNo", this).text(lineNum);
                        lineNum++;
                    });
                    //  CheckDuplicateData(indI, 7, $('#AutoDivision' + indI).val().trim(), $('#AutoProdGrp' + indI).val().trim(), $('#AutoProdSubGrp' + indI).val().trim(), $('#AutoItemCode' + indI).val().trim(), $('#tdFromDate' + indI).val(), $('#tdToDate' + indI).val(), $('#txtAutoUniq' + indI).val());
                }
            });

        }
        function AddMoreRowEmp() {

            $('table#tblEmpDiscount tr#NoROW').remove();  // Remove NO ROW
            /// Add Dynamic Row to the existing Table
            var indE = $('#CountRowEmp').val();

            indE = parseInt(indE) + 1;
            $('#CountRowEmp').val(indE);

            var strEmp = "";
            strEmp = "<tr id='trClaimEmp" + indE + "'>"
                + "<td class='txtSrNo' id='txtSrNo" + indE + "'>" + indE + "</td>"
                + "<td><input type='checkbox' id='chkEditEmp" + indE + "' class='chkEditEmp' checked/>"
                + "<input type='button' class='btnEditEmp btnEditDeleteEmp' id='btnEdit" + indE + "' name='btnEditEmp' value = 'Edit' /></td>"
                + "<td><input type='button' class='btnDelete btnEditDelete' id='btnDelete" + indE + "' name='btnDelete' value = 'Delete' onclick='RemoveClaimLockingRowEmp(" + indE + ");' /></td>"
                + "<td class='tdUniqNo'><input type='text' id='txtAutoUniqEmp" + indE + "' name='txtAutoUniqEmp' onchange='ChangeDataEmp(this);' class='form-control search txtAutoUniqEmp' /></td>"
                + "<td><input type='text' id='AutoEmpName" + indE + "' name='AutoEmpName' onchange='ChangeDataEmp(this);' class='form-control search AutoEmpName' /></td>"
                + "<td class='tdRegion'><input type='text' id='AutoRegion" + indE + "' name='AutoRegion' onchange='ChangeDataEmp(this);' class='form-control search AutoRegion' /></td>"
                /*+ "<td class='tdSS'><input type='text' id='AutoSSName" + indE + "' name='AutoSSName' onchange='ChangeDataEmp(this);' class='form-control search SS AutoSSName' /></td>"*/
                + "<td class='tdDist'><input type='text' id='AutoDistName" + indE + "' name='AutoDistName' onchange='ChangeDataEmp(this);' class='form-control search Dist AutoDistName' /></td>"
                + "<td class='tdCustGroup'><input type='text' id='AutoCustGroup" + indE + "' name='AutoCustGroup' onchange='ChangeDataEmp(this);' class='form-control search AutoCustGroup' /></td>"
                + "<td class='tdCustomer'><input type='text' id='AutoCustomer" + indE + "' name='AutoCustomer' onchange='ChangeDataEmp(this);' class='form-control search AutoCustomer' /></td>"
                + "<td ><input  type='text' id='tdFromDateEmp" + indE + "'name='tdFromDateEmp' onchange='ChangeDataEmp(this);' class='form-control startdateEmp search dtbodyCenter' onpaste='return true;'/></td>"
                + "<td><input  type='text' id='tdToDateEmp" + indE + "'name='tdToDateEmp' onchange='ChangeDataEmp(this);' class='form-control enddateEmp search dtbodyCenter' onpaste='return true;'/></td>"
                + "<td><input type='checkbox' id='chkInclude" + indE + "' name='chkInclude' onchange='ChangeDataEmp(this);'  class='checkbox'/></td>"
                + "<td><input type='checkbox' id='chkIsActiveEmp" + indE + "' name='chkIsActiveEmp' onchange='ChangeDataEmp(this);'  class='checkbox'/></td>"
                // + "<td id='tdUniqueNo" + indE + "' class='tdUniqueNo'></td>"
                //+ "<td id='tdCreatedByEmp" + indE + "' class='tdCreatedBy'></td>"
                //+ "<td id='tdCreatedDateEmp" + indE + "' class='tdCreatedDate'></td>"
                + "<td id='tdUpdateByEmp" + indE + "' class='tdUpdateBy'></td>"
                + "<td id='tdUpdateDateEmp" + indE + "' class='tdUpdateDate'></td>"
                + "<input type='hidden' class='hdnEmpGroupId' id='hdnEmpGroupId" + indE + "' name='hdnEmpGroupId'/>"
                + "<input type='hidden' class='hdnEmployeeGroupId' id='hdnEmployeeGroupId" + indE + "' name='hdnEmployeeGroupId'/>"
                + "<input type='hidden' class='hdnDiscountExcIdEmp' id='hdnDiscountExcIdEmp" + indE + "' name='hdnDiscountExcIdEmp'/>"
                + "<input type='hidden' class='hdnRegionId' id='hdnRegionId" + indE + "' name='hdnRegionId'  />"
                + "<input type='hidden' class='hdnEmpId' id='hdnEmpId" + indE + "' name='hdnEmpId'  />"
                + "<input type='hidden' class='hdnDistId' id='hdnDistId" + indE + "' name='hdnDistId'  /></td>"
                /* + "<input type='hidden' class='hdnSSId' id='hdnSSId" + indE + "' name='hdnSSId'  /></td>"*/
                + "<input type='hidden' class='hdnCustGroupId' id='hdnCustGroupId" + indE + "' name='hdnCustGroupId'  /></td>"
                + "<input type='hidden' class='hdnCustomerId' id='hdnCustomerId" + indE + "' name='hdnCustomerId'  /></td>"
                + "<input type='hidden' class='IsChangeEmp' id='IsChangeEmp" + indE + "' name='IsChangeEmp' value='0' /></td>"
                + "<input type='hidden' class='hdnLineNumEmp' id='hdnLineNumEmp" + indE + "' name='hdnLineNumEmp' value='" + indE + "' /></tr>";

            $('#tblEmpDiscount > tbody').append(strEmp);
            // ShowDistOrSS();
            $('.chkEditEmp').hide();
            $('.chkEditEmp').prop("checked", true);


            $('.startdateEmp').datepicker({
                numberOfMonths: 1,
                dateFormat: 'dd/mm/yy',
                changeMonth: true,
                changeYear: true,
                minDate: new Date(2014, 1, 1)
            });

            $('.enddateEmp').datepicker({
                numberOfMonths: 1,
                dateFormat: 'dd/mm/yy',
                changeMonth: true,
                changeYear: true,
                minDate: new Date(2014, 1, 1)
            });
            //  $('.dataTables_scrollBody').animate({ scrollTop: $('.dataTables_scrollBody').prop("scrollHeight") }, 0);
            var table = document.getElementById("tblEmpDiscount");
        }
        function CheckDuplicateData(row, ChkType, pDivision, pProdGrp, pProdSubGrp, pItemCode, pFromDate, pToDate, pRefNo) {
            var ItmDivision = "0", ItmProdGrp = "0", ItmProdSubGrp = "0", ItmCode = "", ItmfromDate = "", ItmToDate = "";
            if (pDivision != "") {
                ItmDivision = pDivision.split("#")[2].trim();
            }
            if (pProdGrp != "") {
                ItmProdGrp = pProdGrp.split("#")[1].trim();
            }
            if (pProdSubGrp != "") {
                ItmProdSubGrp = pProdSubGrp.split("#")[1].trim();
            }
            if (pItemCode != "") {
                ItmCode = pItemCode.split("#")[0].trim();
            }
            if (pFromDate != "") {
                ItmfromDate = pFromDate.trim();
            }
            if (pToDate != "") {
                ItmToDate = pToDate.trim();
            }
            var rowCnt_Claim = 1;
            var cnt = 0;
            var errRow = 0;
            $('#tblDiscountExc  > tbody > tr').each(function (row1, tr) {

                var LineNum = $("input[name='hdnLineNum']", this).val();
                var DivId = $("input[name='hdnDivisionId']", this).val() == "" ? 0 : $("input[name='hdnDivisionId']", this).val();
                var PGrpId = $("input[name='hdnProdGrpId']", this).val() == "" ? 0 : $("input[name='hdnProdGrpId']", this).val();
                var PSubGrpId = $("input[name='hdnProdSubGrpId']", this).val() == "" ? 0 : $("input[name='hdnProdSubGrpId']", this).val();
                var ItemCode = $("input[name='hdnItemCode']", this).val() == "" ? 0 : $("input[name='hdnItemCode']", this).val();
                var RefNO = $("input[name='txtAutoUniq']", this).val();
                var FromDate = $("input[name='tdFromDate']", this).val();
                var ToDate = $("input[name='tdToDate']", this).val();
                if (parseInt(row) != parseInt(LineNum)) {
                    if (ItmDivision == DivId && ItmProdGrp == PGrpId
                        && ItmProdSubGrp == PSubGrpId && ItmCode == ItemCode && FromDate == pFromDate && ToDate == pToDate
                    ) {
                        cnt = 1;
                        errRow = row;
                        //$('#AutoRegion' + ind).val("");
                        //$('#hdnRegionId' + ind).val(0);
                        //$('#chkIsActive' + row).prop('checked', false);
                        //$('#chkIsActive' + row).attr("disabled", false);
                        errormsg = 'Data is already set for at row : ' + rowCnt_Claim;
                        return false;
                    }
                }
                if (ChkType == 7) {
                    if (DivId != "") {
                        if (parseInt(row) != parseInt(LineNum)) {
                            if (pDivision.split("#")[2].trim() == DivId && RefNO == pRefNo && pFromDate == FromDate && pToDate == ToDate) {
                                cnt = 1;
                                errRow = row;
                                $('#AutoDivision' + row).val('');
                                $('#hdnDivisionId' + row).val(0);
                                errormsg = 'Division is already set for = ' + pDivision + ' at row : ' + rowCnt_Claim;
                                return false;
                            }
                        }
                    }
                }
                else if (ChkType == 8) {
                    if (PGrpId != "") {
                        if (parseInt(row) != parseInt(LineNum)) {
                            if (pProdGrp.split("#")[1].trim() == PGrpId && RefNO == pRefNo && pFromDate == FromDate && pToDate == ToDate) {
                                cnt = 1;
                                errRow = row;
                                $('#AutoProdGrp' + row).val('');
                                $('#hdnProdGrpId' + row).val(0);
                                errormsg = 'Product Group is already set for = ' + pProdGrp + ' at row : ' + rowCnt_Claim;
                                return false;
                            }
                        }
                    }
                }
                else if (ChkType == 9) {
                    if (PSubGrpId != "") {
                        if (parseInt(row) != parseInt(LineNum)) {
                            if (pProdSubGrp.split("#")[1].trim() == PSubGrpId && RefNO == pRefNo && pFromDate == FromDate && pToDate == ToDate) {
                                cnt = 1;
                                errRow = row;
                                $('#AutoProdSubGrp' + row).val('');
                                $('#hdnProdSubGrpId' + row).val(0);
                                errormsg = 'Product Sub Group is already set for = ' + pProdSubGrp + ' at row : ' + rowCnt_Claim;
                                return false;
                            }
                        }
                    }
                }
                else if (ChkType == 10) {
                    if (pItemCode != "") {
                        if (parseInt(row) != parseInt(LineNum)) {
                            if (pItemCode.split("#")[0].trim() == ItemCode && RefNO == pRefNo && pFromDate == FromDate && pToDate == ToDate) {
                                cnt = 1;
                                errRow = row;
                                $('#AutoItemCode' + row).val('');
                                $('#hdnItemCode' + row).val(0);
                                errormsg = 'Item is already set for = ' + pItemCode + ' at row : ' + rowCnt_Claim;
                                return false;
                            }
                        }
                    }
                }
                rowCnt_Claim++;
                //}
            });

            if (cnt == 1) {
                //$('#AutoCustCode' + row).val('');

                if (ChkType == 7) {
                    $('#AutoDivision' + row).val('');
                    $('#hdnDivisionId' + row).val(0);
                }
                else if (ChkType == 8) {
                    $('#AutoProdGrp' + row).val('');
                    $('#hdnProdGrpId' + row).val(0);
                }
                else if (ChkType == 9) {
                    $('#AutoProdSubGrp' + row).val('');
                    $('#hdnProdSubGrpId' + row).val(0);
                }
                else {
                    $('#AutoItemCode' + row).val('');
                    $('#hdnItemCode' + row).val(0);
                }
                ClearClaimRow(row);
                ModelMsg(errormsg, 3);
                return false;
            }

            var ind = $('#CountRowClaim').val();
            if (ind == row) {
                AddMoreRow();
            }
        }
        function CheckDuplicateDataEmp(pRegioCode, pEmpCode, pDistCode, pSSCode, row3, ChkType, pCustGroup, pCustomer, pFromDate, pToDate, pRefNo) {
            var EmpRegion = "", EmpEmpCode = "", EmpDistCode = "", EmpSSCode = "", EmpCustGroup = "", EmpCust = "0", EmpFromDate = "", EmpToDate = "";

            if (pRegioCode != "") {
                EmpRegion = pRegioCode.split("-")[2].trim();
            }
            if (pEmpCode != "") {
                EmpEmpCode = pEmpCode.split("#")[2].trim();
            }

            if (pDistCode != "") {
                EmpDistCode = pDistCode.split("-")[2].trim();
            }
            if (pSSCode != "") {
                EmpSSCode = pSSCode.split("-")[2].trim();
            }
            if (pCustGroup != "") {
                EmpCustGroup = pCustGroup.split("#")[2].trim();
            }
            if (pCustomer != "") {
                EmpCust = pCustomer.split("-")[2].trim();
            }
            if (pFromDate != "") {
                EmpFromDate = pFromDate;
            }
            if (pToDate != "") {
                EmpToDate = pToDate;
            }


            var rowCnt_Claim = 1;
            var cnt = 0;
            var errRow = 0;
            $('#tblEmpDiscount  > tbody > tr').each(function (row2, tr) {

                var RegionCode = $("input[name='AutoRegion']", this).val() != "" ? $("input[name='AutoRegion']", this).val().split("-")[2].trim() : "";
                var EmpCode = $("input[name='AutoEmpName']", this).val() != "" ? $("input[name='AutoEmpName']", this).val().split("#")[2].trim() : "";
                var DistCode = $("input[name='AutoDistName']", this).val() != "" ? $("input[name='AutoDistName']", this).val().split("-")[2].trim() : "";
                var SSCode = $("input[name='AutoSSName']", this).val() != "" ? $("input[name='AutoSSName']", this).val().split("-")[2].trim() : "";
                var RefNo = $("input[name='txtAutoUniqEmp']", this).val();
                var CustGroup = $("input[name='AutoCustGroup']", this).val() != "" ? $("input[name='AutoCustGroup']", this).val().split("#")[2].trim() : "";
                var Customer = $("input[name='AutoCustomer']", this).val() != "" ? $("input[name='AutoCustomer']", this).val().split("-")[2].trim() : "";
                var LineNum = $("input[name='hdnLineNumEmp']", this).val();
                var RgnId = $("input[name='hdnRegionId']", this).val();
                var EmpId = $("input[name='hdnEmpId']", this).val();
                var DistId = $("input[name='hdnDistId']", this).val();
                var SSId = $("input[name='hdnSSId']", this).val();
                var CustGrpId = $("input[name='hdnCustGroupId']", this).val();
                var CustId = $("input[name='hdnCustomerId']", this).val();
                var FromDate = $("input[name='tdFromDateEmp']", this).val();
                var ToDate = $("input[name='tdToDateEmp']", this).val();
                if (parseInt(row3) != parseInt(LineNum)) {
                    if (EmpRegion == RegionCode && EmpEmpCode == EmpCode && EmpDistCode == DistCode && EmpSSCode == SSCode
                        && EmpCustGroup == CustGroup && EmpCust == CustId && EmpFromDate == FromDate && EmpToDate == ToDate && RefNo == pRefNo) {
                        cnt = 1;
                        errRow = row3;
                        $('#AutoRegion' + row3).val("");
                        $('#hdnRegionId' + row3).val(0);
                        $('#chkIsActiveEmp' + row3).prop('checked', false);
                        $('#chkIsActiveEmp' + row3).attr("disabled", false);
                        errormsg = 'Data is already set for at row : ' + rowCnt_Claim;
                        return false;
                    }
                }

                if (ChkType == 1) {
                    if (RgnId != "") {
                        if (parseInt(row3) != parseInt(LineNum)) {
                            if (Item == RegionCode && RefNo == pRefNo && FromDate == EmpFromDate && ToDate == EmpToDate) {
                                cnt = 1;
                                errRow = row3;
                                $('#AutoRegion' + row3).val("");
                                $('#hdnRegionId' + row3).val(0);
                                $('#chkIsActiveEmp' + row3).prop('checked', false);
                                $('#chkIsActiveEmp' + row3).attr("disabled", false);
                                errormsg = 'Region is already set for = ' + pRegioCode + ' at row : ' + rowCnt_Claim;
                                return false;
                            }
                        }
                    }
                }
                else if (ChkType == 2) {

                    if (EmpCode != "") {
                        if (parseInt(row3) != parseInt(LineNum)) {
                            if (pEmpCode.split("#")[2].trim() == EmpCode && RefNo == pRefNo && FromDate == EmpFromDate && ToDate == EmpToDate) {
                                cnt = 1;
                                errRow = row3;
                                $('#AutoEmpName' + row3).val('');
                                $('#hdnEmpId' + ind).val(0);
                                errormsg = 'Employee is already set for = ' + pEmpCode + ' at row : ' + rowCnt_Claim;
                                return false;
                            }
                        }
                    }
                }
                else if (ChkType == 3) {
                    if (DistId != "") {
                        if (parseInt(row3) != parseInt(LineNum)) {
                            if (pDistCode.split("-")[2].trim() == DistCode && RefNo == pRefNo && FromDate == EmpFromDate && ToDate == EmpToDate) {
                                cnt = 1;
                                errRow = row3;
                                $('#AutoDistName' + row3).val('');
                                errormsg = 'Distributor is already set = ' + pDistCode + ' at row : ' + rowCnt_Claim;
                                return false;
                            }
                        }
                    }
                }
                else if (ChkType == 4) {
                    if (SSId != "") {
                        if (parseInt(row3) != parseInt(LineNum)) {
                            if (pSSCode.split("-")[2].trim() == SSCode && RefNo == pRefNo && FromDate == EmpFromDate && ToDate == EmpToDate) {
                                cnt = 1;
                                errRow = row3;
                                $('#AutoSSName' + row3).val('');
                                errormsg = 'Super Stockist is already set for = ' + pSSCode + ' at row : ' + rowCnt_Claim;
                                return false;
                            }
                        }
                    }
                }
                else if (ChkType == 5) {
                    if (CustGroup != "") {
                        if (parseInt(row3) != parseInt(LineNum)) {
                            if (pCustGroup.split("#")[2].trim() == CustGroup && RefNo == pRefNo && FromDate == EmpFromDate && ToDate == EmpToDate) {
                                cnt = 1;
                                errRow = row3;
                                $('#AutoCustGroup' + row3).val('');
                                errormsg = 'Customer Group is already set for = ' + pCustGroup + ' at row : ' + rowCnt_Claim;
                                return false;
                            }
                        }
                    }
                }
                else if (ChkType == 6) {
                    if (CustId != "") {
                        if (parseInt(row3) != parseInt(LineNum)) {
                            if (pCustomer.split("-")[2].trim() == CustId && RefNo == pRefNo && FromDate == EmpFromDate && ToDate == EmpToDate) {
                                cnt = 1;
                                errRow = row3;
                                $('#AutoCustomer' + row3).val('');
                                errormsg = 'Customer is already set for = ' + pCustomer + ' at row : ' + rowCnt_Claim;
                                return false;
                            }
                        }
                    }
                }
                rowCnt_Claim++;
                //}
            });

            if (cnt == 1) {
                //$('#AutoCustCode' + row).val('');
                if (ChkType == 1) {
                    $('#AutoRegion' + row3).val("");
                }
                else if (ChkType == 2) {
                    $('#AutoEmpName' + row3).val('');
                }
                else if (ChkType == 3) {
                    $('#AutoDistName' + row3).val('');
                }
                else if (ChkType == 4) {
                    $('#AutoSSName' + row3).val('');
                }
                else if (ChkType == 5) {
                    $('#AutoCustGroup' + row3).val('');
                }
                else if (ChkType == 6) {
                    $('#AutoCustomer' + row3).val('');
                }
                ClearClaimRowEmp(row3);
                ModelMsg(errormsg, 3);
                return false;
            }

            var indE = $('#CountRowEmp').val();
            if (indE == row3) {
                AddMoreRowEmp();
            }
        }

        function ClearClaimRow(row) {
            var rowCnt_Claim = 1;
            var cnt = 0;
            $('#tblDiscountExc > tbody > tr').each(function (row1, tr) {
                // post table's data to Submit form using Json Format

                var RegionCode = $("input[name='AutoRegion']", this).val();
                if (RegionCode == "") {
                    //$(this).remove();
                }
                cnt++;
                rowCnt_Claim++;
            });

            if (cnt > 1) {
                var rowCnt_Claim = 1;
                $('#tblDiscountExc > tbody > tr').each(function (row1, tr) {
                    // post table's data to Submit form using Json Format                    
                    if (cnt != rowCnt_Claim) {
                        var DiscountExcId = $("input[name='hdnDiscountExcId']", this).val();
                        var RefNo = $("input[name='txtAutoUniq']", this).val();
                        var txtRemark1 = $("input[name='txtRemark1']", this).val();
                        var txtRemark2 = $("input[name='txtRemark2']", this).val();
                        var txtRemark3 = $("input[name='txtRemark3']", this).val();
                        if (RefNo == "" && txtRemark1 == "" && txtRemark2 == "" && txtRemark3 == "") {
                            $(this).remove();
                        }
                    }
                    rowCnt_Claim++;
                });
            }
            var lineNum = 1;
            $('#tblDiscountExc > tbody > tr').each(function (row, tr) {
                $(".txtSrNo", this).text(lineNum);
                lineNum++;
            });
        }
        function ClearClaimRowEmp(row3) {
            var rowCnt_Claim = 1;
            var cnt = 0;
            $('#tblEmpDiscount > tbody > tr').each(function (row4, tr) {
                // post table's data to Submit form using Json Format

                var RegionCode = $("input[name='AutoRegion']", this).val();
                if (RegionCode == "") {
                    //$(this).remove();
                }
                cnt++;
                rowCnt_Claim++;
            });

            if (cnt > 1) {
                var rowCnt_Claim = 1;
                $('#tblEmpDiscount > tbody > tr').each(function (row4, tr) {
                    // post table's data to Submit form using Json Format                    
                    if (cnt != rowCnt_Claim) {
                        var DiscountExcId = $("input[name='hdnDiscountExcIdEmp']", this).val();
                        var RegionName = $("input[name='AutoRegion']", this).val();
                        var EmpName = $("input[name='AutoEmpName']", this).val();
                        var DistName = $("input[name='AutoDistName']", this).val();
                        var SSName = $("input[name='AutoSSName']", this).val();

                        var CustGroup = $("input[name='AutoCustGroup']", this).val();
                        var Customer = $("input[name='AutoCustomer']", this).val();
                        var RefNo = $("input[name='txtAutoUniqEmp']", this).val();
                        //var ProdGroup = $("input[name='AutoProdGrp']", this).val();
                        //var ProdSubGroup = $("input[name='AutoProdSubGrp']", this).val();
                        //var ItemCode = $("input[name='AutoItemCode']", this).val();

                        if (RegionName == "" && EmpName == "" && DistName == "" && SSName == "" && CustGroup == "" && Customer == "" && RefNo == "") {  //&& Divsion == "" && ProdGroup == "" && ProdSubGroup == "" && ItemCode == ""
                            $(this).remove();
                        }
                    }
                    rowCnt_Claim++;
                });
            }
            var lineNum = 1;
            $('#tblEmpDiscount > tbody > tr').each(function (row2, tr) {
                $(".txtSrNo", this).text(lineNum);
                lineNum++;
            });
        }
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
            //$('#tblDiscountExc  > tbody > tr').each(function (row1, tr) {
            //    // post table's data to Submit form using Json Format
            //    $(this).remove();
            //});
            $('#tblDiscountExc  > tbody').empty();
            var IsValid = true;
            $.ajax({
                url: 'CompanyInvRemark.aspx/LoadItemData',
                type: 'POST',
                dataType: 'json',
                contentType: 'application/json; charset=utf-8',
                //data: JSON.stringify({ OptionId: $('.ddlOption').val(), DiscountType: $('.ddlDiscountType').val() }),
                data: JSON.stringify({ OptionId: $('.ddlOption').val() }),
                "bSort": false,
                "bSortClasses": false,
                "bDeferRender": true,
                success: function (result) {
                    $.unblockUI();
                    // $("#tblDiscountExc").DataTable().ajax.reload();

                    if (result.d == '') {

                        //ClearAll();
                        $.unblockUI();
                        event.preventDefault();
                        //ClearControls();
                        AddMoreRow();
                        return false;
                    }
                    else if (result.d[0].indexOf("ERROR#") >= 0) {
                        $.unblockUI();
                        var ErrorMsg = result.d[0].split('#')[1].trim();
                        ModelMsg(ErrorMsg, 3);

                        event.preventDefault();

                        return false;
                    }
                    else {


                        //var items =result.d;//result.d[0];

                        var items = JSON.parse(result.d)

                        // console.log(items);

                        if (items.length > 0) {
                            //$('#tblDiscountExc  > tbody > tr').each(function (row1, tr) {
                            //    // post table's data to Submit form using Json Format
                            //    $(this).remove();
                            //});
                            $('#tblDiscountExc  > tbody').empty();
                            var trHTML = '';
                            var row = 1;
                            $('#CountRowClaim').val(0);
                            //var t = $('#tblDiscountExc').dataTable();
                            var ind = $('#CountRowClaim').val();
                            $('#CountRowClaim').val(ind);
                            var ind = 0;
                            var length = 0;
                            var itm = this;
                            for (var i = 0; i < items.length; i++) {
                                row = $('#CountRowClaim').val();
                                //  $('#chkEdit' + row).click();
                                //   $('#chkEdit' + row).prop("checked", false);
                                $('table#tblDiscountExc tr#NoROW').remove();  // Remove NO ROW
                                var ind = $('#CountRowClaim').val();
                                ind = parseInt(ind) + 1;
                                $('#CountRowClaim').val(ind);
                                // var cells = new Array();
                                var str = "";
                                str = "<tr id='trClaim" + ind + "'>"
                                    + "<td class='txtSrNo' id='txtSrNo" + ind + "'>" + ind + "</td>"
                                    + "<td><input type='checkbox' id='chkEdit" + ind + "' class='chkEdit' checked='false'/>"
                                    + "<input type='button' class='btnEdit btnEditDelete' id='btnEdit" + ind + "' name='btnEdit' value = 'Edit' /></td>"
                                    + "<td><input type='button' class='btnDelete btnEditDelete' id='btnDelete" + ind + "' name='btnDelete' value = 'Delete' onclick='RemoveClaimLockingRow(" + ind + ");' /></td>"
                                    + "<td class='tdUniqNo'><input type='text' id='txtAutoUniq" + ind + "' name='txtAutoUniq' onchange='ChangeData(this);' class='form-control search txtAutoUniq' value='" + items[i].RefNo + "' disabled='false'/></td>"
                                    + "<td class='tdDivision'><input type='text' id='txtRemark1" + ind + "' name='txtRemark1' onchange='ChangeData(this);' class='form-control search txtRemark1' value='" + items[i].Remarks1 + "' disabled='false' MaxLength='100' /></td>"
                                    + "<td class='tdProdGroup'><input type='text' id='txtRemark2" + ind + "' name='txtRemark2' onchange='ChangeData(this);' class='form-control search txtRemark2'  value='" + items[i].Remarks2 + "' disabled='false'  MaxLength='100'/></td>"
                                    + "<td><input type='text' id='txtRemark3" + ind + "' name='txtRemark3' onchange='ChangeData(this);' class='form-control search txtRemark3'  value='" + items[i].Remarks3 + "' disabled='false' MaxLength='100'/></td>"
                                    + "<td ><input readonly type='text' id='tdFromDate" + ind + "'name='tdFromDate' onchange='ChangeData(this);' class='form-control startdate search dtbodyCenter' onpaste='return false;'  value='" + items[i].FromDate + "'/></td>"
                                    + "<td><input readonly type='text' id='tdToDate" + ind + "'name='tdToDate' onchange='ChangeData(this);' class='form-control enddate search dtbodyCenter' onpaste='return false;'  value='" + items[i].ToDate + "'/></td>"

                                    + "<td><input type='checkbox' id='chkIsActive" + ind + "' name='chkIsActive' onchange='ChangeData(this);'  class='checkbox' disabled='false'/></td>"
                                    // + "<td id='tdUniqueNo" + ind + "' class='tdUniqueNo'></td>"
                                    //+ "<td id='tdCreatedBy" + ind + "' class='tdCreatedBy CustName'>" + items[i].CreatedBy + "</td>"
                                    //+ "<td id='tdCreatedDate" + ind + "' class='tdCreatedDate'>" + items[i].CreatedDate + "</td>"
                                    + "<td id='tdUpdateBy" + ind + "' class='tdUpdateBy CustName'>" + items[i].UpdatedBy + "</td>"
                                    + "<td id='tdUpdateDate" + ind + "' class='tdUpdateDate'>" + items[i].UpdatedDate + "</td>"
                                    + "<input type='hidden' class='hdnItmGroupId' id='hdnItmGroupId" + ind + "' name='hdnItmGroupId' value='" + items[i].RefId + "'/></td>"
                                    + "<input type='hidden' class='hdnDiscountExcId' id='hdnDiscountExcId" + ind + "' name='hdnDiscountExcId'  value='" + items[i].DiscountExcId + "' /></td>"
                                    + "<input type='hidden' class='IsChange' id='IsChange" + ind + "' name='IsChange' value='0' /></td>"
                                    + "<input type='hidden' class='hdnLineNum' id='hdnLineNum" + ind + "' name='hdnLineNum' value='" + ind + "' /></tr>";

                                $('#tblDiscountExc > tbody').append(str);
                                //  var ai = t.fnAddData(str, false);
                                $('#trClaim' + ind).find('#chkIsActive' + ind).prop("checked", items[i].Active);

                                //  $('#tblDiscountExc').DataTable();
                                //    ShowDistOrSS();
                                $('.chkEdit').hide();
                                //$('.chkEdit').prop("checked", false);

                                //  $('.dataTables_scrollBody').animate({ scrollTop: $('.dataTables_scrollBody').prop("scrollHeight") }, 0);

                                $('.startdate').datepicker({
                                    numberOfMonths: 1,
                                    dateFormat: 'dd/mm/yy',
                                    changeMonth: true,
                                    changeYear: true,
                                    minDate: new Date(2014, 1, 1)
                                });

                                $('.enddate').datepicker({
                                    numberOfMonths: 1,
                                    dateFormat: 'dd/mm/yy',
                                    changeMonth: true,
                                    changeYear: true,
                                    minDate: new Date(2014, 1, 1)
                                });


                                // $('.dataTables_scrollBody').animate({ scrollTop: $('.dataTables_scrollBody').prop("scrollHeight") }, 0);
                                var table = document.getElementById("tblDiscountExc");


                            }
                        }
                        else {
                            $('#tblDiscountExc  > tbody > tr').each(function (row1, tr) {
                                // post table's data to Submit form using Json Format
                                $(this).remove();
                            });
                        }
                    }

                    AddMoreRow();
                },
                scroller: {
                    loadingIndicator: true
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    $.unblockUI();
                    alert('Something is wrong...' + XMLHttpRequest.responseText);
                    event.preventDefault();
                    return false;
                }

            });
        }


        function FillDataEmployee() {
            
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
            //$('#tblEmpDiscount  > tbody > tr').each(function (row2, tr) {
            //    // post table's data to Submit form using Json Format
            //    $(this).remove();
            //});
            $('#tblEmpDiscount  > tbody').empty();
            //  console.log($('.ddlOption').val());
            var IsValid = true;
            $.ajax({
                url: 'CompanyInvRemark.aspx/LoadEmployeeData',
                type: 'POST',
                dataType: 'json',
                contentType: 'application/json; charset=utf-8',
                data: JSON.stringify({ OptionId: $('.ddlOption').val() }),
                "bSort": false,
                "bSortClasses": false,
                "bDeferRender": true,
                success: function (result) {

                    $.unblockUI();

                    if (result.d == '') {
                        //ClearAll();
                        $.unblockUI();
                        event.preventDefault();

                        AddMoreRowEmp();
                        return false;
                    }
                    else if (result.d[0].indexOf("ERROR#") >= 0) {
                        $.unblockUI();
                        var ErrorMsg = result.d[0].split('#')[1].trim();
                        ModelMsg(ErrorMsg, 3);

                        event.preventDefault();

                        return false;
                    }
                    else {

                        //var items =result.d;//result.d[0];

                        var items = JSON.parse(result.d)

                        //  console.log(items);

                        if (items.length > 0) {
                            //$('#tblEmpDiscount  > tbody > tr').each(function (row2, tr) {
                            //    // post table's data to Submit form using Json Format
                            //    $(this).remove();
                            //});
                            $('#tblEmpDiscount  > tbody').empty();
                            var trHTML = '';
                            var row4 = 1;
                            $('#CountRowEmp').val(0);
                            var indE = $('#CountRowEmp').val();
                            //  ind = parseInt(ind) + 1;

                            $('#CountRowEmp').val(indE);
                            var indE = 0;
                            var length = 0;
                            // $('#CountRowEmp').val(0);
                            // $.each(items, function () {

                            var itm = this;
                            for (var i = 0; i < items.length; i++) {
                                //  AddMoreRowEmp();
                                row4 = $('#CountRowEmp').val();
                                //  $('#chkEditEmp' + row4).click();
                                //$('#chkEditEmp' + row4).prop("checked", false);
                                $('table#tblEmpDiscount tr#NoROW').remove();  // Remove NO ROW
                                /// Add Dynamic Row to the existing Table
                                var indE = $('#CountRowEmp').val();

                                indE = parseInt(indE) + 1;
                                $('#CountRowEmp').val(indE);

                                var strEmp = "";
                                strEmp = "<tr id='trClaimEmp" + indE + "'>"
                                    + "<td class='txtSrNo' id='txtSrNo" + indE + "'>" + indE + "</td>"
                                    + "<td><input type='checkbox' id='chkEditEmp" + indE + "' class='chkEditEmp' checked='false'/>"
                                    + "<input type='button' class='btnEditEmp btnEditDeleteEmp' id='btnEdit" + indE + "' name='btnEditEmp' value = 'Edit' /></td>"
                                    + "<td><input type='button' class='btnDelete btnEditDelete' id='btnDelete" + indE + "' name='btnDelete' value = 'Delete' onclick='RemoveClaimLockingRowEmp(" + indE + ");' /></td>"
                                    + "<td class='tdUniqNo'><input type='text' id='txtAutoUniqEmp" + indE + "' name='txtAutoUniqEmp' onchange='ChangeDataEmp(this);' class='form-control search txtAutoUniqEmp' value='" + items[i].RefNo + "'  disabled='false' /></td>"
                                    /*+ "<td class='tdEmpGroup' style='display:none;'><input type='text' id='AutoEmpGroup" + indE + "' name='AutoEmpGroup' onchange='ChangeData(this);' class='form-control search AutoEmpGroup'  value='" + items[i].EmpGroupName + "' disabled='false'/></td>"*/
                                    + "<td><input type='text' id='AutoEmpName" + indE + "' name='AutoEmpName' onchange='ChangeDataEmp(this);' class='form-control search AutoEmpName' value='" + items[i].EmployeeName + "' disabled='false'/></td>"
                                    + "<td class='tdRegion'><input type='text' id='AutoRegion" + indE + "' name='AutoRegion' onchange='ChangeDataEmp(this);' class='form-control search AutoRegion' value='" + items[i].Region + "' disabled='false'/></td>"
                                    /*+ "<td class='tdSS'><input type='text' id='AutoSSName" + indE + "' name='AutoSSName' onchange='ChangeDataEmp(this);' class='form-control search SS AutoSSName'  value='" + items[i].SSName + "' disabled='false'/></td>"*/
                                    + "<td class='tdDist'><input type='text' id='AutoDistName" + indE + "' name='AutoDistName' onchange='ChangeDataEmp(this);' class='form-control search Dist AutoDistName' value='" + items[i].Distributor + "' disabled='false'/></td>"
                                    + "<td class='tdCustGroup'><input type='text' id='AutoCustGroup" + indE + "' name='AutoCustGroup' onchange='ChangeDataEmp(this);' class='form-control search AutoCustGroup' value='" + items[i].CustGroupName + "' disabled='false' /></td>"
                                    + "<td class='tdCustomer'><input type='text' id='AutoCustomer" + indE + "' name='AutoCustomer' onchange='ChangeDataEmp(this);' class='form-control search AutoCustomer' value='" + items[i].CustomerName + "' disabled='false'/></td>"
                                    + "<td ><input readonly type='text' id='tdFromDateEmp" + indE + "'name='tdFromDateEmp' onchange='ChangeDataEmp(this);' class='form-control startdateEmp search dtbodyCenter' onpaste='return false;' value='" + items[i].FromDate + "' /></td>"
                                    + "<td><input readonly type='text' id='tdToDateEmp" + indE + "'name='tdToDateEmp' onchange='ChangeDataEmp(this);' class='form-control enddateEmp search dtbodyCenter' onpaste='return false;' value='" + items[i].ToDate + "' /></td>"
                                    + "<td><input type='checkbox' id='chkInclude" + indE + "' name='chkInclude' onchange='ChangeDataEmp(this);'  class='checkbox' disabled='false'/></td>"
                                    + "<td><input type='checkbox' id='chkIsActiveEmp" + indE + "' name='chkIsActiveEmp' onchange='ChangeDataEmp(this);'  class='checkbox' disabled='false'/></td>"

                                    //+ "<td id='tdCreatedByEmp" + indE + "' class='tdCreatedBy CustName'>" + items[i].CreatedBy + "</td>"
                                    //+ "<td id='tdCreatedDateEmp" + indE + "' class='tdCreatedDate'>" + items[i].CreatedDate + "</td>"
                                    + "<td id='tdUpdateByEmp" + indE + "' class='tdUpdateBy CustName'>" + items[i].UpdatedBy + "</td>"
                                    + "<td id='tdUpdateDateEmp" + indE + "' class='tdUpdateDate'>" + items[i].UpdatedDate + "</td>"
                                    + "<input type='hidden' class='hdnEmpGroupId' id='hdnEmpGroupId" + indE + "' name='hdnEmpGroupId' value='" + items[i].DiscountGroupId + "'/>"
                                    + "<input type='hidden' class='hdnEmployeeGroupId' id='hdnEmployeeGroupId" + indE + "' name='hdnEmployeeGroupId' value='" + items[i].EmpGroupId + "'/>"
                                    + "<input type='hidden' class='hdnDiscountExcIdEmp' id='hdnDiscountExcIdEmp" + indE + "' name='hdnDiscountExcIdEmp' value='" + items[i].DiscountExcId + "'/>"
                                    + "<input type='hidden' class='hdnRegionId' id='hdnRegionId" + indE + "' name='hdnRegionId' value='" + items[i].RegionId + "' />"
                                    + "<input type='hidden' class='hdnEmpId' id='hdnEmpId" + indE + "' name='hdnEmpId' value='" + items[i].EmpId + "' /></td>"
                                    + "<input type='hidden' class='hdnDistId' id='hdnDistId" + indE + "' name='hdnDistId'  value='" + items[i].DistributorId + "'/></td>"
                                    /*+ "<input type='hidden' class='hdnSSId' id='hdnSSId" + indE + "' name='hdnSSId' value='" + items[i].SSID + "' /></td>"*/
                                    + "<input type='hidden' class='hdnCustGroupId' id='hdnCustGroupId" + indE + "' name='hdnCustGroupId' value='" + items[i].CustGroupId + "' /></td>"
                                    + "<input type='hidden' class='hdnCustomerId' id='hdnCustomerId" + indE + "' name='hdnCustomerId' value='" + items[i].CustomerId + "' /></td>"
                                    + "<input type='hidden' class='IsChangeEmp' id='IsChangeEmp" + indE + "' name='IsChangeEmp' value='0' /></td>"
                                    + "<input type='hidden' class='hdnLineNumEmp' id='hdnLineNumEmp" + indE + "' name='hdnLineNumEmp' value='" + indE + "' /></tr>";

                                $('#tblEmpDiscount > tbody').append(strEmp);
                                $('#trClaimEmp' + indE).find('#chkInclude' + indE).prop("checked", items[i].IsInclude);
                                $('#trClaimEmp' + indE).find('#chkIsActiveEmp' + indE).prop("checked", items[i].Active);
                                //ShowDistOrSS();


                                $('.chkEditEmp').hide();
                                //    $('.chkEditEmp').prop("checked", true);
                                //   $('.dataTables_scrollBody').animate({ scrollTop: $('.dataTables_scrollBody').prop("scrollHeight") }, 0);

                                $('.startdateEmp').datepicker({
                                    numberOfMonths: 1,
                                    dateFormat: 'dd/mm/yy',
                                    changeMonth: true,
                                    changeYear: true,
                                    minDate: new Date(2014, 1, 1)
                                });

                                $('.enddateEmp').datepicker({
                                    numberOfMonths: 1,
                                    dateFormat: 'dd/mm/yy',
                                    changeMonth: true,
                                    changeYear: true,
                                    minDate: new Date(2014, 1, 1)
                                });


                                // $('.dataTables_scrollBody').animate({ scrollTop: $('.dataTables_scrollBody').prop("scrollHeight") }, 0);
                                var table = document.getElementById("tblEmpDiscount");


                            }
                        }
                        else {
                            $('#tblEmpDiscount  > tbody > tr').each(function (row2, tr) {
                                // post table's data to Submit form using Json Format
                                $(this).remove();
                            });
                        }
                    }
                    AddMoreRowEmp();
                },
                scroller: {
                    loadingIndicator: true
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    $.unblockUI();
                    alert('Something is wrong...' + XMLHttpRequest.responseText);
                    event.preventDefault();
                    return false;
                }
            });
        }
        function ClearControls() {
            $('.divDiscountEntry').attr('style', 'display:none;');

            $('.divEmpDiscountEntry').attr('style', 'display:none;');

            $('#tabs a[href="#tabs-Item"]').tab('show');
            $('.divMissData').attr('style', 'display:none;');
            $('.btnSubmit').attr('style', 'display:none;');
            $('.btnSearch').attr('style', 'display:none;');
            $('.divViewDetail').attr('style', 'display:none;');
            $('#tblDiscountExc tbody').empty();
            $('#tblEmpDiscount tbody').empty();
            //if ($.fn.DataTable.isDataTable('.gvDiscountHistory')) {
            //    $('.gvDiscountHistory').DataTable().destroy();
            //}


            //$('.gvDiscountHistory tbody').empty();
            if ($('.chkIsReport').find('input').is(':checked')) {
                // $('.divDiscountReport').removeAttr('style');
                $('.btnSearch').removeAttr('style');
                $('.divViewDetail').removeAttr('style');

                //var option = $(".ddlOption").val();

                //if (option == 2) {
                //    $('#CountRowClaim').val(0);
                //    //   FillData();
                //    $('.tdSS').hide();
                //    $('.thss').hide();
                //    $('.tdSTOD').hide();
                //    $('.thSTOD').hide();
                //    $('.tdCustomer').show();
                //    $('.thCustomer').show();

                //    $('.tdMRP').hide();
                //    $('.thMRP').hide();

                //    $('.thMachine').show();
                //    $('.tdMachine').show();
                //    $('.thParlour').show();
                //    $('.tdParlour').show();

                //    $('#CountRowClaim').val(0);


                //    console.log(245)
                //    LoadAutoCompleteData(1);
                //}
                //else if (option == 4) {
                //    // FillDataEmployee();
                //    $('.tdSS').show();
                //    $('.thss').show();
                //    $('.tdCustomer').hide();
                //    $('.thCustomer').hide();
                //    $('.tdSTOD').show();
                //    $('.thSTOD').show();
                //    $('.tdMRP').hide();
                //    $('.thMRP').hide();
                //    $('.thQPS').hide();
                //    $('.tdQPS').hide();
                //    $('.thMachine').hide();
                //    $('.tdMachine').hide();
                //    $('.thParlour').hide();
                //    $('.tdParlour').hide();
                //    $('#CountRowEmp').val(0);
                //    console.log(23423);
                //    LoadAutoCompleteData(2);
                //}
                //else if (option == 5) {
                //    // FillDataEmployee();
                //    $('.tdSS').show();
                //    $('.thss').show();
                //    $('.tdCustomer').hide();
                //    $('.thCustomer').hide();
                //    $('.tdSTOD').show();
                //    $('.thSTOD').show();
                //    $('.tdMRP').show();
                //    $('.thMRP').show();
                //    $('.thQPS').hide();
                //    $('.tdQPS').hide();
                //    $('.thMachine').hide();
                //    $('.tdMachine').hide();
                //    $('.thParlour').hide();
                //    $('.tdParlour').hide();
                //    $('#CountRowEmp').val(0);
                //    console.log(23423);
                //    LoadAutoCompleteData(2);
                //}
                //else if (option == 6) {
                //    // FillDataEmployee();
                //    $('.tdSS').show();
                //    $('.thss').show();
                //    $('.tdCustomer').hide();
                //    $('.thCustomer').hide();
                //    $('.tdSTOD').show();
                //    $('.thSTOD').show();
                //    $('.tdMRP').hide();
                //    $('.thMRP').hide();
                //    $('.thQPS').hide();
                //    $('.tdQPS').hide();
                //    $('.thMachine').hide();
                //    $('.tdMachine').hide();
                //    $('.thParlour').hide();
                //    $('.tdParlour').hide();
                //    $('#CountRowEmp').val(0);
                //    console.log(23423);
                //    LoadAutoCompleteData(2);
                //}
            }
            else {
                $('.divDiscountEntry').removeAttr('style');
                $('.divEmpDiscountEntry').removeAttr('style');
                $('.btnSubmit').removeAttr('style');
                //  $('.chkIsHistory').find('input').not(':checked');
                $('.chkIsHistory').find('input').prop('checked', false);
                //$('#myCheckbox').prop('checked', false);
                $('#CountRowClaim').val(0);
                $('#CountRowEmp').val(0);

                //FillDataEmployee();
                // console.log(13);
                //   AddMoreRow();
                // AddMoreRowEmp();
            }


        }
        function LoadAutoCompleteData(TabType) {
        }
        function RemoveClaimLockingRow(row) {

            var DiscountExcId = $('table#tblDiscountExc tr#trClaim' + row).find(".hdnDiscountExcId").val();
            $('table#tblDiscountExc tr#trClaim' + row).find(".IsChange").val("1");
            $('table#tblDiscountExc tr#trClaim' + row).remove();
            $('table#tblDiscountExc tr#trClaim' + row).find(".IsDeleted").val("1");
            var deleteIDs = $('#hdnDeleteIDs').val();
            var deletedIDs = DiscountExcId + ",";
            deleteIDs += deletedIDs;
            $('#hdnDeleteIDs').val(deleteIDs);
            $('table#tblDiscountExc tr#trClaim' + (row + 1)).focus();
            $('#hdnIsRowDeleted').val("1");
        }
        function RemoveClaimLockingRowEmp(row) {

            var DiscountExcId = $('table#tblEmpDiscount tr#trClaimEmp' + row).find(".hdnDiscountExcIdEmp").val();
            $('table#tblEmpDiscount tr#trClaimEmp' + row).find(".IsChangeEmp").val("1");
            $('table#tblEmpDiscount tr#trClaimEmp' + row).remove();
            $('table#tblEmpDiscount tr#trClaimEmp' + row).find(".IsDeleted").val("1");
            var deleteIDs = $('#hdnDeleteIDsEmp').val();
            var deletedIDs = DiscountExcId + ",";
            deleteIDs += deletedIDs;
            $('#hdnDeleteIDsEmp').val(deleteIDs);
            $('table#tblEmpDiscount tr#trClaimEmp' + (row + 1)).focus();
            $('#hdnIsRowDeletedEmp').val("1");
        }
        function Cancel() {
            window.location = "../Master/CompanyInvRemark.aspx";
        }


        function ChangeData(txt) {
            $(txt).parent().parent().find("input[name='IsChange']").val("1");
            var ind = $('#CountRowClaim').val();
            var row = Number($(txt).parent().parent().find("input[name='hdnLineNum']").val());
            if (ind == row) {
                //  console.log(14);
                AddMoreRow();
            }
            CheckDateValidation(row);
        }
        function ChangeDataEmp(txtE) {
            $(txtE).parent().parent().find("input[name='IsChangeEmp']").val("1");
            var indE = $('#CountRowEmp').val();
            var rowE = Number($(txtE).parent().parent().find("input[name='hdnLineNumEmp']").val());
            if (indE == rowE) {
                AddMoreRowEmp();
            }
            CheckDateValidationEmp(rowE);
        }
        function ChangeDataEmpRefNo(txtER) {
            var RefNo = $(txtER).parent().parent().find("input[name='txtAutoUniqEmp']").val();
            var sv = $.ajax({
                url: 'CompanyInvRemark.aspx/RefNoValidate',
                type: 'POST',
                //async: false,
                dataType: 'json',
                // traditional: true,
                data: JSON.stringify({ RefNo: RefNo, OptionId: $('.ddlOption').val() }),
                contentType: 'application/json; charset=utf-8'
            });

            var sendcall = 0;
            sv.success(function (result) {

                if (result.d.indexOf("SUCCESS=") >= 0) {
                    var SuccessMsg = result.d.split('=')[1].trim();
                    if (SuccessMsg == "0") {
                        $(txtER).parent().parent().find("input[name='txtAutoUniqEmp']").val('');
                        ModelMsg("Please enter valid ref no", 3);
                        return false;
                    }
                    $(txtER).parent().parent().find("input[name='IsChangeEmp']").val("1");
                    // ModelMsg(SuccessMsg, 3);

                }
            });
            sv.error(function (XMLHttpRequest, textStatus, errorThrown) {
                $.unblockUI();
                alert('Something is wrong...' + XMLHttpRequest.responseText);
                return false;
            });
        }

        function CheckDateValidation(row) {
            var rowCnt_FSSI = 1;
            var cnt = 0;
            var errRow = 0;

            var NewFromDate = $("#tdFromDate" + row).val();
            var NewToDate = $("#tdToDate" + row).val();
            $('#tblDiscountExc  > tbody > tr').each(function (row1, tr) {
                var LineNum = $("input[name='hdnLineNum']", this).val();
                var StartDate = $("input[name='tdFromDate']", this).val();
                var EndDate = $("input[name='tdToDate']", this).val();
                if (StartDate != '' && EndDate != '') {
                    var Start = StartDate.split("/");
                    var End = EndDate.split("/");
                    var sDate = new Date(Start[2], parseInt(Start[1]) - 1, Start[0]);
                    var eDate = new Date(End[2], parseInt(End[1]) - 1, End[0]);

                    if (sDate != '' && eDate != '' && sDate > eDate) {
                        cnt = 1;
                        errRow = row;
                        errormsg = 'To Date should not be less than to From date at row : ' + LineNum;
                        $("#tdToDate" + LineNum).val('');
                        return false;
                    }
                }
            });
            if (cnt == 1) {
                ClearClaimRow(row);
                ModelMsg(errormsg, 3);
                return false;
            }
        }

        function CheckDateValidationEmp(row) {
            var rowCnt_FSSI = 1;
            var cnt = 0;
            var errRow = 0;

            var NewFromDate = $("#tdFromDateEmp" + row).val();
            var NewToDate = $("#tdToDateEmp" + row).val();
            $('#tblEmpDiscount  > tbody > tr').each(function (row2, tr) {
                var LineNum = $("input[name='hdnLineNumEmp']", this).val();
                var StartDate = $("input[name='tdFromDateEmp']", this).val();
                var EndDate = $("input[name='tdToDateEmp']", this).val();
                if (StartDate != '' && EndDate != '') {
                    var Start = StartDate.split("/");
                    var End = EndDate.split("/");
                    var sDate = new Date(Start[2], parseInt(Start[1]) - 1, Start[0]);
                    var eDate = new Date(End[2], parseInt(End[1]) - 1, End[0]);

                    if (sDate != '' && eDate != '' && sDate > eDate) {
                        cnt = 1;
                        errRow = row;
                        errormsg = 'To Date should not be less than to From date at row : ' + LineNum;
                        $("#tdToDateEmp" + LineNum).val('');
                        return false;
                    }
                }
            });
            if (cnt == 1) {
                ClearClaimRowEmp(row);
                ModelMsg(errormsg, 3);
                return false;
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
                return false;
            }

            var TableData_Claim = [];
            var totalItemcnt = 0;
            var cnt = 0;

            rowCnt_Claim = 0;

            var TabName = $('.nav-tabs .active').text();
            //console.log(TabName);
            if (TabName == 'Remarks') {

                if (!IsValid) {
                    $.unblockUI();
                    return false;
                }

                $('#tblDiscountExc  > tbody > tr').each(function (row, tr) {

                    // var IsChange = $("input[name='IsChange']", this).val().trim();
                    var Remarks1 = $("input[name='txtRemark1']", this).val().trim();
                    var Remarks2 = $("input[name='txtRemark2']", this).val().trim();
                    var Remarks3 = $("input[name='txtRemark3']", this).val().trim();

                    var RefNo = $("input[name='txtAutoUniq']", this).val();
                    var IsDeleted = $('#hdnIsRowDeleted').val();
                    var IsChange = $("input[name='IsChange']", this).val().trim();

                    var FromDate = $("input[name='tdFromDate']", this).val();
                    var ToDate = $("input[name='tdToDate']", this).val();
                    if ((Remarks1 != "" || Remarks2 != "" || Remarks3 != "") && (IsChange == "1" || IsDeleted == 1)) {
                        if (RefNo == '') {
                            totalItemcnt = 0;
                            $.unblockUI();
                            ModelMsg('Please select proper ref no at row ' + (row + 1), 3);
                            return false;
                        }
                        if (FromDate == '') {
                            totalItemcnt = 0;
                            $.unblockUI();
                            ModelMsg('Please select proper From Date at row ' + (row + 1), 3);
                            return false;
                        }
                        if (ToDate == '') {
                            totalItemcnt = 0;
                            $.unblockUI();
                            ModelMsg('Please select proper To Date at row ' + (row + 1), 3);
                            return false;
                        }
                        totalItemcnt = 1;
                        var DiscountExcId = $("input[name='hdnDiscountExcId']", this).val().trim();
                        var ItmGroupId = $("input[name='hdnItmGroupId']", this).val().trim();
                        var IsActive = $("input[name='chkIsActive']", this).is(':checked');
                        var IPAddress = $("#hdnIPAdd").val();
                        var IsChange = $("input[name='IsChange']", this).val().trim();
                        var Remark1 = $("input[name='txtRemark1']", this).val();
                        var Remark2 = $("input[name='txtRemark2']", this).val();
                        var Remark3 = $("input[name='txtRemark3']", this).val();


                        var obj = {
                            DiscountExcId: DiscountExcId,
                            IsActive: IsActive,
                            RefNo: ItmGroupId,
                            IPAddress: IPAddress,
                            IsChange: IsChange,
                            Remark1: Remark1,
                            Remark2: Remark2,
                            Remark3: Remark3,
                            FromDate: FromDate,
                            ToDate: ToDate
                        };
                        TableData_Claim.push(obj);
                        rowCnt_Claim++;
                    }
                });

                if (totalItemcnt == 0) {
                    $.unblockUI();
                    ModelMsg("Please select atleast one Item", 3);
                    return false;
                }
                if (cnt == 1) {
                    $.unblockUI();
                    ModelMsg(errormsg, 3);
                    return false;
                }
                var ClaimProcessData = JSON.stringify(TableData_Claim);

                var successMSG = true;

                if (IsValid) {
                    var sv = $.ajax({
                        url: 'CompanyInvRemark.aspx/SaveItemData',
                        type: 'POST',
                        //async: false,
                        dataType: 'json',
                        // traditional: true,
                        data: JSON.stringify({ hidJsonInputClaim: ClaimProcessData, OptionId: $('.ddlOption').val(), IsAnyRowDeleted: $('#hdnIsRowDeleted').val(), DeletedIDs: $('#hdnDeleteIDs').val() }),
                        contentType: 'application/json; charset=utf-8'
                    });

                    var sendcall = 0;

                    sv.success(function (result) {

                        if (result.d == "") {
                            $.unblockUI();
                            return false;
                        }
                        else if (result.d.indexOf("ERROR=") >= 0) {
                            $.unblockUI();
                            var ErrorMsg = result.d.split('=')[1].trim();
                            ModelMsg(ErrorMsg, 2);
                            return false;
                        }
                        else if (result.d.indexOf("WARNING=") >= 0) {
                            $.unblockUI();
                            var ErrorMsg = result.d.split('=')[1].trim();
                            ModelMsg(ErrorMsg, 3);
                            return false;
                        }
                        if (result.d.indexOf("SUCCESS=") >= 0) {
                            var SuccessMsg = result.d.split('=')[1].trim();
                            // ModelMsg(SuccessMsg, 3);
                            alert(SuccessMsg);
                            location.reload(true);
                            return false;
                        }

                    });

                    sv.error(function (XMLHttpRequest, textStatus, errorThrown) {
                        $.unblockUI();
                        alert('Something is wrong...' + XMLHttpRequest.responseText);
                        return false;
                    });
                }
                else {
                    $.unblockUI();
                }
            }
            else {  // Employee
                if (!IsValid) {
                    $.unblockUI();
                    return false;
                }

                $('#tblEmpDiscount  > tbody > tr').each(function (row, tr) {


                    var EmpName = $("input[name='AutoEmpName']", this).val().split('#').pop().trim();// $("input[name='AutoEmpName']", this).val();
                    var EmpGroup = 0; //$("input[name='AutoEmpGroup']", this).val().split('#').pop().trim();// $("input[name='AutoEmpName']", this).val();
                    // var SSName = $("input[name='AutoSSName']", this).val().split('-').pop().trim();
                    //   var Days = $("input[name='days']", this).val();
                    //var EmpID = $("input[name='AutoEmpName']", this).val().split('#').pop().trim();
                    var RefNo = $("input[name='txtAutoUniqEmp']", this).val();
                    var CustGroup = $("input[name='AutoCustGroup']", this).val().split('#').pop().trim();
                    var Customer = $("input[name='AutoCustomer']", this).val().split('-').pop().trim();
                    var DistName = $("input[name='AutoDistName']", this).val().split('-').pop().trim();
                    var RegionName = $("input[name='AutoRegion']", this).val().split('-').pop().trim();//$("input[name='AutoRegion']", this).val();


                    var RgnId = $("input[name='hdnRegionId']", this).val().trim();
                    var EmpId = $("input[name='hdnEmpId']", this).val().trim();
                    var DistId = $("input[name='hdnDistId']", this).val().trim();
                    // var SSId = $("input[name='hdnSSId']", this).val().trim();
                    var IsDeleted = $('#hdnIsRowDeletedEmp').val();
                    var IsChange = $("input[name='IsChangeEmp']", this).val().trim();
                    var FromDate = $("input[name='tdFromDateEmp']", this).val();
                    var ToDate = $("input[name='tdToDateEmp']", this).val();

                    //if (RefNo == '') {
                    //    totalItemcnt = 0;
                    //    $.unblockUI();
                    //    ModelMsg('Please enter Ref No at row ' + (row + 1), 3);
                    //    return false;
                    //}


                    if ((RegionName != "" || EmpName != "" || DistName != '' || CustGroup != '' || Customer != '') && (IsChange == "1" || IsDeleted == 1)) {

                        //totalItemcnt = 0;
                        //$.unblockUI();
                        //ModelMsg('Please select proper data at row ' + (row + 1), 3);
                        //return false;


                        if (RefNo == '') {
                            totalItemcnt = 0;
                            $.unblockUI();
                            ModelMsg('Please enter valid Ref No at row ' + (row + 1), 3);
                            return false;
                        }
                        if (FromDate == '') {
                            totalItemcnt = 0;
                            $.unblockUI();
                            ModelMsg('Please select proper From Date at row ' + (row + 1), 3);
                            return false;
                        }
                        if (ToDate == '') {
                            totalItemcnt = 0;
                            $.unblockUI();
                            ModelMsg('Please select proper To Date at row ' + (row + 1), 3);
                            return false;
                        }
                        totalItemcnt = 1;
                        var DiscountExcId = $("input[name='hdnDiscountExcIdEmp']", this).val().trim();
                        var hdnEmpGroupId = $("input[name='hdnEmpGroupId']", this).val().trim();
                        var RgnId = $("input[name='hdnRegionId']", this).val().trim();
                        var EmpId = $("input[name='hdnEmpId']", this).val().trim();
                        var DistId = $("input[name='hdnDistId']", this).val().trim();
                        // var SSId = $("input[name='hdnSSId']", this).val().trim();
                        var CustGroupId = $("input[name='hdnCustGroupId']", this).val().trim();
                        var CustId = $("input[name='hdnCustomerId']", this).val().trim();
                        // var DaysId = $("input[name='hdnDaysId']", this).val().trim();


                        var IsActive = $("input[name='chkIsActiveEmp']", this).is(':checked');
                        var IsInclude = $("input[name='chkInclude']", this).is(':checked');
                        var IPAddress = $("#hdnIPAdd").val();
                        var IsChange = $("input[name='IsChangeEmp']", this).val().trim();


                        var EmployeeGroupId = 0; //$("input[name='hdnEmployeeGroupId']", this).val().trim();
                        var obj = {
                            DiscountExcId: DiscountExcId,
                            RefNo: hdnEmpGroupId,
                            RegionId: RegionName,
                            EmpId: EmpName,
                            DistId: DistId,

                            IsActive: IsActive,
                            IPAddress: IPAddress,
                            IsChange: IsChange,
                            CustGroupId: CustGroupId,
                            CustId: CustId,
                            IsInclude: IsInclude,
                            FromDate: FromDate,
                            ToDate: ToDate,
                            EmployeeGroupId: EmployeeGroupId
                        };
                        TableData_Claim.push(obj);

                    }
                    rowCnt_Claim++;
                });

                if (totalItemcnt == 0) {
                    $.unblockUI();
                    ModelMsg("Please select atleast one Item", 3);
                    return false;
                }
                if (cnt == 1) {
                    $.unblockUI();
                    ModelMsg(errormsg, 3);
                    return false;
                }
                var ClaimProcessData = JSON.stringify(TableData_Claim);

                var successMSG = true;

                if (IsValid) {
                    var sv = $.ajax({
                        url: 'CompanyInvRemark.aspx/SaveEmpData',
                        type: 'POST',
                        //async: false,
                        dataType: 'json',
                        // traditional: true,
                        data: JSON.stringify({ hidJsonInputClaim: ClaimProcessData, OptionId: $('.ddlOption').val(), IsAnyRowDeleted: $('#hdnIsRowDeletedEmp').val(), DeletedIDs: $('#hdnDeleteIDsEmp').val() }),
                        contentType: 'application/json; charset=utf-8'
                    });

                    var sendcall = 0;

                    sv.success(function (result) {

                        if (result.d == "") {
                            $.unblockUI();
                            return false;
                        }
                        else if (result.d.indexOf("ERROR=") >= 0) {
                            $.unblockUI();
                            var ErrorMsg = result.d.split('=')[1].trim();
                            ModelMsg(ErrorMsg, 2);
                            return false;
                        }
                        else if (result.d.indexOf("WARNING=") >= 0) {
                            $.unblockUI();
                            var ErrorMsg = result.d.split('=')[1].trim();
                            ModelMsg(ErrorMsg, 3);
                            return false;
                        }
                        if (result.d.indexOf("SUCCESS=") >= 0) {
                            var SuccessMsg = result.d.split('=')[1].trim();
                            // ModelMsg(SuccessMsg, 3);
                            alert(SuccessMsg);
                            location.reload(true);
                            return false;
                        }

                    });

                    sv.error(function (XMLHttpRequest, textStatus, errorThrown) {
                        $.unblockUI();
                        alert('Something is wrong...' + XMLHttpRequest.responseText);
                        return false;
                    });
                }
                else {
                    $.unblockUI();
                }
            }

        }
        function Addrow(index, data) {
            msg = '<row r="' + index + '">'
            for (i = 0; i < data.length; i++) {
                var key = data[i].key;
                var value = data[i].value;
                msg += '<c t="inlineStr" r="' + key + index + '">';
                msg += '<is>';
                if (value != "" && Array.isArray(value))
                    value = value[0].replace(/&/g, '&amp;') + value[1].replace(/&/g, '&amp;');
                elest
                value = value.replace(/&/g, '&amp;');
                msg += '<t>' + value + '</t>';
                msg += '</is>';
                msg += '</c>';
            }
            msg += '</row>';
            return msg;
        }
        function downloadMapping() {
            window.open("../Document/CSV Formats/DealertemIncExclude.csv");
        }
    </script>
    <style>
        table.dataTable thead .sorting,
        table.dataTable thead .sorting_asc,
        table.dataTable thead .sorting_desc {
            background: none;
        }

        body {
            overflow: hidden; /* Hide scrollbars */
        }

        .tdUniqNo {
            width: 60px !important;
        }

        .threfNo {
            width: 33px !important;
        }
        /*div:not(.dataTables_scrollFoot)::-webkit-scrollbar { 
  display: none; 
}*/
        /*   div:not(.dataTables_scrollFoot):not(.dataTables_scrollBody)::-webkit-scrollbar {
            display: none;
        }*/


        table.dataTable tbody th, table.dataTable tbody td {
            padding: 2px 5px !important;
        }

        table.tblDiscountExc.table.table-bordered.nowrap.no-footer.dataTable {
            width: 100% !important;
            margin: 0;
            table-layout: auto;
        }

        table#tblDiscountExc {
            width: 100vw;
            margin-top: 0px !important;
            margin-bottom: 0px !important;
            position: relative;
        }

            table#tblDiscountExc tbody {
                width: 100vw;
                height: 30%;
            }

                table#tblDiscountExc tbody tr {
                    position: relative;
                }

            table#tblDiscountExc thead tr {
                position: relative;
            }

            table#tblDiscountExc tfoot tr {
                position: relative;
                width: 100vw;
            }

            table#tblDiscountExc tbody tr td {
                padding: 3px !important;
                width: 100vw;
                vertical-align: middle !important;
            }



        .row {
            margin-right: -15px;
            margin-left: -15px;
            margin-bottom: 0px !important;
        }

        .ui-widget {
            font-size: 12px;
        }

        .ui-datepicker {
            z-index: 9 !important;
        }

        .search {
            font-size: 10px !important;
            height: 22px;
            background-color: rgb(250, 255, 189);
            padding: 6px;
        }

        input.txtCompContri, input.txtDistContri, .tdUniqueNo {
            text-align: right;
        }

        td.txtSrNo, .tdCreatedDate, .tdUpdateDate {
            text-align: center;
        }

        .ui-autocomplete {
            position: absolute;
        }

        table#tblDiscountExc.dataTable tbody th {
            padding-left: 6px !important;
        }

        table#tblEmpDiscount.dataTable tbody th {
            padding-left: 6px !important;
        }

        .txtAutoUniq, .txtAutoUniqEmp {
            width: 60px !important;
            font-size: 10px !important;
            height: 22px;
            padding: 6px;
        }

        .dtbodyCenter {
            text-align: center;
        }

        .dtbodyLeft {
            text-align: left;
        }

        .dtbodyRight {
            text-align: right;
        }

        table.dataTable tbody tr.odd-row {
            background-color: #e3e7ff;
        }

        .dataTables_scrollHeadInner {
            width: auto;
        }

        table.dataTable tbody th {
            text-align: left;
        }

        table.dataTable tbody tr.even-row {
            background-color: #fff;
            position: relative;
        }

        th.table-header-gradient {
            z-index: 9;
        }

        #page-content-wrapper {
            overflow: hidden;
        }

        #tblDiscountExc {
            margin-top: 0px !important;
        }

        #tblEmpDiscount {
            margin-top: 0px !important;
        }

         dataTables_scroll .dataTables_scrollBody {
            overflow-y: auto !important;
            overflow-x: hidden !important;
            max-height: none !important;
        }

        .dataTables_wrapper .dataTables_scroll {
            clear: both;
            width: 100%;
            /*height: 60vh;*/
        }
        #body_divDiscountEntry .dataTables_scrollBody {
            overflow-y:initial !important;
        }
         #body_divEmpDiscountEntry .dataTables_scrollBody {
            overflow-y:initial !important;
        }
        .dataTables_scrollHeadInner {
            width: 100% !important;
        }

        .element::-webkit-scrollbar {
            width: 0 !important;
        }

        .element {
            overflow: -moz-scrollbars-none;
        }

        .element {
            -ms-overflow-style: none;
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

        /* Hide scrollbar for IE, Edge and Firefox */
        .CustName {
            -ms-overflow-style: none; /* IE and Edge */
            scrollbar-width: none; /* Firefox */
        }

        @media (min-width: 768px) {
            .container {
                max-width: 100%;
            }
        }

        @media (min-width: 1200px) {
            .container {
                width: 1430px;
            }
        }

        @media (min-width: 992px) {
            .container {
                max-width: 100%;
            }
        }

        @media (min-width: 1200px) {
            #tblDiscountExc_wrapper .dataTables_scrollHead {
                width: 1325px !important;
            }
            #tblEmpDiscount_wrapper .dataTables_scrollHead {
                width: 1324px !important;
            }
            #tblEmpDiscount_wrapper .dataTables_scrollBody {
                width: 1324px !important;
            }
            #tblDiscountExc_wrapper .dataTables_scrollBody {
                width: 1285px !important;
            }
        }

        .body {
            overflow: hidden !important;
            overflow-x: hidden !important;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <asp:HiddenField runat="server" ID="hdnIPAdd" ClientIDMode="Static" Value="0" />
    <asp:HiddenField runat="server" ID="hdnIsRowDeleted" ClientIDMode="Static" Value="0" />
    <asp:HiddenField runat="server" ID="hdnDeleteIDs" ClientIDMode="Static" Value="" />

    <asp:HiddenField runat="server" ID="hdnIPAddEmp" ClientIDMode="Static" Value="0" />
    <asp:HiddenField runat="server" ID="hdnIsRowDeletedEmp" ClientIDMode="Static" Value="0" />
    <asp:HiddenField runat="server" ID="hdnDeleteIDsEmp" ClientIDMode="Static" Value="" />
    <div class="panel panel-default">
        <div class="panel-body" style="height: 580px !important;">
            <div class="row _masterForm">
                <div class="col-lg-4" style="display: none;">
                    <div class="input-group form-group">
                        <label class="input-group-addon">Option</label>
                        <asp:DropDownList runat="server" ID="ddlOption" CssClass="ddlOption form-control" TabIndex="1" onchange="ShowDistOrSSOnChange();">
                            <asp:ListItem Value="2">Distributor To Dealer - Invoice</asp:ListItem>
                            <%--  <asp:ListItem Value="4">SS To Distributor - Invoice</asp:ListItem>
                            <asp:ListItem Value="5">Order Entry - Item Exclude</asp:ListItem>
                            <asp:ListItem Value="6">Order Entry - Customer Exclude </asp:ListItem>--%>
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-2" style="display: none;">
                    <div class="input-group form-group">
                        <label class="input-group-addon">View Report</label>
                        <asp:CheckBox runat="server" CssClass="chkIsReport form-control" TabIndex="3" onchange="ClearControls();" />
                    </div>
                </div>
                <div class="divViewDetail" style="display: none;">
                    <div class="col-lg-2">
                        <div class="input-group form-group">
                            <label class="input-group-addon">With History</label>
                            <asp:CheckBox runat="server" ID="chkIsHistory" TabIndex="4" CssClass="chkIsHistory form-control" />
                        </div>
                    </div>
                </div>
                <div class="col-lg-2">
                    <div class="input-group form-group">
                    </div>
                </div>
            </div>
            <ul id="tabs" class="nav nav-tabs" role="tablist">
                <li class="active"><a href="#tabs-Item" role="tab" data-toggle="tab">Remarks</a></li>
                <li><a href="#tabs-Emp" role="tab" id="emp">Employee</a></li>
                <li style="margin-left: 320px !important">
                    <input type="hidden" class="hdnUserName" id="hdnUserName" runat="server" />
                    <input type="button" id="btnSubmit" name="btnSubmit" value="Submit" tabindex="5" onclick="btnSubmit_Click()" class="btnSubmit btn btn-default" />
                    &nbsp
                        <input type="button" id="btnCancel" name="btnCancel" value="Cancel" tabindex="7" onclick="Cancel()" class="btn btn-default" />


                </li>
            </ul>
            <div id="myTabContent" class="tab-content">
                <div id="tabs-Item" class="tab-pane active">
                    <div class="row _masterForm">
                        <div class="col-lg-12">
                            <input type="hidden" id="CountRowClaim" />
                            <div id="divDiscountEntry" class="divDiscountEntry" runat="server" style="max-height: 50vh; position: absolute;">
                                <table id="tblDiscountExc" class="table table-bordered nowrap" border="1" tabindex="8" style="border-collapse: collapse; font-size: 10px;">
                                    <thead>
                                        <tr class="table-header-gradient">
                                            <th style="width: 3%; text-align: center;">Sr</th>
                                            <th style="text-align: center;">Edit</th>
                                            <th style="width: 5%; text-align: center;">Delete</th>
                                            <th class="threfNo">Ref-No</th>
                                            <th style="width: 12%; padding-left: 10px !important;">Remarks-1</th>
                                            <th style="width: 12%; padding-left: 10px !important;">Remarks-2</th>
                                            <th style="width: 12%; padding-left: 10px !important;">Remarks-3</th>
                                            <th style="width: 10%;">From-Date</th>
                                            <th style="width: 10%;">To-Date</th>
                                            <th style="padding-left: 3px !important;">Active</th>
                                            <%--<th style="width: 7%; padding-left: 5px !important;">Entry By</th>
                                            <th style="width: 5%;">Entry Date/Time</th>--%>
                                            <th style="width: 7%; padding-left: 5px !important;">Updated By</th>
                                            <th style="width: 5%;">Update Date/Time</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
                <div id="tabs-Emp" class="tab-pane">
                    <div class="row _masterForm">
                        <div class="col-lg-12">
                            <input type="hidden" id="CountRowEmp" />
                            <div id="divEmpDiscountEntry" class="divEmpDiscountEntry" runat="server" style="max-height: 50vh; position: absolute;">
                                <table id="tblEmpDiscount" class="table table-bordered nowrap" border="1" tabindex="9" style="border-collapse: collapse; font-size: 10px;">
                                    <thead>
                                        <tr class="table-header-gradient">
                                            <th style="width: 2%; text-align: center;">Sr</th>
                                            <th style="text-align: center;">Edit</th>
                                            <th style="width: 3.5%; text-align: center;">Delete</th>
                                            <th class="threfNo">Ref-No</th>
                                            <%-- <th style="width: 12%; padding-left: 10px !important;" class="thEmpGroup">Employee Group</th>--%>
                                            <th style="width: 12%; padding-left: 10px !important;">Employee</th>
                                            <th style="width: 12%; padding-left: 10px !important;">Region</th>
                                            <th style="width: 15%; padding-left: 10px !important;">Distributor</th>
                                            <th style="width: 15%; padding-left: 10px !important;">Customer Group</th>
                                            <th style="width: 12%; padding-left: 10px !important;" class="thCustomer">Customer</th>
                                            <th style="width: 10%;">From-Date</th>
                                            <th style="width: 10%;">To-Date</th>
                                            <th style="width: 5%; text-align: left  !important; padding-left: 3px !important;">Inc/Exc</th>
                                            <th style="width: 4%; padding-left: 3px !important;">Active</th>
                                            <%--  <th style="width: 7%; padding-left: 5px !important;">Entry By</th>
                                            <th style="width: 5%; text-align: center;">Entry Date/Time</th>--%>
                                            <th style="width: 50%; padding-left: 5px !important;">Updated By</th>
                                            <th style="width: 50%; text-align: center;">Update Date/Time</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

</asp:Content>

